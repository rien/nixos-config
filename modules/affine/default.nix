{ config, pkgs, lib, util, ... }:

let cfg = config.custom.affine;
in {
  options.custom.affine = {
    enable = lib.mkEnableOption "Affine Server";

    hostname = lib.mkOption {
      example = "example.com";
    };

    version = lib.mkOption {
      example = "v0.22.4";
    };

    hash = lib.mkOption {
      example = "";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 3010;
    };

    backupLocation = lib.mkOption {
      example = "/data/affine-backups";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/affine";
      description = "Directory for user files";
    };
  };

  config = let
    compose-file = pkgs.fetchurl {
      url = "https://github.com/toeverything/affine/releases/download/${cfg.version}/docker-compose.yml";
      hash = cfg.hash;
    };
    env-file = pkgs.writeTextFile {
      name = ".env";
      text = ''
        PORT="${toString cfg.port}"
        DB_DATA_LOCATION="${cfg.stateDir}/postgres"
        UPLOAD_LOCATION="${cfg.stateDir}/storage"
        CONFIG_LOCATION="${cfg.stateDir}/compose"
        DB_USERNAME="affine"
        DB_PASSWORD="affine"
        DB_DATABASE="affine"
      '';
    };
  in lib.mkIf cfg.enable {

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir}/postgres   - - - - -"
      "d ${cfg.stateDir}/storage    - - - - -"
      "d ${cfg.stateDir}/compose    - - - - -"
      "L+ ${cfg.stateDir}/compose/.env   - - - - ${env-file}"
      "L+ ${cfg.stateDir}/compose/docker-compose.yml   - - - - ${compose-file}"
    ];

    systemd.services.affine-server = {
      description = "Affine Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
      };
      serviceConfig = {
        WorkingDirectory = "${cfg.stateDir}/compose";
        ExecStart = "${pkgs.docker}/bin/docker compose up --pull always";
        Restart = "always";
        StateDirectory = "affine";
        DynamicUser = true;
        SupplementaryGroups="docker";
      };
    };

    services.nginx.virtualHosts.${cfg.hostname} = {
      forceSSL = true;
      useACMEHost = util.baseDomain cfg.hostname;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}";
      };
    };
  };
}
