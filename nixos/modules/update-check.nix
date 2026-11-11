# modules/update-check.nix
# Background update check for the bar's update center.
#
#  nixos-update-check  (root, timer)  copies the flake, runs `nix flake update` on the copy,
#                                     builds the new system and saves an nvd diff.
#                                     Your repo and running system are never touched.
#  nixos-update-list   (user)         prints pending changes as "name<TAB>from<TAB>to".
#  nixos-update-apply  (user)         moves the repo's inputs to the checked versions and switches.
#
# Pending/applied is decided per input (by lastModified), so adding a new input to
# flake.nix, or updating with `u`, never makes old updates reappear.
{ config, pkgs, ... }:

let
  flakeDir = "/home/igor/Projects/aneks/nixos";
  state = "/var/lib/nixos-update-check";

  # Number of root inputs whose checked version is newer than the repo's.
  # Inputs since removed from flake.nix don't count.
  pendingJq = ''
    $s[0] as $s | $r[0] as $r
    | [ $s.nodes.root.inputs | to_entries[] | select(.value | type == "string")
        | .key as $name
        | select($r.nodes.root.inputs[$name] != null)
        | ($s.nodes[.value].locked.lastModified // 0) as $want
        | ($r.nodes[$r.nodes.root.inputs[$name] // ""].locked.lastModified // 0) as $have
        | select($want > $have) ]
    | length
  '';

  # Repo lock with every node from the checked lock copied over; inputs added since stay
  mergeJq = ''
    $s[0] as $s | $r[0] as $r
    | reduce ($s.nodes | keys[] | select(. != "root")) as $k
        ($r; if .nodes[$k] != null then .nodes[$k] = $s.nodes[$k] else . end)
  '';

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
    runtimeInputs = [ pkgs.coreutils pkgs.gnused pkgs.gawk pkgs.jq ];
    text = ''
      if [ ! -f "${state}/changes.txt" ] || [ ! -f "${state}/flake.lock" ]; then exit 0; fi

      pending=$(jq -n --slurpfile s "${state}/flake.lock" --slurpfile r "${flakeDir}/flake.lock" '${pendingJq}')
      if [ "$pending" = 0 ]; then exit 0; fi

      sed -nE \
        -e 's/^\[U.\][[:space:]]+#[0-9]+[[:space:]]+([^[:space:]]+)[[:space:]]+(.*) -> (.*)$/\1\t\2\t\3/p' \
        -e 's/^\[A.\][[:space:]]+#[0-9]+[[:space:]]+([^[:space:]]+)[[:space:]]+(.*)$/\1\t\t\2 (new)/p' \
        -e 's/^\[R.\][[:space:]]+#[0-9]+[[:space:]]+([^[:space:]]+)[[:space:]]+(.*)$/\1\t\2\tremoved/p' \
        "${state}/changes.txt" \
        | awk -F'\t' -v OFS='\t' '$1 !~ /^nixos-system-/ { for (i = 2; i <= 3; i++) { split($i, a, ", "); sub(/ x[0-9]+$/, "", a[1]); $i = a[1] } print }'
    '';
  };

  apply = pkgs.writeShellApplication {
    name = "nixos-update-apply";
    runtimeInputs = [ pkgs.coreutils pkgs.jq ];
    text = ''
      if [ ! -f "${state}/flake.lock" ]; then
        echo "No checked update yet - run: systemctl start nixos-update-check"
        exit 1
      fi

      backup=$(mktemp)
      cp "${flakeDir}/flake.lock" "$backup"

      # Move the repo's inputs to the checked (already built) versions, keep anything added since
      merged=$(mktemp)
      jq -n --slurpfile s "${state}/flake.lock" --slurpfile r "${flakeDir}/flake.lock" '${mergeJq}' > "$merged"
      cp "$merged" "${flakeDir}/flake.lock"
      rm -f "$merged"

      if ! /run/wrappers/bin/pkexec env PATH=/run/current-system/sw/bin \
           nixos-rebuild switch --flake "${flakeDir}#nixos"; then
        cp "$backup" "${flakeDir}/flake.lock"
        echo
        echo "Update failed - flake.lock restored, nothing was changed."
        exit 1
      fi
      rm -f "$backup"

      # Re-check against the new system so the bar's list starts fresh
      systemctl start --no-block nixos-update-check.service || true
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
  security.polkit.enablePkexecWrapper = true;
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
