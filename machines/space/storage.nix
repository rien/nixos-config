{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ sshfs bindfs ];
  fileSystems = {
    "/data/" = {
      device = "u239266@u239266.your-storagebox.de:/";
      fsType = "fuse.sshfs";
      options = [
        "transform_symlinks"
        "_netdev"
        "reconnect"
        "identityfile=/etc/nixos/machines/space/storage/ssh_key.secret"
        "idmap=user"
      ];
    };

    "/home/rien/data/" = {
      device = "/data/rien/";
      fsType = "fuse.bindfs";
      options = [
        "multithreaded"
        "x-systemd.after=data.mount"
        "x-systemd.requires=data.mount"
        "force-user=rien"
      ];
    };
  };


}
