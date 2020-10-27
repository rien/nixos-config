# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../../conf/defaults.nix
      ../../services/sshd.nix
      ../../services/nginx.nix
      ../../services/transmission.nix
      ./wireguard.secret.nix
      ./motd.nix
      ./hardware-configuration.nix
    ];

  custom.transmission = {
    domain = "transmission.masjiene.rxn.be";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.smartd.enable = true;

  networking.hostName = "masjiene"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
}

