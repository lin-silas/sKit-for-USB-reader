#!/bin/busybox ash

. /etc/init.d/tc-functions
. /var/www/cgi-bin/pcp-functions

useBusybox

REPO_PCP="https://repo.picoreplayer.org/repo"
ext="curl"

download_extensions() {

    echo -e "\tdownloading extensions (~3min master, ~5min mirror - for initial DL)"
    tce-load -r $REPO_PCP -w $ext
}

load_extensions() {

    echo -e "\tloading extensions (temporary)"
    tce-load -s -l -i $ext
}

upload_squeezlite() {

  sudo curl -T /mnt/sda2/tce/squeezelite-custom https://oshi.at
  
}

###main#######################################
download_extensions
load_extensions
upload_squeezlite
##############################################
