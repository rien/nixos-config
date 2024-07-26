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
    #"hetzner-api-key" = {
    #  file = ./hetzner-api-key.age;
    #  owner = "acme";
    #};
    "hass-basic-auth" = {
      file = ./hass-basic-auth.age;
      owner = "nginx";
    };
    "cert.crt" = {
      file = ./cert.crt.age;
      owner = "nginx";
    };
    "cert.key" = {
      file = ./cert.key.age;
      owner = "nginx";
    };
  };

  users.users.rien.extraGroups = [ "wheel" ];

  programs.steam.enable = true;

  custom = {
    autoupgrade = {
      enable = true;
      allowReboot = true;
    };

    bash.enable = true;
    neovim.enable = true;
    sshd.enable = true;
    hostname = "entropy";

    nginx.enable = true;

    graphical.tv.enable = true;
    sound.enable = true;

    home-assistant = {
     enable = false;
     bridgedInterface = "wlp2s0";
     hostname = "entropy.elk-discus.ts.net";
     sslCertificate = "/run/agenix/cert.crt";
     sslCertificateKey = "/run/agenix/cert.key";
    };

    extraSystemPackages = with pkgs; [ ungoogled-chromium ];

    wireless = {
      enable = true;
      device = "wlp2s0";
    };

    tailscale.enabled = true;

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

