{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wezterm
    jetbrains-mono
  ];

  home.file.".config/wezterm" = {
    source = ./wezterm;
    recursive = true;
  };
}
