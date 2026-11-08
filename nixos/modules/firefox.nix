{ ... }:

{
  programs.firefox = {
    enable = true;
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

  systemd.user.services.firefox = {
    serviceConfig = {
      BindPaths = "/run/opengl-driver/lib/dri";
    };
  };

  # Lets Firefox's video decoder process load the Nvidia VA-API driver
  environment.sessionVariables.MOZ_DISABLE_RDD_SANDBOX = "1";

  # FIX: Force the browser window and compositor to render natively on Wayland frames!
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
