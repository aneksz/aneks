{ config, pkgs, ... }:

{
  # ---------- Audio  ----------

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true; # pactl, and apps that expect PulseAudio
    wireplumber.enable = true; # wpctl
  };

  # ---------- Desktop services your bar uses ----------

  hardware.bluetooth.enable = true; # Bluetooth panel
  services.upower.enable = true; # battery info
  security.polkit.enable = true; # the bar's own password prompt (pkexec)
  services.gnome.gnome-keyring.enable = true;
  hardware.i2c.enable = true; # monitor panel (ddcutil); adds the i2c group
  programs.dconf.enable = true;
  services.flatpak.enable = true;

  # File-picker / screenshot portals (Hyprland's own comes with programs.hyprland)
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Logitech receivers: installs solaar plus the device permissions it needs
  hardware.logitech.wireless.enable = true;
  programs.solaar.enable = true;

  services.gvfs.enable = true; # Trash, network shares in Nautilus
  services.udisks2.enable = true; # USB drive mounting (Nautilus sidebar)

  # gsettings
  environment.sessionVariables.GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";

  # quickshell graphics
  environment.sessionVariables.QML_IMPORT_PATH = "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}";

  # ---------- Data drive (wallpapers live here) ----------
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/320EF8150EF7CFB9";
    fsType = "ntfs3";
    options = [
      "nofail"
      "nosuid"
      "nodev"
      "uid=1000"
      "gid=100"
      "iocharset=utf8"
    ];
  };

  # ---------- Packages ----------
  environment.systemPackages = with pkgs; [
    # Bar and the Qt modules it imports
    quickshell
    qt6.qt5compat # Qt5Compat.GraphicalEffects (blur/colour effects)
    qt6.qtwayland
    qt6.qtsvg
    qt6.qtimageformats
    qt6Packages.qt6ct
    glib
    gsettings-desktop-schemas
    gnome-themes-extra
    lm_sensors

    # GTK themes
    gnome-themes-extra # Adwaita-dark
    magnetic-catppuccin-gtk # Fausto's Catppuccin (was catppuccin-gtk-theme-mocha)
    dracula-theme
    tokyonight-gtk-theme
    everforest-gtk-theme
    gruvbox-gtk-theme
    materia-theme

    # Icons
    adwaita-icon-theme
    yaru-theme
    tela-icon-theme
    tela-circle-icon-theme
    reversal-icon-theme
    nordzy-icon-theme
    gruvbox-plus-icons
    papirus-icon-theme

    # Hyprland helpers from your autostart and binds
    hypridle
    hyprlock
    hyprsunset
    hyprshot
    hyprpolkitagent
    awww # wallpapers (formerly swww; use swww if awww isn't found)
    cliphist
    wl-clipboard
    grim
    slurp
    satty

    # Things your scripts and bar call
    playerctl
    libnotify
    jq
    socat
    curl
    imagemagick
    cava
    ddcutil
    pamixer
    networkmanagerapplet # nmcli comes with NetworkManager itself
    btop
    stow
  ];
}
