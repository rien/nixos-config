{ lib, config, pkgs, ... }:
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
      ./wireguard.secret.nix
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
    "fava-auth"= {
      owner = "nginx";
      file = ./fava-auth.age;
    };
    "hetzner-api-key" = {
      file = ./hetzner-api-key.age;
      owner = "acme";
    };
    "coturn-secret" = {
      file = ./coturn-secret.age;
      owner = "turnserver";
    };
  };

  system.activationScripts.users.supportsDryActivation = lib.mkForce false;

  services.coturn = {
    enable = true;
    realm = "coturn.rxn.be";
    listening-ips = [ "49.12.7.126" ];
    use-auth-secret = true;
    static-auth-secret-file = "/run/agenix/coturn-secret";
  };

  networking.firewall.allowedTCPPorts = [ 3478 ];
  networking.firewall.allowedUDPPorts = [ 3478 ];

  custom = {
    bash.enable = true;
    neovim.enable = true;
    sshd.enable = true;

    nginx = {
      enable = true;
      dnsCredentialsFile = "/run/agenix/hetzner-api-key";
      certificateDomains = [
        {
          domain = "maertens.io";
          extra = [ "*.maertens.io" ];
        }
        {
          domain = "rxn.be";
          extra = ["*.rxn.be"];
        }
        {
          domain = "theatervolta.be";
          extra = [ "*.theatervolta.be" "voltaprojects.be" "*.voltaprojects.be" ];
        }
      ];
    };

    nextcloud = {
      enable = true;
      hostname = "cloud.rxn.be";
      adminpassFile = "/run/agenix/nextcloud-adminpass";
    };

    transmission = {
      enable = true;
      domain = "transmission.rxn.be";
      download-dir = "/var/lib/transmission/data/complete";
      incomplete-dir = "/var/lib/transmission/data/incomplete";
      basicAuthFile = "/run/agenix/transmission-auth";
      port = secret.transmission.port;
    };
    postfix = {
      enable = true;
      loginFile = "/run/agenix/postfix-sasl";
    };
    syncthing-server = {
      enable = true;
      hostname = "sync.rxn.be";
      basicAuthFile = "/run/agenix/syncthing-auth";
    };
    fava = {
      enable = true;
      hostname = "fin.rxn.be";
      basicAuthFile = "/run/agenix/fava-auth";
      journalFiles = [
        "rien.beancount"
        "gedeeld.beancount"
      ];
    };
    #mail.fetcher.enable = true;

    extraSystemPackages = with pkgs; [
      htop
    ];
  };


  services.accentor = {
    enable = true;
    hostname = "music.rxn.be";
    workers = 1;
    environmentFile = "/run/agenix/accentor-env";
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

