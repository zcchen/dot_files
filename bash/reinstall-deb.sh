#!/bin/bash
# Debian System Reinstaller
# Copyright (C) 2015 Albert Huang
#               2023 CHEN, Zhechuan
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# ---
# This script assumes you are using a Debian based system
# (Debian, Mint, Ubuntu, #!), and have sudo installed. If you don't
# have sudo installed, replace "sudo" with "su -c" instead.
# 

becho() {
	echo -e "\033[1m$@\033[0m"
}

spinat=0

spinner() {
	spinat=`expr $spinat + 1`
	if [ "$spinat" = "1" ];then
		spin="|"
	elif [ "$spinat" = "2" ];then
		spin="/"
	elif [ "$spinat" = "3" ];then
		spin="-"
	elif [ "$spinat" = "4" ];then
		spin="\\"
		spinat=0;
	else
		spinat=0;
	fi
	printf "\b$spin"
}

spinner_loop() {
	while :; do
		spinner
		sleep 0.1s
	done
}

spinner_register() {
	spinner_proc=$1
	export spinner_proc
}

spinner_cancel() {
	kill -PIPE $spinner_proc
	printf "\b \b"
}

stopnow=0
export stopnow

trap "echo 'Detected CTRL-C, exiting...'; stopnow=1; export stopnow" INT TERM

becho " * Scanning for all installed packages on the system..."

[ "$stopnow" = "1" ] && exit

spinner_loop &
spinner_register %%

pkgs=`dpkg --get-selections | grep -w 'install$' | cut -f 1 | \
		egrep -v '(dpkg|apt)'`

spinner_cancel

[ "$stopnow" = "1" ] && exit

becho " * Reinstallation will start in 3 seconds..."

[ "$stopnow" = "1" ] && exit

sleep 3s

[ "$stopnow" = "1" ] && exit

becho " * Reinstalling..."

rm -f reinstall.log

#echo "pkgs: ${pkgs}"
echo "Prepare to Re-installing packages..."
echo "Check reinstall.log file for more details."
sudo apt-get install --reinstall -o Dpkg::Options::="--force-confmiss" ${pkgs} | tee -a reinstall.log
cerr=$?
if [ ! "$cerr" = "0" ]; then
    echo "ERROR: Reinstallation failed. See reinstall.log for details."
    exit 1
else
    echo "Re-installation is done. See reinstall.log for details."
fi

#for pkg in $pkgs; do
	#echo -e "\033[1m   * Reinstalling:\033[0m $pkg"
	#echo "***** Reinstalling: $pkg *****" >> reinstall.log
	#printf "      "
	#[ "$stopnow" = "1" ] && exit
	#spinner_loop &
	#spinner_register %%
	#sudo apt-get -q -y --force-yes install --reinstall -o Dpkg::Options::="--force-confmiss" $pkg >> reinstall.log
	#cerr=$?
	#spinner_cancel
	#backstep "      "
	#if [ ! "$cerr" = "0" ]; then
		#echo "ERROR: Reinstallation failed. See reinstall.log for details."
		#exit 1
	#fi
	#[ "$stopnow" = "1" ] && exit
#done
