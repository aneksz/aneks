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
    # quieter boot so the splash isn't covered by console text
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [ "quiet" "splash" ];
  };
}