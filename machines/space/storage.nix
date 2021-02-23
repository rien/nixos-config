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
  };


}
