#!/bin/sh
#-------------------------------------------------------------------------------------------------------#
sh cls.fw.sh
ipt="/usr/sbin/iptables"
eth="ens32"
#-------------------------------------------------------------------------------------------------------#
$ipt -P INPUT DROP
#---------# Negar todas as conexoes que estavam ativas antes de iniciarmos nosso firewall --------------#
$ipt -A INPUT -p tcp -m tcp ! --tcp-flags SYN,RST,ACK SYN -m state --state NEW -j DROP
#---------# Negar todos os pacotes que possuem estado INVALIDO #----------------------------------------#
$ipt -N drop_invalid 
$ipt -A INPUT -m state --state INVALID -j drop_invalid 
$ipt -A INPUT -p tcp -m tcp --sport 1:65535 --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j drop_invalid 
$ipt -A drop_invalid -j DROP
#---------# Limit de 1 segundo por ping na ICMP #-------------------------------------------------------#
$ipt -N hakaze_1
$ipt -A INPUT -p icmp -m limit --limit 1/s --limit-burst 1 -j hakaze_1
$ipt -A hakaze_1 -j ACCEPT
#---------# Bloqueio tambem qualquer tentativa de fazer Whois na minha maquina #------------------------#
$ipt -N hakaze_2
$ipt -A INPUT -p tcp -m tcp --dport 43 -j hakaze_2
$ipt -A hakaze_2 -j DROP
#---------# Regra anti xmas-scan + logs sobre tentativas desse tipo de scan #---------------------------#
$ipt -N hakaze_3
$ipt -A INPUT -p tcp -m tcp --tcp-flags ALL URG,PSH,FIN -j hakaze_3
$ipt -A hakaze_3 -j DROP
#---------# Bloquear tudo relacionado reinforce #-------------------------------------------------------#
$ipt -N hakaze_4
$ipt -A INPUT -p tcp -m tcp --tcp-flags ALL URG,ACK,PSH,RST,SYN,FIN -j hakaze_4
$ipt -A hakaze_4 -j DROP
#---------# Bloquear fragmentos de IP #-----------------------------------------------------------------#
$ipt -N hakaze_5
$ipt -A INPUT -p all -f -j hakaze_5
$ipt -A hakaze_5 -j DROP
#---------#  Impedir que fazer "Who" na sua maquina #---------------------------------------------------#
$ipt -N hakaze_6
$ipt -A INPUT -p udp -m udp --dport 513 -j hakaze_6
$ipt -A hakaze_6 -j DROP
#---------# Bloquear tracerout, e logar caso alguem tente #---------------------------------------------#
$ipt -N hakaze_7
$ipt -A INPUT -p udp -m udp --dport 33434:33524 -j hakaze_7
$ipt -A hakaze_7 -j DROP
#=========# LIBERANDO O NECESSARIO DE ENTRADA #=========================================================#
$ipt -A INPUT -i $eth -j ACCEPT
$ipt -A INPUT -i lo -j ACCEPT
$ipt -A INPUT -i lo -m state --state NEW  -j ACCEPT
$ipt -A INPUT  -m state --state ESTABLISHED,RELATED  -j ACCEPT
#-------------------------------------------------------------------------------------------------------#
$ipt -N hakaze_8
$ipt -A INPUT -i $eth -p tcp --dport 22 -j hakaze_8
$ipt -A hakaze_8 -j ACCEPT
#-------------------------------------------------------------------------------------------------------#
$ipt -L
exit 0