#!/bin/bash

docker exec -i mysql mysql -e"source /tmp/createdb.sql;"
docker exec -i apache-fpm /install.sh | grep -v 42S02
docker exec -i mysql mysql -e"use liveagent; INSERT INTO qu_g_settings (name, value) VALUES ('mod_rewrite_enabled', 'Y');"
