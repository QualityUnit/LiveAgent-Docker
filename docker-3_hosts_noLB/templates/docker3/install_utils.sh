#!/bin/bash

#SYSTEMD

sed -i "s/#LogLevel=info/LogLevel=notice/g" /etc/systemd/system.conf && systemctl daemon-reexec

#AWS CLI & YUM UPDATE

yum -y install wget unzip
yum update -y

#GEOIP

if [[ $(yum list installed geoip | grep 'base\|anaconda\|installed' | wc -l) == 1 ]]; then yum remove geoip -y; fi
rpm -ivh ./conf/geoipupdate-2.2.2-2.el7.art.x86_64.rpm && rm -rf ./conf/geoipupdate-2.2.2-2.el7.art.x86_64.rpm
mkdir -p ./geoip
cp -r ./conf/GeoIP.conf /etc/GeoIP.conf && rm -rf ./conf/GeoIP.conf
echo "#GEOIP" >> /etc/crontab
echo "44 2 * * 6 root /usr/bin/geoipupdate -d /opt/LiveAgent-Docker/docker-3_hosts_noLB/production/docker1/geoip/ > /dev/null" >> /etc/crontab
echo "" >> /etc/crontab
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz -P ./geoip/ && gunzip -f ./geoip/GeoLiteCity.dat.gz
/usr/bin/geoipupdate -d /opt/LiveAgent-Docker/docker-3_hosts_noLB/production/docker1/geoip/ > /dev/null

#CLAMAV

wget http://www6.atomicorp.com/channels/atomic/centos/7/x86_64/RPMS/clamav-0.99.4-3788.el7.art.x86_64.rpm -P ./conf
wget http://www6.atomicorp.com/channels/atomic/centos/7/x86_64/RPMS/clamav-db-0.99.4-3788.el7.art.x86_64.rpm -P ./conf
wget http://www6.atomicorp.com/channels/atomic/centos/7/x86_64/RPMS/clamd-0.99.4-3788.el7.art.x86_64.rpm -P ./conf
rpm -ivh ./conf/clamav-0.99.4-3788.el7.art.x86_64.rpm ./conf/clamav-db-0.99.4-3788.el7.art.x86_64.rpm ./conf/clamd-0.99.4-3788.el7.art.x86_64.rpm
rm -rf ./conf/clamav-0.99.4-3788.el7.art.x86_64.rpm ./conf/clamav-db-0.99.4-3788.el7.art.x86_64.rpm ./conf/clamd-0.99.4-3788.el7.art.x86_64.rpm
yum -y install socat
mkdir -p /opt/LiveAgent-Docker/docker-3_hosts_noLB/production/docker3/clamav && chown clamav:clamav /opt/LiveAgent-Docker/docker-3_hosts_noLB/production/docker3/clamav
cp -r ./conf/freshclam.conf /etc/freshclam.conf && rm -rf ./conf/freshclam.conf
/usr/bin/freshclam
cp -r ./conf/clamd.service /etc/systemd/system/clamd.service && rm -rf ./conf/clamd.service
cp -r ./conf/clamd.conf /etc/clamd.conf && rm -rf ./conf/clamd.conf
systemctl start clamd.service && systemctl enable clamd.service
echo "#CLAMD" >> /etc/crontab
echo "25 3 * * * root /usr/bin/freshclam" >> /etc/crontab
echo "0 5 * * * root service clamd restart " >> /etc/crontab
echo "" >> /etc/crontab

#FIREWALL

yum install -y iptables-services && systemctl enable iptables && systemctl start iptables
chmod +x ./conf/iptables.sh && ./conf/iptables.sh

#SET UP THE REPOSITORY

yum install -y yum-utils \
    device-mapper-persistent-data \
    lvm2
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --enable docker-ce-edge

#INSTALL DOCKER CE

yum install -y docker-ce-18.03.0.ce
yum -y install yum-versionlock
yum versionlock docker-ce
systemctl start docker && systemctl enable docker

#INSTALL DOCKER-COMPOSE

cp ./conf/docker-compose-Linux-x86_64 /usr/local/bin/docker-compose && rm -rf ./conf/docker-compose-Linux-x86_64
chmod +x /usr/local/bin/docker-compose

#INSTALL XINETD

yum -y install xinetd
systemctl enable xinetd.service && systemctl start xinetd.service

#RSYNC SET UP

cp ./conf/rsync /etc/xinetd.d/rsync && rm -rf ./conf/rsync
chmod +x /etc/xinetd.d/rsync
cp ./conf/rsyncd.conf /etc/rsyncd.conf && rm -rf ./conf/rsyncd.conf
chmod 644 /etc/rsyncd.conf
chmod 600 ./conf/rsyncd.secrets
chmod 600 ./conf/rsync_pass
chown root:root ./conf/rsyncd.secrets ./conf/rsync_pass

#SELINUX disable

setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#PHP script

echo "#PHP" >> /etc/crontab
echo "*/1 * * * * root docker exec -i apache-fpm /usr/bin/php -q /var/www/liveagent/scripts/jobs.php" >> /etc/crontab
systemctl restart crond

#ELASTICSEARCH vm.max_map_count set for production minimum

echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144

#REDIS TCP backlog setting

echo 'vm.overcommit_memory=1' >> /etc/sysctl.conf
sysctl -w vm.overcommit_memory=1

#REDIS This will prevent latency and memory usage issues with Redis

echo never > /sys/kernel/mm/transparent_hugepage/enabled

echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
chmod +x /etc/rc.d/rc.local

clear

echo "Docker and Docker-compose successfully installed."
echo "GeoIP and ClamAV successfully installed."
echo "SELINUX disabled for rsync and ClamAV to work."
echo "Xinetd enabled and started for php-cron."
echo "Firewall is UP!"
