{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.custom.docker;
in {
  options.custom.docker.enable = mkOption {
    default = false;
    example = true;
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    users.users.rien.extraGroups = [ "docker" ];
  };
}
