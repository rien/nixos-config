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
      ];
    };

    "/var/lib/transmission/data" = {
      device = "/data/transmission/";
      fsType = "fuse.bindfs";
      options = [
        "nonempty"
        "multithreaded"
        "x-systemd.requires=data.mount"
        "x-systemd.before=transmission.service"
        "x-systemd.required-by=transmission.service"
        "force-user=transmission"
      ];
    };

    "/var/lib/nextcloud/data" = {
      device = "/data/nextcloud/";
      fsType = "fuse.bindfs";
      options = [
        "nonempty"
        "multithreaded"
        "x-systemd.requires=data.mount"
        "x-systemd.before=phpfpm-nextcloud.service"
        "x-systemd.required-by=phpfpm-nextcloud.service"
        "force-user=nextcloud"
        "force-group=nextcloud"
      ];
    };

    "/var/lib/nextcloud/transmission" = {
      device = "/data/transmission/";
      fsType = "fuse.bindfs";
      options = [
        "ro"
        "nonempty"
        "multithreaded"
        "x-systemd.requires=data.mount"
        "x-systemd.before=phpfpm-nextcloud.service"
        "x-systemd.required-by=phpfpm-nextcloud.service"
        "force-user=nextcloud"
        "force-group=nextcloud"
      ];
    };

    "/var/lib/nextcloud/syncthing" = {
      device = "/data/syncthing/";
      fsType = "fuse.bindfs";
      options = [
        "ro"
        "nonempty"
        "multithreaded"
        "x-systemd.requires=data.mount"
        "x-systemd.before=phpfpm-nextcloud.service"
        "x-systemd.required-by=phpfpm-nextcloud.service"
        "force-user=nextcloud"
        "force-group=nextcloud"
      ];
    };

    "/var/lib/syncthing/data" = {
      device = "/data/syncthing/";
      fsType = "fuse.bindfs";
      options = [
        "nonempty"
        "multithreaded"
        "x-systemd.requires=data.mount"
        "x-systemd.before=syncthing.service"
        "x-systemd.required-by=syncthing.service"
        "force-user=syncthing"
        "force-group=syncthing"
      ];
    };

    "/var/lib/accentor/transmission" = {
      device = "/data/transmission/";
      fsType = "fuse.bindfs";
      options = [
        "ro"
        "nonempty"
        "multithreaded"
        "x-systemd.requires=data.mount"
        "x-systemd.before=accentor-api.service"
        "x-systemd.required-by=accentor-api.service"
        "force-user=accentor"
        "force-group=accentor"
      ];
    };

    "/var/lib/accentor/storage" = {
      device = "/data/accentor/";
      fsType = "fuse.bindfs";
      options = [
        "nonempty"
        "multithreaded"
        "x-systemd.requires=data.mount"
        "x-systemd.before=accentor-api.service"
        "x-systemd.required-by=accentor-api.service"
        "force-user=accentor"
        "force-group=accentor"
      ];
    };

    "/var/lib/fava/data" = {
      device = "/data/syncthing/ledger/";
      fsType = "fuse.bindfs";
      options = [
        "nonempty"
        "multithreaded"
        "x-systemd.requires=data.mount"
        "x-systemd.before=fava.service"
        "x-systemd.required-by=fava.service"
        "force-user=fava"
        "force-group=fava"
      ];
    };
  };


}
