# install the znap command
znap_path=${HOME}/.zsh/maangers/znap/
if [[ ! -f "${znap_path}/znap.zsh" ]]; then
    git clone https://github.com/marlonrichert/zsh-snap.git ${znap_path}
fi
source ${znap_path}/znap.zsh


# `znap prompt` makes your prompt visible in just 15-40ms!
znap prompt sindresorhus/pure

# `znap source` automatically downloads and starts your plugins.
#znap source marlonrichert/zsh-autocomplete
#znap source zsh-users/zsh-autosuggestions
#znap source zsh-users/zsh-syntax-highlighting
