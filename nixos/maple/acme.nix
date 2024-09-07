{ config, ... }: {
  sops.secrets."acme_environment" = { };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "cert+admin@meep.sh";
      dnsProvider = "rfc2136";
      dnsResolver = "192.168.1.1:53";
      environmentFile = config.sops.secrets."acme_environment".path;
      dnsPropagationCheck = false;
    };
    # certs."meep.sh" = {
    #   webroot = "/var/lib/acme/challenges-meep";
    #   email = "cert+admin@meep.sh";
    #   group = "nginx";
    #   extraDomainNames = [
    #     "ca.meep.sh"
    #     "cloud.meep.sh"
    #     "maple.meep.sh"
    #     "minio.meep.sh"
    #     "s3.meep.sh"
    #   ];
    # };
    # certs."bbl.systems" = {
    #   webroot = "/var/lib/acme/challenges-bbl";
    #   email = "cert+admin@bbl.systems";
    #   group = "nginx";
    #   extraDomainNames = [
    #     "cloud.bbl.systems"
    #   ]; services/faceif/authenticated_get.go both paravision and innovactics
    # }; services/liveness/check_test image, gen image, store it with image and auth with it, auth
  };

  # systemd.services.dns-rfc2136-conf = {
  #   requiredBy = ["acme-example.com.service" "bind.service"];
  #   before = ["acme-example.com.service" "bind.service"];
  #   unitConfig = {
  #     ConditionPathExists = "!/var/lib/secrets/dnskeys.conf";
  #   };
  #   serviceConfig = {
  #     Type = "oneshot";
  #     UMask = 0077;
  #   };
  #   path = [ pkgs.bind ];
  #   script = ''
  #     mkdir -p /var/lib/secrets
  #     chmod 755 /var/lib/secrets
  #     tsig-keygen rfc2136key.example.com > /var/lib/secrets/dnskeys.conf
  #     chown named:root /var/lib/secrets/dnskeys.conf
  #     chmod 400 /var/lib/secrets/dnskeys.conf

  #     # extract secret value from the dnskeys.conf
  #     while read x y; do if [ "$x" = "secret" ]; then secret="''${y:1:''${#y}-3}"; fi; done < /var/lib/secrets/dnskeys.conf

  #     cat > /var/lib/secrets/certs.secret << EOF
  #     RFC2136_NAMESERVER='127.0.0.1:53'
  #     RFC2136_TSIG_ALGORITHM='hmac-sha256.'
  #     RFC2136_TSIG_KEY='rfc2136key.example.com'
  #     RFC2136_TSIG_SECRET='$secret'
  #     EOF
  #     chmod 400 /var/lib/secrets/certs.secret
  #   '';
  # };
}
