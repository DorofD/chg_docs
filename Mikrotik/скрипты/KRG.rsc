# jan/02/1970 00:21:12 by RouterOS 6.44.6
#
# model = 951Ui-2nD
/interface bridge
add name=Local
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n country=kazakhstan disabled=\
    no mode=ap-bridge name=wlan2 ssid=mt_wifi wireless-protocol=802.11 wps-mode=\
    disabled
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa-psk,wpa2-psk mode=\
    dynamic-keys supplicant-identity=MikroTik wpa-pre-shared-key=preshared_key \
    wpa2-pre-shared-key=preshared_key
/ip pool
add name=dhcp_pool0 ranges=10.0.0.2-10.0.0.254
/ip dhcp-server
add address-pool=dhcp_pool0 disabled=no interface=Local lease-time=10h10m name=dhcp1
/interface bridge port
add bridge=Local interface=ether2
add bridge=Local interface=ether3
add bridge=Local interface=ether4
add bridge=Local interface=ether5
add bridge=Local interface=wlan2
/ip address
add address=10.0.0.1/24 interface=Local network=10.0.0.0
/ip dhcp-client
add dhcp-options=hostname,clientid disabled=no interface=ether1
/ip dhcp-server network
add address=10.0.0.0/24 dns-server=192.168.8.224,192.168.14.237 gateway=10.0.0.1
/ip firewall nat
add action=masquerade chain=srcnat ipsec-policy=out,none out-interface=ether1
/ip traffic-flow set enabled=yes
/user set admin password=router_password
/system identity set name=krg_mt
