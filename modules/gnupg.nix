{ config, lib, ... }:
with lib;
let
  cfg = config.custom.gnupg;
in
{
  options.custom.gnupg.enable = mkOption {
    example = true;
    default = false;
  };

  config = mkIf cfg.enable {
    programs.gnupg.agent.enable = true;
    home-manager.users.rien = { pkgs, ... }: {
      programs.gpg.enable = true;
      services.gpg-agent = {
        enable = true;
        enableSshSupport = config.custom.ssh.enable;
        defaultCacheTtl = 7200;
        maxCacheTtl = 99999;
        pinentryFlavor = "qt";
      };
    };
  };
}
