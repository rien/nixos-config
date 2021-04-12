{ config, lib, ... }:
with lib;
let
  cfg = config.custom.pass;
in
{
  options.custom.pass.enable = mkOption {
    example = true;
    default = false;
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.user} = { pkgs, ... }: {
      programs.browserpass.enable = true;
      programs.password-store.enable = true;
    };
  };
}
