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

    environment.systemPackages = [
      (let
      # XXX specify the postgresql package you'd like to upgrade to.
      # Do not forget to list the extensions you need.
      newPostgres = pkgs.postgresql_12;
      in pkgs.writeScriptBin "upgrade-pg-cluster" ''
        set -eux
      # XXX it's perhaps advisable to stop all services that depend on postgresql
        systemctl stop postgresql

        export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"

        export NEWBIN="${newPostgres}/bin"

        export OLDDATA="${config.services.postgresql.dataDir}"
        export OLDBIN="${config.services.postgresql.package}/bin"

        install -d -m 0700 -o postgres -g postgres "$NEWDATA"
        cd "$NEWDATA"
        sudo -u postgres $NEWBIN/initdb -D "$NEWDATA"

        sudo -u postgres $NEWBIN/pg_upgrade \
        --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
        --old-bindir $OLDBIN --new-bindir $NEWBIN \
        "$@"
      '')
    ];

    services = {
      nextcloud = {
        maxUploadSize = "4G";
        https = true;
        hostName = cfg.hostname;
        enable = true;
        autoUpdateApps.enable = true;
        package = pkgs.nextcloud27;
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
        enable = true;
        package = pkgs.postgresql_11;
        ensureDatabases = [ "nextcloud" ];
        ensureUsers = [{
          name = "nextcloud";
          #ensureDBOwnership = true;
          ensurePermissions = { "DATABASE nextcloud" = "ALL PRIVILEGES"; };
        }];
      };
    };
    systemd.services."nextcloud-setup" = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };
  };
}
