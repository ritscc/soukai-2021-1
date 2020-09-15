#!/usr/bin/env python3.7
import sys

from setup import setup_init as init
from setup import setup_create_files as create_files
from setup import setup_create_issues as create_issues
from setup import setup_msg as msg

def print_help():
    help_msg: str = msg.HELP_MSG
    print(help_msg)

if __name__ == "__main__":
    args: list = sys.argv
    # コマンドライン引数が1つしかない -> コマンド指定なし
    if len(args) == 1:
        print_help()
        exit()

    if args[1] == 'I' or args[1] == 'init':
        init.init()
    elif args[1] == 'g' or args[1] == 'generate':
        sl = args[2:]
        create_files.create_files(*sl)
    elif args[1] == 'i' or args[1] == 'issue':
        sl = args[2:]
        create_issues.create_issues(*sl)
    else:
        print_help()
