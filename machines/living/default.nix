{ config, pkgs, ... }:
{
  imports =
    [
      ../../services/sshd.nix
      ./motd.nix
      ./hardware-configuration.nix
    ];

  custom = {
    bash.enable = true;
  };

  wireless = {
    enable = true;
    device = "wlan0";
  };

  documentation.enable = false;
  networking.hostName = "harmony"; # Define your hostname.

  # Don't change this.
  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "21.11";

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
}

