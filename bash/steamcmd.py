#!/usr/bin/env python3
import pty
import pexpect
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
STEAMCMD_CMDLIST_CACHEFILE = CONFIG_FILE.parent / "cmdlist.txt"

class Executor:

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

    def sudo_check(self, pw=""):
        if not pw:
            return True
        ret = False
        with pexpect.spawn("sudo id -u", env={"LANG": "C"}) as p:
            try:
                p.expect(r'\[sudo\]', timeout=3)
                p.sendline(pw)
                check = p.expect([r'[0-9]+', r'\[sudo\]'], timeout=3)
                if check == 0:
                    # print("DEBUG: sudo password is OK.")
                    ret = True
                elif check == 1:
                    print("ERROR: sudo password is incorrect.")
                    p.terminate()
            except pexpect.TIMEOUT:
                print("WARNING: timeout")
            finally:
                # print("DEBUG: wait spawn proc to be closed.")
                p.wait()
                if p.isalive():
                    p.close()
        return ret

    def _pexpect_exec(self, cmd, sudo_pw="", interact=False, loggerStarts=[], loggerEnds=[]):
        if sudo_pw and not self.sudo_check(sudo_pw):
            return -1, "ERROR: sudo password incorrect."
        class Logger:
            def __init__(self):
                self._l = []
                self.terminal = sys.stdout
            def write(self, data):
                self._l.append(data)
                self.terminal.write(data)
                self.flush()
            def flush(self):
                self.terminal.flush()
            def getLines(self):
                return self._l
            def clear(self):
                self._l.clear()
        logger = Logger()
        exit_code = -1
        with pexpect.spawn(" ".join(cmd), encoding='utf-8') as p:
            if sudo_pw:
                p.expect(r'\[sudo\]', timeout=3)
                p.sendline(sudo_pw)
            if interact:
                p.interact()
            else:
                logger.clear()
                p.logfile_read = sys.stdout
                while p.isalive():
                    index_starts = p.expect([pexpect.EOF] + loggerStarts)
                    if index_starts == 0:
                        break
                    else:
                        p.logger_read = logger
                        index_ends = p.expect([pexpect.EOF] + loggerEnds)
                        if index_ends == 0:
                            p.logger_read = sys.stdout
                            break
            exit_code = p.wait()
        return exit_code, logger.getLines()

    def exec(self, cmd, run_as=None, use_pty=False, **kwargs):
        final_cmd = []
        # Prepare for the cmd
        if run_as:
            if run_as == "root":
                final_cmd.extend(["sudo"])
            elif run_as != self.current_user:
                final_cmd.extend(["sudo", "-u", run_as])
        final_cmd.extend(cmd)
        if self._debug:     # show cmd for debug mode
            print(f"[-] DEBUG: {final_cmd}")
        return self._pexpect_exec(final_cmd, sudo_pw=self._get_sudo_pw(), **kwargs)


class SteamCMDManager:
    def __init__(self, executor):
        self._exec = executor
        self.current_user = getpass.getuser()

    @property
    def e(self):
        return self._exec

    def _get_uid(self, username):
        try:
            # pwd.getpwnam 返回一个包含用户信息的类元组对象
            user_info = pwd.getpwnam(username)
            return user_info.pw_uid
        except KeyError:
            return -1

    def setup(self, steam_user, steam_homedir):
        """Create isolated environment."""
        print(f"[*] Setting up isolation for user '{steam_user}' at '{steam_homedir}'...")
        steam_uid = self._get_uid(steam_user)
        if steam_uid == -1:
            # Create user if not exists
            self._exec.exec(["useradd", "-m", "-d", steam_homedir, "-s", "/bin/bash", steam_user], run_as="root")
            steam_uid = self._get_uid(steam_user)
            if steam_uid == -1:
                # self._exec.exec(["rm", "-rf", steam_homedir], run_as="root")
                raise RuntimeError("ERROR: Failed to get steam uid even 'useradd' return correct.")
            self.e.exec(["mkdir", "-p", steam_homedir], run_as="root")
        # Set `x` permission for steam user for its parent dirs. TODO: this will raise error if steam homedir are too nested.
        self.e.exec(["setfacl", "-m", f"u:{steam_user}:x", Path(steam_homedir) .parent.as_posix()], run_as="root")
        # Set permissions (770, owner:steam_user, group:current_user)
        self.e.exec(["chown", "-R", f"{steam_user}:{self.current_user}", steam_homedir], run_as="root")
        self.e.exec(["chmod", "-R", "770", steam_homedir], run_as="root")
        # Download SteamCMD
        print("[*] Downloading SteamCMD...")
        dl_cmd = f"\"cd {steam_homedir} && {STEAMCMD_INSTALL_CMD}\""
        self.e.exec(["bash", "-c", dl_cmd], run_as=steam_user)
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
        self.e.exec(["userdel", "-r", user], run_as="root")
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
        if CONFIG_FILE.exists():
            print(CONFIG_FILE.read_text().strip())
        else:
            print("[!] WARNING: No config found.")

    def run_steamcmd(self, args=[]):
        """Pass args to steamcmd in isolation."""
        cfg = self.load_config()
        path = os.path.join(cfg['STEAM_HOMEDIR'], "steamcmd.sh")
        kwargs = {
                "interact": True
        } if not args else {
                "loggerStarts": [r'Loading Steam API...[\s\S]*OK'],
                "loggerEnds": [r'Unloading Steam API']
        }
        self.e.exec([path] + args, run_as=cfg['STEAM_USER'], **kwargs)


class SteamCMDExec:

    def __init__(self, manager, login="anonymous"):
        self._mgr = manager

    def exec(self, cmds: list = []):
        ret = []
        return ret

class SteamCmdList:
    def __init__(self, file: Path = STEAMCMD_CMDLIST_CACHEFILE):
        self._cachefile = file
        self._commands = {}
        self._conVars = {}
        if not self._cachefile.exists():
            with open(self._cmdlist_file, "w") as f:
                f.write("")
        self._load()

    def _load(self):
        state = "undefined"
        with open(self._cachefile, "r") as f:
            l = f.read()
            if l == "ConVars:":
                state = "conVars"
            elif l == "Commands:":
                state = "commands"
            else:
                s_val, s_comment = l.split(":")
                if state == "conVars":
                    k, v = s_val.split("=")
                    self._conVars[re.sub(r'(^\s*|\s*$)', "", k)] = {
                        "value": re.sub(r'(^\s*|\s*$)', "", v),
                        "comment": re.sub(r'(^\s*|\s*$)', "", s_comment)
                    }
                elif state == "commands":
                    self._commands[re.sub(r'(^\s*|\s*$)', "", s_val)] = {
                        "comment": re.sub(r'(^\s*|\s*$)', "", s_comment)
                    }
    def update(self):
        # for i in {a..z}; ad
        #   steamcmd +login anonymous +find ${LETTER} +quit
        # done
        pass

    def show(self):
        pass

class SteamGame:
    def game_list_owned(self):
        # steamcmd +@sSteamCmdForcePlatformType linux 
        #   +login {steamUser} +licenses_print validate +quit
        # for i in ${appID}
        #   steamcmd +@sSteamCmdForcePlatformType linux \
        #       +login {steamUser} +app_info_print ${app_id} +quit
        pass

    def game_update(self, gameName_or_appid):
        # download the updating game
        #   steamcmd +@sSteamCmdForcePlatformType linux \
        #       +login {steamUser} +app_license_request ${app_id} +app_update ${app_id} +quit
        pass


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
    # Prepare the executor and mgr
    exe = Executor(debug=args.debug)
    mgr = SteamCMDManager(exe)
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
