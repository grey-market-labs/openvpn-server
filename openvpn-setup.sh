#!/bin/bash

VPN_ROOT=/opt/vpnsetup
GIT_ROOT=$VPN_ROOT/openvpn-server

echo "apt update"
sudo apt update

echo "Installing iptables-persistent..."
sudo apt install iptables-persistent -y

echo "Installing OpenVPN..."

sudo wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg|apt-key add -
sudo echo "deb http://build.openvpn.net/debian/openvpn/stable xenial main" > /etc/apt/sources.list.d/openvpn-aptrepo.list

sudo apt install openvpn -y

#TODO REMOVE SECTION ONCE CERTS ARE MANAGED OUTSIDE OF INDIVIDUAL SERVERS
echo "Installing EasyRSA..."
sudo apt install easy-rsa -y												
echo "Setting up easy-rsa configuration..."								
sudo mkdir /etc/openvpn/easy-rsa/											
sudo cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/						
##########################################################################

echo "setting up config files"
sudo cp $GIT_ROOT/server-udp.conf /etc/openvpn/
sudo cp $GIT_ROOT/server-tcp.conf /etc/openvpn/
sudo chmod +x openvpn-server-iptables.sh

echo "enabling ip forwarding"
sudo sed -i -e 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

echo "setting up routing"
cd $VPN_ROOT
$GIT_ROOT/openvpn-server-iptables.sh

echo "adding openvpn user"
sudo adduser --system --shell /usr/sbin/nologin --no-create-home openvpn_server

#echo "starting openvpn (skipped until deployed as an AMI)"
#cd /etc/openvpn
#sudo service openvpn@server-udp start
#sudo service openvpn@server-tcp start
