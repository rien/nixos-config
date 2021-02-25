{ lib, config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets."media-key".file = ./chaos_key.age;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.firewall.allowedTCPPorts = [ 10999 ];
  networking.firewall.allowedUDPPorts = [ 10999 ];

  programs.steam.enable = true;

  custom = {
    sshd.enable = true;
    bash.enable = true;
    docker.enable = true;
    git.enable = true;
    gnupg.enable = true;
    graphical.enable = true;
    kitty.enable = true;
    neovim.enable = true;
    pass.enable = true;
    ssh.enable = true;
    zeroad.enable = true;
    mail.enable = true;
    vpnc.enable = true;
    tor.enable = true;

    minidlna = {
      enable = true;
      dirs = [ "/data/music/" ];
    };

    mounts.ugent.enable = true;
    mounts.media = {
      enable = true;
      mountPoint = "/mnt/media";
      identityFile = "/run/secrets/media-key";
    };

    extraPackages = with pkgs; [
      qview
      remmina
      lutris
      discord
      okular
      steam-run
      protontricks
      teeworlds
      libqalculate
      youtube-dl
      sent
      gimp
      firefox
      spotify-tui
      jetbrains.idea-ultimate
      jdk
      mpv
      ffmpeg-full
      teams
      zathura
      imagemagick7
      mumble
      signal-desktop
      audacity
    ];

    allowUnfree = with pkgs; [ jetbrains.idea-ultimate teams steam "steam-original" "steam-runtime" discord ];

    wireless = {
      enable = true;
      device = "wlp114s0";
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "chaos"; # Define your hostname.
  # Required for ZFS
  networking.hostId = "04cdf13e";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?

}

