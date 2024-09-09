{ pkgs, ... }:
{
  nix.distributedBuilds = true;
  # nix.settings.builders-use-substitutes = true;

  systemd.services.hydra-evaluator.environment.GC_DONT_GC = "true";  # REF: <https://github.com/NixOS/nix/issues/4178#issuecomment-738886808>
  nix.buildMachines = [
    {
      hostName = "localhost";
      system = "aarch64-linux";
      supportedFeatures = [ "nixos-test" ];
      protocol = null;
      maxJobs = 1;
      speedFactor = 1;
    }
    {
      hostName = "boojum.meep.sh";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/builder_boojum";
      systems = [ "x86_64-linux" ];
      supportedFeatures = [ "nixos-test" "big-parallel" "kvm" "benchmark" ];
      protocol = "ssh-ng";
      maxJobs = 2;
      speedFactor = 4;
    }
  ];
}
