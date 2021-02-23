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
      permitRootLogin = "prohibit-password";
      passwordAuthentication = false;
      challengeResponseAuthentication = false;
    };
  };
}
