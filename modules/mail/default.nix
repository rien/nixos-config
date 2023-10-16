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
    name, address, host ? "", imapHost ? host, smtpHost ? host,
    useStartTls ? false, passFile, extraConfig ? { }, primary ? false,
    userName ? address, signature ? personal.defaultSignature, mbsync ? true,
    folders ? null, oauth ? null, signByDefault ? true, extraFolderPatterns ? []
  }: (
    lib.recursiveUpdate
    {
      inherit address primary userName;
      gpg = {
        inherit signByDefault;
        key = personal.gpgKey;
      };
      imap = {
        host = imapHost;
        port = 993;
        tls.enable = true;
      };
      smtp = {
        host = smtpHost;
        port = if useStartTls then 587 else 465;
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
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.user} = { ... }: {
      accounts.email = {
        maildirBasePath = "/home/${config.custom.user}/mail";
        accounts = eachAccount makeAccount;
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
