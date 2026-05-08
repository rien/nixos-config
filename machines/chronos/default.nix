{ lib, config, pkgs, stylix, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets = {
    "media-key".file = ./chronos_key.age;
  };

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    cursor = {
      name = "BreezeX-RosePine-Linux";
      size = 32;
      package = pkgs.rose-pine-cursor;
    };
    fonts = {
      serif = {
        package = pkgs.source-serif-pro; 
        name = "Source Serif Pro";
      };
      sansSerif = {
        package = pkgs.source-sans-pro;
        name = "Source Serif Sans";
      };
      monospace = {
        package = pkgs.source-code-pro;
        name = "Source Code Pro";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.firewall.allowedTCPPorts = [ 10999 20595 8000 2350 3450 ];
  networking.firewall.allowedUDPPorts = [ 10999 20595 8000 2350 3450];

  #services.openvpn.servers = {
  #  bagofholding = { config = ''config /run/agenix/vpn-conf''; };
  #};

  networking.networkmanager.plugins = [ pkgs.networkmanager-openconnect ];

  # services.mullvad-vpn.enable = true;

  # Ignore power key and lid events
  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandleLidSwitch = "ignore";
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
  virtualisation.waydroid.enable = false;
  users.extraGroups.vboxusers.members = [ "rien" ];
  system.activationScripts.users.supportsDryActivation = lib.mkForce false;


  programs.adb.enable = true;

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
      flavour = "gnome";
    };
    kitty.enable = true;
    neovim.enable = true;
    pass.enable = true;
    ssh.enable = true;
    mail = {
      enable = true;
      thunderbird = true;
    };
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
      citrix_workspace
      openconnect
      networkmanager-openconnect
      (firefox.override { pkcs11Modules = [ eid-mw ]; })
      chromium
      _1password-cli
      _1password-gui
      binutils
      binwalk
      ardour
      brightnessctl
      ffmpeg-full
      gimp
      imagemagick
      inkscape
      kdePackages.okular
      libqalculate
      libreoffice
      mpv
      nmap
      obsidian
      pandoc
      qview
      signal-desktop
      steam-run
      teams-for-linux
      texlive.combined.scheme-full
      trayscale
      vscode
      wine-staging
      yt-dlp
    ];

    stateVersion = "25.11";
  };


  # enable NetworkManager
  networking.networkmanager.enable = true;
  users.users.rien.extraGroups = [ "networkmanager" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "chronos"; # Define your hostname.
  # Required for ZFS
  networking.hostId = "04cdf13f";
  networking.timeServers = [ "ntp.ugent.be" "2.nixos.pool.ntp.org" ];

}

