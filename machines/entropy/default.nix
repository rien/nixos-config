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
    "hass-basic-auth" = {
      file = ./hass-basic-auth.age;
      owner = "nginx";
    };
  };

  users.users.rien.extraGroups = [ "wheel" ];

  custom = {
    bash.enable = true;
    neovim.enable = true;
    sshd.enable = true;

    hostname = "entropy";

    nginx = {
      enable = true;
      dnsCredentialsFile = "/run/agenix/hetzner-api-key";
      certificateDomains = [{
        domain = "entropy.rxn.be";
        extra = [ "home.rxn.be" ];
      }];
    };

    home-assistant = {
      enable = true;
      hostname = "entropy.rxn.be";
      basicAuthFile = "/run/agenix/hass-basic-auth";
    };

    extraSystemPackages = with pkgs; [
    ];

    wireless = {
      enable = true;
      device = "wlan0";
    };

    stateVersion = "23.11";
  };

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.dhcpcd.extraConfig = ''
    interface eth0
    inform 192.168.0.2

    interface wlan0
    inform 192.168.0.3
  '';
}

