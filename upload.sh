#!/bin/busybox ash

. /etc/init.d/tc-functions
. /var/www/cgi-bin/pcp-functions

useBusybox

REPO_PCP="https://repo.picoreplayer.org/repo"
ext="curl"

tce-load -i ca-certificates.tcz

echo -e "\tdownloading extensions"
tce-load -w $ext

echo -e "\tloading extensions"
tce-load -s -l -i $ext

echo -e "\tuploading squeezelite-custom"
sudo curl -T /mnt/sda2/tce/squeezelite-custom https://oshi.at
