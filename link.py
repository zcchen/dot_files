#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function
import os, re

special_files_targets = {
        # The key is the config file names, with
        # The value is the config file targets.
        "_.zathurarc":  "~/.config/zathura/zathurarc"
    }

ln_cmd = "ln -snf"
rm_cmd = "rm -if"

Usage = """This command is the config file manager.
Usage: python {} <link|remove|update>
    link:   Link all the config files to the default place, aka ~/.*, and special places.
    remove: Remove all the config file soft-link targets.
    update: Update some config files from remote.
"""

def get_files_and_targets(conf_dir, target_dir):
    ret = {}
    all_files = os.listdir(conf_dir)
    abs_conf = os.path.abspath(conf_dir)
    abs_target = os.path.abspath(os.path.expanduser(target_dir))
    for f in all_files:
        if re.match("^_.\S+$", f):
            k, v = None, None
            if f not in special_files_targets.keys():
                k = abs_conf + os.path.sep + f
                v = abs_target + os.path.sep + re.sub("_.", ".", f)
            else:
                if special_files_targets[f]:
                    k = abs_conf + os.path.sep + f
                    v = os.path.abspath(os.path.expanduser(\
                            special_files_targets[f]))
                else:
                    pass
            if k and v:
                ret[k] = v
    return ret

def ln_configs(files_targets):
    ret = []
    for k, v in files_targets.items():
        cmd = "{cmd} {src} {dest}".format(cmd = ln_cmd, src=k, dest=v)
        ret.append(cmd)
    return ret

def rm_links(files_targets):
    ret = []
    for k, v in files_targets.items():
        cmd = "{cmd} {dest}".format(cmd = rm_cmd, dest=v)
        ret.append(cmd)
    return ret

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print(Usage)
        sys.exit(1)

    d = get_files_and_targets(os.path.dirname(os.path.abspath(__file__)), "~")
    if sys.argv[1].lower() == "link":
        cmd = ln_configs(d)
    elif sys.argv[1].lower() == "remove":
        cmd = rm_links(d)
    else:
        print(Usage)
        sys.exit(1)

    for i in cmd:
        print(i)
        os.system(i)
