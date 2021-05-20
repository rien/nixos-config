{ config, lib, util, ... }:
let
  cfg = config.custom.syncthing-server;
in {
  options.custom.syncthing-server = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
    hostname = lib.mkOption {
      example = "syncthing.example.org";
      type = lib.types.str;
    };
    basicAuthFile = lib.mkOption {
      example = "/run/secrets/syncthing-auth";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      dataDir = "/var/lib/syncthing/data";
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:8384";
    };
    services.nginx.virtualHosts.${cfg.hostname} = {
      forceSSL = true;
      useACMEHost = util.baseDomain cfg.hostname;
      locations."/" = {
        proxyPass = "http://localhost:8384";
        basicAuthFile = cfg.basicAuthFile;
      };
    };
  };
}
