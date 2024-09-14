_:
{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.settings.trusted-users = [ "remotebuild" ];

  nix.buildMachines = [
    {
      hostName = "localhost";
      system = "aarch64-linux";
      supportedFeatures = [ "benchmark" "big-parallel" "gccarch-armv8-a" "kvm" "nixos-test" ];
      protocol = null;
      speedFactor = 1;
    }
    {
      hostName = "boojum.meep.sh";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/builder_boojum";
      systems = [ "x86_64-linux" ];
      supportedFeatures = [ "nixos-test" "big-parallel" "kvm" "benchmark" "ca-derivations" ];
      protocol = "ssh-ng";
      maxJobs = 2;
      speedFactor = 4;
    }
    {
      hostName = "ash.meep.sh";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/builder_ash";
      systems = [ "aarch64-linux" ];
      supportedFeatures = [ "nixos-test" "benchmark" ];
      protocol = "ssh-ng";
      maxJobs = 1;
      speedFactor = 1;
    }
  ];
}
