{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ bindfs ];

  systemd.services.storagebox-reachable = {
    enable = true;
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    description = "Wait for DNS to reach storagebox";
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec="15s";
      ExecStart="${pkgs.bash}/bin/bash -c 'until ${pkgs.dig.host}/bin/host u239266.your-storagebox.de; do sleep 1; done'";
    };
  };

  fileSystems = {
    "/data" = {
      device = "//u239266.your-storagebox.de/backup";
      fsType = "cifs";
      options = [
        "_netdev"
        "credentials=/run/agenix/storagebox-credentials"
        "rsize=65546"
        "wsize=126976"
        "vers=3"
        "iocharset=utf8"
        "seal"
        "x-systemd.after=storagebox-reachable.service"
        "x-systemd.requires=storagebox-reachable.service"
      ];
    };

    "/home/rien/data" = {
      device = "/data/rien/";
      fsType = "fuse.bindfs";
      options = [
        "multithreaded"
        "x-systemd.after=data.mount"
        "x-systemd.requires=data.mount"
        "force-user=rien"
        "_netdev"
      ];
    };

    "/home/rien/docs" = {
      device = "/data/syncthing/docs/";
      fsType = "fuse.bindfs";
      options = [
        "multithreaded"
        "x-systemd.after=data.mount"
        "x-systemd.requires=data.mount"
        "force-user=rien"
        "_netdev"
      ];
    };

    "/var/lib/syncthing/data" = {
      device = "/data/syncthing/";
      fsType = "fuse.bindfs";
      options = [
        "multithreaded"
        "x-systemd.after=data.mount"
        "x-systemd.requires=data.mount"
        "x-systemd.before=syncthing.service"
        "x-systemd.required-by=syncthing.service"
        "force-user=syncthing"
        "force-group=syncthing"
        "_netdev"
      ];
    };

    "/var/lib/photoprism/data-originals" = {
      device = "/data/photoprism/originals";
      fsType = "fuse.bindfs";
      options = [
        "multithreaded"
        "x-systemd.after=data.mount"
        "x-systemd.requires=data.mount"
        "x-systemd.before=photoprism.service"
        "x-systemd.required-by=photoprism.service"
        "force-user=photoprism"
        "force-group=photoprism"
        "_netdev"
      ];
    };

    "/var/lib/photoprism/data-import" = {
      device = "/data/syncthing/fp3-photos";
      fsType = "fuse.bindfs";
      options = [
        "multithreaded"
        "ro"
        "x-systemd.after=data.mount"
        "x-systemd.requires=data.mount"
        "x-systemd.before=photoprism.service"
        "x-systemd.required-by=photoprism.service"
        "force-user=photoprism"
        "force-group=photoprism"
        "_netdev"
      ];
    };

    "/var/lib/postgres-backups" = {
      device = "/data/postgres-backups";
      fsType = "fuse.bindfs";
      options = [
        "multithreaded"
        "x-systemd.after=data.mount"
        "x-systemd.requires=data.mount"
        "x-systemd.before=postgresqlBackup.service"
        "x-systemd.required-by=postgresqlBackup.service"
        "force-user=postgres"
        "force-group=postgres"
        "_netdev"
      ];
    };

  };
}
