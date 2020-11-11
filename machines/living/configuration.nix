{ config, pkgs, ... }:
{
  imports =
    [
      ../../conf/defaults.nix
      ../../conf/home-network.secret.nix
      ../../services/sshd.nix
      ./motd.nix
      ./hardware-configuration.nix
    ];

  sound.enable = true;

  networking.hostName = "living"; # Define your hostname.

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}

