# Darwin: Colima + Docker CLI tooling on the system profile
# Export as flake.modules.darwin.docker

{ ... }:
{
  flake.modules.darwin.docker =
    { pkgs, ... }:
    {
      # Use unstable Colima + lima-full (Lima 2.x); stable 25.11 pairs Colima with EOL Lima 1.2.2.
      environment.systemPackages = with pkgs; [
        unstable.colima
        docker-client
        docker-compose
        docker-buildx
        docker-credential-helpers
      ];
    };
}
