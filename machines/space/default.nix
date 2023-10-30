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
    "ovh-api-key" = {
      file = ./ovh-api-key.age;
      owner = "acme";
    };
    "opendkim.private" = {
      file = ./opendkim.private.age;
      path = "/var/lib/opendkim/keys/opendkim.private";
      owner = "opendkim";
    };
    "mastodon-vapid-privkey" = {
      file = ./mastodon-vapid-privkey.age;
      owner = "mastodon";
    };
    "mastodon-vapid-pubkey" = {
      file = ./mastodon-vapid-pubkey.age;
      owner = "mastodon";
    };
    "mastodon-secretkey" = {
      file = ./mastodon-secretkey.age;
      owner = "mastodon";
    };
    "mastodon-otpsecret" = {
      file = ./mastodon-otpsecret.age;
      owner = "mastodon";
    };
    "photoprism-admin-password" = {
      file = ./photoprism-admin-password.age;
      owner = "photoprism";
    };
    "vaultwarden-env" = {
      file = ./vaultwarden-env.age;
      owner = "vaultwarden";
    };
  };

  system.activationScripts.linkDKIMtxt = {
    text = "ln -sf ${./opendkim.txt} /var/lib/opendkim/keys/opendkim.txt";
  };

  system.activationScripts.users.supportsDryActivation = lib.mkForce false;


  networking.firewall.allowedTCPPorts = [ 3478 ];
  networking.firewall.allowedUDPPorts = [ 3478 ];

  custom = {
    bash.enable = true;
    neovim.enable = true;
    sshd.enable = true;

    vaultwarden = {
      enable = true;
      hostname = "vault.rxn.be";
      backupDir = "/var/lib/vaultwarden-backups";
      environmentFile = "/run/agenix/vaultwarden-env";
    };

    mastodon = {
      enable = true;
      localDomain = "toot.rxn.be";
      vapidPublicKeyFile = "/run/agenix/mastodon-vapid-pubkey";
      vapidPrivateKeyFile = "/run/agenix/mastodon-vapid-privkey";
      secretKeyBaseFile = "/run/agenix/mastodon-secretkey";
      otpSecretFile = "/run/agenix/mastodon-otpsecret";
    };

    photoprism = {
      enable = true;
      domain = "foto.rxn.be";
      importPath = "/var/lib/photoprism/data-import";
      originalsPath = "/var/lib/photoprism/data-originals";
      adminUser = "rien";
      adminPasswordFile = "/run/agenix/photoprism-admin-password";
    };

    nginx = {
      enable = true;
      certificateDomains = let
        hetzner = {
          dnsProvider = "hetzner";
          environmentFile = "/run/agenix/hetzner-api-key";
        };
        ovh = {
          dnsProvider = "ovh";
          environmentFile = "/run/agenix/ovh-api-key";
        };
      in [
        {
          domain = "maertens.io";
          extra = [ "*.maertens.io" ];
          dns = hetzner;
        }
        {
          domain = "rxn.be";
          extra = ["*.rxn.be"];
          dns = hetzner;
        }
        {
          domain = "theatervolta.be";
          extra = [ "*.theatervolta.be" "voltaprojects.be" "*.voltaprojects.be" ];
          dns = ovh;
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
    stateVersion = "20.03";
  };


  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "space"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;

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

