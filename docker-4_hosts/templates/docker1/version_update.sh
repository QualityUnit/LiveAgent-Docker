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
RED='\033[0;31m'
NC='\033[0m'

clear

echo "###################################################################################"
echo "Welcome to the update installation of LiveAgent, before we start, make sure"
echo "you have root privileges, apache-fpm containers are stopped on 2nd host with apache"
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
   unzip -o $FILE -d /var/lib/docker/volumes/docker1_app/_data | awk 'BEGIN {ORS=" "} {if(NR%50==0)print "."}'
   echo -ne '\n'
   echo "LiveAgent config files have been successfully updated, please enter your LiveAgent URL"
   echo "to your web browser followed by /liveagent/install/ to start the update:"
   echo ""
   echo "for example: support.ladesk.com/liveagent/install/"
   echo ""
   echo -e "${RED}Complete all steps and wait until LiveAgent is functioning on 100% again and"
   echo -e "begin the last step of the update.${NC}"
   echo ""
else
   echo "File $FILE is not in the same directory as this script"
   echo "Please move it to the same dir and re-run this script"
   exit 0
fi

read -p "Did you complete the update in your browser? - if yes, press Y:  " prompt

if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
   echo "Great, starting to update LiveAgent config files on other host..."
   echo ""
   rsync -a --password-file=/opt/docker1/conf/rsync_pass /var/lib/docker/volumes/docker1_app/_data/ replicator@PRIVATE_IP_2::liveagent
   echo ""
   echo "Done, you can start your apache-fpm containers and get back to work."
else
   echo "You didn't press Y, did you? Now you need to start all over again!"
   exit 0
fi
