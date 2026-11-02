# modules/update-check.nix
# Background update check for the bar's update center.
#
#  nixos-update-check  (root, timer)  copies the flake, runs `nix flake update` on the copy,
#                                     builds the new system and saves an nvd diff.
#                                     Your repo and running system are never touched.
#  nixos-update-list   (user)         prints pending changes as "name<TAB>from<TAB>to".
#  nixos-update-apply  (user)         copies the checked flake.lock into the repo and switches.
{ config, pkgs, ... }:

let
  flakeDir = "/home/igor/Projects/aneks/nixos";
  state = "/var/lib/nixos-update-check";

  check = pkgs.writeShellApplication {
    name = "nixos-update-check";
    runtimeInputs = [ config.nix.package pkgs.nvd pkgs.coreutils pkgs.diffutils ];
    text = ''
      work=$(mktemp -d)
      trap 'rm -rf "$work"' EXIT

      cp -r ${flakeDir}/. "$work/"
      rm -f "$work/result"
      nix flake update --flake "path:$work"

      # Same lock as last time and already built: nothing new upstream
      if cmp -s "$work/flake.lock" "${state}/flake.lock" && [ -e "${state}/result" ]; then
        date +%s > "${state}/checked"
        exit 0
      fi

      nix build "path:$work#nixosConfigurations.nixos.config.system.build.toplevel" \
        --out-link "${state}/result"
      nvd diff /run/current-system "${state}/result" > "${state}/changes.txt" || true
      cp "$work/flake.lock" "${state}/flake.lock"
      date +%s > "${state}/checked"
    '';
  };

  list = pkgs.writeShellApplication {
    name = "nixos-update-list";
    runtimeInputs = [ pkgs.coreutils pkgs.diffutils pkgs.gnused ];
    text = ''
      if [ ! -f "${state}/changes.txt" ] || [ ! -f "${state}/flake.lock" ]; then exit 0; fi
      # Already applied: the repo has the checked lock
      if cmp -s "${state}/flake.lock" "${flakeDir}/flake.lock"; then exit 0; fi
      sed -nE \
        -e 's/^\[U.\][[:space:]]+#[0-9]+[[:space:]]+([^[:space:]]+)[[:space:]]+(.*) -> (.*)$/\1\t\2\t\3/p' \
        -e 's/^\[A.\][[:space:]]+#[0-9]+[[:space:]]+([^[:space:]]+)[[:space:]]+(.*)$/\1\t\t\2 (new)/p' \
        -e 's/^\[R.\][[:space:]]+#[0-9]+[[:space:]]+([^[:space:]]+)[[:space:]]+(.*)$/\1\t\2\tremoved/p' \
        "${state}/changes.txt"
    '';
  };

  apply = pkgs.writeShellApplication {
    name = "nixos-update-apply";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      if [ ! -f "${state}/flake.lock" ]; then
        echo "No checked update yet - run: systemctl start nixos-update-check"
        exit 1
      fi
      cp "${state}/flake.lock" "${flakeDir}/flake.lock"
      sudo nixos-rebuild switch
    '';
  };
in
{
  environment.systemPackages = [ list apply pkgs.nvd ];

  systemd.services.nixos-update-check = {
    description = "Check for NixOS updates (build only, no switch)";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    environment.XDG_CACHE_HOME = "/var/cache/nixos-update-check";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${check}/bin/nixos-update-check";
      StateDirectory = "nixos-update-check";
      CacheDirectory = "nixos-update-check";
      Nice = 10;
      IOSchedulingClass = "idle";
    };
  };

  systemd.timers.nixos-update-check = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15min";
      OnUnitActiveSec = "6h";
      Persistent = true;
    };
  };

  # Let wheel users start the check from the bar without a password
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "nixos-update-check.service" &&
          action.lookup("verb") == "start" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
}
