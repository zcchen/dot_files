#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, sys

def list_and_run(d='./'):
    for f in os.listdir(d):
        file_name, file_ext = os.path.splitext(f)
        if file_ext.lower() == '.desktop':
            p = os.path.join(d, f)
            os.system('xdg-open {} &'.format(p))

if __name__ == "__main__":
    if len(sys.argv) > 2:
        print('python exec_folder_desktop_files.py <dir>')
    else:
        list_and_run(sys.argv[1])
