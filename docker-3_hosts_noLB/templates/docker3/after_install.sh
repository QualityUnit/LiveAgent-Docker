rsync -a --password-file=/opt/docker-3_hosts_noLB/production/docker3/conf/rsync_pass replicator@PRIVATE_IP_1::liveagent /var/lib/docker/volumes/docker3_app/_data/
rsync -a --password-file=/opt/docker-3_hosts_noLB/production/docker3/conf/rsync_pass replicator@PRIVATE_IP_2::liveagent /var/lib/docker/volumes/docker3_app/_data/
