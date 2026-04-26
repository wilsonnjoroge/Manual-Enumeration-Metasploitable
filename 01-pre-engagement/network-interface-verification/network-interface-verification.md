1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 xxxxxxxxx scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether xx:xx:xx:xx:xx:xx brd xx:xx:xx:xx:xx:xx
    inet 192.168.x.x/24 brd 192.168.x.x scope global eth0
    inet6 xxxxxxxxxxxx/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether xx:xx:xx:xx:xx:xx brd xx:xx:xx:xx:xx:xx
