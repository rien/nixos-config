{ config, pkgs, ... }:
let
  secret = import ./secret.nix;
  df-keys = import ./df-keys.secret.nix;
in
{
  imports =
    [
      ../../conf/defaults.nix
      ../../services/sshd.nix
      ../../services/nginx.nix
      ../../services/transmission.nix
      ../../services/postfix.nix
      ../../services/dwarffortress.nix
      ./wireguard.secret.nix
      ./storage.nix
      ./static-sites.nix
      ./motd.nix
      ./hardware-configuration.nix
    ];

  custom.transmission = {
    domain = "transmission.rxn.be";
    download-dir = "/var/lib/transmission/data/downloaded";
    incomplete-dir = "/var/lib/transmission/data/incomplete";
    port = secret.transmission.port;
    netns = secret.transmission.netns;
    rpc-bind-address = secret.transmission.rpc-bind-address;
    rpc-whitelist = secret.transmission.rpc-whitelist;
  };

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

