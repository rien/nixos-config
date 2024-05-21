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
        forwardAgent = true;
        matchBlocks = import ./hosts.secret.nix;
        extraConfig = "IdentityAgent ~/.1password/agent.sock";
      };


      systemd.user.services._1password = {
        Unit = {
          Description = "1Password system tray";
          After = [ "hyprland-session.target" ];
          PartOf = [ "hyprland-session.target" ];
        };
        Service = {
          Environment = [ "PATH=${lib.makeBinPath [ pkgs._1password-gui ]}" ];
          ExecStart = "${pkgs._1password-gui}/bin/1password --silent";
        };
        Install.WantedBy = [ "hyprland-session.target" ];
      };
    };
  };
}
