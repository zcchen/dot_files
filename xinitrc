#pkill urxvtd
#urxvtd -q -o -f

#pkill syndaemon
#syndaemon -i 2 -dtk

setxkbmap -option ctrl:nocaps
#synclient TouchpadOff=$(synclient -l|grep -c 'TouchpadOff.*=.*0')

#/usr/bin/start-pulseaudio-x11

source ~/.xprofile

#fcitx -d

# Radeon Opensource driver video decode
export LIBVA_DRIVER_NAME=vdpau
#export VDPAU_DRIVER=radeonsi

#exec awesome
#exec enlightenment_start
#exec i3 -V >> ~/.i3/i3log 2>&1
#exec i3
#epxort KDE_WM="/usr/bin/i3"
#exec startkde
#exec openbox
#exec xfce4-session
