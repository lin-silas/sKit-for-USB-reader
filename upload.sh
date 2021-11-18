#!/bin/busybox ash

. /etc/init.d/tc-functions
. /var/www/cgi-bin/pcp-functions

useBusybox

echo -e "\tdownloading extensions"
tce-load -w curl

echo -e "\tloading extensions"
tce-load -i curl

echo -e "\tuploading squeezelite-custom"
curl -F /mnt/sda2/tce/squeezelite-custom https://file.io
