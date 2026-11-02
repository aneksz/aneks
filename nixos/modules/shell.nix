{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    autosuggestions.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
    };
    interactiveShellInit = lib.mkAfter ''
      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
      source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
    '';
    promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    '';
  };

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  environment.systemPackages = with pkgs; [
    eza
    fzf
    bat
    fastfetch
    yazi
  ];
}
