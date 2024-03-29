{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ sshfs bindfs ];
  fileSystems = {
    "/data" = {
      device = "u239266@u239266.your-storagebox.de:/";
      fsType = "fuse.sshfs";
      options = [
        "umask=0077"
        "transform_symlinks"
        "_netdev"
        "reconnect"
        "identityfile=/etc/nixos/machines/space/storage/ssh_key.secret"
        "idmap=user"
        "x-systemd.after=network-addresses-ens3.service"
        "x-systemd.requires=network-addresses-ens3.service"
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

    "/var/lib/transmission/data" = {
      device = "/data/transmission/";
      fsType = "fuse.bindfs";
      options = [
        "multithreaded"
        "x-systemd.after=data.mount"
        "x-systemd.requires=data.mount"
        "x-systemd.before=transmission.service"
        "x-systemd.required-by=transmission.service"
        "force-user=transmission"
        "force-group=nginx"
        "perms=u=rwD:g=rD"
        "_netdev"
      ];
    };

    "/var/lib/nextcloud/data" = {
      device = "/data/nextcloud/";
      fsType = "fuse.bindfs";
      options = [
        "multithreaded"
        "x-systemd.after=data.mount"
        "x-systemd.requires=data.mount"
        "x-systemd.before=phpfpm-nextcloud.service"
        "x-systemd.required-by=phpfpm-nextcloud.service"
        "force-user=nextcloud"
        "force-group=nextcloud"
        "_netdev"
      ];
    };

    "/var/lib/nextcloud/transmission" = {
      device = "/data/transmission/";
      fsType = "fuse.bindfs";
      options = [
        "ro"
        "multithreaded"
        "x-systemd.after=data.mount"
        "x-systemd.requires=data.mount"
        "x-systemd.before=phpfpm-nextcloud.service"
        "x-systemd.required-by=phpfpm-nextcloud.service"
        "force-user=nextcloud"
        "force-group=nextcloud"
        "_netdev"
      ];
    };

    "/var/lib/nextcloud/syncthing" = {
      device = "/data/syncthing/";
      fsType = "fuse.bindfs";
      options = [
        "ro"
        "multithreaded"
        "x-systemd.after=data.mount"
        "x-systemd.requires=data.mount"
        "x-systemd.before=phpfpm-nextcloud.service"
        "x-systemd.required-by=phpfpm-nextcloud.service"
        "force-user=nextcloud"
        "force-group=nextcloud"
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

    "/var/lib/fava/data" = {
      device = "/data/syncthing/ledger/";
      fsType = "fuse.bindfs";
      options = [
        "multithreaded"
        "x-systemd.after=data.mount"
        "x-systemd.requires=data.mount"
        "x-systemd.before=fava.service"
        "x-systemd.required-by=fava.service"
        "force-user=fava"
        "force-group=fava"
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
