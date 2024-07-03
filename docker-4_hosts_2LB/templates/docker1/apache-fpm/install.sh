#!/bin/bash

cd /var/www/liveagent/install
php docker_install.php '{"name":"ADMIN_NAME","email":"ADMIN_EMAIL","password":"ADMIN_PASSWORD","licenseCode":"LICENSE_CODE","es_host":"FLOAT_IP","es_port":"10200","redis_host":"FLOAT_IP","redis_port":"7379","perf_tracking":"R","domain":"SERVER_NAME","resque_redis_backend":"FLOAT_IP:7379","visitor_bus_private_ip":"FLOAT_IP:8060","visitor_bus_domain":"SERVER_NAME","pushstream_profile":"liveagent_docker"}'
