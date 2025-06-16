{ lib, config, pkgs, ... }:
let
  secret = import ./secret.nix;
in
  {
    imports =
      [
        ./motd.nix
        ./hardware-configuration.nix
      ];

      age.secrets = {
        "hetzner-api-key" = {
          file = ./hetzner-api-key.age;
          owner = "acme";
        };
      };

      users.users.rien.extraGroups = [ "wheel" ];

      programs.steam.enable = false;
      services.flatpak.enable = true;

      custom = {
        autoupgrade = {
          enable = true;
          allowReboot = true;
        };

        bash.enable = true;
        neovim.enable = true;
        sshd.enable = true;
        hostname = "entropy";

        nginx = {
          enable = true;
          certificateDomains = let
            hetzner = {
              dnsProvider = "hetzner";
              environmentFile = "/run/agenix/hetzner-api-key";
            };
          in [
            {
              domain = "entropy.rxn.be";
              extra = [ "home.rxn.be" ];
              dns = hetzner;
            }
            {
              domain = "thuis.maertens.gent";
              dns = hetzner;
            }
          ];
        };

        graphical.tv.enable = true;
        sound.enable = true;

        home-assistant = {
          enable = true;
          hostname = "thuis.maertens.gent";
          sslCertificate = "/run/agenix/cert.crt";
          sslCertificateKey = "/run/agenix/cert.key";
        };

        extraSystemPackages = with pkgs; [ ungoogled-chromium ];

        wireless = {
          enable = true;
          device = "wlp2s0";
        };

        tailscale.enable = true;

        stateVersion = "24.05";
      };

      networking.hostId = "39a9e79d";
      networking.hostName = "entropy";
      networking.useDHCP = false;

      networking.interfaces.eno0.useDHCP = true;
      networking.dhcpcd.extraConfig = ''
          interface eno0
          inform 192.168.0.2

          interface wlp2s0
          inform 192.168.0.3
      '';

    }

