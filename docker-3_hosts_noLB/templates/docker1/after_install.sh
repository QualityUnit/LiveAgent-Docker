docker exec -i redis redis-cli del {liveagent}:c:settings && \
docker exec -i mysql mysql -e"use liveagent; INSERT INTO qu_g_settings (name, value) VALUES ('redis_tracking_hosts', 'PRIVATE_IP_1'); INSERT INTO qu_g_settings (name, value) VALUES ('resque_redis_host_port', 'PRIVATE_IP_1:7379'); INSERT INTO qu_g_settings (name, value) VALUES ('resque_redis_enabled', 'Y'); UPDATE qu_g_settings SET value='Y' WHERE name='mod_rewrite_enabled';"
rsync -a --password-file=/opt/docker-3_hosts_noLB/production/docker1/conf/rsync_pass replicator@PRIVATE_IP_2::liveagent /var/lib/docker/volumes/docker1_app/_data/
rsync -a --password-file=/opt/docker-3_hosts_noLB/production/docker1/conf/rsync_pass replicator@PRIVATE_IP_3::liveagent /var/lib/docker/volumes/docker1_app/_data/
