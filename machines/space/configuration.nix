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
      #../../services/dwarffortress.nix
      ./storage.nix
      ./static-sites.nix
      ./motd.nix
      ./hardware-configuration.nix
    ];

  custom.transmission = {
    domain = "transmission.rxn.be";
    download-dir = "/var/lib/transmission/data/complete";
    incomplete-dir = "/var/lib/transmission/data/incomplete";
    port = secret.transmission.port;
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

  # Don't change this.
  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "20.03";

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;
  system.autoUpgrade.channel = https://nixos.org/channels/nixos-20.09;

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      dates = [ "daily" ];
    };
  };
}

