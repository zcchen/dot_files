# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export HISTSIZE=65535

#PS1='[`date +%R:%S` \u@\h \W]\$ '
#PS1='\[\033[01;32m\]`date +%R:%S` \u@\h\[\033[01;34m\] \w\$\[\033[00m\] '
PS1='\[\033[01;32m\]\t \u \[\033[01;34m\]\w\$\[\033[00m\] '
#PS1='`a=$?;if [ $a -ne 0 ]; then a="  "$a; echo -ne "\[\e[s\e[1A\e[$((COLUMNS-2))G\e[31m\e[1;41m${a:(-3)}\e[u\]\[\e[0m\e[7m\e[2m\]"; fi`\[\e[1;32m\]\u@\h:\[\e[0m\e[1;34m\]\W\[\e[1;34m\]\$ \[\e[0m\]'

source ~/.profile
#export USE_CCACHE=1
#python Docs
export PYTHONDOCS=/usr/share/doc/python2/html/


# set bash completion
source /usr/share/git/completion/git-completion.bash        #git
source /usr/share/doc/pkgfile/command-not-found.bash        #pkgfile
#complete -cf {pacman,packer}
complete -cf {sudo,proxychains,systemctl}

#export GTK_IM_MODULE=ibus
#export XMODIFIERS=@im=ibus
#export QT_IM_MODULE=ibus

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

#go init
mkdir -p /tmp/go
export GOPATH=/tmp/go

# Skype Setting for uncomman pulseAudio Problem
export PULSE_LATENCY_MSEC=60

# source all alias setting
source ~/.bash/alias.sh

MY_SHELL_PATH="${HOME}/.bash"
if [[ -z $(echo ${PATH} | grep ${MY_SHELL_PATH}) ]]; then
    export PATH="${MY_SHELL_PATH}:$PATH"
fi

