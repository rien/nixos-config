{ config, pkgs, ... }:
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


  custom = {
    bash.enable = true;
    neovim.enable = true;
    sshd.enable = true;
    nginx = {
      enable = true;
      dnsCredentialsFile = "/run/secrets/hetzner-api-key";
      certificateDomains = [{
        domain = "entropy.rxn.be";
        extra = [ "home.rxn.be" ];
      }];
    };

    home-assistant = {
      enable = true;
      hostname = "home.rxn.be";
      acmeHost = "entropy.rxn.be";
    };

    extraSystemPackages = with pkgs; [
      htop
    ];

    wireless = {
      enable = true;
      device = "wlan0";
    };
  };

  networking.hostName = "entropy";

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  # Don't change this.
  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "21.11";
}

