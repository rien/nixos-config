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
      default = "/var/lib/home-assistant";
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
      containers = {
        homeassistant = {
          autoStart = true;
          volumes = [
            "${cfg.configDir}/config:/config"
            "/run/dbus:/run/dbus:ro"
            "/etc/localtime:/etc/localtime:ro"
            ];
            environment.TZ = "Europe/Brussels";
            labels."io.containers.autoupdate" = "registry";
            image = "ghcr.io/home-assistant/home-assistant:stable";
            extraOptions = [
              "--network=host"
              "--privileged"
            ];
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 1883 ];
    networking.firewall.allowedUDPPorts = [ 1883 ];

    services.mosquitto.enable = true;
    services.zigbee2mqtt = {
      enable = true;
      settings = {
        permit_join = true;
        homeassistant = true;
        availability.enabled = true;
        serial.port = "/dev/serial/by-id/usb-Nabu_Casa_Home_Assistant_Connect_ZBT-1_327f6fcbf338ef11b197e1d154516304-if00-port0";
      };
    };


    systemd.services.podman-update = {
      description = "Update and prune podman containers";

      restartIfChanged = false;
      unitConfig.X-StopOnRemoval = false;

      serviceConfig.Type = "oneshot";

      script = ''
        ${pkgs.podman}/bin/podman auto-update
        ${pkgs.podman}/bin/podman system prune -f --filter until="300h"
      '';

      startAt = "daily";
      after = [ "podman.service" ];
      requires = [ "podman.service" ];
    };

    systemd.timers.podman-update.timerConfig = {
      Persistent = true;
      RandomizedDelaySec = 1800;
    };


    services.nginx.virtualHosts.${cfg.hostname} = {
      forceSSL = true;
      useACMEHost = cfg.hostname;

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
