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

    basicAuthFile = mkOption {
      example = "/run/secrets/hass-basic-auth";
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

  };

  config = mkIf cfg.enable{
    services.home-assistant = {
      enable = true;
      config = {
        frontend = { };
        config = { };
        system_health = {};
        default_config = {};

        sensor = [
          {
            name = "vlinder";
            platform = "rest";
            resource = "https://mooncake.ugent.be/api/measurements/zZ6ZeSg11dJ5zp5GrNwNck9A";
            json_attributes_path = "$[-1:]";
            json_attributes = [
              "humidity"
              "pressure"
              "rainIntensity"
              "temp"
              "time"
              "windDirection"
              "windGust"
              "windSpeed"
              "rainVolume"
            ];
            value_template = "OK";
          }
          {
            platform = "template";
            sensors = {
              vlinder_temperature = {
                value_template = "{{ states.sensor.vlinder.attributes['temp'] }}";
                device_class = "temperature";
                unit_of_measurement = "°C";
              };
            };
          }
        ];

        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [
            "127.0.0.1"
            "::1"
          ];
        };
        logger.default = "info";
      };
    };

    # Enable writing to /dev/ttyUSB0
    users.users.hass.extraGroups = [ "dialout" ];


    services.nginx.virtualHosts.${cfg.hostname} = {
      useACMEHost = if cfg.acmeHost != null
                    then cfg.acmeHost
                    else cfg.hostname;
      forceSSL = true;

      extraConfig = ''
        proxy_buffering off;
      '';

      basicAuthFile = cfg.basicAuthFile;


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
