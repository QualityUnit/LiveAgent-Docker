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

#INSTALL KEEPALIVED

yum install -y keepalived-1.3.5
\cp ./conf/keep* /etc/keepalived/keepalived.conf && rm -rf ./conf/keep*
###### keepalived will need manual config , enable and start will be commented
#systemctl start keepalived.service && systemctl enable keepalived.service

#INSTALL XINETD

yum -y install xinetd
systemctl enable xinetd.service && systemctl start xinetd.service

#SELINUX disable

setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

clear

echo "Docker and Docker-compose successfully installed."
echo "Keepalived successfully installed and started."
echo "SELINUX disabled."
echo "Xinetd enabled and started for mysqlchk and php-cron."
echo "Firewall is UP!"
