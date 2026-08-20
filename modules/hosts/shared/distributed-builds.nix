# Distributed-build consumer module.
# Enables remote builds and registers all fleet builders (minus this host).
# Import on every NixOS host that should be able to delegate builds.
{
  config,
  lib,
  vars,
  ...
}:
let
  host = config.networking.hostName;
  # Full fleet minus self (a host never delegates to itself).
  remoteBuilders = lib.filter (m: m.hostName != host) vars.builders;
  knownHosts = lib.filterAttrs (name: _: name != host) vars.builderHostKeys;
in
{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  # `remotebuild` must be trusted on consumers too (it owns the SSH key).
  nix.settings.trusted-users = [ "remotebuild" ];

  nix.buildMachines = map (m: {
    inherit (m)
      hostName
      systems
      speedFactor
      maxJobs
      supportedFeatures
      publicHostKey
      ;
    protocol = "ssh-ng";
    sshUser = "remotebuild";
    sshKey = vars.remotebuildKey;
  }) remoteBuilders;

  # Shared remotebuild SSH private key (deployed by sops from nix-secrets).
  # The nix-daemon (root) reads this to authenticate to remote builders.
  sops.secrets."private_keys/remotebuild" = {
    path = vars.remotebuildKey;
    owner = "root";
    mode = "0600";
  };

  # Fail fast on unreachable builders instead of blocking for the OS TCP
  # timeout (~2min, worse on Tailscale where offline nodes drop packets
  # silently).  ServerAlive also detects builders that die mid-build.
  programs.ssh.extraConfig = ''
    Host ${lib.concatStringsSep " " (map (m: m.hostName) vars.builders)}
      ConnectTimeout 10
      ServerAliveInterval 15
      ServerAliveCountMax 3
  '';

  programs.ssh.knownHosts = lib.mapAttrs (name: key: {
    hostNames = [ name ];
    publicKey = key;
  }) knownHosts;
}
