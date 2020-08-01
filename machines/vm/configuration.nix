# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [
      ../../conf/defaults.nix
      ../../services/sshd.nix
      ../../services/nginx.nix
      ../../services/nextcloud.nix
      ../../services/transmission.nix
      ../../services/postfix.nix
      ./hardware-configuration.nix
    ];

  boot = {
    initrd = {
      checkJournalingFS = false;
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  security.rngd.enable = false;

  networking.hostName = "vm"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;
  networking.interfaces.enp0s8.useDHCP = true;
}

