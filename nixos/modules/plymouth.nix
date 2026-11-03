{ pkgs, inputs, ... }:
let
  theme = inputs.seamless-asahi-plymouth.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  boot = {
    plymouth = {
      enable = true;
      theme = "seamless-asahi";
      themePackages = [ theme ];
      extraConfig = ''
        DeviceScale=1
      '';
    };
    kernelParams = [ "quiet" "splash" ];
  };
}