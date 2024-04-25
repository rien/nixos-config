{ config, pkgs, lib, ... }:
with lib;
let
  personal = import ../personal.secret.nix;
  cfg = config.custom.mail;
  toml = pkgs.formats.toml {};

  eachAccount = f: builtins.listToAttrs (
    builtins.filter
    (v: v != null)
    (builtins.map (account:
      let
      value = f (personal.emailAccounts.${account} // { name = "${account}"; });
      in if value == null
        then null
        else {
          name = "${account}";
          inherit value;
     })
     (builtins.attrNames personal.emailAccounts))
  );

  makeAccount = {
    name, address, host ? "", imapHost ? host, imapPort ? 993, smtpHost ? host, smtpPort ? (lib.mkDefault 465),
    useStartTls ? false, passFile, extraConfig ? { }, primary ? false,
    userName ? address, signature ? personal.defaultSignature, mbsync ? true,
    folders ? null, oauth ? null, extraFolderPatterns ? []
  }: (
    lib.recursiveUpdate
    {
      inherit address primary userName;
      imap = {
        host = imapHost;
        port = imapPort;
        tls.enable = true;
      };
      smtp = {
        host = smtpHost;
        port = smtpPort;
        tls = {
          enable = true;
          inherit useStartTls;
        };
      };
      folders = mkIf (folders != null) folders;
      realName = personal.fullName;
      signature = {
        text = signature;
        showSignature = "append";
      };
      thunderbird = mkIf cfg.thunderbird {
        enable = true;
        settings = mkIf (oauth != null) (id: {
          "mail.smtpserver.smtp_${id}.authMethod" = 10;
          "mail.server.server_${id}.authMethod" = 10;
        });
      };
    }
    extraConfig
  );
in {

  imports = [ ./fetcher.nix ];

  options.custom.mail = {
    enable = mkOption {
      example = true;
      default = false;
    };

    thunderbird = mkOption {
      example = true;
      default = false;
    };

    protonbridge = {
      enable = mkOption {
        example = true;
        default = false;
      };
      certificate = mkOption {};
    };
  };

  config = mkIf cfg.enable {

    security.pki.certificates = mkIf cfg.protonbridge.enable [ cfg.protonbridge.certificate ];

    home-manager.users.${config.custom.user} = { ... }: {
      home.packages = [ pkgs.protonmail-bridge ];
      accounts.email = {
        maildirBasePath = "/home/${config.custom.user}/mail";
        accounts = eachAccount makeAccount;
      };

      systemd.user.services.protonmail-bridge = mkIf cfg.protonbridge.enable {
        Unit = {
          Description = "Proton Mail Bridge";
          After = [ "network.target" ];
        };
        Service = {
          Restart = "always";
          ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --noninteractive --log-level debug";
        };
        Install.WantedBy = [ "default.target" ];
      };

      programs = {
        thunderbird = mkIf cfg.thunderbird {
          enable = true;
          package = pkgs.thunderbird;
          profiles = {
            default = {
              isDefault = true;
            };
          };
        };
      };
    };
  };
}
