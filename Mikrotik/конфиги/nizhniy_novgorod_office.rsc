# jul/11/2023 18:59:42 by RouterOS 6.47.10
#
# model = RB750Gr3
/interface bridge
add name=Local
/interface ethernet
set [ find default-name=ether1 ] name=WAN1
set [ find default-name=ether2 ] name=WAN2
/interface pppoe-client
add add-default-route=yes dial-on-demand=yes disabled=no interface=WAN1 \
    keepalive-timeout=disabled name=pppoe-out1 password=password user=\
    user_name
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip hotspot profile
set [ find default=yes ] html-directory=flash/hotspot
/ip ipsec profile
add dh-group=modp1024 dpd-interval=20s dpd-maximum-failures=3 enc-algorithm=\
    des lifetime=8h name=bc
/ip ipsec peer
add address=1.1.1.1 name=peer1 profile=bc
/ip ipsec proposal
add enc-algorithms=des lifetime=8h name=bc pfs-group=none
/ip pool
add name=dhcp_pool0 ranges=172.16.254.10-172.16.254.254
/ip dhcp-server
add address-pool=dhcp_pool0 disabled=no interface=Local lease-time=10h10m \
    name=dhcp1
/interface bridge port
add bridge=Local interface=ether3
add bridge=Local interface=ether4
add bridge=Local interface=ether5
/ip address
add address=172.16.254.1/24 interface=Local network=172.16.254.0
add address=2.2.2.2/24 interface=WAN2 network=2.2.2.0
/ip dhcp-server network
add address=172.16.254.0/24 dns-server=192.168.14.237,192.168.8.224 gateway=\
    172.16.254.1
/ip dns
set servers=8.8.8.8
/ip firewall mangle
add action=mark-connection chain=input comment="Mark connection WAN1" \
    in-interface=pppoe-out1 new-connection-mark=WAN1_conn passthrough=yes
add action=mark-connection chain=input comment="Mark connection WAN2" \
    in-interface=WAN2 new-connection-mark=WAN2_conn passthrough=yes
add action=mark-routing chain=output comment="Mark routing WAN1" \
    connection-mark=WAN1_conn new-routing-mark=to_WAN1 passthrough=no
add action=mark-routing chain=output comment="Mark routing WAN2" \
    connection-mark=WAN2_conn new-routing-mark=to_WAN2 passthrough=no
add action=change-mss chain=forward dst-address=192.168.0.0/19 new-mss=1320 \
    passthrough=yes protocol=tcp src-address=172.16.254.0/24 tcp-flags=syn \
    tcp-mss=!0-1350
/ip firewall nat
add action=masquerade chain=srcnat ipsec-policy=out,none out-interface=\
    pppoe-out1 to-addresses=1.1.1.1
add action=src-nat chain=srcnat ipsec-policy=out,none out-interface=WAN2 \
    to-addresses=2.2.2.2
/ip ipsec identity
add peer=peer1 secret=preshared_key
/ip ipsec policy
add dst-address=192.168.0.0/19 peer=peer1 proposal=bc src-address=\
    172.16.254.0/24 tunnel=yes
/ip route
add distance=1 gateway=pppoe-out1 routing-mark=to_WAN1
add check-gateway=ping distance=1 gateway=2.2.2.3 routing-mark=to_WAN2
add check-gateway=ping distance=2 gateway=2.2.2.3
add check-gateway=ping disabled=yes distance=1 gateway=1.1.1.2
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www port=8088
set ssh address=192.168.0.0/19,172.16.0.0/16
set api disabled=yes
set winbox address=192.168.0.0/19,172.16.0.0/16
set api-ssl disabled=yes
/snmp
set enabled=yes
/system clock
set time-zone-name=Europe/Moscow
/system identity
set name=nizhniy_novgorod_office
