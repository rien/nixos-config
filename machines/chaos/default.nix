{ lib, config, pkgs, custompkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets."media-key".file = ./chaos_key.age;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.firewall.allowedTCPPorts = [ 10999 20595 ];
  networking.firewall.allowedUDPPorts = [ 10999 20595 ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  programs.cdemu = {
    enable = true;
    gui = true;
  };

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "rien" ];
  system.activationScripts.users.supportsDryActivation = lib.mkForce false;


  programs.adb.enable = true;
  users.users.rien.extraGroups = [ "adbusers" "cdemu" ];
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  services.transmission = {
    enable = true;
    downloadDirPermissions = "775";
    settings = {
      download-dir = "/home/rien/Downloads/transmission/downloaded/";
      incomplete-dir = "/home/rien/Downloads/transmission/incomplete/";
      encryption = 2;
      rpc-url = "/";
      rpc-host-whitelist-enabled = false;
    };
  };

  custom = {
    sshd.enable = true;
    bash.enable = true;
    docker.enable = true;
    dwarffortress.enable = false;
    git.enable = true;
    gnupg.enable = true;
    graphical.enable = true;
    kitty.enable = true;
    neovim.enable = true;
    pass.enable = true;
    ssh.enable = true;
    zeroad.enable = true;
    mail.enable = true;
    #vpnc.enable = true;
    ugent-vpn.enable = true;
    tor.enable = true;
    intellij.enable = true;
    syncthing-client.enable = true;
    wireshark.enable = true;
    #vscode.enable = false;

    #minidlna = {
    #  enable = false;
    #  dirs = [ "/data/music/" "/mnt/media/transmission/complete/" ];
    #};

    mounts.ugent.enable = true;
    mounts.media = {
      enable = true;
      mountPoint = "/mnt/media";
      identityFile = "/run/agenix/media-key";
    };

    extraSystemPackages = with pkgs; [
      cntr
      ntfs3g
    ];

    extraHomePackages = with pkgs; let
      cura = stdenv.mkDerivation {
        name = "curaWrapped";
        nativeBuildInputs = [ glib wrapGAppsHook gtk3 ];
        buildCommand = ''
          gappsWrapperArgsHook

          makeWrapper ${pkgs.cura}/bin/cura $out/bin/cura \
            ''${gappsWrapperArgs[@]}
        '';

      };
    in [
      signal-desktop
      orca-c
      qsynth
      thunderbird
      retroarch
      lutris
      feh
      wesnoth
      inkscape
      texlive.combined.scheme-full
      pandoc
      beancount
      wine-staging
      android-studio
      weechat
      binutils
      python3Packages.binwalk
      citrix_workspace
      cura
      blender
      audacity
      discord
      ffmpeg-full
      firefox
      gimp
      imagemagick
      libqalculate
      lutris
      minecraft
      mpv
      mumble
      obs-studio
      okular
      protontricks
      qview
      qutebrowser
      remmina
      sent
      signal-desktop
      spotify-tui
      steam-run
      krita
      remarkable-mouse
      teams
      teeworlds
      youtube-dl
      zathura
      openttd
      zotero
      openscad
      obsidian
      #freecad
      ncspot
      colmap
      python3Packages.ds4drv
      godot
      termdown
      zoom-us
    ];

    wireless = {
      enable = true;
      device = "wlp114s0";
    };

    stateVersion = "21.03";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "chaos"; # Define your hostname.
  # Required for ZFS
  networking.hostId = "04cdf13e";

  #networking.interfaces.enp0s13f0u3u2 = {
  #  useDHCP = true;
  #  neededForBoot = false;
  #};

}

