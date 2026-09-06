# aerc — TUI mail client for jack@meep.sh.
#
# IMAP (993) and SMTP submission (587 STARTTLS) both terminate on maple over
# Tailscale. The raw login password is the `mail/password-plain` sops secret
# (maple's side of the same credential is the `mail-password` dovecot
# passwd-file hash). unsafe-accounts-conf is required by home-manager (it
# renders accounts.conf into the world-readable store); the password is only
# fetched at runtime via passwordCommand, so nothing secret lands in the
# store.
{
  config,
  pkgs,
  vars,
  ...
}:
{
  programs.aerc = {
    enable = true;
    extraConfig = {
      general.unsafe-accounts-conf = true;
      # On macOS aerc's default opener is `open`, which has no handler for
      # .asc (PGP/unknown parts) and exits 1. View text-ish parts in the
      # pager instead; other types (images, pdfs) still use `open`.
      openers."text/*" = "less -R";
      openers."message/*" = "less -R";
      openers."application/pgp-signature" = "less -R";
    };
  };

  accounts.email.accounts.meep = {
    address = "jack@${vars.domain}";
    realName = "Jack Bartlett";
    userName = "jack";
    primary = true;
    imap = {
      host = "maple.${vars.domain}";
      port = 993;
      tls.enable = true;
    };
    smtp = {
      host = "maple.${vars.domain}";
      port = 587;
      tls.enable = true;
      tls.useStartTls = true;
    };
    aerc.enable = true;
    passwordCommand = "cat ${config.sops.secrets."mail/password-plain".path}";
  };

  sops.secrets."mail/password-plain" = { };
}
