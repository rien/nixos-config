{ config, lib, util, pkgs, ... }:
let
  cfg = config.custom.vaultwarden;
in {
  options.custom.vaultwarden = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
    backupDir = lib.mkOption {
      example = "/var/lib/vaultwarden-backups";
    };
    hostname = lib.mkOption {
      example = "vault.example.com";
    };
    environmentFile = lib.mkOption {
      example = "/run/secrets/vaultwarden-env";
    };
    localPort = lib.mkOption {
      default = "8222";
    };
  };

  config = lib.mkIf cfg.enable {

    services.vaultwarden = {
      enable = true;
      backupDir = cfg.backupDir;
      environmentFile = cfg.environmentFile;
      config = {
        DOMAIN = "https://${cfg.hostname}";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = cfg.localPort;
        ROCKET_LOG = "critical";
        SMTP_HOST = "localhost";
        SMTP_PORT = "25";
        SMTP_SECURITY = "off";
        SMTP_FROM = "vaultwarden@${ util.baseDomain cfg.hostname }";
        SMTP_FROM_NAME = "Vaultwarden";
      };
    };

    services.nginx.virtualHosts.${cfg.hostname} = {
      forceSSL = true;
      useACMEHost = util.baseDomain cfg.hostname;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${cfg.localPort}";
      };
    };
  };
}
