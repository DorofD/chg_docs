# jul/11/2023 18:58:08 by RouterOS 6.48.6
#
# model = CCR1009-7G-1C-1S+
/caps-man channel
add band=2ghz-b/g/n extension-channel=Ce frequency=2412,2437,2462 name=\
    channel1-6-11_2.4Ghz tx-power=17
add band=5ghz-a/n/ac name=channel2
/interface bridge
add name=bridge1-WiFi
add name=bridge2-WiFi
/interface ethernet
set [ find default-name=ether1 ] comment=14.3
set [ find default-name=ether2 ] comment=14.1
set [ find default-name=ether3 ] comment=GARS disabled=yes
/caps-man datapath
add bridge=bridge1-WiFi client-to-client-forwarding=yes name=\
    datapath1-forward-to-CAPsMAN
add bridge=bridge2-WiFi client-to-client-forwarding=yes name=datapath-TV
/caps-man security
add authentication-types=wpa2-psk encryption=aes-ccm,tkip group-encryption=\
    aes-ccm name=Secr-TSD passphrase=wifi_password1
add authentication-types=wpa2-psk encryption=aes-ccm,tkip group-encryption=\
    aes-ccm name=Secr-TV passphrase=wifi_password2
/caps-man configuration
add channel=channel1-6-11_2.4Ghz country=russia datapath=\
    datapath1-forward-to-CAPsMAN distance=indoors guard-interval=long \
    hw-protection-mode=cts-to-self keepalive-frames=enabled mode=ap \
    multicast-helper=default name=cfg_24_TSD rx-chains=0,1,2,3 security=\
    Secr-TSD ssid=TSD tx-chains=0,1,2,3
add channel=channel1-6-11_2.4Ghz country=russia3 datapath=\
    datapath1-forward-to-CAPsMAN distance=indoors guard-interval=long \
    hw-protection-mode=cts-to-self keepalive-frames=enabled mode=ap \
    multicast-helper=default name=cfg_hAP_TSD rx-chains=0,1,2,3 security=\
    Secr-TSD ssid=TSD tx-chains=0,1,2,3
add channel=channel1-6-11_2.4Ghz country=russia datapath=datapath-TV \
    distance=indoors guard-interval=long hw-protection-mode=cts-to-self \
    keepalive-frames=enabled mode=ap multicast-helper=default name=cfg_TV \
    rx-chains=0,1,2,3 security=Secr-TV ssid=DS tx-chains=0,1,2,3
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=dhcp_pool0 ranges=10.250.16.2-10.250.31.254
add name=dhcp_pool1 ranges=10.250.0.100-10.250.15.254
add name=dhcp_pool2 ranges=10.251.0.50-10.251.15.254
add name=dhcp_pool4 ranges=10.251.16.2-10.251.16.254
/ip dhcp-server
add address-pool=dhcp_pool2 disabled=no interface=bridge1-WiFi lease-time=\
    8h10m name=dhcp1
add address-pool=dhcp_pool4 disabled=no interface=bridge2-WiFi lease-time=\
    10h10m name=dhcp2
/snmp community
set [ find default=yes ] name=nkcsnmp
add addresses=::/0 name=public
/user group
set full policy="local,telnet,ssh,ftp,reboot,read,write,policy,test,winbox,pas\
    sword,web,sniff,sensitive,api,romon,dude,tikapp"
/caps-man manager
set enabled=yes
/caps-man provisioning
add action=create-dynamic-enabled hw-supported-modes=gn identity-regexp=24_ \
    master-configuration=cfg_24_TSD name-format=identity name-prefix=AP
add action=create-dynamic-enabled identity-regexp=hAP_ master-configuration=\
    cfg_hAP_TSD name-format=identity name-prefix=AP
add action=create-dynamic-enabled identity-regexp=TVap_ master-configuration=\
    cfg_TV name-format=identity name-prefix=AP
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/ip address
add address=10.251.0.1/20 interface=bridge1-WiFi network=10.251.0.0
add address=192.168.14.3/24 interface=ether1 network=192.168.14.0
add address=10.251.16.1/24 interface=bridge2-WiFi network=10.251.16.0
/ip dhcp-server network
add address=10.251.0.0/20 dns-server=192.168.14.237,192.168.8.224 gateway=\
    10.251.0.1
add address=10.251.16.0/24 dns-server=192.168.14.237,192.168.8.224 gateway=\
    10.251.16.1
/ip dns
set servers=192.168.14.237
/ip firewall mangle
add action=mark-connection chain=input comment="Mark connection Bridge2" \
    disabled=yes in-interface=bridge1-WiFi new-connection-mark=bridge2_conn \
    passthrough=yes
add action=mark-routing chain=prerouting comment="Mark routing Bridge2" \
    new-routing-mark=from_bridge2 passthrough=yes src-address=10.251.16.0/24
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1 src-address=\
    10.251.0.0/20 
add action=masquerade chain=srcnat out-interface=ether1 src-address=\
    10.251.16.0/24 
/ip route
add distance=1 gateway=192.168.14.1 routing-mark=from_bridge2
add distance=1 gateway=192.168.14.41
/snmp
set enabled=yes
/system clock
set time-zone-name=Europe/Moscow
/system identity
set name=CAPS14
/system package update
set channel=long-term
/tool graphing interface
add
/tool sniffer
set file-limit=10000KiB file-name=test filter-interface=all
