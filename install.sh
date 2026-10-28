#!/usr/bin/env bash
# Fresh Arch bootstrap for aneksz/aneks
#   git clone https://github.com/aneksz/aneks ~/aneks && cd ~/aneks && ./install.sh
# Run as your normal user (not root). Safe to re-run.
set -uo pipefail
mkdir -p "$HOME/.config"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG="$DIR/packages"
FAILED=()

msg()  { printf '\n\e[1;34m==>\e[0m \e[1m%s\e[0m\n' "$*"; }
warn() { printf '\e[1;33m  ->\e[0m %s\n' "$*"; }

[[ $EUID -eq 0 ]] && { echo "Run as your normal user, not root."; exit 1; }

# Strip comments, blank lines and -debug packages (those can't be installed directly)
read_list() { grep -vE '^\s*(#|$)' "$1" | grep -v -- '-debug$' | sort -u; }

# Keep sudo alive for the whole run so long AUR builds don't stall on a password prompt
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ---------------------------------------------------------------------------
msg "Updating system"
sudo pacman -Syu --noconfirm

# ---------------------------------------------------------------------------
msg "Installing official repo packages"
# A single unknown name aborts the whole pacman transaction, so check first
mapfile -t want  < <(read_list "$PKG/pkglist-repo.txt")
mapfile -t avail < <(pacman -Slq | sort -u)
mapfile -t ok      < <(comm -12 <(printf '%s\n' "${want[@]}") <(printf '%s\n' "${avail[@]}"))
mapfile -t missing < <(comm -23 <(printf '%s\n' "${want[@]}") <(printf '%s\n' "${avail[@]}"))

for p in "${missing[@]}"; do warn "not in repos (renamed/moved to AUR?): $p"; FAILED+=("repo:$p"); done
sudo pacman -S --needed --noconfirm "${ok[@]}"

# ---------------------------------------------------------------------------
msg "Installing yay"
if ! command -v yay &>/dev/null; then
    tmp="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi

# ---------------------------------------------------------------------------
msg "Installing AUR packages"
mapfile -t aur < <(read_list "$PKG/pkglist-aur.txt" | grep -vxE 'yay|yay-bin')
# Try them all at once; if anything fails, go one by one so one bad build
# doesn't block the rest
if ! yay -S --needed --noconfirm --answerdiff None --answerclean None "${aur[@]}"; then
    warn "batch install failed, retrying individually"
    for p in "${aur[@]}"; do
        pacman -Q "$p" &>/dev/null && continue
        yay -S --needed --noconfirm --answerdiff None --answerclean None "$p" \
            || { warn "failed: $p"; FAILED+=("aur:$p"); }
    done
fi

# ---------------------------------------------------------------------------
if [[ -s "$PKG/pkglist-flatpak.txt" ]]; then
    msg "Installing Flatpaks"
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    while read -r app; do
        flatpak install -y --noninteractive flathub "$app" \
            || { warn "failed: $app"; FAILED+=("flatpak:$app"); }
    done < <(read_list "$PKG/pkglist-flatpak.txt")
fi

# ---------------------------------------------------------------------------
msg "Enabling services"
# Custom unit files kept in the repo (e.g. system/liquidctl.service) go in first
if compgen -G "$DIR/system/*.service" >/dev/null; then
    sudo install -Dm644 -t /etc/systemd/system "$DIR"/system/*.service
    sudo systemctl daemon-reload
fi

SERVICES=(
    NetworkManager        # also pulls in -dispatcher and -wait-online
    bluetooth
    liquidctl             # custom unit, from system/ above
    virtqemud.socket      # libvirt for QEMU VMs (the -ro/-admin sockets come along)
    virtnetworkd.socket
    virtstoraged.socket
    avahi-daemon          # mDNS, needed to find the HomePods
    systemd-resolved
    systemd-timesyncd
    auto-cpufreq
    grub-btrfsd
    ufw
    # Media stack: drop these once it lives on the media server
    plexmediaserver
    jellyfin
    radarr
    sonarr
)
for svc in "${SERVICES[@]}"; do
    sudo systemctl enable --now "$svc" 2>/dev/null || { warn "couldn't enable $svc"; FAILED+=("service:$svc"); }
done

# systemd-resolved only takes over DNS once resolv.conf points at its stub
sudo ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Firewall: deny incoming, allow outgoing, allow the LAN (HomePods/AirPlay)
sudo ufw default deny incoming  >/dev/null
sudo ufw default allow outgoing >/dev/null
sudo ufw allow from 192.168.86.0/24 >/dev/null
sudo ufw --force enable >/dev/null

# User services. pipewire, wireplumber, gnome-keyring and xdg-user-dirs enable
# themselves when installed, ydotool doesn't.
systemctl --user enable ydotool 2>/dev/null || warn "couldn't enable ydotool (user)"

# Not covered by the package lists: pw-airplay (and its airptpd service) is
# built from source in ~/build/pw-airplay. Rebuild it after this script, then:
#   systemctl --user enable pw-airplay pw-airplay-engine && sudo systemctl enable airptpd

# ---------------------------------------------------------------------------
msg "Linking dotfiles"
# stow mirrors dotfiles/ into $HOME, so dotfiles/.config/hypr -> ~/.config/hypr.
# Anything already there (e.g. default configs from first launch) is moved aside first.
sudo pacman -S --needed --noconfirm stow
backup="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
while IFS= read -r -d '' src; do
    rel="${src#"$DIR/dotfiles/"}"
    dest="$HOME/$rel"
    if [[ -e "$dest" && ! -L "$dest" ]]; then
        mkdir -p "$backup/$(dirname "$rel")"
        mv "$dest" "$backup/$rel"
        warn "backed up existing $rel"
    fi
done < <(find "$DIR/dotfiles/.config" -mindepth 1 -maxdepth 1 -print0)
stow -d "$DIR" -t "$HOME" --restow dotfiles && echo "  dotfiles linked"
[[ -d "$backup" ]] && warn "old configs saved in $backup"

# ---------------------------------------------------------------------------
msg "Shell"
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
    chsh -s "$(command -v zsh)" && echo "  default shell set to zsh"
fi

# ---------------------------------------------------------------------------
msg "Done"
if ((${#FAILED[@]})); then
    warn "These didn't install, check them by hand:"
    printf '     %s\n' "${FAILED[@]}"
else
    echo "  Everything installed."
fi
echo "  Reboot to load the Nvidia driver and start Hyprland."
