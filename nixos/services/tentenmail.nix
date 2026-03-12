{
  config,
  vars,
  ...
}:
{
  imports = [
    (builtins.fetchTarball {
      # This is a quick and dirty way to import a NixOS mailserver release. What
      # you should do long-term is use a proper dependency pinning tool like npins
      # or flakes.

      # URL to the tarball for the release matching your NixOS release
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-25.11/nixos-mailserver-nixos-25.11.tar.gz";

      # Hash of the unpacked tarball, run the following command to retrieve it
      # release="nixos-25.11" nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      sha256 = "0pqc7bay9v360x2b7irqaz4ly63gp4z859cgg5c04imknv0pwjqw";
    })
  ];

  # Enable ACME HTTP-01 challenge with nginx
  services.nginx.virtualHosts.${config.mailserver.fqdn}.enableACME = true;

  mailserver = {
    enable = true;
    stateVersion = 3;
    fqdn = "mail.${vars.domain}";
    domains = [ "${vars.domain}" ];

    # Reference the existing ACME configuration created by nginx
    x509.useACMEHost = config.mailserver.fqdn;

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -s'
    loginAccounts = {
      "jack@${vars.domain}" = {
        # Reads the password hash from a file on the server
        hashedPasswordFile = config.sops.secrets.ratatoskr-password.path;

        # Additional addresses delivered to this mailbox
        aliases = [ "postmaster@${vars.domain}" ];
      };
    };
  };
}
