#!/bin/bash

docker exec -i mysql mysql -e"source /tmp/createdb.sql;"
docker exec -i apache-fpm /install.sh | grep -v 42S02
curl -k https://SERVER_NAME/index.php?action=rewrite_ok