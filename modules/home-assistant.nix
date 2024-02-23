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
  };

  config = mkIf cfg.enable{

    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} - - - - -"
    ];


    # Enable writing to /dev/ttyUSB0
    # users.users.hass.extraGroups = [ "dialout" ];
    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        autoStart = true;
        volumes = [ "${cfg.configDir}:/config" ];
        environment.TZ = "Europe/Brussels";
        image = "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [
          "--network=host"
          # "--device=/dev/ttyACM0:/dev/ttyACM0"
        ];
      };
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
