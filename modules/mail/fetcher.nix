{ config, lib, ... }:
with lib;
let
  cfg = config.custom.mail;
  makeFetchAccount = {
    name, address, host ? "", imapHost ? host,
    useStartTls ? false, passFile, extraConfig ? { }, primary ? false,
    userName ? address, mbsync ? true, ...
  }: (
    lib.recursiveUpdate
    {
      inherit address primary userName;
      imap = {
        host = imapHost;
        port = 993;
        tls.enable = true;
      };
      notmuch.enable = true;
      mbsync = {
        enable = mbsync;
        create = "both";
        expunge = "both";
        flatten = ".";
        remove = "both";
        extraConfig.account.AuthMechs = "LOGIN";
      };
      msmtp.enable = true;
      passwordCommand = "cat ${passFile}";
    }
    extraConfig
  );
in {
  options.custom.mail.fetcher = {
    enable = mkOption {
      default = false;
      example = true;
    };
    user = mkOption {
      default = "facteur";
    };
    home = mkOption {
      default = "/srv/facteur";
    };
    authorizedKeys = mkOption {
      default = [];
    };
  };

  config  = mkIf cfg.fetcher.enable {

    users.users.${cfg.fetcher.user} = {
      createHome = true;
      home = cfg.fetcher.home;
      openssh.authorizedKeys.keys = cfg.fetcher.authorizedKeys;
    };

    home-manager.users.${cfg.fetcher.user} = { pkgs, ... }: {
      mbsync.enable = true;
      accounts.email = {
        maildirbasePAth = "${cfg.fetcher.home}/mail";
        accounts = builtins.listToAttrs (
          builtins.map
          (account: {
            name = "${account}";
            value = makeFetchAccount (
                personal.emailAccounts.${account} //
                  { name = "${account}"; }
              );
          })
          (builtins.attrNames personal.emailAccounts)
        );
        afew = {
          enable = true;
          extraConfig = ''
            # Marks mail with 'spam' header
            [SpamFilter]

            # UGent sometimes still sends spam
            # but with [SPAM] as subject ...
            [HeaderMatchingFilter.1]
            header = Subject
            pattern = ^\[SPAM\]
            tags = +spam

            # Adds the 'killed' tag to mails within a thread that
            # has been tagged with 'killed'.
            [KillThreadsFilter]

            # Tag mails from one of my adresses as 'sent'
            # and remove them from 'new'
            [ArchiveSentMailsFilter]
            sent_tag=sent

            # Removes the 'new' tag and adds the 'inbox' tag
            [InboxFilter]
            '';
        };
        notmuch = {
          enable = true;
          new.tags = [ "unread" "new" ];
          search.excludeTags = [ "killed" "spam" ];
        };
      };
    };

  };
}
