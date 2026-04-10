# Logical service layout: public names, backends, and local binds.
# Change backend hostnames here when moving workloads between machines.
{ domain }:
let
  mapleFqdn = "maple.${domain}";
  # Hosts that reach maple’s services over Tailscale (same IP on ash / oak).
  mapleClientHostsOnTailscale = [
    "maple.${domain}"
    "s3.${domain}"
    "books.${domain}"
    "auth.${domain}"
    "minio.${domain}"
    "cloud.${domain}"
    "wiki.${domain}"
  ];
in
{
  leadershipMatrix = {
    bindHost = "127.0.0.2";
    bindPort = "13121";
  };

  matrixEdge = {
    publicHost = "matrix.${domain}";
    backendTarget = "${mapleFqdn}:8008";
    accessLogBase = "matrix.${domain}";
  };

  mxEdge = {
    publicHost = "mx.${domain}";
    backendTarget = "${mapleFqdn}:443";
    accessLogBase = "mx.${domain}";
  };

  # /etc/hosts entries keyed by NixOS hostName (see service-catalog-hosts.nix).
  localVhosts = {
    maple = {
      "127.0.0.2" = [
        "maple.${domain}"
        "auth.${domain}"
        "books.${domain}"
        "cloud.${domain}"
        "minio.${domain}"
        "s3.${domain}"
        "wiki.${domain}"
        "kosync.${domain}"
        "mail.${domain}"
      ];
      "100.78.207.83" = [
        "unicron"
        "unicron.bbl.systems"
      ];
      "10.120.0.1" = [
        "mesquite"
        "mesquite.${domain}"
      ];
    };
    oak = {
      "127.0.0.2" = [
        "oak.${domain}"
        "matrix.${domain}"
        "mx.${domain}"
        "tun.${domain}"
        "mail.${domain}"
      ];
      "100.116.178.48" = mapleClientHostsOnTailscale;
    };
    ash = {
      "127.0.0.2" = [ "ash.${domain}" ];
      "100.116.178.48" = mapleClientHostsOnTailscale;
    };
    boojum = {
      "127.0.0.2" = [
        "boojum.${domain}"
        "remote.dev"
      ];
    };
    cork = {
      "127.0.0.2" = [
        "cork.${domain}"
        "remote.dev"
      ];
    };
    mesquite = {
      "127.0.0.2" = [
        "mesquite"
        "mesquite.${domain}"
      ];
    };
  };
}
