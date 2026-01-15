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
      example = pkgs.postgresql_17;
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

    environment.systemPackages = [
      (
        let
        # XXX specify the postgresql package you'd like to upgrade to.
        # Do not forget to list the extensions you need.
        newPostgres = pkgs.postgresql_17;
        cfg = config.services.postgresql;
        in
        pkgs.writeScriptBin "upgrade-pg-cluster" ''
          set -eux
        # XXX it's perhaps advisable to stop all services that depend on postgresql
          systemctl stop postgresql

          export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"
          export NEWBIN="${newPostgres}/bin"

          export OLDDATA="${cfg.dataDir}"
          export OLDBIN="${cfg.finalPackage}/bin"

          install -d -m 0700 -o postgres -g postgres "$NEWDATA"
          cd "$NEWDATA"
          sudo -u postgres "$NEWBIN/initdb" -D "$NEWDATA" ${lib.escapeShellArgs cfg.initdbArgs}

          sudo -u postgres "$NEWBIN/pg_upgrade" \
          --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
          --old-bindir "$OLDBIN" --new-bindir "$NEWBIN" \
          "$@"
        ''
        )
      ];

  };

}
