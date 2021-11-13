#!/bin/sh
#

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
        if [[ $? -ne 0 ]] || grep -q -i "FAILED" $LOG; then

            FAILED=true
            break

        fi

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
    wget https://raw.githubusercontent.com/lin-silas/pcp-squeezelite/main/squeezelite-1.9.8-1317.tar.bz2
    tar jxvf squeezelite-1.9.8-1317.tar.bz2
}

install_squeezelite() {

    cd /tmp/squeezelite

    echo -e "\tbuilding"
    make clean
    make --makefile=Makefile.rpi4-64-basic || out "compiling binary"
    echo -e "\tinstalling"
    sudo mv -f squeezelite $TCE/squeezelite-custom  || out "installing binary"
}

activate_squeezelite() {

    echo -e "\tactivating binary"
    if [[ ! -f $TCE/squeezelite ]]; then

        ln -sf $TCE/squeezelite-custom $TCE/squeezelite

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
INSTALL

DONE
reboot_system
exit 0
##############################################