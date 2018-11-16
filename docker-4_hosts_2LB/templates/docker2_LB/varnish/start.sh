#!/bin/bash

/usr/sbin/varnishd -F -a varnish:81 -f /etc/varnish/default.vcl -T varnish:6082 -t 120 -p thread_pool_min=50 -p thread_pool_max=1000 -p thread_pool_timeout=120 -p thread_pool_stack=256k -p listen_depth=1024 -S /etc/varnish/secret -s "malloc,512M"
