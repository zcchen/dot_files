# -------------------------- Self handle the zplug (start) ---------------------
# Check if zplug is installed
zplug_path=${HOME}/.zsh/managers/zplug
if [[ ! -f ${zplug_path}/init.zsh ]]; then
  git clone https://github.com/zplug/zplug ${zplug_path}
  #source ~/.zplug/init.zsh && zplug update --self
fi
# Essential
source ${zplug_path}/init.zsh
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
#zplug "plugins/history",   from:oh-my-zsh,  defer:3
zplug "jimhester/per-directory-history"
if zplug check "jimhester/per-directory-history"; then
    HISTORY_BASE="${HOME}/.zsh_histories"
    SAVEHIST=65535
fi

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
zplug "romkatv/powerlevel10k", as:theme, depth:1
# zplug "jeffreytse/zsh-vi-mode", use:zsh-vi-mode.zsh from:github, as:theme
# zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
# zplug "spaceship-prompt/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
# zplug "spaceship-prompt/spaceship-vi-mode", from:github   #use:spaceship-vi-mode.plugin.zsh, from:github
# if zplug check "spaceship-prompt/spaceship-prompt"; then
#     # export SPACESHIP_CONFIG="/home/zcchen/.zsh/plugins/spaceship-prompt-config.zsh"
# fi
#zplug "caiogondim/bullet-train.zsh", use:bullet-train.zsh-theme, defer:3 # defer until other plugins like oh-my-zsh is loaded
if zplug check "caiogondim/bullet-train.zsh"; then
    BULLETTRAIN_STATUS_EXIT_SHOW=true
    BULLETTRAIN_PROMPT_ORDER=( time context dir git)
    SPACESHIP_GIT_PREFIX="($(git config --get user.name))"
    SPACESHIP_GIT_BRANCH_PREFIX=" "
fi
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
        export https_proxy=http:///127.0.0.1:8228
        echo; zplug install
        export https_proxy=
    else
        echo
    fi
fi
zplug load
# ------------------------- load the plugins (end) -----------------------------

if zplug check "romkatv/powerlevel10k"; then
    source ~/.zsh/conf/p10k-config.zsh
fi
