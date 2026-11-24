# deploy-rs node registry, generated from the nixosHosts/darwinHosts
# registries in ../configurations.nix. Only hosts listed in
# vars.deployHosts are deploy targets — see modules/vars.nix for the
# rollout-allowlist rationale.
{
  config,
  inputs,
  vars,
  lib,
  ...
}:
let
  # mesquite is the LAN gateway itself and isn't on the tailnet (see the
  # same exception in modules/home/shell/profiles/base.nix) — reach it via
  # its LAN address instead.
  deployHostName =
    name:
    if name == "mesquite" then
      vars.lanGateway
    else
      vars.tailscaleIps.${name} or (throw "modules/flake/deploy.nix: no vars.tailscaleIps entry for host '${name}'");

  # oak's sshd listens on a non-default port, and — being a DigitalOcean
  # droplet — root's key there was provisioned out-of-band by DO at
  # creation, not by this flake. It's only reachable as root via a
  # dedicated key (same exception already encoded in
  # modules/home/shell/profiles/base.nix's SSH config for "oak").
  sshOptsFor =
    name:
    if name == "oak" then
      [
        "-p"
        "3048"
        "-i"
        "~/.ssh/id_do"
      ]
    else
      [ ];

  # Admin users (meep/ratatoskr) have no root SSH key and no passwordless
  # sudo configured — deploy as the host's normal admin user and let
  # deploy-rs prompt for the sudo password interactively, same as the
  # manual `sudo nixos-rebuild switch` / `nh os switch --ask` flow.
  # oak is the one exception: it's reached directly as root (see above),
  # so no sudo escalation is needed there.
  mkNixosNode =
    name:
    let
      sshUser = if name == "oak" then "root" else config.nixosHosts.${name}.username;
      user = "root";
    in
    {
      hostname = deployHostName name;
      inherit sshUser;
      sshOpts = sshOptsFor name;
      profiles.system = {
        inherit user;
        interactiveSudo = sshUser != user;
        path = inputs.deploy-rs.lib.${config.nixosHosts.${name}.system}.activate.nixos (
          config.flake.nixosConfigurations.${name}
        );
      };
    };

  mkDarwinNode = name: {
    hostname = deployHostName name;
    sshUser = config.darwinHosts.${name}.username;
    profiles.system = {
      user = "root";
      interactiveSudo = true;
      path =
        inputs.deploy-rs.lib.${config.flake.darwinConfigurations.${name}.pkgs.stdenv.hostPlatform.system}.activate.darwin
          config.flake.darwinConfigurations.${name};
    };
  };
in
{
  # No perSystem.checks = deployChecks here: this fleet mixes NixOS and
  # Darwin targets with no darwin remote builder registered anywhere
  # (modules/vars.nix's `builders` list is all-Linux), so building every
  # node's activation closure — including sycamore's — is only possible
  # from an actual aarch64-darwin machine. `deploy`'s own eval + per-node
  # build (run against whichever single host you target) already catches
  # real problems without that bootstrapping requirement.
  flake.deploy.nodes =
    lib.genAttrs vars.deployHosts.nixos mkNixosNode // lib.genAttrs vars.deployHosts.darwin mkDarwinNode;
}
