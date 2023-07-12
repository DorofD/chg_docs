import pandas as pd

sheet = pd.read_excel('file.xlsx')

for i in range(len(sheet['ip_ap'])):

    script_template = f"""
# localAddress - адрес точки вида 172.16.100.2/28
# localGate - внутренний адрес роутера вида 172.16.100.1
# pswd - пароль точки
# ident - имя точки в формате 24_pidМагазина_AP или hAP_pidМагазина_AP в зависимости от устройства
#
#
:global localAddress value={sheet['ip_ap'][i]}
:global localGate value={sheet['ip_gw'][i]}
:global pswd value=qwerty-bc
:global ident value={sheet['ident'][i]}
    
# Change admin password
/user set admin password=$pswd;                    
# Create Bridge
/interface bridge
add name=Local
# CAPsMAN
/interface wireless cap set enabled=yes interfaces=wlan1 caps-man-addresses=192.168.14.3
# Set ip address
/ip address add address=$localAddress interface=Local
# Create default route
/ip route add check-gateway=ping distance=1 gateway=$localGate
# DNS
/ip dns set servers=192.168.8.224,192.168.14.237
#ADD ansible and awx users
/user add name=ansible address=192.168.0.0/19 password=password group=full
/user ssh-keys import public-key-file=key.pub user=ansible
/snmp set enabled=yes
# Set CAP id
/system identity set name=$ident
/interface bridge port
add bridge=Local interface=all
    """

    file = open(f"{sheet['ident'][i]}.rsc", 'w')
    file.write(script_template)
    file.close
