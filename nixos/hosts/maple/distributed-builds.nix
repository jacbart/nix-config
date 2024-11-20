{ ... }:
{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.settings.trusted-users = [ "remotebuild" ];

  nix.buildMachines = [
    # {
    #   hostName = "localhost";
    #   protocol = null;
    #   system = "aarch64-linux";
    #   supportedFeatures = [ "benchmark" "big-parallel" "gccarch-armv8-a" "kvm" "nixos-test" ];
    #   speedFactor = 1;
    # }
    {
      hostName = "boojum.meep.sh";
      protocol = "ssh";
      sshUser = "remotebuild";
      sshKey = "~/.ssh/builder_boojum";
      systems = [ "x86_64-linux" ];
      supportedFeatures = [ "nixos-test" "big-parallel" "kvm" "benchmark" ];
      maxJobs = 2;
      speedFactor = 4;
    }
    # {
    #   hostName = "ash.meep.sh";
    #   protocol = "ssh";
    #   sshUser = "remotebuild";
    #   sshKey = "~/.ssh/builder_ash";
    #   systems = [ "aarch64-linux" ];
    #   supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" ];
    #   maxJobs = 1;
    #   speedFactor = 2;
    # }
  ];

  programs.ssh.knownHosts = {
    boojum = {
      extraHostNames = [ "boojum.meep.sh" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE4MTXIg+HPG7g8ZKCReM2nRMcC3+m3MPStHL5sw9E7H";
    };
    ash = {
      extraHostNames = [ "ash.meep.sh" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQCfoMseiQ9Ddr9boq7bnGvMdK6egjvshXptsWXgNsu";
    };
  };
}
