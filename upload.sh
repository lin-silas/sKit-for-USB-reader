#!/bin/busybox ash

. /etc/init.d/tc-functions
. /var/www/cgi-bin/pcp-functions

useBusybox

download_extensions() {

    echo -e "\tdownloading extensions (~3min master, ~5min mirror - for initial DL)"
    pcp-load -r "https://repo.picoreplayer.org/repo" -w "curl"
}

load_extensions() {

    echo -e "\tloading extensions (temporary)"
    pcp-load -s -l -i "curl"
}

upload_squeezlite() {

  sudo curl -T /mnt/sda2/tce/squeezelite-custom https://oshi.at
  
}

###main#######################################
download_extensions
load_extensions
upload_squeezlite
##############################################
