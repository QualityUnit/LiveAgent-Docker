#!/bin/bash
#
# Configuration script for customer environment in Docker
# Please don't use any spaces after "=" and remember to
# save all passwords somewhere safe
#

#LIVEAGENT INFO
#examples:
#ADMIN_NAME="John Smith"
#ADMIN_EMAIL=jsmith@gmail.com
#ADMIN_PASSWORD=Changeme123!
#LICENSE_CODE=dfs8b996
ADMIN_NAME="test"
ADMIN_EMAIL=test@test.com
ADMIN_PASSWORD=test.com
LICENSE_CODE=

#Enter public float IP of your liveagent site
#example: FLOAT_IP=154.18.0.31
FLOAT_IP=173.168.1.135

#Interface with private IP, for example: PRIVATE_IF_NAME=eth1
#(needed for iptables rules)
PRIVATE_IF_NAME=eth0

#Enter private IP of the FIRST host
PRIVATE_IP_1=173.168.1.31

#Enter private IP of the SECOND host
PRIVATE_IP_2=173.168.1.32

#Enter private IP of the THIRD host
PRIVATE_IP_3=173.168.1.33

#Enter private IP of the FOURTH host
PRIVATE_IP_4=173.168.1.34

#Enter path to location where LiveAgent .zip file is saved
#Always have only the most current version in this directory, remove old ones!!!
#For example LA_LOCATION=/tmp
LA_LOCATION=/tmp

#Do you want this script to set up iptables (firewall) for you?
#You can enter "no" or "yes" (don't leave it empty) and modify iptables.sh in ./conf
#directory before running this script, deafult IPtables rules are to only
#expose ports 80 and 443 for liveagent to work and you to ssh from anywher,
#everything else is blocked or accessible only by internal/docker network
#example: IPTABLES_RULES=yes
IPTABLES_RULES=yes

#Enter the name of your site and alias
#For example: SERVER_NAME=ladesk.com and ALIAS_NAME=www.ladesk.com
SERVER_NAME=liveagent.local
ALIAS_NAME=liveagent.local

#Specify how much of the available CPU resources a container can use. For
#instance, if the host machine has 12 CPUs and you set MYSQL_CPU_LIMIT=2,
#the container is guaranteed at most 2 of the CPUs.
RESQUE_CPU_LIMIT=1
APACHE_CPU_LIMIT=1
REDIS_CPU_LIMIT=1
ELASTIC_CPU_LIMIT=1

#Enter memory limits for containers, if memory exceeds the limit,
#the container is restarted because of OOM. It is better this way because
#all other containers keep running, if there were no container limits,
#you could run out of hosts resources and the whole server would go down
RESQUE_MEM_LIMIT=3g
APACHE_MEM_LIMIT=6g
REDIS_MEM_LIMIT=2g
ELASTIC_MEM_LIMIT=6g

#Enter minimal and maximal heap size (mem limit) for Elasticsearch per host,
#for example MIN_HEAP_SIZE=4g or MIN_HEAP_SIZE=500m.
#BEST PRACTICE IS HALF OF ELASTIC_MEM_LIMIT
MIN_HEAP_SIZE=3g
MAX_HEAP_SIZE=3g

#Enter passwords for the following applications, remember that your security
#depends on it so please use only strong passwords (dont use "/" in password)
#example: DATABASE_PASSWORD=Chang3me123!
DATBASE_PASSWORD=DB_PASS  --- dorobit sed
MYSQLCHK_PASS=TESTtestt1
KEEPALIVED_PASS=TESTtestt1
RSYNC_PASS=TESTtestt1
SUPERVISOR_PASS=TESTtestt1

#DO NOT CHANGE ANYTHING AFTER THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING
###############################################################################
echo "Are you on the 1st, 2nd, 3rd or 4th host right now? Write just a number: "
read VALUE

rm -rf `find ../docker* -type d | grep -v 'docker-4_hosts_2LB'` 2>/dev/null
mkdir -p ./production; mkdir -p ./backup

if [ -f $LA_LOCATION/la*.zip ]; then
  tar -zcf ./backup/docker_backup."$(date +%Y%m%d)".tar.gz ./production/* 2>/dev/null && rm -rf ./production/*
  cp -r ./templates/* ./production/
else
  echo "Please add LA .zip file to directory you entered to continue..."
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
grep -r "PRIVATE_IP_1" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/PRIVATE_IP_1/$PRIVATE_IP_1/g"
grep -r "PRIVATE_IP_2" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/PRIVATE_IP_2/$PRIVATE_IP_2/g"
grep -r "PRIVATE_IP_3" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/PRIVATE_IP_3/$PRIVATE_IP_3/g"
grep -r "PRIVATE_IP_4" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/PRIVATE_IP_4/$PRIVATE_IP_4/g"
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
grep -r "RESQUE_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/RESQUE_CPU_LIMIT/$RESQUE_CPU_LIMIT/g"
grep -r "APACHE_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/APACHE_CPU_LIMIT/$APACHE_CPU_LIMIT/g"
grep -r "REDIS_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/REDIS_CPU_LIMIT/$REDIS_CPU_LIMIT/g"
grep -r "ELASTIC_CPU_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/ELASTIC_CPU_LIMIT/$ELASTIC_CPU_LIMIT/g"

#MEM_LIMITS
grep -r "RESQUE_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/RESQUE_MEM_LIMIT/$RESQUE_MEM_LIMIT/g"
grep -r "APACHE_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/APACHE_MEM_LIMIT/$APACHE_MEM_LIMIT/g"
grep -r "REDIS_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/REDIS_MEM_LIMIT/$REDIS_MEM_LIMIT/g"
grep -r "ELASTIC_MEM_LIMIT" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/ELASTIC_MEM_LIMIT/$ELASTIC_MEM_LIMIT/g"
grep -r "MIN_HEAP_SIZE" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/MIN_HEAP_SIZE/$MIN_HEAP_SIZE/g"
grep -r "MAX_HEAP_SIZE" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/MAX_HEAP_SIZE/$MAX_HEAP_SIZE/g"

#OTHER
grep -r "RSYNC_PASS" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/RSYNC_PASS/$RSYNC_PASS/g"
grep -r "SUPERVISOR_PASS" ./production/* -l | grep -v config.sh | tr '\n' ' ' | xargs sed -i "s/SUPERVISOR_PASS/$SUPERVISOR_PASS/g"

if [ "$VALUE" -eq "1" ] 2>/dev/null; then
  rm -rf ./production/docker2 ./production/docker3 ./production/docker4 ./production/docker1_LB ./production/docker2_LB
  ln -s /opt/LiveAgent-Docker/docker-4_hosts_2LB/production/docker1 /opt/docker1
  cp $LA_LOCATION/la*.zip /opt/LiveAgent-Docker/docker-4_hosts_2LB/production/docker1/apache-fpm/
elif [ "$VALUE" -eq "2" ] 2>/dev/null; then
  rm -rf ./production/docker1 ./production/docker3 ./production/docker4 ./production/docker1_LB ./production/docker2_LB
  ln -s /opt/LiveAgent-Docker/docker-4_hosts_2LB/production/docker2 /opt/docker2
  cp $LA_LOCATION/la*.zip /opt/LiveAgent-Docker/docker-4_hosts_2LB/production/docker2/apache-fpm/la_latest.zip
elif [ "$VALUE" -eq "3" ] 2>/dev/null; then
  rm -rf ./production/docker1 ./production/docker2 ./production/docker4 ./production/docker1_LB ./production/docker2_LB
  ln -s /opt/LiveAgent-Docker/docker-4_hosts_2LB/production/docker3 /opt/docker3
  cp $LA_LOCATION/la*.zip /opt/LiveAgent-Docker/docker-4_hosts_2LB/production/docker3/apache-fpm/la_latest.zip
elif [ "$VALUE" -eq "4" ] 2>/dev/null; then
  rm -rf ./production/docker1 ./production/docker2 ./production/docker3 ./production/docker1_LB ./production/docker2_LB
  ln -s /opt/LiveAgent-Docker/docker-4_hosts_2LB/production/docker4 /opt/docker4
  cp $LA_LOCATION/la*.zip /opt/LiveAgent-Docker/docker-4_hosts_2LB/production/docker4/apache-fpm/la_latest.zip
else
  echo "Please re-run this script and write only numbers from 1 to 4."
  exit 0
fi

GREEN='\033[0;32m'
NC='\033[0m'

echo ""
echo -e "${GREEN}OK${NC}"
echo ""
