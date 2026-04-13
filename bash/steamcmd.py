#!/usr/bin/env python3
import pty
import argparse
import os
import sys
import subprocess
import getpass
import shutil
import pwd
from pathlib import Path

CONFIG_FILE = Path.home() / ".config" / "steamcmd.conf"
STEAMCMD_INSTALL_CMD = 'curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -'

class SteamCMDManager:
    def __init__(self, debug=False):
        self.sudo_password = None
        self.current_user = getpass.getuser()
        self._debug = debug
        # Exit if root
        if os.geteuid() == 0:
            print(f"\n[!] Error: This script must not be run as root.")
            sys.exit(1)

    def _get_sudo_pw(self):
        """Prompt and remember sudo password."""
        if self.sudo_password is None:
            self.sudo_password = getpass.getpass(f"[sudo] password for '{self.current_user}': ")
        return self.sudo_password

    def _get_uid(self, username):
        try:
            # pwd.getpwnam 返回一个包含用户信息的类元组对象
            user_info = pwd.getpwnam(username)
            return user_info.pw_uid
        except KeyError:
            return -1

    def _exec(self, cmd, run_as=None, capture=False, use_pty=False):
        """Execute commands with optional sudo and error handling."""
        final_cmd = []
        subproc_run_kwargs = {}
        # Prepare for the cmd
        if run_as:
            if run_as == "root":
                final_cmd = ["sudo", "--stdin"]
            elif run_as != self.current_user:
                final_cmd = ["sudo", "--stdin", "-u", run_as]
        final_cmd.extend(cmd)
        # show cmd for debug mode
        if self._debug:
            print(f"[-] DEBUG: {final_cmd}")
        # switch pty or subprocess mode to execute the cmd.
        if use_pty:
            exit_code = pty.spawn(final_cmd)
            if exit_code != 0:
                print(f"\n[!] ERROR: Execution failed, exit_code: '{exit_code}'.")
                sys.exit(exit_code if exit_code!= 0 else 2)
            return None
        else:
            pw = self._get_sudo_pw()
            subproc_run_kwargs["input"] = pw + "\n"
            try:
                return subprocess.run(
                    final_cmd,
                    text=True,
                    capture_output=capture,
                    check=True,
                    **subproc_run_kwargs
                )
            except subprocess.CalledProcessError as e:
                # Execution error handling
                print(f"\n[!] Execution failed: {e}")
                sys.exit(e.returncode if e.returncode != 0 else 2)

    def setup(self, steam_user, steam_homedir):
        """Create isolated environment."""
        print(f"[*] Setting up isolation for user '{steam_user}' at '{steam_homedir}'...")
        steam_uid = self._get_uid(steam_user)
        if steam_uid == -1:
            # Create user if not exists
            self._exec(["useradd", "-m", "-d", steam_homedir, "-s", "/bin/bash", steam_user], run_as="root")
            steam_uid = self._get_uid(steam_user)
            if steam_uid == -1:
                # self._exec(["rm", "-rf", steam_homedir], run_as="root")
                raise RuntimeError("ERROR: Failed to get steam uid even 'useradd' return correct.")
            self._exec(["mkdir", "-p", steam_homedir], run_as="root")
        # Set `x` permission for steam user for its parent dirs. TODO: this will raise error if steam homedir are too nested.
        self._exec(["setfacl", "-m", f"u:{steam_user}:x", Path(steam_homedir).parent.as_posix()], run_as="root")
        # Set permissions (770, owner:steam_user, group:current_user)
        self._exec(["chown", "-R", f"{steam_user}:{self.current_user}", steam_homedir], run_as="root")
        self._exec(["chmod", "-R", "770", steam_homedir], run_as="root")
        # Download SteamCMD
        print("[*] Downloading SteamCMD...")
        dl_cmd = f"cd {steam_homedir} && {STEAMCMD_INSTALL_CMD}"
        self._exec(["bash", "-c", dl_cmd], run_as=steam_user)
        # Write config
        CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(CONFIG_FILE, "w") as f:
            f.write(f"STEAM_USER={steam_user}\nSTEAM_HOMEDIR={steam_homedir}\n")
        print(f"[+] Setup successful.")

    def clean(self):
        """Remove isolated environment."""
        cfg = self.load_config()
        user, homedir = cfg['STEAM_USER'], cfg['STEAM_HOMEDIR']
        print(f"[*] Cleaning up user '{user}' and directory '{homedir}'...")
        # Remove user and home directory
        self._exec(["userdel", "-r", user], run_as="root")
        # Delete config file
        # if CONFIG_FILE.exists():
        #     CONFIG_FILE.unlink()
        print("[+] Cleanup complete.")

    def load_config(self):
        if not CONFIG_FILE.exists():
            print("[!] Error: Configuration not found. Please run 'setup' first.")
            sys.exit(2)
        cfg = {}
        with open(CONFIG_FILE, "r") as f:
            for line in f:
                if "=" in line:
                    k, v = line.strip().split("=", 1)
                    cfg[k] = v
        return cfg

    def show_config(self):
        """5: Print config."""
        if CONFIG_FILE.exists():
            print(CONFIG_FILE.read_text().strip())
        else:
            print("[!] WARNING: No config found.")

    def run_steamcmd(self, args):
        """Pass args to steamcmd in isolation."""
        cfg = self.load_config()
        path = os.path.join(cfg['STEAM_HOMEDIR'], "steamcmd.sh")
        self._exec([path] + list(args), run_as=cfg['STEAM_USER'], use_pty=True)

def main():
    # Setup Argument Parsers
    parent_parser = argparse.ArgumentParser(add_help=False)
    parent_parser.add_argument("-d", "--debug", action="store_true", default=False)
    parser = argparse.ArgumentParser(prog="steamcmd.py", add_help=True, parents=[parent_parser])
    subparsers = parser.add_subparsers(dest="command")
    # Command: setup
    p_setup = subparsers.add_parser("setup", add_help=True)
    p_setup.add_argument("-u", "--steam_user", default="steam")
    p_setup.add_argument("-H", "--steam_homedir", default=str(Path.home() / "steam"))
    # Command: clean & config
    subparsers.add_parser("clean", add_help=True)
    subparsers.add_parser("config", add_help=True)
    # Command: steamcmd
    p_steam = subparsers.add_parser("steamcmd", help="Run steamcmd", add_help=False)
    p_steam.add_argument("args", nargs=argparse.REMAINDER)
    # parse the args
    args, extras = parser.parse_known_args()
    mgr = SteamCMDManager(debug=args.debug)
    if args.command == "setup":
        mgr.setup(args.steam_user, args.steam_homedir)
    elif args.command == "clean":
        mgr.clean()
    elif args.command == "config":
        mgr.show_config()
    elif args.command == "steamcmd":
        mgr.run_steamcmd(args.args + extras)
    else:
        # Exit code 1 for parameter errors
        parser.print_usage()
        sys.exit(1)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(3)

