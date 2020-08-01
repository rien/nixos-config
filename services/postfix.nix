{ ... }:
{
  services.postfix = {
    enable = true;
    hostname = "transmission.vm";
    domain = "transmission.vm";
    networksStyle = "host";

    enableSmtp = true;        # Receiving mail from other mail servers
    enableSubmission = true;  # Submitting (sending) new emails

    recipientDelimiter = "+";

    extraConfig = "
    # disable \"new mail\" notifications for local unix users
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

    # require addresses of the form \"user@domain.tld\"
    allow_percent_hack = no
    swap_bangpath = no
    ";

  };
}
