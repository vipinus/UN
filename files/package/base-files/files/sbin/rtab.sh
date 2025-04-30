#!/bin/sh
file="/tmp/rtab.lock"
if [ ! -f "$file" ]; then
    touch /tmp/rtab.lock
    /etc/init.d/redsocks start
    ipset restore < /etc/ipsets
    iptables-nft -t nat -N REDSOCKS
    iptables-nft -t nat -A OUTPUT -p tcp --dport 22 -j RETURN
    iptables-nft -t nat -A OUTPUT -p tcp -j REDSOCKS
    iptables-nft -t nat -A REDSOCKS -m set ! --match-set redsocks_bypass dst -j RETURN
    iptables-nft -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 1081
    iptables-nft -t nat -A PREROUTING -p tcp -j REDSOCKS
    /etc/init.d/firewall restart
    rm /tmp/rtab.lock
fi
