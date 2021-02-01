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
    mounts.media = {
      enable = true;
      identityFile = "/run/secrets/media-key";
    };
    minidlna = {
      enable = true;
      dirs = [ "/media" ];
    };
  };

  networking.hostName = "living"; # Define your hostname.

  # Don't change this.
  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "20.03";

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
}

