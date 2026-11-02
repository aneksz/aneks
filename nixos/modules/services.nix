{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.liquidctl ];

  # AIO cooler lighting (was system/liquidctl.service on Arch)
  systemd.services.liquidctl = {
    description = "liquidctl configuration";
    after = [ "systemd-udev-settle.service" ];
    wants = [ "systemd-udev-settle.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = [
        "${pkgs.liquidctl}/bin/liquidctl initialize all"
        "${pkgs.liquidctl}/bin/liquidctl set ring color spectrum-wave"
        "${pkgs.liquidctl}/bin/liquidctl set logo color fixed a020f0"
      ];
    };
  };
}