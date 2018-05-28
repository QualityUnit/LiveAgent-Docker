#!/bin/bash
#
# iptables configuration script
#
# Flush all current rules from iptables
#
 iptables -F
#
# Allow SSH and HTTP/HTTPS connections
#
 iptables -A INPUT -p tcp --dport 80 -j ACCEPT
 iptables -A INPUT -p tcp --dport 443 -j ACCEPT
#
# Set default policies for INPUT, FORWARD and OUTPUT chains
#
 iptables -P INPUT DROP
 iptables -P FORWARD DROP
 iptables -P OUTPUT ACCEPT
#
# Set access for localhost/docker and internal network
#
 iptables -A INPUT -i lo -j ACCEPT
 iptables -A INPUT -i PRIVATE_IF_NAME -j ACCEPT
 iptables -A INPUT -i docker0 -j ACCEPT
 iptables -A FORWARD -i docker0 -j ACCEPT
 iptables -A FORWARD -o docker0 -j ACCEPT
 iptables -A INPUT -s 172.18.0.0/16 -j ACCEPT
#
# Accept packets belonging to established and related connections
#
 iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#
# Save settings
#
 /sbin/service iptables save
#
# List rules
#
 iptables -L -v
