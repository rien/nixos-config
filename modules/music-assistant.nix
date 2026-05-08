{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.custom.music-assistant;
in {
  options.custom.music-assistant = {
    enable = mkOption {
      example = true;
      default = false;
    };

    hostname = mkOption {
      example = "mass.example.org";
      type = lib.types.str;
    };

    acmeHost = mkOption {
      default = null;
      example = "example.org";
    };

    configDir = mkOption {
      default = "/var/lib/music-assistant/config";
    };

    dataDir = mkOption {
      default = "/var/lib/music-assistant/data";
    };
  };

  config = mkIf cfg.enable{

    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} - - - - -"
      "d ${cfg.dataDir} - - - - -"
    ];

    # Enable writing to /dev/ttyUSB0
    # users.users.hass.extraGroups = [ "dialout" ];
    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        musicassistant = {
          autoStart = true;
          volumes = [
            "${cfg.configDir}/config:/config"
            "/run/dbus:/run/dbus:ro"
            "/etc/localtime:/etc/localtime:ro"
            ];
            environment.TZ = "Europe/Brussels";
            labels."io.containers.autoupdate" = "registry";
            image = "ghcr.io/music-assistant/server:stable";
            extraOptions = [
              "--network=host"
              "--privileged"
            ];
        };
      };
    };

    services.nginx.virtualHosts.${cfg.hostname} = {
      forceSSL = true;
      useACMEHost = cfg.acmeHost or cfg.hostname;

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
