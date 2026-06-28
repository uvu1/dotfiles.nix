{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/desktop.nix
    ../../modules/system/flatpak.nix
    ../../modules/system/gaming.nix
    ../../modules/system/ime.nix
    ../../modules/system/onepassword.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nix-vm";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Tokyo";
  virtualisation.vmware.guest.enable = true;

  users.users.uvu1 = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "input"
      "networkmanager"
      "video"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05";
}
