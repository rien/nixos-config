{ config, lib, pkgs, util, ... }:
let
  cfg = config.custom.nextcloud;
in {
  options.custom.nextcloud = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
    hostname = lib.mkOption {
      example = "nexcloud.example.com";
      type = lib.types.str;
    };
    adminpassFile = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {


    services = {
      nextcloud = {
        maxUploadSize = "4G";
        https = true;
        hostName = cfg.hostname;
        enable = true;
        autoUpdateApps.enable = true;
        package = pkgs.nextcloud28;
        config = {
          dbuser = "nextcloud";
          dbname = "nextcloud";
          dbtype = "pgsql";
          dbhost = "/run/postgresql";
          adminuser = "rien";
          adminpassFile = cfg.adminpassFile;
          overwriteProtocol = "https";
        };
        extraOptions = {
          calendar = {
            calendarSubscriptionRefreshRate = "PT1H";
          };
        };
      };
      nginx.virtualHosts.${cfg.hostname} = {
        useACMEHost = util.baseDomain cfg.hostname;
        forceSSL = true;
      };
      postgresql = {
        ensureDatabases = [ "nextcloud" ];
        ensureUsers = [{
          name = "nextcloud";
          ensureDBOwnership = true;
          # ensurePermissions = { "DATABASE nextcloud" = "ALL PRIVILEGES"; };
        }];
      };
    };
    systemd.services."nextcloud-setup" = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };
  };
}
