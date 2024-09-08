{ pkgs, ... }:
{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      hostName = "boojum.meep.sh";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/builder_boojum";
      system = "x86_64-linux";
      supportedFeatures = [ "nixos-test" "big-parallel" "kvm" ];
    }
  ];
}
