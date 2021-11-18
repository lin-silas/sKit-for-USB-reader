#!/bin/sh

env_set() {
    TCE=/mnt/sda2/tce 
    TCEO=$TCE/optional
    ONB=$TCE/onboot.lst
    sKitbase=$TCE/sKit
    LOGDIR=$sKitbase/log
    LOG=$LOGDIR/$fname.log
  REPO_PCP="https://repo.picoreplayer.org/repo"
  EXTENSIONS="\
  curl" 
  TIMEOUT=300
}

download_extensions() {

    echo -e "\tdownloading extensions (~3min master, ~5min mirror - for initial DL)"
    timeout 300 pcp-load -r "https://repo.picoreplayer.org/repo" -w "curl"
}

load_extensions() {

    echo -e "\tloading extensions (temporary)"
    pcp-load -s -l -i "curl" >>$LOG 2>&1
}

upload_squeezlite() {

  sudo curl -T /mnt/sda2/tce/squeezelite-custom https://oshi.at
  
}

###main#######################################
env_set
download_extensions
load_extensions
upload_squeezlite
##############################################
