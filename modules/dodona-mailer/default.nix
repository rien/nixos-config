{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.custom.dodona-mailer;
in {
  options.custom.dodona-mailer = {
    enable = mkOption {
      example = true;
      default = false;
    };

    interval = mkOption {
      default = "hourly";
    };
  };

  config = let
    python = pkgs.python3.withPackages (p: with p; [ requests ]);
    runCommand = "${python}/bin/python ${./question_mailer.py}";
  in mkIf cfg.enable {

    home-manager.users.${config.custom.user} = { pkgs, ... }: {
      systemd.user = {
          services = {
            dodona-mailer = {
              Unit = {
                Description = "Send mails for Dodona questions";
              };
              Service = {
                Type = "oneshot";
                ExecStart = runCommand;
              };
            };
          };
          timers = {
            dodona-mailer = {
              Unit = {
                Description = "Run dodona-mailer ${cfg.interval}";
              };
              Timer = {
                Unit = "dodona-mailer.service";
                OnCalendar = cfg.interval;
                RandomizedDelaySec = 900;
                Persistent = true;
              };
              Install = {
                WantedBy = [ "timers.target" ];
              };
            };
          };
      };
    };
  };
}
