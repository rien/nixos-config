{ config, pkgs, ... }:
{
  imports =
    [
      ../../conf/defaults.nix
      ../../conf/home-network.secret.nix
      ../../services/sshd.nix
      ../../services/kodi.nix
      ./motd.nix
      ./hardware-configuration.nix
    ];

  sound.enable = true;

  networking.hostName = "living"; # Define your hostname.

  # Don't change this.
  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "20.03";

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.channel = https://nixos.org/channels/nixos-20.09;

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
}

