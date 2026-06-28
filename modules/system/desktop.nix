{ lib, pkgs, ... }:

let
  pipewireWithoutLibcamera =
    pipewire: libcamera:
    (pipewire.override {
      bluezSupport = false;
      ffadoSupport = false;
      rocSupport = false;
    }).overrideAttrs
      (old: {
        buildInputs = lib.remove libcamera (old.buildInputs or [ ]);
        mesonFlags = lib.filter (flag: !(lib.hasPrefix "-Dlibcamera=" flag)) (old.mesonFlags or [ ]) ++ [
          "-Dlibcamera=disabled"
        ];
      });
in

{
  nixpkgs.overlays = [
    (final: prev: {
      pipewire = pipewireWithoutLibcamera prev.pipewire prev.libcamera;
    })
  ];

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.dconf.enable = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;

  services.gnome.gnome-keyring.enable = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    package = pkgs.pipewire;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = false;
    wireplumber.enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

  environment.systemPackages = with pkgs; [
    celluloid
    evince
    file-roller
    fsearch
    gnome-screenshot
    gnome-tweaks
    gnomeExtensions.appindicator
    loupe
    mpv
    p7zip
    plocate
    slurp
    unrar
    unzip
    wl-clipboard
    xdg-user-dirs
    xdg-utils
  ];
}
