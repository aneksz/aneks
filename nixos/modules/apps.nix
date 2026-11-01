{ config, pkgs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [          
    git
    gh
    kitty
    nwg-look
    
  ];
}
