#!/bin/bash
#
#Script for updating docker infrastructure
#

DOCKER=`ls | grep -o docker*`

echo "DO NOT UPDATE your docker build unless it was recommended to you by someone from QualityUnit!"
read -p "Press Y and enter to continue: " prompt

if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  mv $DOCKER/config.sh /tmp && mv $DOCKER/ssl* /tmp
  git reset --hard origin/master
  git pull
  rm -rf `find ./docker* -type d | grep -v $DOCKER` 2>/dev/null
  mv /tmp/config.sh $DOCKER/config.sh.OLD && mv /tmp/ssl* $DOCKER
else
 exit 0
fi
