{ lib, config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets = {
    "media-key".file = ./chaos_key.age;
    "vpn-conf".file = ./vpn-conf.age;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.firewall.allowedTCPPorts = [ 10999 20595 8000 2350 3450 ];
  networking.firewall.allowedUDPPorts = [ 10999 20595 8000 2350 3450];
  
  services.openvpn.servers = {
    bagofholding = { config = ''config /run/agenix/vpn-conf''; };
  };

  # Ignore power key and lid events
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
    HandleLidSwitch=ignore
  '';

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

  custom = {
    sshd.enable = true;
    bash.enable = true;
    docker = {
      enable = true;
      storageDriver = "zfs";
    };
    dwarffortress.enable = false;
    git.enable = true;
    gnupg.enable = true;
    sound.enable = true;
    graphical = {
      enable = true;
      flavour = "plasma";
    };
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
    tailscale.enable = true;
    mounts.ugent.enable = true;
    mounts.media = {
      enable = true;
      mountPoint = "/mnt/media";
      identityFile = "/run/agenix/media-key";
    };

    extraSystemPackages = with pkgs; [
      eid-mw
      cntr
      ntfs3g
    ];

    permittedInsecurePackages = [
      "electron-35.7.5"
      "electron-24.8.6"
      "electron-25.9.0"
      "zotero-6.0.27"
      "qtwebkit-5.212.0-alpha4"
      "libsoup-2.74.3"
    ];

    extraHomePackages = with pkgs; [
      # blender
      (firefox.override { pkcs11Modules = [ eid-mw ]; })
      (ungoogled-chromium.override { enableWideVine = true; })
      _1password-cli
      _1password-gui
      binutils
      binwalk
      bitwig-studio
      brightnessctl
      discord
      feh
      ffmpeg-full
      gimp
      ghostty
      godot
      hyperfine
      imagemagick
      inkscape
      kdePackages.kdenlive
      kdePackages.okular
      libqalculate
      libreoffice
      mpv
      nmap
      obs-studio
      obsidian
      pandoc
      prismlauncher
      qview
      remmina
      scribus
      signal-desktop
      steam-run
      teams-for-linux
      texlive.combined.scheme-full
      trayscale
      vscode
      wine-staging
      yt-dlp
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
  networking.timeServers = [ "ntp.ugent.be" "2.nixos.pool.ntp.org" ];

}

