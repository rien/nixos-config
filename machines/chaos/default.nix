{ lib, config, pkgs, custompkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets = {
    "media-key".file = ./chaos_key.age;
    "vpn-conf".file = ./vpn-conf.age;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.firewall.allowedTCPPorts = [ 10999 20595 8000 ];
  networking.firewall.allowedUDPPorts = [ 10999 20595 8000 ];

  services.openvpn.servers = {
    bagofholding = { config = ''config /run/agenix/vpn-conf''; };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  programs.cdemu = {
    enable = true;
    gui = true;
  };

  programs.nix-ld.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.waydroid.enable = true;
  users.extraGroups.vboxusers.members = [ "rien" ];
  system.activationScripts.users.supportsDryActivation = lib.mkForce false;


  programs.adb.enable = true;
  users.users.rien.extraGroups = [ "adbusers" "cdemu" ];
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  services.ollama.enable = true;

  custom = {
    sshd.enable = true;
    bash.enable = true;
    docker.enable = true;
    dwarffortress.enable = false;
    git.enable = true;
    gnupg.enable = true;
    sound.enable = true;
    graphical.plasma.enable = true;
    kitty.enable = true;
    neovim.enable = true;
    pass.enable = true;
    ssh.enable = true;
    mail = {
      enable = true;
      thunderbird = true;
      protonbridge = {
        enable = true;
        certificate = builtins.readFile ./bridge.pem;
      };
    };
    ugent-vpn.enable = true;
    tor.enable = true;
    intellij.enable = true;
    syncthing-client.enable = true;
    wireshark.enable = true;

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

    permittedInsecurePackages = [
      "electron-24.8.6"
      "electron-25.9.0"
      "zotero-6.0.27"
      "qtwebkit-5.212.0-alpha4"
    ];

    extraHomePackages = with pkgs; [
      _1password-gui
      _1password
      brightnessctl
      blender
      protonup-qt
      hyperfine
      prismlauncher
      lutris
      bitwig-studio
      feh
      inkscape
      texlive.combined.scheme-full
      pandoc
      wine-staging
      binutils
      python3Packages.binwalk
      audacity
      discord
      ffmpeg-full
      firefox
      gimp
      imagemagick
      libqalculate
      mpv
      obs-studio
      okular
      qview
      signal-desktop
      steam-run
      teams-for-linux
      yt-dlp
      zathura
      zotero
      obsidian
      nmap
      ungoogled-chromium
      kdenlive
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
  networking.timeServers = [ "ntp.ugent.be" "2.nixos.pool.ntp.org" ];

}

