docker exec -i redis redis-cli del {liveagent}:c:settings && \
docker exec -i mysql mysql -e"use liveagent; INSERT INTO qu_g_settings (name, value) VALUES ('redis_tracking_hosts', 'redis'); INSERT INTO qu_g_settings (name, value) VALUES ('resque_redis_host_port', 'redis:6379'); INSERT INTO qu_g_settings (name, value) VALUES ('resque_redis_enabled', 'Y'); UPDATE qu_g_settings SET value='Y' WHERE name='mod_rewrite_enabled';"