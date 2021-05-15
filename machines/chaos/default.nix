{ lib, config, pkgs, custompkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets."media-key".file = ./chaos_key.age;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.firewall.allowedTCPPorts = [ 10999 ];
  networking.firewall.allowedUDPPorts = [ 10999 ];

  programs.steam.enable = true;

  virtualisation.virtualbox.host.enable = true;

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
    #vpnc.enable = true;
    ugent-vpn.enable = true;
    tor.enable = true;
    intellij.enable = true;

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

    extraSystemPackages = with pkgs; [
      ntfs3g
    ];

    extraHomePackages = with pkgs; [
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
      imagemagick7
      libqalculate
      lutris
      minecraft
      mpv
      mumble
      obs-studio
      obs-v4l2sink
      okular
      protontricks
      qview
      qutebrowser
      remmina
      sent
      signal-desktop
      spotify-tui
      steam-run
      teams
      teeworlds
      youtube-dl
      zathura
      openttd
      zotero
      openscad
      freecad
      ncspot
      colmap
      openmvg
      python3Packages.ds4drv
      godot
      #ardour
      termdown
    ];

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

