{ config, pkgs, ... }:
{
  imports =
    [
      ../../conf/defaults.nix
      ../../services/sshd.nix
      ../../services/nginx.nix
      ../../services/transmission.nix
      ../../services/wireguard.nix
      ../../services/postfix.nix
      ./storage.nix
      ./static-sites.nix
      ./motd.nix
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "space"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;
}

