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

  environment.systemPackages = with pkgs; [
     ncspot
  ];

  sound.enable = true;

  networking.hostName = "living"; # Define your hostname.
}

