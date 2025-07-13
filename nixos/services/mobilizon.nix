_:
let
  domain = "meep.sh";
in
{
  services.mobilizon = {
    enable = true;
    nginx.enable = true;
    settings =
      # let
      #   # These are helper functions, that allow us to use all the features of the Mix configuration language.
      #   # - mkAtom and mkRaw both produce "raw" strings, which are not enclosed by quotes.
      #   # - mkGetEnv allows for convenient calls to System.get_env/2
      #   inherit ((pkgs.formats.elixirConf { }).lib) mkAtom mkGetEnv;
      # in
      {
        ":mobilizon" = {
          # General information about the instance
          ":instance" = {
            name = "events";
            description = "Event management with a mobilizon instance";
            hostname = "events.${domain}";
          };
          "Mobilizon.Web.Endpoint" = {
            http = {
              port = 4000;
            };
          };

          # # SMTP configuration
          # "Mobilizon.Web.Email.Mailer" = {
          #   adapter = mkAtom "Swoosh.Adapters.SMTP";
          #   relay = "your.smtp.server";
          #   # usually 25, 465 or 587
          #   port = 587;
          #   username = "mail@your-mobilizon-domain.com";
          #   # See "Providing a SMTP password" below
          #   password = mkGetEnv { envVariable = "SMTP_PASSWORD"; };
          #   tls = mkAtom ":always";
          #   allowed_tls_versions = [
          #     (mkAtom ":tlsv1")
          #     (mkAtom ":\"tlsv1.1\"")
          #     (mkAtom ":\"tlsv1.2\"")
          #   ];
          #   retries = 1;
          #   no_mx_lookups = false;
          #   auth = mkAtom ":always";
          # };
        };
      };
  };
}
