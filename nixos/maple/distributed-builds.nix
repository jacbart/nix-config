{ ... }:
{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.settings.trusted-users = [ "remotebuild" ];

  nix.buildMachines = [
    {
      hostName = "localhost";
      protocol = null;
      system = "aarch64-linux";
      supportedFeatures = [ "benchmark" "big-parallel" "gccarch-armv8-a" "kvm" "nixos-test" ];
      speedFactor = 1;
    }
    {
      hostName = "boojum.meep.sh";
      protocol = "ssh";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/builder_boojum";
      systems = [ "x86_64-linux" "aarch64-linux" "riscv64" "arm" ];
      supportedFeatures = [ "nixos-test" "big-parallel" "kvm" "benchmark" ];
      maxJobs = 2;
      speedFactor = 4;
    }
    {
      hostName = "ash.meep.sh";
      protocol = "ssh";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/builder_ash";
      systems = [ "aarch64-linux" ];
      supportedFeatures = [ "nixos-test" "benchmark" ];
      maxJobs = 1;
      speedFactor = 2;
    }
  ];

  programs.ssh.knownHosts = {
    boojum = {
      extraHostNames = [ "boojum.meep.sh" "192.168.1.3" ];
      publicKeyFile = ../boojum/remotebuild.pub;
    };
    ash = {
      extraHostNames = [ "ash.meep.sh" "192.168.1.4" ];
      publicKeyFile = ../ash/remotebuild.pub;
    };
  };
}
