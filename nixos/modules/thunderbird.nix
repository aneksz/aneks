{ pkgs, ... }:

{
  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird.override {
      extraPrefs = builtins.readFile ./tooltip-fix.js;
    };
  };
}