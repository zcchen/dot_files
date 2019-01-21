#! /bin/bash

cd `dirname $0`

linkcmd="ln -snf "
rmcmd="rm "

ignoreFiles=(
    _.ssh-config
    _.zathurarc
#_.vim_myPlugins
#_vim_bundle.vim
    _.fcitx_config
    _.fcitx_profile
    _.fcitx_conf
    _.fcitx_data
    _.mimeapps.list
    _.autostart
    _.dunstrc
)
ignoreFileTargets=(
    ~/.ssh/config
    ~/.config/zathura/zathurarc
#   ~/.vim/myPlugins
#    ~/.vim/bundle.vim
    ~/.config/fcitx/config
    ~/.config/fcitx/profile
    ~/.config/fcitx/conf
    ~/.config/fcitx/data
    ~/.local/share/applications/mimeapps.list
    ~/.config/autostart
    ~/.config/dunst/dunstrc
)

ignoreLink() {            # Generate the sed script to ignore some files
    ignoreSedSh=""
    elem=${#ignoreFiles[@]}
    strReturn=""

    for (( i=0; i < $elem; i++ )); do
        strReturn=$strReturn'/^\(.\/\)\{0,1\}'${ignoreFiles[$i]}'$/d;'
    done

    ignoreSedSh=$strReturn              # Return sed script strings
}

linkCommand() {                         # Generate the link script
    ignoreLink                          # In order to define ignoreSedSh
    if [[ $1 = "link" ]]; then
        sedScript=(
            #'/^\(\.\/\)\{0,1\}[^_][a-zA-Z\.]*$/d'';'
                                        ## delete those not start with \_
            #'s:^\(\.\/\)\{0,1\}::g'';'  # let cmd find return as ls -1
            's:^\_.*$:&\ &:g'';'        # create simple copy
            's:\ \_\.:\ \~\/\.:g'';'    # generate the target name
            "s:^:$linkcmd\ `pwd`\/:g"   # generate the source pat
        )
    elif [[ $1 = "remove" ]]; then
        sedScript=(
            #'/^\(\.\/\)\{0,1\}[^_][a-zA-Z\.]*$/d'';'
                                        ## delete those not start with \_
            #'s:^\(\.\/\)\{0,1\}::g'';'  # let cmd find return as ls -1
            's:^\_\.:\~\/\.:g'';'       # generate the target name
            "s:^:$rmcmd\ :g"            # generate the source pat
        )
    fi
    echo '#! /bin/bash'
    #find -maxdepth 1 -type f |\
        #sed -e "${ignoreSedSh}" |           # delete some ignore file line
        #sed -e "${sedScript[*]}"

    ls -1 |\
        sed '/^[^_]/d' |                    # start Sel
        sed -e "${ignoreSedSh}" |           # delete some ignore file line
        sed -e "${sedScript[*]}"
}

otherLink() {
    if [[ ${#ignoreFiles[@]} -eq ${#ignoreFileTargets[@]} ]]; then
        for (( i=0; i < ${#ignoreFiles[@]}; i++ )); do
            if [[ -f ${ignoreFiles[$i]} ]] || [[ -d ${ignoreFiles[$i]} ]]
            then
                echo "mkdir -p $(dirname ${ignoreFileTargets[$i]} )"
                if [[ $1 = "link" ]]; then
                    echo "ln -snf "`pwd`/${ignoreFiles[$i]}" ${ignoreFileTargets[$i]}"
                elif [[ $1 = "remove" ]]; then
                    echo "rm -rf ${ignoreFileTargets[$i]}"
                fi
            fi
        done
    else
        echo "*******************************************"
        echo "* Some files could not be linked well!    *"
        echo "* Please check the script and edit it!    *"
	echo "*******************************************"
    fi
}

update_submodule() {
    cd $(dirname $0)/_.vimperator/plugins
    git pull
}


if [[ -z $1 ]] && [[ $1 != 'remove' ]] && [[ $1 != 'link' ]]; then
    echo "Usage: link.sh <link | remove | update>"
    echo "    link, create the soft link to the ~/ directory."
    echo "      Some file in the ignore group will be link to "
    echo "      the other directory."
    echo "    remove, remove all the soft link."
    echo "    update, update the submodules."
else
    if [[ $1 = 'remove' ]] || [[ $1 = 'link' ]]; then
        if [[ -f linkScript.sh ]]; then
            rm linkScript.sh
        fi
        #linkCommand $1                         For test
        linkCommand $1 |tee -a linkScript.sh   # Generate the script command
        #otherLink $1
        otherLink $1 |tee -a linkScript.sh
        chmod +x linkScript.sh
        ./linkScript.sh
        rm ./linkScript.sh
    elif [[ $1 = 'update' ]]; then
        update_submodule
    fi
fi

# vim: sw=4 sts=4 et tw=70
