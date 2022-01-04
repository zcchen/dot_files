#!/usr/bin/env zsh

export LANG="en_US.UTF-8"

source ~/.bash/alias.sh
alias zplug="LANGUAGE=en_US.UTF-8 zplug"

MY_SHELL_PATH="${HOME}/.bash:${HOME}/.local/bin:/snap/bin"
if [[ -z "$(echo ${PATH} | grep ${MY_SHELL_PATH})" ]]; then
    export PATH="${MY_SHELL_PATH}:$PATH"
fi

source ~/.zsh/zplug.zsh


# -------------------------- load my plugins (start) ---------------------------
# For fun
source ${HOME}/.bash/fbi_warning.sh

for f in $(find ${HOME}/.zsh/plugins -iname "*.zsh" -type f); do
    source $f
done

# some basic stuffs
export EDITOR=vim
export GRAPHIC_EDITOR="gvim"


alias zshrc="${EDITOR} ~/.zshrc"
eval $(thefuck --alias)
# -------------------------- load my plugins (end) -----------------------------
