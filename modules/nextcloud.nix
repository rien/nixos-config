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
        package = pkgs.nextcloud31;
        config = {
          dbtype = "sqlite";
          adminuser = "rien";
          adminpassFile = cfg.adminpassFile;
        };
        settings.overwriteprotocol = "https";
        phpOptions = {
          "opcache.interned_strings_buffer" = "16";
        };
      };
      nginx.virtualHosts.${cfg.hostname} = {
        useACMEHost = util.baseDomain cfg.hostname;
        forceSSL = true;
      };
    };
  };
}
