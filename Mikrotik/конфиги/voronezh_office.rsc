# jul/11/2023 18:58:54 by RouterOS 6.48.6
#
# model = RB750Gr3
/interface bridge
add name=Local
/interface ethernet
set [ find default-name=ether1 ] name=\
    ether1-WAN
set [ find default-name=ether2 ] name=ether2-L2
set [ find default-name=ether3 ] name=\
    ether3-LAN
set [ find default-name=ether4 ] disabled=yes
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip ipsec profile
set [ find default=yes ] dh-group=modp1024 enc-algorithm=des
add dh-group=modp1024 dpd-interval=20s dpd-maximum-failures=3 enc-algorithm=\
    des lifetime=8h name=bc
/ip ipsec peer
add address=1.1.1.1 name=peer1 profile=bc
/ip ipsec proposal
set [ find default=yes ] enc-algorithms=des lifetime=1d30m pfs-group=none
add enc-algorithms=des lifetime=8h name=bc
/ip pool
add name=dhcp_pool0 ranges=172.16.255.30-172.16.255.253
/ip dhcp-server
add address-pool=dhcp_pool0 disabled=no interface=Local lease-time=1d10m \
    name=dhcp1
/interface bridge port
add bridge=Local interface=ether3-LAN
/ip address
add address=14.88.228.1/24 interface=ether1-WAN network=14.88.228.0
add address=2.2.2.2/24 interface=ether2-L2 network=2.2.2.0
add address=172.16.255.1/24 interface=Local network=172.16.255.0
/ip dhcp-server network
add address=172.16.255.0/24 dns-server=192.168.14.237 gateway=172.16.255.1
/ip dns
set servers=8.8.8.8
/ip firewall filter
add action=accept chain=forward comment="voip asterisk" dst-port=10000-20000 \
    protocol=udp src-address=192.168.6.2
add action=accept chain=forward dst-port="" out-interface=Local protocol=udp \
    src-port=10000-20000
/ip firewall nat
add action=src-nat chain=srcnat ipsec-policy=out,none out-interface=\
    ether1-WAN
/ip firewall service-port
set sip disabled=yes
/ip ipsec identity
add peer=peer1 secret=preshared_key
/ip ipsec policy
set 0 disabled=yes
add disabled=yes dst-address=192.168.0.0/19 peer=peer1 proposal=bc \
    src-address=172.16.255.0/24 tunnel=yes
/ip route
add distance=1 gateway=ether1-WAN
add distance=1 dst-address=10.0.0.0/19 gateway=10.8.5.1
add distance=1 dst-address=10.1.0.0/19 gateway=10.8.5.1
add distance=1 dst-address=10.9.5.0/24 gateway=10.8.5.1
add distance=1 dst-address=10.48.0.0/12 gateway=10.8.5.1
add comment=xmo distance=1 dst-address=10.180.0.0/16 gateway=10.8.5.1
add distance=1 dst-address=192.168.0.0/19 gateway=10.8.5.1
add distance=1 dst-address=192.168.100.0/24 gateway=10.8.5.1
add distance=1 dst-address=192.168.101.0/24 gateway=10.8.5.1
add distance=1 dst-address=192.168.103.0/24 gateway=10.8.5.1
add distance=1 dst-address=192.168.104.0/24 gateway=10.8.5.1
add distance=1 dst-address=192.168.200.0/24 gateway=10.8.5.1
add distance=1 dst-address=192.168.224.0/24 gateway=10.8.5.1
add distance=1 dst-address=192.168.225.0/24 gateway=10.8.5.1
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www address=192.168.0.0/19,172.16.255.0/24
set ssh address=192.168.0.0/19
set api address=192.168.0.0/19
set winbox address="192.168.0.0/19,172.16.255.0/24
set api-ssl address=192.168.0.0/19
/snmp
set enabled=yes
/system clock
set time-zone-name=Europe/Moscow
/system identity
set name=voronezh_office
/system package update
set channel=long-term
/tool graphing interface
add interface=ether1-WAN
add interface=ether2-L2
add interface=ether3-LAN
