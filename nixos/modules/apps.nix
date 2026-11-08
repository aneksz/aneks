{ config, pkgs, ... }:

{

   # Firefox Hardware Preference Overrides
    programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
      "gfx.webrender.all" = true;
      "media.av1.enabled" = false; # Forces YouTube to use the VP9 stream your RTX 2060 understands
      "media.rdd-process.enabled" = true;
      "media.utility-process.enabled" = true;

      # --- ADD THESE THREE FORCING FLAGS ---
      "media.hardware-video-decoding.force-enabled" = true; # Forces Firefox to ignore its internal Linux blacklist
      "media.navigator.mediadatadecoder_vpx_enabled" = true; # Explicitly enables the hardware VP9 decoder engine
      "widget.dmabuf.force-enabled" = true;                  # Forces smooth memory sharing between your driver and Wayland
    };
  };

  # 2. Give Firefox's sandbox process direct permission to load external system drivers
  # This lets the browser read nvidia_drv_video.so out of the Nix store paths
    # Inside modules/apps.nix
  systemd.user.services.firefox = {
    # FIX: Change extraConfig to serviceConfig
    serviceConfig = {
      BindPaths = "/run/opengl-driver/lib/dri";
    };
  };



  # 2. Centralized session variables mapping for Hyprland + Nvidia VA-API
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    
    # Points Firefox to your hardware acceleration translation objects
    LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
  };


  programs.localsend.enable = true;
  programs.steam.enable = true;
  programs.starship.enable = true;
  programs.vlc.enable = true;
 

  programs.neovim = {
  enable = true;
};

# Lets Mason's downloaded language servers run
 programs.nix-ld.enable = true;


  environment.systemPackages = with pkgs; [
    bat
    bibata-cursors
    caffeine-ng
    cliamp
    curl
    fastfetch
    fd
    git
    gh
    gcc
    gnumake
    gpu-screen-recorder-gtk
    image-roll
    imv
    irssi
    kitty
    lazygit
    libreoffice
    nautilus
    nodejs
    nwg-look
    ookla-speedtest
    pywalfox-native
    python3
    ripgrep
    steam
    spicetify-cli
    thunderbird
    tree-sitter
    vesktop
    vscodium
    zsh-completions
    unzip
    nixos-bgrt-plymouth
    vm-curator
    wget
    zapzap
  ];
}
