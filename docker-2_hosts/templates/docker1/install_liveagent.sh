#!/bin/bash

if [[ $(docker exec -i mysql mysql -e"show databases;" | grep -i liveagent) == "" ]]; then
  docker exec -i mysql mysql -e"source /tmp/createdb.sql;"
  docker exec -i apache-fpm /install.sh | grep -v 42S02
  curl -k https://SERVER_NAME/index.php?action=rewrite_ok
  rsync -a --password-file=/opt/docker1/conf/rsync_pass /var/lib/docker/volumes/docker1_app/_data/ replicator@PRIVATE_IP_2::liveagent
else
  docker exec -i apache-fpm /install.sh | grep -v 42S02
  curl -k https://SERVER_NAME/index.php?action=rewrite_ok
  rsync -a --password-file=/opt/docker1/conf/rsync_pass /var/lib/docker/volumes/docker1_app/_data/ replicator@PRIVATE_IP_2::liveagent
fi
