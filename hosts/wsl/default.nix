{ pkgs, ... }:

{
  wsl = {
    enable = true;
    defaultUser = "uvu1";
    useWindowsDriver = true;
    interop.register = true;
  };

  networking.hostName = "wsl";
  time.timeZone = "Asia/Tokyo";

  programs.zsh.enable = true;
  users.users.uvu1.shell = pkgs.zsh;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    gnupg
    unzip
    wget
  ];

  system.stateVersion = "26.05";
}
