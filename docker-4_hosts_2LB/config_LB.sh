#!/bin/bash
#
# Loadbalancer configuration script for customer environment in Docker
# Please don't use any spaces after "=" and remember to
# save all passwords somewhere safe
#

#LIVEAGENT INFO
#examples:
#ADMIN_NAME="John Smith"
#ADMIN_EMAIL=jsmith@gmail.com
#ADMIN_PASSWORD=Changeme123!
ADMIN_NAME=""
ADMIN_EMAIL=
ADMIN_PASSWORD=

#Enter public float IP of your liveagent site
#example: FLOAT_IP=154.18.0.31
FLOAT_IP=

#Interface with private IP, for example: PRIVATE_IF_NAME=eth1
#(needed for iptables rules)
PRIVATE_IF_NAME=

#Do you want this script to set up iptables (firewall) for you?
#You can enter "no" or "yes" (don't leave it empty) and modify iptables.sh in ./conf
#directory before running this script, deafult IPtables rules are to only
#expose ports 80 and 443 for liveagent to work and you to ssh from anywher,
#everything else is blocked or accessible only by internal/docker network
#example: IPTABLES_RULES=yes
IPTABLES_RULES=

#Enter the name of your site and alias
#For example: SERVER_NAME=ladesk.com and ALIAS_NAME=www.ladesk.com
SERVER_NAME=
ALIAS_NAME=


#Specify how much of the available CPU resources a container can use. For
#instance, if the host machine has 12 CPUs and you set MYSQL_CPU_LIMIT=2,
#the container is guaranteed at most 2 of the CPUs.
NGINX_CPU_LIMIT=4
VARNISH_CPU_LIMIT=1
HAPROXY_CPU_LIMIT=2
ELASTIC_CPU_LIMIT=1

#Enter memory limits for containers, if memory exceeds the limit,
#the container is restarted because of OOM. It is better this way because
#all other containers keep running, if there were no container limits,
#you could run out of hosts resources and the whole server would go down
NGINX_MEM_LIMIT=1g
VARNISH_MEM_LIMIT=2g
HAPROXY_MEM_LIMIT=500m
ELASTIC_MEM_LIMIT=6g

#Enter minimal and maximal heap size (mem limit) for Elasticsearch per host,
#for example MIN_HEAP_SIZE=4g or MIN_HEAP_SIZE=500m.
#BEST PRACTICE IS HALF OF ELASTIC_MEM_LIMIT
MIN_HEAP_SIZE=3g
MAX_HEAP_SIZE=3g

#Enter passwords for the following applications, remember that your security
#depends on it so please use only strong passwords (dont use "/" in password)
#example: DATABASE_PASSWORD=Chang3me123!
KEEPALIVED_PASS=
RSYNC_PASS=
HAPROXY_PASS=

#DO NOT CHANGE ANYTHING AFTER THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING
###############################################################################
echo "Are you on the 1st loadbalancer or 2nd loadbalancer right now? Write just a number: "
read VALUE

rm -rf `find ../docker* -type d | grep -v 'docker-4_hosts_2LB'` 2>/dev/null
mkdir -p ./production; mkdir -p ./backup

SSL_CRT=./ssl.crt
SSL_KEY=./ssl.key
if [ -f $SSL_CRT ] && [ -f $SSL_KEY ] ; then
  tar -zcf ./backup/docker_backup."$(date +%Y%m%d)".tar.gz ./production/* 2>/dev/null && rm -rf ./production/*
  cp -r ./templates/*_LB ./production/
  echo ./production/docker*/nginx/ | xargs -n 1 cp ./ssl.key
  echo ./production/docker*/nginx/ | xargs -n 1 cp ./ssl.crt
else
  echo "Please add ssl.key and ssl.crt files to this directory to continue..."
  pwd
  exit 0
fi

#LIVEAGENT
grep -r "ADMIN_NAME" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/ADMIN_NAME/$ADMIN_NAME/g"
grep -r "ADMIN_EMAIL" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/ADMIN_EMAIL/$ADMIN_EMAIL/g"
grep -r "ADMIN_PASSWORD" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/ADMIN_PASSWORD/$ADMIN_PASSWORD/g"
grep -r "LICENSE_CODE" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/LICENSE_CODE/$LICENSE_CODE/g"

#NETWORK
grep -r "PRIVATE_IF_NAME" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/PRIVATE_IF_NAME/$PRIVATE_IF_NAME/g"
grep -r "FLOAT_IP" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/FLOAT_IP/$FLOAT_IP/g"
grep -r "SERVER_NAME" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/SERVER_NAME/$SERVER_NAME/g"
grep -r "ALIAS_NAME" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/ALIAS_NAME/$ALIAS_NAME/g"

GREP_ETC_HOSTS=$(grep $SERVER_NAME /etc/hosts)
if [ "$GREP_ETC_HOSTS" == "" ] && [ "$VALUE" -eq "1" ] || [ "$VALUE" -eq "2" ]
then
  echo "$FLOAT_IP       $SERVER_NAME $ALIAS_NAME" >> /etc/hosts
fi

if [ $IPTABLES_RULES = no ]
then
  grep -r "iptables" ./production/docker*/install_utils.sh -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "/iptables/d"
fi

#CPU_LIMITS
grep -r "NGINX_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/NGINX_CPU_LIMIT/$NGINX_CPU_LIMIT/g"
grep -r "VARNISH_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/VARNISH_CPU_LIMIT/$VARNISH_CPU_LIMIT/g"
grep -r "HAPROXY_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/HAPROXY_CPU_LIMIT/$HAPROXY_CPU_LIMIT/g"
grep -r "ELASTIC_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/ELASTIC_CPU_LIMIT/$ELASTIC_CPU_LIMIT/g"

#MEM_LIMITS
grep -r "NGINX_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/NGINX_MEM_LIMIT/$NGINX_MEM_LIMIT/g"
grep -r "VARNISH_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/VARNISH_MEM_LIMIT/$VARNISH_MEM_LIMIT/g"
grep -r "HAPROXY_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/HAPROXY_MEM_LIMIT/$HAPROXY_MEM_LIMIT/g"
grep -r "ELASTIC_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/ELASTIC_MEM_LIMIT/$ELASTIC_MEM_LIMIT/g"
grep -r "MIN_HEAP_SIZE" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/MIN_HEAP_SIZE/$MIN_HEAP_SIZE/g"
grep -r "MAX_HEAP_SIZE" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/MAX_HEAP_SIZE/$MAX_HEAP_SIZE/g"

#OTHER
grep -r "KEEPALIVED_PASS" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/KEEPALIVED_PASS/$KEEPALIVED_PASS/g"
grep -r "RSYNC_PASS" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/RSYNC_PASS/$RSYNC_PASS/g"
grep -r "HAPROXY_PASS" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/HAPROXY_PASS/$HAPROXY_PASS/g"

if [ "$VALUE" -eq "1" ] 2>/dev/null; then
  rm -rf ./production/docker2_LB ./production/docker1 ./production/docker2 ./production/docker3 ./production/docker4
  ln -s /opt/LiveAgent-Docker/docker-4_hosts_2LB/production/docker1_LB /opt/docker1_LB
elif [ "$VALUE" -eq "2" ] 2>/dev/null; then
  rm -rf ./production/docker1_LB ./production/docker1 ./production/docker2 ./production/docker3 ./production/docker4
  ln -s /opt/LiveAgent-Docker/docker-4_hosts_2LB/production/docker2_2LB /opt/docker2_LB
else
  echo "Please re-run this script and write only number 1 or 2."
  exit 0
fi

GREEN='\033[0;32m'
NC='\033[0m'

echo ""
echo -e "${GREEN}OK${NC}"
echo ""
