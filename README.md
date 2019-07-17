# Setup Instructions

## Overview

1. Clone repo into /opt/vpnsetup

2. Run setup script `openvpn-server.sh` to install openvpn server

3. Create and setup server certs

4. Start Server

## Step by Step Instructions

### Server Setup and Software Installs

The following steps will create a new server and install the required software for running OpenVPN.

1. In your environment (e.g. AWS), create an Ubuntu 18.04 LTS server.  Use a key pair that you have access to.
   - **Note:** Open TCP/UDP 1194 (or whatever you use in server-tcp.conf and server-udp.conf) on your firewall

2. SSH into the server.

3. Gain root priviledges.

        sudo su

4. Make and access the new folder.

        mkdir /opt/vpnsetup
        cd /opt/vpnsetup

5. Obtain the OpenVPN server setup package.

        git clone https://github.com/grey-market-labs/openvpn-server.git

6. Execute the VPN setup script.

        cd openvpn-server
        ./openvpn-server.sh

7. Select YES each time you are prompted.

### OpenVPN Server Setup

The following steps will show you a quick way to configure the server with OpenVPN and a self-signed cert.  See also the following link for reference, more details, and more options for configuration: https://openvpn.net/community-resources/rsa-key-management/.

1. Access OpenVPN Easy-RSA Folder for access to scripts which allow you to build the keys

        cd /etc/openvpn/easy-rsa

2. Choose the openssl version you want and copy it to openssl.cnf

        cp openssl-1.0.0.cnf openssl.cnf
        . vars

3. Do initial clean (also sets up keys folder)

        ./clean-all

4. Build Certificate Authority and answer the questions. Hit enter to just use defaults for testing.

        ./build-ca

5. Build Diffie-Hellman Parameters

        ./build-dh

6. Build Server Certificate & Key with command below and answer the questions.  Hit enter to just use defaults for testing.  Answer y to sign the certificate and to commit.

        ./build-key-server server

7. Copy keys (dh2048.pem, server.key, server.crt, ca.crt) into /etc/openvpn 

        cp keys/ca.crt keys/server.key keys/server.crt keys/dh2048.pem ../

8. Put ca.key somewhere safe so no one can issue certs that your system(s) will trust.  Alternatively, you can create the CA somewhere safe and issue CSRs.

9. Grant read/write permissions on config files so that the service can properly access them

        cd ..
        chmod ugo+rw server-*.conf

10. Start TCP Service and wait a few seconds.  Note that you can substitute udp for tcp if running w/UDP; you can also run both simultaneously

        service openvpn@server-tcp start

11. Check the service status to see if it indicates that the openvpn was started and is active (running)

        service openvpn@server-tcp status

12. View Connections in `/etc/openvpn/openvpn-status-tcp.log` (or udp)

        cat /etc/openvpn/openvpn-status-tcp.log
        cat /etc/openvpn/openvpn-status-udp.log

13. Openvpn logs are recorded in `/var/log/syslog` To filter on openvpn use one of the following.  You check here for any initial errors as well after starting the service.

        cat /var/log/syslog | grep ovpn
        tail -f /var/log/syslog | grep ovpn

### OpenVPN Client Certificates

To connect an OpenVPN client to the OpenVPN server you will need a way to authenticate.  One way is to create a client certificate that the client can then use to connect.  The following steps detail this process.  It is assumed you are still logged into the server and running as root.

1. Go to the easy-rsa directory.

        cd /etc/openvpn/easy-rsa

2. Run build-key to generate the client certificate and key.

         ./build-key key

3. Copy the cert to the openvpn folder.

         cp keys/key.crt ../

4. Transfer the Client Cert (key.crt) and the Client Cert Key (key.key) files to your OpenVPN client.  Also, transfer the Server Certificate (ca.crt) from the previous section to the OpenVPN client.

### OpenVPN Client Setup & Configuration File

The exact steps for installing & setting up an OpenVPN Client are not provided here but will be similar to those for setting up the OpenVPN Server should you wish to create your own OpenVPN client.

For the OpenVPN client you will need to provide the following:

        Server Certificate (ca.crt)
        Client Certificate (key.crt)
        Client Certificate Key (key.key)
        OpenVPN Configuration File (openvpn.conf)

You can use the provided openvpn.conf file for your openvpn client configuration.  This provides a basic setup for connecting to your new OpenVPN server.  Read the comments in the configuration file to understand what the properties do.  Check the following settings and make the appropriate changes to connect to your Server.

1. If you are using UDP instead of TCP then comment out proto tcp and uncomment proto udp like shown below.  Otherwise, leave it alone.

         ;proto tcp
         proto udp

2. Provide the IP address of the VPN server that you setup.  Replace xxx.xxx.xxx.xxx with your IP.  If you modified the port for the server then also replace 1194 with your server's port.  Find the line below and make the changes.

         remote xxx.xxx.xxx.xxx 1194

3. Check that the certs generated in the previous sections have been placed in the correct location and that it corresponds to the settings shown below.  This will depend on your OpenVPN Client setup.

         ca /etc/openvpn/ca.crt
         cert /etc/openvpn/key.crt
         key /etc/openvpn/key.key