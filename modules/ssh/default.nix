{ config, lib, ... }:
with lib;
let
  cfg = config.custom.ssh;
in
{
  options.custom.ssh.enable = mkOption {
    example = true;
    default = false;
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.user} = { pkgs, ... }: {
      programs.ssh = {
        enable = true;
        settings = lib.recursiveUpdate (import ./hosts.secret.nix) {
          "*".IdentityAgent =
            if pkgs.stdenv.isDarwin
            then "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock"
            else "~/.1password/agent.sock";
        };
        enableDefaultConfig = false;
      };

      systemd.user.services = mkIf pkgs.stdenv.isLinux {
        _1password = {
          Unit = {
            Description = "1Password system tray";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Environment = [ "PATH=${lib.makeBinPath [ pkgs._1password-gui ]}" ];
            ExecStart = "${pkgs._1password-gui}/bin/1password --silent";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
