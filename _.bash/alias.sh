#!/bin/bash

alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias l=ls
#alias sl='ls'

alias rm='rm -Iv'
alias mv='mv -iv'
alias cp='cp -v'

alias v='vim'
alias vimrc='vim ~/.vimrc'
alias ctags='ctags --c++-kinds=+p --fields=+iaS --extra=+q'

#alias wine="env LANG=en_US.UTF-8 wine"
alias xterm='xterm -class 256color'
alias w3m='w3m -cookie -graph -F -num'

# pacman command setting
#alias pacman='sudo pacman'
function pacman() {
    if [[ $1 == '-Syu' ]]; then
        command sudo paccache -r -k 1
        command sudo pkgfile -u -v -z
        command sudo pacman "$@"
    else
        command sudo pacman "$@"
    fi
}
function pacaur() {
    mkdir -p /tmp/makepkg/{pkg,src}
    command pacaur "$@"
}

#set bash work like vi.
#set -o vi
alias info='info --vi-keys'
alias lynx='lynx -vikeys'

alias aurploader='aurploader -nk'

alias t="todo.sh"
alias vtodo="vim ~/Documents/Dropbox/todo/todo.txt"

##change login name, especially for that close-source program
#alias skype='xhost +local: && sudo -u skype /usr/bin/skype'
#alias winetricks='xhost +local: && sudo -u skype /usr/bin/winetricks'
#alias wine='xhost +local: && sudo -u skype /usr/bin/wine'

alias clockUpdate='sudo systemctl stop ntpd && sudo ntpd -qg && sudo hwclock -uw && sudo systemctl start ntpd'
alias pwdcp="pwd | xsel -ib"
alias cdpwd="cd $(xsel -ob)"
alias my_create_ap="sudo systemctl stop dnscrypt-proxy && sudo ~/.myPasswd/my_create_ap.sh"

# Game Simutrans
alias simutrans="simutrans -use_hw -pause"

# tsocks proxy
#alias tsocks='TSOCKS_CONF_FILE=~/.tsocks.conf tsocks '

# matlab
alias matlab="matlab -nosplash"

# Grep
#alias grep="grep -a"

# Reboot to Windows
alias reboot_win="sudo grub-reboot 2 && reboot"

# aria2c baidu
#alias baidu_aria2c="aria2c --header 'User-Agent: netdisk;5.3.4.5;PC;PC-Windows;5.1.2600;WindowsBaiduYunGuanJia -m0 -t 1 -c' $@"
alias baidu_aria2c="aria2c-fast --header 'User-Agent: netdisk;5.3.4.5;PC;PC-Windows;5.1.2600;WindowsBaiduYunGuanJia -m0 -t 1 -c' $@"

# picocom
alias picocom="picocom --imap lfcrlf --omap crlf"

# dd progress
alias dd="dd status=progress"

# vim: tw=0
