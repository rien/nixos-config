{ config, pkgs, ... }:
let
  secret = import ./secret.nix;
in
{
  imports =
    [
      ./storage.nix
      ./static-sites.nix
      ./motd.nix
      ./hardware-configuration.nix
    ];

  age.secrets."transmission-auth" = {
    owner = "nginx";
    file = ./transmission-auth.age;
  };
  age.secrets."postfix-sasl".file = ./postfix-sasl.age;

  custom = {
    bash.enable = true;
    neovim.enable = true;
    sshd.enable = true;
    nginx.enable = true;
    transmission = {
      enable = true;
      domain = "transmission.rxn.be";
      download-dir = "/var/lib/transmission/data/complete";
      incomplete-dir = "/var/lib/transmission/data/incomplete";
      basicAuthFile = "/run/secrets/transmission-auth";
      port = secret.transmission.port;
    };
    postfix = {
      enable = true;
      loginFile = "/run/secrets/postfix-sasl";
    };
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

