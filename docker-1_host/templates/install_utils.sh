#!/bin/bash

set -euo pipefail

LOGFILE="/var/log/setup_script.log"
exec &> >(tee -a "$LOGFILE")

# Check for Debian 11
if [[ "$(lsb_release -is)" != "Debian" ]] || [[ "$(lsb_release -rs)" != "11" ]]; then
  echo "This script is intended for Debian 11 systems only."
  exit 1
fi

# Function to handle errors
error_exit() {
  echo "$1" 1>&2
  exit 1
}

# Function to update APT and install packages quietly (only show errors)
install_packages() {
  apt-get update -qq
  apt-get install -qq -y --no-install-recommends "$@" || error_exit "Failed to install packages: $*"
}

# Function to temporarily enable contrib repo and install geoipupdate and geoip-database
install_geoip() {
  echo "deb http://deb.debian.org/debian/ bullseye contrib" > /etc/apt/sources.list.d/temp-contrib.list
  apt-get update -qq
  install_packages geoipupdate geoip-database
  rm /etc/apt/sources.list.d/temp-contrib.list
  apt-get update -qq
}

# SYSTEMD configuration
configure_systemd() {
  sed -i "s/#LogLevel=info/LogLevel=notice/g" /etc/systemd/system.conf
  systemctl daemon-reexec
}

# GEOIP setup
setup_geoip() {
  install_geoip
  mkdir -p /etc/geoip  # Ensure the directory exists
  cp ./conf/GeoIP.conf /etc/GeoIP.conf
  if ! grep -q GEOIP /etc/crontab; then
    echo "#GEOIP" >> /etc/crontab
    echo "44 2 * * 6 root /usr/bin/geoipupdate -d /etc/geoip/ > /dev/null" >> /etc/crontab
    echo "" >> /etc/crontab
  fi
  echo "Updating GeoIP DB"
  /usr/bin/geoipupdate -d /etc/geoip/ > /dev/null || error_exit "Failed to update GeoIP"
}

# CLAMAV setup
setup_clamav() {
  install_packages clamav clamav-daemon
  systemctl stop clamav-freshclam
  cp ./conf/freshclam.conf /etc/clamav/freshclam.conf
  freshclam || error_exit "Failed to update ClamAV"
  systemctl start clamav-daemon
  systemctl enable clamav-daemon
  if ! grep -q CLAMD /etc/crontab; then
    echo "#CLAMD" >> /etc/crontab
    echo "25 3 * * * root /usr/bin/freshclam" >> /etc/crontab
    echo "0 5 * * * root systemctl restart clamav-daemon" >> /etc/crontab
    echo "" >> /etc/crontab
  fi
}

# FIREWALL setup
setup_firewall() {
  install_packages iptables iptables-persistent
  chmod +x ./conf/iptables.sh
  ./conf/iptables.sh || error_exit "Failed to apply iptables rules"
}

# Docker setup
setup_docker() {
  install_packages apt-transport-https ca-certificates curl gnupg lsb-release
  if [ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmour -o /usr/share/keyrings/docker-archive-keyring.gpg
  fi
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
  apt-get update -qq
  DOCKER_VERSION="5:26.1.4-1~debian.11~bullseye"
  install_packages docker-ce=${DOCKER_VERSION} docker-ce-cli=${DOCKER_VERSION} containerd.io
  apt-mark hold docker-ce docker-ce-cli containerd.io
  systemctl start docker
  systemctl enable docker
}

# Docker Compose setup
setup_docker_compose() {
  install_packages docker-compose
}

# PHP script setup
setup_php_cron() {
  if ! grep -q PHP /etc/crontab; then
    echo "#PHP" >> /etc/crontab
    echo "*/1 * * * * root docker exec -i apache-fpm /usr/bin/php -q /var/www/liveagent/scripts/jobs.php" >> /etc/crontab
  fi
  systemctl restart cron
}

# Elasticsearch configuration
setup_elasticsearch() {
  echo "vm.max_map_count=262144" >> /etc/sysctl.conf
  sysctl -w vm.max_map_count=262144
}

# Redis configuration
setup_redis() {
  echo 'vm.overcommit_memory=1' >> /etc/sysctl.conf
  sysctl -w vm.overcommit_memory=1
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
  echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
  chmod +x /etc/rc.local
}

main() {
  configure_systemd
  install_packages wget unzip
  setup_geoip
  setup_clamav
  setup_firewall
  setup_docker
  setup_docker_compose
  setup_php_cron
  setup_elasticsearch
  setup_redis

  clear

  echo "Docker and Docker Compose successfully installed."
  echo "GeoIP and ClamAV successfully installed and started."
  echo "Firewall is UP!"
}

main "$@"
