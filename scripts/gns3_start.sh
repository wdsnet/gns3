#!/bin/sh
brctl addbr virbr0
ip link set dev virbr0 up
ip ad add 192.168.122.1/24 dev virbr0
tunctl -t virbr0-nic
brctl addif virbr0 virbr0-nic
brctl stp virbr0 yes
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
dnsmasq -i virbr0 -z -h --dhcp-range=192.168.122.10,192.168.122.250,4h
echo " Starting  SSH daemon ..."
/usr/sbin/sshd -D -e -f /etc/ssh/sshd_config & 
cd /home/gns3/.ssh 
ssh-keygen -b 2048 -t rsa -f id_rsa -P '' -C 'GNS3 ssh key' 
cp id_rsa.pub authorized_keys
chmod 700 *;chown gns3:gns3 *
echo "---------------------------------------------------------------"
echo " Please use this key bellow for SSH connection: "

echo `cat /home/gns3/.ssh/id_rsa`

echo "---------------------------------------------------------------"
echo "Starting GNS3 Server  ... "
gns3server -A --config /etc/gns3_server.conf
