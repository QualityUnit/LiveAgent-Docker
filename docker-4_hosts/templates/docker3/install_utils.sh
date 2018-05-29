#!/bin/bash

#SYSTEMD

sed -i "s/#LogLevel=info/LogLevel=notice/g" /etc/systemd/system.conf && systemctl daemon-reexec

#AWS CLI & YUM UPDATE

yum -y install wget unzip
yum update -y

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

#MYSQL-HAPROXY checker

cp ./conf/mysqlchk /etc/xinetd.d/mysqlchk && rm -rf ./conf/mysqlchk
chmod +x /etc/xinetd.d/mysqlchk
cp ./conf/hprx_mysql_check.sh /etc/hprx_mysql_check.sh && rm -rf ./conf/hprx_mysql_check.sh
chmod +x /etc/hprx_mysql_check.sh
echo "mysqlchk        3000/tcp" >> /etc/services

#MYSQL-BACKUP

mv /opt/docker2/conf/db_bck_check.sh BACKUP_PATH/db_bck_check.sh && chmod +x BACKUP_PATH/db_bck_check.sh
echo "#MYSQL" >> /etc/crontab
echo "0 BACKUP_RUN * * * root BACKUP_PATH/db_bck_check.sh" >> /etc/crontab
echo "0 4 * * * root find BACKUP_PATH/backup* -mtime +X_DAYS_OLDER -exec rm -f {} \;" >> /etc/crontab
echo "" >> /etc/crontab

#SELINUX disable

setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#ELASTICSEARCH vm.max_map_count set for production minimum

echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144

clear

echo "Docker and Docker-compose successfully installed."
echo "SELINUX disabled for ClamAV to work."
echo "Xinetd enabled and started for mysqlchk."
echo "Firewall is UP!"
