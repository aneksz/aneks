{ config, pkgs, ... }:

{
  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.starship.enable = true;

  programs.neovim = {
  enable = true;
};

# Lets Mason's downloaded language servers run
 programs.nix-ld.enable = true;


  environment.systemPackages = with pkgs; [
    bat
    bibata-cursors
    cliamp
    curl
    fastfetch
    fd
    git
    gh
    gcc
    gnumake
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
    wget
    zapzap
  ];
}
