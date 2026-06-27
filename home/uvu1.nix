{ pkgs, ... }:

{
  home.username = "uvu1";
  home.homeDirectory = "/home/uvu1";

  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    bat
    eza
    fd
    fzf
    gh
    jq
    ripgrep
    yq-go
    zoxide
  ];

  programs.git.enable = true;

  programs.zsh = {
      enable = true;
      enableCompletion = true;

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };

  programs.staarship = {
      enable = true;
      enableZshIntegration = true;
    };

  programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };



  programs.home-manager.enable = true;
}
