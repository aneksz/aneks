{ config, pkgs, ... }:

{
  # Load the driver early so Plymouth can draw at full resolution
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  # Driver: open kernel modules, newest version matching the kernel
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # VA-API: hardware video decoding on the GPU (used by Firefox, VLC, mpv...)
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.nvidia-vaapi-driver pkgs.ffmpeg_7-full ];
  };

  # vainfo: check what the GPU can decode
  environment.systemPackages = [ pkgs.libva-utils ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";        # use the Nvidia VA-API driver
    NVD_BACKEND = "direct";              # nvidia-vaapi-driver talks to the GPU directly (Wayland)
    GBM_BACKEND = "nvidia-drm";          # recommended by Hyprland for Nvidia
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
  };
}