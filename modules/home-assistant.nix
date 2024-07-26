{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.custom.home-assistant;
in {
  options.custom.home-assistant = {
    enable = mkOption {
      example = true;
      default = false;
    };

    sslCertificate = mkOption {
      example = "/run/secrets/cert.crt";
      default = null;
    };

    sslCertificateKey = mkOption {
      example = "/run/secrets/cert.key";
      default = null;
    };

    hostname = mkOption {
      example = "hass.example.org";
      type = lib.types.str;
    };

    acmeHost = mkOption {
      default = null;
      example = "example.org";
    };

    configDir = mkOption {
      default = "/var/lib/home-assistant/config";
    };

    bridgedInterface = mkOption {
      example = "eno0";
    };
  };

  config = mkIf cfg.enable{

    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} - - - - -"
    ];

    # Virtualisation with Libvirtd
    virtualisation = {
      libvirtd = {
        enable = true;
        qemuOvmf = true;
      };
    };
    environment.systemPackages = with pkgs; [
      virt-manager usbutils
    ];
    users.users.${config.custom.user}.extraGroups = [ "libvirtd" ];

    # Bridged network
    networking.bridges.br0.interfaces = [ cfg.bridgedInterface ];
    networking.interfaces.br0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "10.0.0.2";
        prefixLength = 24;
      }];
    };

    services.nginx.virtualHosts.${cfg.hostname} = {
      inherit (cfg) sslCertificate sslCertificateKey;
      forceSSL = true;

      extraConfig = ''
        proxy_buffering off;
      '';

      locations."/".extraConfig = ''
        proxy_pass http://127.0.0.1:8123;
        proxy_set_header Host $host;
        proxy_redirect http:// https://;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
  };
}
