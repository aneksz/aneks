#!/bin/bash

iface="ash-b16"

# Helper to send notifications as the logged-in user
notify_user() {
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
    notify-send "$1"
}

# Restore default route if needed
restore_routes() {
    # Remove any VPN-specific rules
    sudo ip -4 rule del fwmark 51820 table 51820 2>/dev/null || true
    sudo ip -4 rule del table main suppress_prefixlength 0 2>/dev/null || true
    sudo ip -4 route flush table 51820 2>/dev/null || true

    # Restore default route
    default_iface=$(ip route | grep '^default' | awk '{print $5}' | head -n1)
    default_gw=$(ip route | grep '^default' | awk '{print $3}' | head -n1)
    sudo ip route add default via "$default_gw" dev "$default_iface" 2>/dev/null || true
}

# Toggle VPN
toggle_vpn() {
    if ip link show "$iface" up &>/dev/null; then
        # Disconnect VPN
        sudo wg-quick down "$iface"

        # Restore DNS via NetworkManager
        sudo systemctl restart NetworkManager

        restore_routes
        notify_user "VPN disconnected"
    else
        # Connect VPN
        sudo wg-quick up "$iface"
        notify_user "VPN connected"
    fi
}

# Handle Waybar click
if [ "$1" = "toggle" ]; then
    toggle_vpn
    exit 0
fi

# Waybar icon display
if ip link show "$iface" up &>/dev/null; then
    echo '{"text": "VPN 󰦝", "class": "connected"}'
else
    echo '{"text": "VPN 󱦚", "class": "disconnected"}'
fi
