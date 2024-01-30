{ config, lib, pkgs, util, ... }:
let
  cfg = config.custom.postgres;
in {
  options.custom.postgres = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
    package = lib.mkOption {
      example = pkgs.postgresql_16;
    };
    backupLocation = lib.mkOption {
      example = "/data/backup";
    };
  };
  config = lib.mkIf cfg.enable {

    services.postgresql = {
      enable = true;
      package = cfg.package;
    };

    services.postgresqlBackup = {
      enable = true;
      compression = "zstd";
      compressionLevel = 19;
      location = cfg.backupLocation;
    };

#    Upgrade script:
#    environment.systemPackages = [
#      (let
#      # XXX specify the postgresql package you'd like to upgrade to.
#      # Do not forget to list the extensions you need.
#      newPostgres = pkgs.postgresql_17;
#      in pkgs.writeScriptBin "upgrade-pg-cluster" ''
#        set -eux
#      # XXX it's perhaps advisable to stop all services that depend on postgresql
#        systemctl stop postgresql
#
#        export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"
#
#        export NEWBIN="${newPostgres}/bin"
#
#        export OLDDATA="${config.services.postgresql.dataDir}"
#        export OLDBIN="${config.services.postgresql.package}/bin"
#
#        install -d -m 0700 -o postgres -g postgres "$NEWDATA"
#        cd "$NEWDATA"
#        sudo -u postgres $NEWBIN/initdb -D "$NEWDATA"
#
#        sudo -u postgres $NEWBIN/pg_upgrade \
#        --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
#        --old-bindir $OLDBIN --new-bindir $NEWBIN \
#        "$@"
#      '')
#    ];

  };

}
