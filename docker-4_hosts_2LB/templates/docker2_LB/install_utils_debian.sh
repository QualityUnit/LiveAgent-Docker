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

# SYSTEMD configuration
configure_systemd() {
  sed -i "s/#LogLevel=info/LogLevel=notice/g" /etc/systemd/system.conf
  systemctl daemon-reexec
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


main() {
  configure_systemd
  install_packages wget unzip
  setup_firewall
  setup_docker
  setup_docker_compose

  clear

  echo "Docker and Docker Compose successfully installed."
  echo "Firewall is UP!"
}

main "$@"
