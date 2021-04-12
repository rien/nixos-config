{ config, pkgs, ... }:
{
  imports =
    [
      ../../services/sshd.nix
      ./motd.nix
      ./hardware-configuration.nix
    ];

  age.secrets."media-key".file = ./living_key.age;

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 32768;
  };


  custom = {
    bash.enable = true;
    neovim.enable = true;
    mounts.media = {
      enable = true;
      identityFile = "/run/secrets/media-key";
    };

    extraSystemPackages = with pkgs; [
      mpv
      ffmpeg
    ];

    minidlna = {
      enable = true;
      dirs = [ "/media" ];
    };
  };

  documentation.enable = false;
  networking.hostName = "living"; # Define your hostname.

  # Don't change this.
  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "21.03";

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
}

