#!/usr/bin/env zsh

# -------------------------- Self handle the zplug (start) ---------------------
# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
fi
# Essential
source ~/.zplug/init.zsh
# -------------------------- Self handle the zplug (end) -----------------------


# ------------------------------- plugins (start) ------------------------------
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"

zplug "plugins/git", from:oh-my-zsh
zplug "plugins/autojump", from:oh-my-zsh
zplug "plugins/battery", from:oh-my-zsh
zplug "plugins/colored-man", from:oh-my-zsh
zplug "plugins/colorize", from:oh-my-zsh
zplug "plugins/cp", from:oh-my-zsh
zplug "plugins/per-directory-history", from:oh-my-zsh
zplug "plugins/python", from:oh-my-zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/systemd", from:oh-my-zsh
zplug "plugins/vi-mode", from:oh-my-zsh
zplug "plugins/virtualenwrapper", from:oh-my-zsh
#zplug "plugins/z", from:oh-my-zsh
#zplug "plugins/command-not-found", from:oh-my-zsh
# ------------------------------- plugins (end) --------------------------------


# ---------------------------- UI themes (start) -------------------------------
zplug "themes/dst", from:oh-my-zsh
export KEYTIMEOUT=1
old_RPS1=${RPS1}
function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]% %{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $(git_custom_status) $EPS1"${old_RPS1}
    #if [[ $(fcitx-remote) -eq 2 ]]; then
        #fcitx-remote -c
        #FCITX_TIGGER=true
    #elif [[ $FCITX_TIGGER ]]; then
        #fcitx-remote -o
        #FCITX_TIGGER=false
    #fi
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
# ---------------------------- UI themes (end) ---------------------------------


# ------------------------- load the plugins (start) ---------------------------
# Install packages that have not been installed yet
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    else
        echo
    fi
fi
zplug load
# ------------------------- load the plugins (end) -----------------------------


# -------------------------- load my plugins (start) ---------------------------
source ~/.bash/alias.sh

# For fun
zsh ~/.bash/fbi_warning.sh

# some basic stuffs
export EDITOR=vim
export GRAPHIC_EDITOR="gvim"
# -------------------------- load my plugins (end) -----------------------------
