{ config, lib, pkgs, ... }:
{
  options.custom.tailscale = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
  };

  config =
    let
      personal = import ./personal.secret.nix;
    in
    lib.mkIf config.custom.tailscale.enable {

      services.tailscale = {
        enable = true;
      };

      #networking.nameservers = [ "9.9.9.9" "1.1.1.1" ];
      networking.search = [ "elk-discus.ts.net" ];



      home-manager.users.${config.custom.user} = { pkgs, ... }: {
        systemd.user.services.trayscale = lib.mkIf config.custom.graphical.enable {
          Unit = {
            Description = "Tailscale system tray";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Environment = [ "PATH=${lib.makeBinPath [ pkgs.trayscale ]}" ];
            ExecStart = "${pkgs.trayscale}/bin/trayscale --hide-window";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
