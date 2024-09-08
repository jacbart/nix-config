{ pkgs, ... }:
{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      hostName = "boojum.meep.sh";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/builder_boojum";
      system = pkgs.stdenv.hostPlatform;
      supportedFeatures = [ "nixos-test" "big-parallel" "kvm" ];
    }
  ];
}
