docker exec -i redis redis-cli del {liveagent}:c:settings
rsync -a --password-file=/opt/docker1/conf/rsync_pass replicator@PRIVATE_IP_2::liveagent /var/lib/docker/volumes/docker1_app/_data/
