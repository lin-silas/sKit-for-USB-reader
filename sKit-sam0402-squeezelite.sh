#!/bin/sh
#
# soundcheck's tuning kit - pCP - sKit-custom-squeezlite.sh
# custom squeezelite binary build tool for piCorePlayer
# supporting RPi3 and RPi4 and related CM modules
#
# Latest Update: Aug-07-2021
#
# Copyright © 2021 - Klaus Schulz
# All rights reserved
# 
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License 
# as published by the Free Software Foundation, 
# either version 3 of the License, or (at your option) 
# any later version.
#
# This program is distributed in the hope that it will be useful, 
# but WITHOUT ANY WARRANTY; without even the implied warranty 
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
# See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License 
# along with this program. 
#
# If not, see http://www.gnu.org/licenses
#
########################################################################
VERSION=1.3
sKit_VERSION=1.5

fname="${0##*/}"
opts="$@"
license_accept_flag=/mnt/sda2/tce/.sKit-license-accepted.flag

###functions############################################################

colors() {

    RED='\033[0;31m'
    GREEN="\033[0;32m"
    YELLOW="\033[0;33m" 
    NC='\033[0m'
}


out() {

    echo -e "\tprogram aborted"
    echo -e "\t${RED}ERROR: $@ ${NC}"
    DONE
    exit 1
}


line() {

    echo -e "${RED}_______________________________________________________________${NC}\n"
}


checkroot() {

    (( EUID != 0 )) && out "root privileges required"
}


header() {

    line
    echo -e "\t   sKit - custom squeezelite builder ($VERSION)"
    echo -e "\t            (c) soundcheck"
    echo
    echo -e "\t           welcome $(id -un)@$(hostname)"
    line
}


DONE() {

    line
    sync
}


countdown() {

    counter=$1
    while [[ "$counter" -gt 0 ]]; do


        echo -ne -e "\t>> $counter \r"
        let counter--
        sleep 1

    done
    echo -e "\t>> 0"
    line
}


reboot_system() {

   if [[ "$REBOOT" == "true" ]]; then

      echo -e "\trebooting system in"
      countdown 10
      sudo reboot
      exit 1

   fi
}


############################################

env_set() {

    TCE=/mnt/sda2/tce 
    TCEO=$TCE/optional
    ONB=$TCE/onboot.lst
    sKitbase=$TCE/sKit
    LOGDIR=$sKitbase/log
    LOG=$LOGDIR/$fname.log
    pcpcfg=/usr/local/etc/pcp/pcp.cfg
    BOOT_MNT=/mnt/sda1
    BOOT_DEV=/dev/sda1
    REPO_PCP1="https://repo.picoreplayer.org/repo"
    REPO_PCP2="http://picoreplayer.sourceforge.net/tcz_repo"
    REPO_SL="https://github.com/klslz/squeezelite.git"
    EXT_BA="sKit-extensions-backup.tar.gz"
    EXTENSIONS="\
compiletc
git
libasound-dev
pcp-libogg-dev
pcp-libflac-dev
pcp-libvorbis-dev
pcp-libmad-dev
pcp-libmpg123-dev
pcp-libalac-dev
pcp-libfaad2-dev
pcp-libsoxr-dev" 
    BASE=/tmp/squeezelite
    ISOLCPUS="3"
}

download_extensions() {

    echo -e "\tdownloading extensions (~3min master, ~5min mirror - for initial DL)"
    start=$(date +%s)
    for ext in $EXTENSIONS; do

        timeout $TIMEOUT pcp-load -r $REPO_PCP -w "$ext" >>$LOG 2>&1
#        if [[ $? -ne 0 ]] || grep -q -i "FAILED" $LOG; then

#            FAILED=true
#            break

#        fi

    done

    end=$(date +%s)
    total=$((end-start))
    duration=$(printf '%dm:%ds\n' $(($total%3600/60)) $(($total%60)))
 
                        
    if [[ "$FAILED" == "true" ]]; then

        echo
        echo -e "\t${RED}ERROR: serious issue while downloading extensions${NC}"
        echo -e "\t${RED}ERROR: prior status will be restored${NC}"
        echo -e "\t${RED}ERROR: please try once more later or use a different repo server${NC}"
        echo -e "\t${RED}ERROR: you could also have look @ ${NC}"
        echo -e "\t${RED}ERROR:   >> $LOG${NC}"
        grep -i "FAILED" $LOG | while IFS= read i; do 

                                  echo -e "\t${RED}ERROR:   >> $i${NC}\n" 

                                done
        echo
        restore_extensions
        REBOOT=true
        DONE
        reboot_system
        exit 1
    fi

   echo -e "\t   DL-duration: $duration"
}

load_extensions() {

    echo -e "\tloading extensions (temporary)"
    echo "$EXTENSIONS" | while IFS= read -r ext; do

                            pcp-load -s -l -i "$ext" >>$LOG 2>&1

                         done 
}

download_squeezelite() {

    echo -e "\tdownloading squeezelite sources"

    cd /tmp
    wget https://raw.githubusercontent.com/lin-silas/pcp-squeezelite/main/squeezelite-1.9.8-1317.tar.bz2 >$LOG 2>&1
    sudo tar jxf squeezelite-1.9.8-1317.tar.bz2
}

install_squeezelite() {

    cd /tmp/squeezelite

    echo -e "\tbuilding"
    sudo make clean >$LOG 2>&1
    sudo make --makefile=Makefile.rpi4-64-basic >$LOG 2>&1 || out "compiling binary"
    echo -e "\tinstalling"
    sudo mv -f squeezelite $TCE/squeezelite-custom  || out "installing binary"
}

activate_squeezelite() {

    echo -e "\tactivating binary"
    if [[ ! -f $TCE/squeezelite ]]; then

        sudo ln -sf $TCE/squeezelite-custom $TCE/squeezelite

    fi
    sed -i 's/SQBINARY="default"/SQBINARY="custom"/' $pcpcfg
}

DONE() {

    line
    sync
}


countdown() {

    counter=$1
    while [[ "$counter" -gt 0 ]]; do


        echo -ne -e "\t>> $counter \r"
        let counter--
        sleep 1

    done
    echo -e "\t>> 0"
    line
}


reboot_system() {

   if [[ "$REBOOT" == "true" ]]; then

      echo -e "\trebooting system in"
      countdown 10
      sudo reboot
      exit 1

   fi
}

INSTALL() {

    download_extensions
    load_extensions
    download_squeezelite
    install_squeezelite
    activate_squeezelite
    REBOOT=true
}

###main#######################################
colors
env_set

INSTALL

DONE
reboot_system
exit 0
##############################################
