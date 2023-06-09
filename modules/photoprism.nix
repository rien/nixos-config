{ pkgs, config, lib, util, ... }:
with lib;
let
  cfg = config.custom.photoprism;
in {
  options.custom.photoprism = {
    enable = mkOption {
      example = true;
      default = false;
    };

    localPort = mkOption {
      default = 2342;
    };

    domain = mkOption {
      example = "photoprism.example.com";
      type = lib.types.str;
    };

    adminUser = mkOption {
      example = "admin";
    };

    originalsPath = mkOption {
      example = "/data/photoprism";
    };

    importPath = mkOption {
      example = "/data/photoprism";
    };

    adminPasswordFile = mkOption {
      example = "/run/secrets/photoprism-admin-password";
    };
  };

  config = mkIf cfg.enable {
    users.groups.photoprism = {};
    users.users.photoprism = {
      group = "photoprism";
      createHome = true;
      description = "Photo management WebApp";
      isSystemUser = true;
      home = "/var/lib/photoprism";
    };
    services.photoprism = {
      enable = true;
      passwordFile = cfg.adminPasswordFile;
      originalsPath = cfg.originalsPath;
      importPath = cfg.importPath;
      port = cfg.localPort;
      settings = {
        PHOTOPRISM_SITE_CAPTION = "Slimme site voor prentjes";
        PHOTOPRISM_DEFAULT_LOCALE = "en";
        PHOTOPRISM_ADMIN_USER = cfg.adminUser;
        PHOTOPRISM_WORKERS = "2";
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = util.baseDomain cfg.domain;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.localPort}";
        proxyWebsockets = true;
      };
    };
  };
}
