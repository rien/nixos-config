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

  age.secrets = {
    "accentor-env" = {
      owner = "accentor";
      file = ./accentor-env.age;
    };
    "transmission-auth" = {
      owner = "nginx";
      file = ./transmission-auth.age;
    };
    "postfix-sasl".file = ./postfix-sasl.age;
    "nextcloud-adminpass"= {
      owner = "nextcloud";
      file = ./nextcloud-adminpass.age;
    };
    "syncthing-auth"= {
      owner = "nginx";
      file = ./syncthing-auth.age;
    };
  };

  custom = {
    bash.enable = true;
    neovim.enable = true;
    sshd.enable = true;
    nginx.enable = true;
    nextcloud = {
      enable = true;
      hostname = "cloud.rxn.be";
      adminpassFile = "/run/secrets/nextcloud-adminpass";
    };
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
    syncthing-server = {
      enable = true;
      hostname = "sync.rxn.be";
      basicAuthFile = "/run/secrets/syncthing-auth";
    };
    #mail.fetcher.enable = true;
  };

  services.accentor = {
    enable = true;
    hostname = "music.rxn.be";
    workers = 1;
    environmentFile = "/run/secrets/accentor-env";
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

