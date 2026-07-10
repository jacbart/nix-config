# Darwin: Colima + Docker CLI tooling on the system profile
# Export as flake.modules.darwin.docker

{ ... }:
{
  flake.modules.darwin.docker =
    { pkgs, ... }:
    {
      # Stable 26.05 ships Colima + lima-full 2.1.3 (non-EOL); no need for unstable.
      # Unstable's lima-full 2.1.4 currently fails to build on aarch64-darwin due to
      # a cctools-binutils-darwin-1010.6 ld SIGTRAP when linking limactl.
      environment.systemPackages = with pkgs; [
        colima
        docker-client
        docker-compose
        docker-buildx
        docker-credential-helpers
      ];
    };
}
