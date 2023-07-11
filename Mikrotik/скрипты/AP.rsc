#
#Комментарий
#
#
# localAddress - адрес точки вида 172.16.100.2/28
# localGate - внутренний адрес роутера вида 172.16.100.1
# pswd - пароль точки
# ident - имя точки в формате 24_pidМагазина_AP 
#
#
:global shopVars {
    "localAddress"=172.16.100.2/27;
    "localGate"=172.16.100.1;
    "pswd"="router_password";
    "ident"="24_000_AP";
    }
# Change admin password
/user set admin password=($shopVars->"pswd");                    
# Create Bridge
/interface bridge
add name=Local
/interface bridge port
add bridge=Local interface=all
# CAPsMAN
/interface wireless cap set enabled=yes interfaces=wlan1 caps-man-addresses=192.168.14.3
# Set ip address
/ip address add address=($shopVars->"localAddress") interface=Local
# Create default route
/ip route add check-gateway=ping distance=1 gateway=($shopVars->"localGate")
# DNS
/ip dns set servers=192.168.8.224,192.168.14.237
# Set CAP id
/system identity set name=($shopVars->"ident")