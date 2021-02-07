{ config, pkgs, lib, ... }:
with lib;
let
  passwordScript = pkgs.writeShellScript "get_mail_password" ''
    ${pkgs.pass}/bin/pass show "$@" | head -n1 | tr -d "\n"
  '';
  personal = import ./personal.secret.nix;
  cfg = config.custom.mail;
  makeAccount = {
    name, address, host ? "", imapHost ? host, smtpHost ? host,
    useStartTls ? false, passFile, extraConfig ? { }, primary ? false,
    userName ? address
  }: (
    lib.recursiveUpdate
    {
      inherit address primary userName;
      gpg = {
        key = personal.email;
        signByDefault = true;
      };
      imap = {
        host = imapHost;
        port = 993;
        tls.enable = true;
      };
      notmuch.enable = true;
      #imapnotify = {
      #  enable = true;
      #  boxes = [ "INBOX" ];
      #  onNotify = "${pkgs.isync}/bin/mbsync ${name}:INBOX";
      #  onNotifyPost = "${notifyScript name}";
      #};
      mbsync = {
        enable = true;
        create = "both";
        expunge = "both";
        flatten = ".";
        remove = "both";
        extraConfig.account.AuthMechs = "LOGIN";
      };
      msmtp.enable = true;
      #neomutt = {
      #  enable = true;
      #  sendMailCommand = "msmtpq --read-envelope-from --read-recipients --account ${name}";
      #};
      passwordCommand = "${passwordScript} ${passFile}";
      realName = personal.fullName;
      signature = {
        showSignature = "attach";
      };
      smtp = {
        host = smtpHost;
        port = if useStartTls then 587 else 465;
        tls = {
          enable = true;
          inherit useStartTls;
        };
      };
    }
    extraConfig
  );
  
in {
  options.custom.mail.enable = mkOption {
    example = true;
    default = false;
  };

  config = mkIf cfg.enable {
    home-manager.users.rien = { ... }: {
      accounts.email = {
        maildirBasePath = "/home/rien/mail";
        accounts = builtins.listToAttrs (
          builtins.map
            (account: {
              name = "${account}";
              value = makeAccount (
                personal.emailAccounts.${account} // { name = "${account}"; }
              );
            })
            (builtins.attrNames personal.emailAccounts)
        );
      };
      programs = {
        mbsync.enable = true;
        msmtp.enable = true;
        alot.enable = true;
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
