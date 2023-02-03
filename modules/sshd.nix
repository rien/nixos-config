{ config, lib, ... }:
with lib;
let
  cfg = config.custom.sshd;
in {
  options.custom.sshd.enable = mkOption {
    default = false;
    example = true;
  };
  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 9450 ];
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };
}
