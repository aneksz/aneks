{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;

    # Removes Firefox's 0.5px tooltip hairline border, which gets clipped at
    # fractional scaling. userChrome.css can't reach the generated tooltip, so it
    # is loaded as an agent stylesheet via AutoConfig.
    autoConfig = ''
      try {
        const Cc = Components.classes, Ci = Components.interfaces;
        const sss = Cc["@mozilla.org/content/style-sheet-service;1"]
                      .getService(Ci.nsIStyleSheetService);
        const css = "tooltip { border: none !important; }";
        const uri = Cc["@mozilla.org/network/io-service;1"]
                      .getService(Ci.nsIIOService)
                      .newURI("data:text/css," + encodeURIComponent(css));
        if (!sss.sheetRegistered(uri, sss.AGENT_SHEET))
          sss.loadAndRegisterSheet(uri, sss.AGENT_SHEET);
      } catch (e) {}
    '';

    preferences = {
      # Hardware video decoding through VA-API (nvidia-vaapi-driver, see nvidia.nix)
      "media.ffmpeg.vaapi.enabled" = true;
      "media.hardware-video-decoding.force-enabled" = true;   # skip Firefox's Linux driver blocklist
      "media.rdd-process.enabled" = true;
      "media.utility-process.enabled" = true;

      # GPU rendering and zero-copy frames on Wayland
      "gfx.webrender.all" = true;
      "widget.dmabuf.force-enabled" = true;

      # The RTX 2060 can't decode AV1 in hardware; this makes YouTube use VP9 instead
      "media.av1.enabled" = false;
    };
  };

  systemd.user.services = {
    firefox = {
      serviceConfig = {
        BindPaths = "/run/opengl-driver/lib/dri";
      };
    };

    # Keeps ~/.mozilla/native-messaging-hosts/pywalfox.json pointed at the
    # active /nix/store path across system updates and garbage collection
    pywalfox-install = {
      description = "Register Pywalfox native messaging host";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.pywalfox-native}/bin/pywalfox install";
      };
    };
  };

  # Lets Firefox's video decoder process load the Nvidia VA-API driver
  environment.sessionVariables.MOZ_DISABLE_RDD_SANDBOX = "1";

  # FIX: Force the browser window and compositor to render natively on Wayland frames!
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
