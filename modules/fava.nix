{ config, lib, util, pkgs, ... }:
let
  cfg = config.custom.fava;
in {
  options.custom.fava = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
    homeDir = lib.mkOption {
      default = "/var/lib/fava";
      type = lib.types.str;
    };
    dataDir = lib.mkOption {
      default = "/var/lib/fava/data";
      type = lib.types.str;
    };
    journalFiles = lib.mkOption {
      default = [ "journal.beancount" ];
    };
    hostname = lib.mkOption {
      example = "fava.example.com";
      type = lib.types.str;
    };
    port = lib.mkOption {
      default = "5000";
    };
    basicAuthFile = lib.mkOption {
      example = "/run/agenix/fava-auth";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.fava = {};
    users.users.fava = {
      group = "fava";
      createHome = true;
      description = "Web interface for Beancount";
      isSystemUser = true;
      home = cfg.homeDir;
    };

    systemd.services = {
      fava = {
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          User = "fava";
          Group = "fava";
          Restart = "on-failure";
          WorkingDirectory = cfg.dataDir;
          ExecStart = "${pkgs.fava}/bin/fava --port ${cfg.port} ${builtins.concatStringsSep " " cfg.journalFiles}";
        };
      };
    };

    services.nginx.virtualHosts.${cfg.hostname} = {
      forceSSL = true;
      useACMEHost = util.baseDomain cfg.hostname;
      locations."/" = {
        proxyPass = "http://localhost:${cfg.port}";
        basicAuthFile = cfg.basicAuthFile;
      };
    };
  };
}
