/usr/sbin/iptables -F
/usr/sbin/iptables -X
/usr/sbin/iptables -t nat -F
/usr/sbin/iptables -t nat -X
/usr/sbin/iptables -t mangle -F
/usr/sbin/iptables -t mangle -X
/usr/sbin/iptables -P INPUT ACCEPT
/usr/sbin/iptables -P FORWARD ACCEPT
/usr/sbin/iptables -P OUTPUT ACCEPT

