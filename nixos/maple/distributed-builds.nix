{ pkgs, ... }:
{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      hostName = "localhost";
      system = "aarch64-linux";
      supportedFeatures = [ "nixos-test" ];
      protocol = null;
      maxJobs = 2;
      speedFactor = 1;
    }
    {
      hostName = "boojum.meep.sh";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/builder_boojum";
      systems = [ "x86_64-linux" ];
      supportedFeatures = [ "nixos-test" "big-parallel" "kvm" "benchmark" ];
      protocol = "ssh-ng";
      maxJobs = 4;
      speedFactor = 4;
    }
  ];
}
