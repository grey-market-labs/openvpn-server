#!/bin/bash


####FLUSH####
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i tun1 -o eth0 -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o tun1 -m state --state RELATED,ESTABLISHED -j ACCEPT


sudo bash -c "iptables-save > /etc/iptables/rules.v4"
