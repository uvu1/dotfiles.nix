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

  programs.home-manager.enable = true;
}
