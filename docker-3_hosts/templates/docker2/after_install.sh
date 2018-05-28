docker exec -i redis redis-cli del {liveagent}:c:settings
rsync -a --password-file=/opt/docker2/conf/rsync_pass replicator@PRIVATE_IP_1::liveagent /var/lib/docker/volumes/docker2_app/_data/
rsync -a --password-file=/opt/docker2/conf/rsync_pass replicator@PRIVATE_IP_3::liveagent /var/lib/docker/volumes/docker2_app/_data/
