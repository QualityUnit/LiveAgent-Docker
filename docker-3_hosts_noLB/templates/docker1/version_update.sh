#!/bin/bash

# Make this script executable, run it and follow all the instructions
# and you should be fine.
#
# If you are getting rsync errors, make sure everything regarding RSYNC is
# set up as it should be in install_utils.sh script, section = RSYNC SET UP
#
# If the script is giving you the wrong URL, just use the correct one
# followed by /liveagent/install
#
GREEN='\033[0;32m'
NC='\033[0m'

clear

echo "###################################################################################"
echo "Welcome to the update installation of LiveAgent, before we start, make sure"
echo "you have root privileges, apache-fpm containers are stopped on servers 2 and 3"
echo "and the .zip file with new version of LiveAgent is in the same dir as this script."
echo "###################################################################################"
echo ""
read -p "Press Y (or ctrl + c and complete steps above first) to continue: " prompt

if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
   echo "Great, starting to update LiveAgent config files..."
else
   echo "First you need to complete all the steps written above."
   exit 0
fi

clear

FILE=$(ls -al la_*.zip | grep -o la_*.zip)
if [ -f $FILE ]; then
   echo "Updating LiveAgent config files with the following version = $FILE"
   unzip -o $FILE -d /var/lib/docker/volumes/*_app/_data | awk 'BEGIN {ORS=" "} {if(NR%50==0)print "."}'
   echo ""
   echo ""
   docker exec -i apache-fpm /install.sh | grep -v 42S02
   curl -k https://SERVER_NAME/index.php?action=rewrite_ok
   rsync -a --password-file=/opt/docker1/conf/rsync_pass /var/lib/docker/volumes/docker1_app/_data/ replicator@PRIVATE_IP_2::liveagent
   rsync -a --password-file=/opt/docker1/conf/rsync_pass /var/lib/docker/volumes/docker1_app/_data/ replicator@PRIVATE_IP_3::liveagent
   rm -f ./apache-fpm/la*
   mv $FILE ./apache-fpm
   rsync -a --password-file=/opt/docker1/conf/rsync_pass ./apache-fpm/$FILE replicator@PRIVATE_IP_2::liveagent1/la_latest.zip
   rsync -a --password-file=/opt/docker1/conf/rsync_pass ./apache-fpm/$FILE replicator@PRIVATE_IP_3::liveagent1/la_latest.zip
   echo -ne '\n'
   echo -e "${GREEN}LiveAgent has been successfully updated, you can start your apache-fpm containers"
   echo -e "and get back to work.${NC}"
   echo ""
else
   echo "File $FILE is not in the same directory as this script"
   echo "Please move it to the same dir and re-run this script"
   exit 0
fi
