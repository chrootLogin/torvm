#!/usr/bin/env bash

# the UID Tor runs as
TOR_UID=$(id -u debian-tor)

# Tor's TransPort
TRANS_PORT="9040"

iptables -F
iptables -t nat -F

iptables -P INPUT ACCEPT
iptables -P OUTPUT DROP

iptables -A OUTPUT -d 127.0.0.1/8 -j ACCEPT

iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m owner --uid-owner $TOR_UID -j ACCEPT

iptables -t nat -A OUTPUT -m owner --uid-owner $TOR_UID -j RETURN
iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $TRANS_PORT

iptables -A OUTPUT -j REJECT
