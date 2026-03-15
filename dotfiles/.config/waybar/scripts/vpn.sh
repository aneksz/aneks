#!/usr/bin/env bash

WG_DIR="/etc/wireguard"
DNS_BACKUP="$HOME/.vpn-dns-backup"
LAST_VPN_FILE="$HOME/.vpn-last"

# ----------------------
# Notification function
# ----------------------
notify_user() {
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
    notify-send "$1"
}

# ----------------------
# Backup/restore DNS
# ----------------------
backup_dns() {
    if [ ! -f "$DNS_BACKUP" ]; then
        grep -E "^(nameserver|search)" /etc/resolv.conf > "$DNS_BACKUP"
    fi
}

restore_dns() {
    if [ -f "$DNS_BACKUP" ]; then
        sudo cp "$DNS_BACKUP" /etc/resolv.conf
        sudo resolvconf -u
    fi
}

# ----------------------
# Last-used VPN
# ----------------------
save_last_vpn() {
    echo "$1" > "$LAST_VPN_FILE"
}

load_last_vpn() {
    [ -f "$LAST_VPN_FILE" ] && cat "$LAST_VPN_FILE" || echo ""
}

# ----------------------
# Active WireGuard interfaces
# ----------------------
active_ifaces() {
    ls /sys/class/net | grep -E '^(ash|ber|hel|lis|prg)-[a-z0-9]+$'
}

# ----------------------
# Toggle VPN (left-click)
# ----------------------
toggle_vpn() {
    # Use last-used VPN as target iface
    iface=$(load_last_vpn)
    [ -z "$iface" ] && iface=$(basename $(ls $WG_DIR | head -n1) .conf)

    if ip link show "$iface" up &>/dev/null; then
        # Disconnect the interface
        sudo wg-quick down "$iface"

        # Restore DNS / routes
        sudo systemctl restart NetworkManager
        restore_routes
        notify_user "VPN disconnected"
    else
        # Connect the interface
        sudo wg-quick up "$iface"
        notify_user "VPN connected ($iface)"
    fi
}

# ----------------------
# Select VPN via Rofi (right-click)
# ----------------------
select_vpn() {
    configs=$(find "$WG_DIR" -maxdepth 1 -name "*.conf" -printf "%f\n" | sed 's/.conf//' | sort)
    theme="$HOME/.config/rofi/launchers/type-2/style-2.rasi"

    iface=$(printf "%s\n" "$configs" | rofi -dmenu -p "Select VPN" -theme "$theme")
    [ -z "$iface" ] && exit 0

    # Disconnect all active VPNs first
    ifaces=$(active_ifaces)
    [ -n "$ifaces" ] && while read -r iface_active; do
        sudo -n wg-quick down "$iface_active" >/dev/null 2>&1
    done <<< "$ifaces"

    backup_dns
    sudo -n wg-quick up "$iface" >/dev/null 2>&1
    save_last_vpn "$iface"
    notify_user "VPN connected ($iface)"
}

# ----------------------
# Status output for Waybar
# ----------------------
status() {
    ifaces=$(active_ifaces)
    if [ -n "$ifaces" ]; then
        iface=$(echo "$ifaces" | head -n1)
        echo "{\"text\": \"󰦝 $iface\", \"tooltip\": \"VPN connected ($iface)\", \"class\": \"connected pulse\"}"
    else
        echo '{"text": "󱦚 VPN", "tooltip": "VPN disconnected", "class": "disconnected"}'
    fi
}

# ----------------------
# Main
# ----------------------
case "$1" in
    toggle)
        toggle_vpn >/dev/null 2>&1
        ;;
    select)
        select_vpn >/dev/null 2>&1
        ;;
    *)
        status
        ;;
esac
