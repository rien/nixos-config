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
    home-manager.users.rien = { ... }: {
      programs.keychain = {
        enable = true;
        enableXsessionIntegration = true;
        agents = [ "ssh" ];
        keys = [ "id_ed25519" ];
      };
      programs.ssh = {
        enable = true;
        matchBlocks = import ./hosts.secret.nix;
      };
    };
  };
}
