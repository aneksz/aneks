{ pkgs, inputs, ... }:

{
  programs.localsend.enable = true;
  programs.steam.enable = true;     # also installs Steam itself
  programs.vlc.enable = true;
  programs.neovim.enable = true;
  programs.openvpn3.enable = true;

  # Lets Mason's downloaded language servers (Neovim) run
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    # Apps
    caffeine-ng
    cliamp
    ghostty
    gpu-screen-recorder-gtk
    image-roll
    imv
    irssi
    kitty
    libreoffice
    nautilus
    nwg-look
    thunderbird
    vesktop
    vm-curator
    vscodium
    zapzap

    # Theming
    bibata-cursors
    pywalfox-native
    spicetify-cli

    # Command-line tools
    curl
    fd
    gh
    git
    lazygit
    ookla-speedtest
    ripgrep
    unzip
    wget
    wireguard-tools

    # Neovim / development
    gcc
    gnumake
    nodejs
    python3
    tree-sitter
  ];
}