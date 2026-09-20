{ lib, config, pkgs, stylix, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets = {
    "media-key".file = ./chaos_key.age;
    "vpn-conf".file = ./vpn-conf.age;
  };

  stylix = {
    enable = false;
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


  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };


  programs.nix-ld.enable = true;


  custom = {
    sshd.enable = true;
    bash.enable = true;
    docker = {
      enable = true;
      storageDriver = "zfs";
    };
    git.enable = true;
    gnupg.enable = true;
    sound.enable = false;
    graphical = {
      enable = true;
      flavour = "jovian";
    };
    kitty.enable = true;
    neovim.enable = true;
    ssh.enable = true;
    tailscale.enable = true;
    mounts.media = {
      enable = true;
      mountPoint = "/mnt/media";
      identityFile = "/run/agenix/media-key";
    };

    extraSystemPackages = with pkgs; [
      cntr
      ntfs3g
    ];

    extraHomePackages = with pkgs; [
      (firefox.override { pkcs11Modules = [ eid-mw ]; })
      _1password-cli
      _1password-gui
      binutils
      binwalk
      brightnessctl
      ffmpeg-full
      imagemagick
      libqalculate
      mpv
      nmap
      steam-run
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

  boot.initrd.kernelModules = [ "i915" ];
  services.fwupd.enable = true;

  networking.hostName = "chaos"; # Define your hostname.
  # Required for ZFS
  networking.hostId = "12345678";
  networking.timeServers = [ "2.nixos.pool.ntp.org" ];

}

