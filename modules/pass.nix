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
    home-manager.users.rien = { pkgs, ... }: {
      programs.browserpass.enable = true;
      programs.password-store.enable = true;
      services.password-store-sync.enable = true;
    };
  };
}
