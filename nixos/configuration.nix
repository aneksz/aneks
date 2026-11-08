{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/apps.nix
    ./modules/firefox.nix
    ./modules/fonts.nix
    ./modules/desktop.nix
    ./modules/nvidia.nix
    ./modules/shell.nix
    ./modules/airplay.nix
    ./modules/services.nix
    ./modules/update-check.nix
    ./modules/plymouth.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Boot: latest kernel, quiet boot behind the splash
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" "splash" "udev.log_priority=3" "rd.systemd.show_status=auto" ];

  # GRUB with a theme (installed as the removable fallback so the firmware always finds it)
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
    configurationLimit = 5;
    gfxmodeEfi = "1280x720";
    theme = pkgs.catppuccin-grub;
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Australia/Melbourne";
  i18n.defaultLocale = "en_AU.UTF-8";

  users.users.igor = {
    isNormalUser = true;
    description = "igor";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
  };

  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Never change this, even after updates (see `man configuration.nix`)
  system.stateVersion = "26.05";
}