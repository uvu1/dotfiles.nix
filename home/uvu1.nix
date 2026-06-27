{ inputs, ... }:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./cli.nix
    ./git.nix
    ./zsh.nix
    ./wezterm.nix
    ./nixvim
  ];

  home.username = "uvu1";
  home.homeDirectory = "/home/uvu1";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
