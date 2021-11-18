#!/bin/sh

env_set() {
    LOGDIR=$sKitbase/log
    LOG=$LOGDIR/$fname.log
  REPO_PCP="https://repo.picoreplayer.org/repo"
  EXTENSIONS="\
  curl" 
  TIMEOUT=300
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

upload_squeezlite() {

  curl -T /mnt/sda2/tce/squeezelite-custom https://oshi.at
  
}

###main#######################################
env_set
download_extensions
load_extensions
upload_squeezlite
##############################################
