{ config, pkgs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    bat
    bibata-cursors
    fastfetch
    git
    gh
    irssi
    kitty
    nautilus
    nwg-look
    pywalfox-native
    spicetify-cli
    vesktop
    vscodium
    zsh-completions
    unzip

  ];
}
