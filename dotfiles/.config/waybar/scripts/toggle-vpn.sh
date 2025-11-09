#!/bin/bash

iface="ash-b16"
DNS_BACKUP="/home/igor/.vpn-dns-backup"

# Backup DNS once
if [ ! -f "$DNS_BACKUP" ]; then
    grep -E "^(nameserver|search)" /etc/resolv.conf > "$DNS_BACKUP"
fi

if ip link show "$iface" up &>/dev/null; then
    # Disconnect VPN
    wg-quick down "$iface"
    
    # Restore DNS
    cp "$DNS_BACKUP" /etc/resolv.conf
    resolvconf -u
    
    # Restore default route
    default_iface=$(ip route | grep '^default' | awk '{print $5}' | head -n1)
    default_gw=$(ip route | grep '^default' | awk '{print $3}' | head -n1)
    ip route add default via "$default_gw" dev "$default_iface" 2>/dev/null || true

    notify-send "VPN disconnected"
else
    # Pre-update DNS to allow VPN to connect
    resolvconf -u
    wg-quick up "$iface"
    notify-send "VPN connected"
fi
