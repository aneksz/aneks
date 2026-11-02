{ config, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-mono
    material-symbols
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    dm-mono
  ];
  fonts.fontconfig.hinting.style = "slight";
  fonts.fontconfig.subpixel.rgba = "none";
}
