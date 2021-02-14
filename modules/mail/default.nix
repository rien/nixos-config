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
    userName ? address, signature ? personal.defaultSignature
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
        text = signature;
        showSignature = "append";
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
        alot = let
          dmenu = "${pkgs.dmenu}/bin/dmenu";
          urlscan = "${pkgs.urlscan}/bin/urlscan";
          xdg-open = "${pkgs.xdg-utils}/bin/xdg-open";
          selecturl = pkgs.writeScript
            "selecturl"
            "${urlscan} -n | ${dmenu} | xargs --no-run-if-empty ${xdg-open}";
        in {
          enable = true;
          settings = {
            initial_command = "search tag:inbox";
            hooksfile = ./alothook.py
          };
          bindings = {
            "0" = "taglist";
            "1" = "search tag:inbox";
            "2" = "search tag:sent";
            "3" = "search tag:sent";
            "r" = "refresh";
            search = {
              "x" = "toggletags killed";
            };
            thread = {
              "a" = "toggletags inbox"
              "A" = "untag inbox ; bclose ; refresh"
              "n" = "move next"
              "N" = "move previous"
              "r" = "reply --all"
              "R" = "reply"
              "u" = "pipeto --background ${selecturl}";
            };
          };
        };
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

      home.file.".mailcap".text = ''
        text/html; ${pkgs.firefox}/bin/firefox %s ; nametemplate=%s.html; needsterminal
        text/html; ${pkgs.w3m}/bin/w3m -dump -o display_link_number=1 -o document_charset=%{charset} %s ; copiousoutput; nametemplate=%s.html
        text/calendar; ${pkgs.khal}/bin/khal import %s;
        application/pdf; ${pkgs.okular}/bin/okular %s
        image/png; ${pkgs.okular}/bin/okular %s
        image/jpeg; ${pkgs.okular}/bin/okular %s
      '';
    };
  };
}
