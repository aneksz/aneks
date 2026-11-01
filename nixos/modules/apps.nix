{ config, pkgs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [   
    bat       
    bibata-cursors
    pywalfox-native
    git
    gh
    kitty
    nautilus
    nwg-look
    spicetify-cli
    spotify
    vesktop
    vscodium
    
  ];
}
