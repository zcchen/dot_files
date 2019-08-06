#!/usr/bin/env zsh

export LANG="en_US.UTF-8"

source ~/.bash/alias.sh
alias zplug="LANGUAGE=en_US.UTF-8 zplug"

MY_SHELL_PATH="${HOME}/.bash"
if [[ -z $(echo ${PATH} | grep ${MY_SHELL_PATH}) ]]; then
    export PATH="${MY_SHELL_PATH}:$PATH"
fi

# -------------------------- Self handle the zplug (start) ---------------------
# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
fi
# Essential
source ~/.zplug/init.zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
# -------------------------- Self handle the zplug (end) -----------------------


# ------------------------------- plugins (start) ------------------------------
zplug "mafredri/zsh-async", from:"github", use:"async.zsh"
zplug "zsh-users/zsh-syntax-highlighting"       # syntax highlight
zplug "zsh-users/zsh-completions"               # completions
zplug "zsh-users/zsh-autosuggestions"           # auto suggestions, shows the last commands
zplug "bobthecow/git-flow-completion"           # git working flow
zplug "b4b4r07/enhancd"                         # "cd" command enhance
zplug "supercrabtree/k"; alias k="k -h"         # Directory listings for zsh with git features
zplug "chrissicool/zsh-256color"
zplug "Tarrasch/zsh-autoenv"
zplug "desyncr/auto-ls"                         # auto list
zplug "libs/history", from:oh-my-zsh
#zplug "jimhester/per-directory-history"

zplug "plugins/git", from:oh-my-zsh
zplug "plugins/autojump", from:oh-my-zsh
zplug "plugins/autopep8", from:oh-my-zsh
#zplug "plugins/battery", from:oh-my-zsh
zplug "plugins/colored-man", from:oh-my-zsh
#zplug "plugins/colorize", from:oh-my-zsh
zplug "plugins/command-not-found", from:oh-my-zsh
zplug "plugins/cp", from:oh-my-zsh
zplug "plugins/python", from:oh-my-zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/systemd", from:oh-my-zsh
zplug "plugins/vi-mode", from:oh-my-zsh
#zplug "plugins/virtualenwrapper", from:oh-my-zsh
zplug "plugins/z", from:oh-my-zsh
# ------------------------------- plugins (end) --------------------------------


# ---------------------------- UI themes (start) -------------------------------
setopt prompt_subst # Make sure prompt is able to be generated properly.
zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
#zplug "caiogondim/bullet-train.zsh", use:bullet-train.zsh-theme, defer:3 # defer until other plugins like oh-my-zsh is loaded
#BULLETTRAIN_PROMPT_ORDER=( time context dir git)
#BULLETTRAIN_STATUS_EXIT_SHOW=true
# ---------------------------- UI themes (end) ---------------------------------


# ------------------------- Plugin Settings (start) ----------------------------
source /etc/zsh_command_not_found

# zsh cd completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# ------------------------- Plugin Settings (end) ------------------------------


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
# For fun
zsh ~/.bash/fbi_warning.sh

# some basic stuffs
export EDITOR=vim
export GRAPHIC_EDITOR="gvim"

#mkdir -p ~/.directory_history/

alias zshrc="${EDITOR} ~/.zshrc"
eval $(thefuck --alias)
# -------------------------- load my plugins (end) -----------------------------
