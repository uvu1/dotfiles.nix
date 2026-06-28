{ pkgs, ... }:

{
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  home.packages = with pkgs; [
    discord-canary
    obsidian
  ];
}
