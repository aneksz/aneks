{ config, pkgs, ... }:

{
  programs.firefox.enable = true;
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    bat
    bibata-cursors
    cliamp
    fastfetch
    git
    gh
    irssi
    libreoffice
    kitty
    nautilus
    nwg-look
    ookla-speedtest
    pywalfox-native
    steam
    spicetify-cli
    thunderbird
    vesktop
    vscodium
    zsh-completions
    unzip
    nixos-bgrt-plymouth
    zapzap
  ];
}
