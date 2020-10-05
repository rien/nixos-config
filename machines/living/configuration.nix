{ config, pkgs, ... }:
{
  imports =
    [
      ../../conf/defaults.nix
      ../../conf/home-network.secret.nix
      ../../services/sshd.nix
      #../../services/kodi.nix
      ./motd.nix
      ./hardware-configuration.nix
    ];

  sound.enable = true;

  networking.hostName = "living"; # Define your hostname.
}

