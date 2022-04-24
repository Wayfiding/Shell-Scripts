#!/bin/bash


# Script for start a firewall in a linux server

#Declaração de variavéis
PATH=/sbin:/bin:/usr/bin:/usr/bin:
WAN=eth0
LAN=eth1

#Ativando Modulos
modprobe iptable_nat
modprobe ip_tables
modprobe ipt_REJECT
modprobe ipt_MASQUERADE
modprobe ipt_multiport

#Excluir todas as regras
iptables -t nat -F
iptables -t filter -F
iptables -t mangle -F

#Ativar roteamento de pacotes entre as interfaces

echo  1 > /proc/sys/net/ipv4/ip_forward



#Inserir redirecionamento de conexões

iptables -t nat -A PREROUTING -i $WAN -p tcp --dport 3389 -j DNAT --to 192.168.10.10
iptables -t nat -A PREROUTING -i $WAN -p tcp --dport 80 -j DNAT --to 192.168.10.1


#Liberar o input para interface loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#Permite o acesso ao firewall
iptables -A INPUT -p tcp --dport 22 -j ACCEPT


#Regras forward
#Libera trafego de pacotes internet para a rede externa na porta 25 SMTP
iptables -I FORWARD -o $WAN -p tcp --dport 25 -j ACCEPT
iptables -I FORWARD -o $WAN -p tcp --dport 110 -j ACCEPT
iptables -I FORWARD -o $WAN -p tcp --dport 21 -j ACCEPT

#Regras POSTROUTING

iptables -t nat -A POSTROUTING -o $WAN -j MASQUERADE

#PROXY transparent
iptables -t nat -A PREROUTING -s 10.9.8.5/255.255.255.0 -p tcp --dport 80 -j REDIRECT --to-port 3128


#
