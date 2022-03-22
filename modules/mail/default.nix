{ config, pkgs, lib, ... }:
with lib;
let
  passwordScript = pkgs.writeShellScript "get_mail_password" ''
    ${pkgs.pass}/bin/pass show "$@" | head -n1 | tr -d "\n"
  '';
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
    folders ? null, oauth ? null
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
      folders = mkIf (folders != null) folders;
      mbsync = {
        enable = mbsync;
        create = "both";
        expunge = "both";
        flatten = ".";
        remove = "both";
        patterns = mkIf (folders != null) (lib.attrsets.attrValues folders);
        extraConfig.account.AuthMechs = if (oauth != null)
          then "XOAUTH2"
          else "LOGIN";
      };
      msmtp = {
        enable = true;
        extraConfig = mkIf (oauth != null) { auth = "xoauth2"; };
      };
      alot = {
        sendMailCommand = "${pkgs.msmtp}/bin/msmtp --read-recipients --read-envelope-from --account ${name}";
        contactCompletion = {
          type = "shellcommand";
          command = "${pkgs.notmuch-addrlookup}/bin/notmuch-addrlookup";
          regexp = "(?P<name>.*).*<(?P<email>.+)>";
          ignorecase = "True";
        };
      };
      passwordCommand = if oauth == null
        then "${passwordScript} ${passFile}"
        else "${pkgs.mfauth}/bin/mfauth access ${name}";
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

  imports = [ ./fetcher.nix ];

  options.custom.mail.enable = mkOption {
    example = true;
    default = false;
  };

  config = mkIf cfg.enable {

    nixpkgs.overlays = [(self: super: rec {
      cyrus_sasl_xoauth2_plugin = self.callPackage ../../packages/cyrus_sasl_xoauth2.nix {
        cyrus_sasl = super.cyrus_sasl;
      };
      cyrus_sasl_with_xoauth2 = super.cyrus_sasl.overrideAttrs (oldAttrs: {
        postInstall =
          ''
          for i in $(find ${self.cyrus_sasl_xoauth2_plugin}/lib/sasl2/ -mindepth 1); do
            ln -s $i $out/lib/sasl2/
          done
          '';
        });
        isync = super.isync.override {
          cyrus_sasl = cyrus_sasl_with_xoauth2;
        };
    })];

    home-manager.users.${config.custom.user} = { ... }: {
      home.packages = with pkgs; [ mfauth ];
      xdg.configFile."mfauth/config.toml".source = toml.generate
      "mfauth-config.toml"
      {
        accounts = eachAccount ({ oauth ? null, ... }: oauth );
      };
      accounts.email = {
        maildirBasePath = "/home/${config.custom.user}/mail";
        accounts = eachAccount makeAccount;
      };
      programs = {
        mbsync.enable = true;
        msmtp.enable = true;
        alot = let
          dmenu = "${pkgs.dmenu}/bin/dmenu";
          urlscan = "${pkgs.urlscan}/bin/urlscan";
          xdg-open = "${pkgs.xdg_utils}/bin/xdg-open";
          selecturl = pkgs.writeScript
            "selecturl"
            "${urlscan} -n | ${dmenu} | xargs --no-run-if-empty ${xdg-open}";
        in {
          enable = true;
          settings = {
            initial_command = "search tag:inbox";
          };
          bindings = {
            global = {
              "0" = "taglist";
              "1" = "search tag:inbox";
              "2" = "search tag:sent";
              "3" = "search tag:sent";
              "r" = "refresh";
            };
            search = {
              "x" = "toggletags killed";
            };
            thread = {
              "a" = "toggletags inbox";
              "A" = "untag inbox ; bclose ; refresh";
              "n" = "move next";
              "N" = "move previous";
              "r" = "reply --all";
              "R" = "reply";
              "u" = "pipeto --background ${selecturl}";
            };
          };
          extraConfig = "hooksfile = ${./alothook.py}";
        };
        afew = {
          enable = true;
          extraConfig = ''
            # Marks mail with 'spam' header
            [SpamFilter]

            # UGent sometimes still sends spam
            # but with [SPAM] as subject ...
            [HeaderMatchingFilter.0]
            header = Subject
            pattern = ^\[SPAM\]
            tags = +spam

            [HeaderMatchingFilter.1]
            header = From
            pattern = logcheck@
            tags = +logcheck

            [HeaderMatchingFilter.2]
            header = From
            pattern = dodona@ugent.be
            tags = +dodona

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
        application/pdf; ${pkgs.okular}/bin/okular %s
        image/png; ${pkgs.okular}/bin/okular %s
        image/jpeg; ${pkgs.okular}/bin/okular %s
      '';
    };
  };
}
