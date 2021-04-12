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
    home-manager.users.${config.custom.user} = { ... }: {
      programs.ssh = {
        enable = true;
        matchBlocks = import ./hosts.secret.nix;
      };
    };
  };
}
