# Для конфигурации необходимо установить следующие параметры:
#
# w1addr - адрес первого канала вида 1.1.1.2/30
# w1gate - шлюз первого канала вида 1.1.1.1
# w1srcnat - адрес первого канала вида 1.1.1.2
# w2addr - адрес второго канала вида 2.2.2.2/30
# w2gate - шлюз второго провайдера вида 2.2.2.1
# w2srcnat - адрес второго канала вида 2.2.2.2
# l1addr - локальный адрес роутера вида 172.16.100.1/28
# l1net - локальная подсеть вида 172.16.100.0/28
# secret - Preshared Key
# ident - название магазина
# pswd - пароль роутера
#
:global shopVars {
    "w1addr"=1.1.1.2/30;
    "w1gate"=1.1.1.1;
    "w1srcnat"=1.1.1.2;
    "w2addr"=2.2.2.2/30;
    "w2gate"=2.2.2.1;
    "w2srcnat"=2.2.2.2;
    "l1addr"=172.16.100.1/28;
    "l1net"=172.16.100.0/28;
    "bcnet"=192.168.0.0/19;
    "secret"="preshared_key";
    "pswd"="router_password";
    "ident"="shop_name";
    }                    
# Change admin password
/user set admin password=($shopVars->"pswd");
# Create Bridge
/interface bridge
add name=Local
/interface bridge port
add bridge=Local interface=ether3
add bridge=Local interface=ether4
add bridge=Local interface=ether5
# Rename ether interface
/interface ethernet
set [ find default-name=ether1 ] name=WAN1
set [ find default-name=ether2 ] name=WAN2
# Set ip address
/ip address add address=($shopVars->"l1addr") interface=Local
/ip address add address=($shopVars->"w1addr") interface=WAN1
/ip address add address=($shopVars->"w2addr") interface=WAN2
# Set DNS to mikrotik
/ip dns set servers=8.8.8.8
# Mark Connection
/ip firewall mangle add action=mark-connection chain=input comment="Mark connection WAN1" in-interface=WAN1 new-connection-mark=WAN1_conn passthrough=yes
/ip firewall mangle add action=mark-connection chain=input comment="Mark connection WAN2" in-interface=WAN2 new-connection-mark=WAN2_conn passthrough=yes
# Mark Routing
/ip firewall mangle add action=mark-routing chain=output comment="Mark routing WAN1" connection-mark=WAN1_conn new-routing-mark=to_WAN1 passthrough=no
/ip firewall mangle add action=mark-routing chain=output comment="Mark routing WAN2" connection-mark=WAN2_conn new-routing-mark=to_WAN2 passthrough=no
# Create routes for mark connection
/ip route add check-gateway=ping distance=1 gateway=($shopVars->"w1gate") routing-mark=to_WAN1
/ip route add check-gateway=ping distance=1 gateway=($shopVars->"w2gate") routing-mark=to_WAN2
# Create default routes
/ip route add check-gateway=ping distance=1 gateway=($shopVars->"w1gate")
/ip route add check-gateway=ping distance=2 gateway=($shopVars->"w2gate")
# Create IPsec
/ip ipsec proposal add name=bc auth-algorithms=sha1 enc-algorithms=des lifetime=28800 pfs-group=none
/ip ipsec profile add name=bc enc-algorithm=des nat-traversal=yes hash-algorithm=sha1 dh-group=modp1024 lifetime=28800 dpd-interval=20 dpd-maximum-failures=3
/ip ipsec peer add name=peer1 address=peer.domain.ru profile=bc
/ip ipsec policy add peer=peer1 src-address=($shopVars->"l1net") dst-address=($shopVars->"bcnet") tunnel=yes proposal=bc
/ip ipsec identity add peer=sh14 secret=($shopVars->"secret")
# Set Time zone
/system clock
set time-zone-name=Europe/Moscow
# Create NAT
/ip firewall nat add action=src-nat chain=srcnat out-interface=WAN1 to-addresses=($shopVars->"w1srcnat") ipsec-policy=out,none
/ip firewall nat add action=src-nat chain=srcnat out-interface=WAN2 to-addresses=($shopVars->"w2srcnat") ipsec-policy=out,none
# Change MSS
/ip firewall mangle add action=change-mss chain=forward dst-address=192.168.0.0/19 new-mss=1350 passthrough=yes protocol=tcp src-address=($shopVars->"l1net") tcp-flags=syn tcp-mss=!0-1350
# Access bc only
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www port=8088
/ip service set ssh address=192.168.0.0/19,172.16.0.0/16
/ip service set api disabled=yes
/ip service set winbox address=192.168.0.0/19,172.16.0.0/16
/ip service set api-ssl disabled=yes
# Set router id
/system identity set name=($shopVars->"ident")