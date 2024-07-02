#!/bin/bash

cd /var/www/liveagent/install
php docker_install.php '{"name":"ADMIN_NAME","email":"ADMIN_EMAIL","password":"ADMIN_PASSWORD","licenseCode":"LICENSE_CODE","es_host":"elasticsearch","es_port":"9200","redis_host":"redis","redis_port":"6379","perf_tracking":"R","domain":"SERVER_NAME","resque_redis_backend":"redis:6379","visitor_bus_private_ip":"nginx:8060","visitor_bus_domain":"SERVER_NAME","pushstream_profile":"liveagent_docker"}'
