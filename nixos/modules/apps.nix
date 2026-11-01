{ config, pkgs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    kitty
    git
    gh
    nwg-look
    
  ];
}
