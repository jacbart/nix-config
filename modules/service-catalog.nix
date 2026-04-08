# Logical service layout: public names, backends, and local binds.
# Change backend hostnames here when moving workloads between machines.
{ domain }:
let
  mapleFqdn = "maple.${domain}";
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
}
