# Darwin: Docker CLI tooling on the system profile
# Export as flake.modules.darwin.docker
#
# Colima itself is installed by flake.modules.darwin.colima (modules/darwin/colima.nix)
# since it also manages the colima.yaml config and builder provisioning.

{ ... }:
{
  flake.modules.darwin.docker =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        docker-client
        docker-compose
        docker-buildx
        docker-credential-helpers
      ];
    };
}
