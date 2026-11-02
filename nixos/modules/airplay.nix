# modules/airplay.nix
# HomePods as PipeWire outputs via pw-airplay (AirPlay 2).
# Source lives in the repo at pw-airplay/ (daemon + OwnTone engine patch).
{ pkgs, lib, ... }:

let
  src = ../pkgs/pw-airplay;

  # AirPlay engine: OwnTone 29.3 with the pw-airplay patch, plus airptpd
  owntone-airplay = pkgs.stdenv.mkDerivation {
    pname = "owntone-pw-airplay";
    version = "29.3";

    src = pkgs.fetchFromGitHub {
      owner = "owntone";
      repo = "owntone-server";
      rev = "29.3";
      hash = "sha256-a7OpRQBzeOcZEINRxWvOlbmKCXFBtQTk9nMJAUkCqgM=";
    };

    patches = [ "${src}/engine/owntone-29.3.patch" ];

    nativeBuildInputs = with pkgs; [
      autoreconfHook
      pkg-config
      gperf
      bison
      flex
      gettext
    ];
    buildInputs = with pkgs; [
      zlib
      libconfuse
      curl
      libsodium
      libxml2
      sqlite
      libevent
      json_c
      libplist
      ffmpeg
      gnutls
      libwebsockets
      avahi
      alsa-lib
      libgcrypt
      libgpg-error
      libunistring
    ];
    configureFlags = [
      "--disable-chromecast"
      "--disable-spotify"
      "--disable-mpd"
      "--disable-install-systemd"
      "--enable-daemon" # passed on to src/libairptp: builds airptpd
    ];

    enableParallelBuilding = true;
  };

  # pw-airplayd: creates the PipeWire sinks and drives the engine
  pw-airplayd = pkgs.stdenv.mkDerivation {
    pname = "pw-airplayd";
    version = "local";
    inherit src;

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = with pkgs; [
      pipewire
      curl
      json_c
      avahi
      systemd
    ];

    makeFlags = [ "PREFIX=$(out)" ];
  };
in
{
  environment.systemPackages = [ pw-airplayd ];

  # Speakers are found over mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # PipeWire's own AirPlay 1 sinks would show the speakers twice
  services.pipewire.extraConfig.pipewire."50-pw-airplay-no-raop" = {
    "context.properties"."module.raop" = false;
  };

  # PTP clock the speakers sync to (needs UDP 319/320)
  systemd.services.airptpd = {
    description = "PTP clock for AirPlay 2 senders (airptpd)";
    wants = [ "network-online.target" ];
    after = [
      "network.target"
      "network-online.target"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${owntone-airplay}/sbin/airptpd -f";
      DynamicUser = true;
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
      NoNewPrivileges = true;
      Restart = "on-failure";
    };
  };

  systemd.user.services.pw-airplay-engine = {
    description = "AirPlay 2 engine for pw-airplay (OwnTone)";
    after = [ "network-online.target" ];
    partOf = [ "pw-airplay.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStartPre = "${pw-airplayd}/bin/pw-airplayd --write-engine-conf %h/.local/share/pw-airplay/owntone.conf";
      ExecStart = "${owntone-airplay}/sbin/owntone -f -c %h/.local/share/pw-airplay/owntone.conf";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  systemd.user.services.pw-airplay = {
    description = "AirPlay 2 output for PipeWire";
    requires = [ "pw-airplay-engine.service" ];
    wants = [ "pipewire.service" ];
    after = [
      "pipewire.service"
      "pipewire-pulse.service"
      "wireplumber.service"
      "pw-airplay-engine.service"
    ];
    wantedBy = [ "default.target" ];
    environment.PIPEWIRE_DEBUG = "2,default:3";
    serviceConfig = {
      ExecStart = "${pw-airplayd}/bin/pw-airplayd";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  # Same as the old ufw rule: let the local network in (PTP, DACP, AirPlay control)
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -s 192.168.86.0/24 -j nixos-fw-accept
  '';
}
