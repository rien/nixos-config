{ config, pkgs, lib, util, ... }:

let cfg = config.custom.actual;
in {
  options.custom.actual = {
    enable = lib.mkEnableOption "Actual Server";

    hostname = lib.mkOption {
      example = "example.com";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 5006;
    };

    basicAuthFile = lib.mkOption {
      example = "/run/agenix/actual-auth";
    };

    backupLocation = lib.mkOption {
      example = "/data/actual-backups";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/actual-server";
      description = "Directory for user files";
    };

    upload = {
      fileSizeSyncLimitMB = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "File size limit in MB for synchronized files";
      };

      syncEncryptedFileSizeLimitMB = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "File size limit in MB for synchronized encrypted files";
      };

      fileSizeLimitMB = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "File size limit in MB for file uploads";
      };
    };
  };

  config = let
    repo = "${pkgs.actual-server}/lib/node_modules/actual-sync";
    linkRepo = pkgs.writeShellScript "actual-link-repo" ''
      ln -sf ${repo}/migrations ${repo}/src ${repo}/package.json ${cfg.stateDir}/
    '';
  in lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.actual-server ];

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir}/user       - - - - -"
      "d ${cfg.stateDir}/server     - - - - - -"
    ];

    systemd.services.actual-server = let
      config = {
        inherit (cfg) upload port;
        hostname = "0.0.0.0";
        userFiles = "${cfg.stateDir}/user";
        serverFiles = "${cfg.stateDir}/server";
        dataDir = cfg.stateDir;
      };
      configFile = pkgs.writeTextFile {
        name = "config.json";
        text = builtins.toJSON config;
      };
    in {
      description = "Actual Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        DEBUG="actual:*";
        ACTUAL_CONFIG_PATH = configFile;
      };
      serviceConfig = {
        WorkingDirectory = cfg.stateDir;
        ExecStartPre = linkRepo;
        ExecStart = "${pkgs.actual-server}/bin/actual-server";
        Restart = "always";
        StateDirectory = "actual-server";
        DynamicUser = true;
      };
    };

    services.nginx.virtualHosts.${cfg.hostname} = {
      forceSSL = true;
      useACMEHost = util.baseDomain cfg.hostname;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}";
        basicAuthFile = cfg.basicAuthFile;
      };
    };
  };
}
