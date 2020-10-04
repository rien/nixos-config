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

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;

  networking.hostName = "living"; # Define your hostname.
}

