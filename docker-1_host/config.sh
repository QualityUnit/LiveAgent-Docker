#!/bin/bash
#
# Configuration script for customer environment in docker
# Please don't use any spaces after "=" and remember to
# save all passwords somewhere safe
#

#Enter public/private IP of your liveagent site (from which you will access LiveAgent)
CUSTOMER_IP=

#Do you want this script to set up iptables (firewall) for you?
#You can enter "no" or "yes" (don't leave it empty) and modify iptables.sh in ./conf
#directory before running this script, deafult IPtables rules are to only
#expose ports 80 and 443 for liveagent to work and you to ssh from anywher,
#everything else is blocked or accessible only by internal/docker network
IPTABLES_RULES=

#Interface with private IP, for example: eth1 (needed for iptables rules)
PRIVATE_IF_NAME=

#Enter path to location where LiveAgent .zip file is saved
#Always have only the most current version in this directory, remove old ones!!!
#For example LA_LOCATION=/tmp
LA_LOCATION=

#Enter the name of your site and alias
#For example: support.ladesk.com and support.qualityunit.com
SERVER_NAME=
ALIAS_NAME=

#Enter CPU limits - How many CPUs can container use
NGINX_CPU_LIMIT=1
VARNISH_CPU_LIMIT=1
HAPROXY_CPU_LIMIT=1
RESQUE_CPU_LIMIT=1
APACHE_CPU_LIMIT=3
MYSQL_CPU_LIMIT=2
REDIS_CPU_LIMIT=1
ELASTIC_CPU_LIMIT=1

#Enter memory limits for containers, if memory exceeds the limit,
#the container is restarted because of OOM. It is better this way because
#all other containers keep running, if there were no container limits,
#you could run out of hosts resources and the whole server would go down
NGINX_MEM_LIMIT=1g
VARNISH_MEM_LIMIT=2g
HAPROXY_MEM_LIMIT=500m
RESQUE_MEM_LIMIT=3g
APACHE_MEM_LIMIT=6g
MYSQL_MEM_LIMIT=8g
REDIS_MEM_LIMIT=2g
ELASTIC_MEM_LIMIT=6g

#Enter minimal and maximal heap size (mem limit) for Elasticsearch per host,
#for example =4g. USUALLY HALF OF ELASTIC_MEM_LIMIT
MIN_HEAP_SIZE=3g
MAX_HEAP_SIZE=3g

#Enter passwords for the following applications, remember that your security
#depends on it so please use only strong passwords (dont use "/" in password)
DATABASE_PASSWORD=
SUPERVISOR_PASS=

#DO NOT CHANGE ANYTHING AFTER THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING
###############################################################################
mkdir -p ./production; mkdir -p ./backup

SSL_CRT=./ssl.crt
SSL_KEY=./ssl.key
if [ -f $SSL_CRT ] && [ -f $SSL_KEY ] && [ -f $LA_LOCATION/la*.zip ]; then
  tar -zcf ./backup/docker_backup."$(date +%Y%m%d)".tar.gz ./production/* 2>/dev/null && rm -rf ./production/*
  cp -r ./templates/* ./production/
  cp ./ssl.key ./production/nginx/
  cp ./ssl.crt ./production/nginx/
  cp $LA_LOCATION/la*.zip /opt/LiveAgent-Docker/docker-1_host/production/apache-fpm/
else
  echo "Please add ssl.key and ssl.crt files to this directory and LA .zip file to directory you entered to continue..."
  pwd
  exit 0
fi

#NETWORK
grep -r "PRIVATE_IF_NAME" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/PRIVATE_IF_NAME/$PRIVATE_IF_NAME/g"
grep -r "SERVER_NAME" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/SERVER_NAME/$SERVER_NAME/g"
grep -r "ALIAS_NAME" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/ALIAS_NAME/$ALIAS_NAME/g"

GREP_ETC_HOSTS=$(grep $SERVER_NAME /etc/hosts)
if [ $ETC_HOSTS_MODIFIED = no ] && [ "$GREP_ETC_HOSTS" == "" ]
then
  echo "$CUSTOMER_IP       $SERVER_NAME $ALIAS_NAME" >> /etc/hosts
fi

if [ $IPTABLES_RULES = no ]
then
  grep -r "iptables" ./production/install_utils.sh -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "/iptables/d"
fi

#CPU_LIMITS
grep -r "NGINX_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/NGINX_CPU_LIMIT/$NGINX_CPU_LIMIT/g"
grep -r "VARNISH_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/VARNISH_CPU_LIMIT/$VARNISH_CPU_LIMIT/g"
grep -r "RESQUE_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/RESQUE_CPU_LIMIT/$RESQUE_CPU_LIMIT/g"
grep -r "APACHE_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/APACHE_CPU_LIMIT/$APACHE_CPU_LIMIT/g"
grep -r "MYSQL_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/MYSQL_CPU_LIMIT/$MYSQL_CPU_LIMIT/g"
grep -r "REDIS_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/REDIS_CPU_LIMIT/$REDIS_CPU_LIMIT/g"
grep -r "ELASTIC_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/ELASTIC_CPU_LIMIT/$ELASTIC_CPU_LIMIT/g"

#MEM_LIMITS
grep -r "NGINX_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/NGINX_MEM_LIMIT/$NGINX_MEM_LIMIT/g"
grep -r "VARNISH_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/VARNISH_MEM_LIMIT/$VARNISH_MEM_LIMIT/g"
grep -r "RESQUE_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/RESQUE_MEM_LIMIT/$RESQUE_MEM_LIMIT/g"
grep -r "APACHE_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/APACHE_MEM_LIMIT/$APACHE_MEM_LIMIT/g"
grep -r "MYSQL_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/MYSQL_MEM_LIMIT/$MYSQL_MEM_LIMIT/g"
grep -r "REDIS_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/REDIS_MEM_LIMIT/$REDIS_MEM_LIMIT/g"
grep -r "ELASTIC_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/ELASTIC_MEM_LIMIT/$ELASTIC_MEM_LIMIT/g"
grep -r "MIN_HEAP_SIZE" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/MIN_HEAP_SIZE/$MIN_HEAP_SIZE/g"
grep -r "MAX_HEAP_SIZE" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/MAX_HEAP_SIZE/$MAX_HEAP_SIZE/g"

#OTHER
grep -r "DATABASE_PASSWORD" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/DATABASE_PASSWORD/$DATABASE_PASSWORD/g"
grep -r "SUPERVISOR_PASS" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/SUPERVISOR_PASS/$SUPERVISOR_PASS/g"
