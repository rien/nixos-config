{ config, lib, pkgs, util, ... }:
with lib;
let
  inherit (lib.strings) concatStringsSep;
  cfg = config.custom.postfix;
  host = "space.rxn.be";
  aliases = import ./aliases.secret.nix;
  domains = [ host ] ++ aliases.virtualDomains;
in
{

  options.custom.postfix = {
    enable = mkOption {
      default = false;
      example = true;
    };

    loginFile = mkOption {
      example = "/var/run/postfix-sasl";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = [ 25 587 ];
    users.users.postfix.extraGroups = [ "acme" ];

    services.opendkim = {
      enable = true;
      group = "postfix";
      domains = concatStringsSep "," domains;
      selector = "opendkim";
      configFile = pkgs.writeTextFile {
        name = "opendkim.conf";
        text = ''
        FixCRLF true
        Canonicalization relaxed/simple
        UMask 007
        '';
      };
    };

    environment.etc = {
      "sasl2/smtpd.conf" = {
        text = ''
        pwcheck_method: auxprop
        auxprop_plugin: sasldb
        mech_list: PLAIN LOGIN
        '';
      };
    };

    system.activationScripts = {
      sasldb = {
        deps = [];
        text = ''
        export PATH=${pkgs.stdenv}/bin:${pkgs.gnused}/bin:${pkgs.cyrus_sasl}/bin:$PATH
        username="$(cat ${cfg.loginFile} | sed 's/\(\w*\) \(\w*\)/\1/')"
        password="$(cat ${cfg.loginFile} | sed 's/\(\w*\) \(\w*\)/\2/')"
        rm /etc/sasldb2
        echo "$password" | saslpasswd2 -p -c -u "${host}" "$username"
        chown root:postfix /etc/sasldb2
        '';
      };
    };

    security.dhparams.enable = true;
    security.dhparams.params.postfix = {};

    services.postfix = {
      enable = true;
      hostname = host;
      domain = host;
      networksStyle = "host";

      config = {
        smtp_tls_security_level = "may";
        smtpd_tls_chain_files = [
          "/var/lib/acme/${ util.baseDomain host }/key.pem"
          "/var/lib/acme/${ util.baseDomain host }/fullchain.pem"
        ];
      };

      enableSmtp = true;        # Receiving mail from other mail servers

      enableSubmission = true;  # Submitting (sending) new emails
      submissionOptions = {
        smtpd_tls_security_level = "encrypt";
        tls_preempt_cipherlist="yes";
        milter_macro_daemon_name = "ORIGINATING";
      };

      recipientDelimiter = "+";

      extraAliases = aliases.alias;
      virtual = aliases.virtual;

      extraConfig = ''
      virtual_alias_domains = ${concatStringsSep ", " aliases.virtualDomains}

      # DKIM (and other milters)
      milter_default_action = accept
      milter_protocol = 2
      smtpd_milters = unix:/run/opendkim/opendkim.sock
      non_smtpd_milters = unix:/run/opendkim/opendkim.sock

      # disable "new mail" notifications for local unix users
      biff = no

      # prevent spammers from searching for valid users
      disable_vrfy_command = yes

      # require properly formatted email addresses - prevents a lot of spam
      strict_rfc821_envelopes = yes

      # don't give any helpful info when a mailbox doesn't exist
      show_user_unknown_table_name = no

      # limit maximum e-mail size to 50MB. mailbox size must be at least as big as
      # the message size for the mail to be accepted, but has no meaning after
      # that since we are using Dovecot for delivery.
      message_size_limit = 51200000
      mailbox_size_limit = 51200000

      # require addresses of the form "user@domain.tld"
      allow_percent_hack = no
      swap_bangpath = no

      # These two lines define how postfix will connect to other mail servers.
      # DANE is a stronger form of opportunistic TLS. You can read about it here:
      # http://www.postfix.org/TLS_README.html#client_tls_dane
      # smtp_tls_security_level = dane -- already set trough NixOS
      smtp_dns_support_level = dnssec

      smtpd_tls_auth_only = yes
      smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
      smtpd_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
      smtpd_tls_mandatory_ciphers = medium

      smtpd_tls_dh1024_param_file = ${ config.security.dhparams.params.postfix.path }

      tls_medium_cipherlist = ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
      tls_preempt_cipherlist = no


      # cache incoming and outgoing TLS sessions
      smtpd_tls_session_cache_database = btree:''${data_directory}/smtpd_tlscache
      smtp_tls_session_cache_database  = btree:''${data_directory}/smtp_tlscache

      # enable SMTPD auth.
      smtpd_sasl_auth_enable = yes
      smtpd_sasl_path = smtpd
      smtpd_sasl_type = cyrus

      # don't allow plaintext auth methods on unencrypted connections
      smtpd_sasl_security_options = noanonymous, noplaintext, nodictionary, forward_secrecy, mutual_auth
      # but plaintext auth is fine when using TLS
      smtpd_sasl_tls_security_options = noanonymous

      # add a message header when email was recieved over TLS
      smtpd_tls_received_header = yes

      # require that connecting mail servers identify themselves - this greatly
      # reduces spam
      smtpd_helo_required = yes

      # The following block specifies some security restrictions for incoming
      # mail. The gist of it is, authenticated users and connections from
      # localhost can do anything they want. Random people connecting over the
      # internet are treated with more suspicion: they must have a reverse DNS
      # entry and present a valid, FQDN HELO hostname. In addition, they can only
      # send mail to valid mailboxes on the server, and the sender's domain must
      # actually exist.
      smtpd_client_restrictions =
              permit_mynetworks,
              permit_sasl_authenticated,
              reject_unknown_reverse_client_hostname,
              reject_unauth_pipelining


      # The following block specifies some security restrictions for incoming
      # mail. The gist of it is, authenticated users and connections from
      # localhost can do anything they want. Random people connecting over the
      # internet are treated with more suspicion: they must have a reverse DNS
      # entry and present a valid, FQDN HELO hostname. In addition, they can only
      # send mail to valid mailboxes on the server, and the sender's domain must
      # actually exist.
      smtpd_client_restrictions =
              permit_mynetworks,
              permit_sasl_authenticated,
              reject_unknown_reverse_client_hostname,
              reject_unauth_pipelining

      smtpd_sender_restrictions =
              permit_mynetworks,
              permit_sasl_authenticated,
              reject_non_fqdn_sender,
              reject_unknown_sender_domain,
              reject_unauth_pipelining

      smtpd_relay_restrictions =
              permit_mynetworks,
              permit_sasl_authenticated,
              # !!! THIS SETTING PREVENTS YOU FROM BEING AN OPEN RELAY !!!
              reject_unauth_destination
              # !!!      DO NOT REMOVE IT UNDER ANY CIRCUMSTANCES      !!!

      smtpd_recipient_restrictions =
              permit_mynetworks,
              permit_sasl_authenticated,
              reject_non_fqdn_recipient,
              reject_unknown_recipient_domain,
              reject_unauth_pipelining,
              reject_unverified_recipient

      smtpd_data_restrictions =
              permit_mynetworks,
              permit_sasl_authenticated,
              reject_multi_recipient_bounce,
              reject_unauth_pipelining
      '';

    };

  };
}
