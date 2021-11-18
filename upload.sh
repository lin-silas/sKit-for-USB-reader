#!/bin/busybox ash

. /etc/init.d/tc-functions
. /var/www/cgi-bin/pcp-functions

useBusybox

echo -e "\tloading extensions"
tce-load -i curl.tcz

echo -e "\tuploading squeezelite-custom"
sudo curl -T /mnt/sda2/tce/squeezelite-custom https://oshi.at
