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
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "SF Pro Text" "SF Pro Display" "DejaVu Sans" ];
    serif     = [ "SF Pro Text" "DejaVu Serif" ];
    monospace = [ "JetBrainsMono Nerd Font" "DejaVu Sans Mono" ];
    emoji     = [ "Noto Color Emoji" ];
  };
}