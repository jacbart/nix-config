{ config, ... }:
{
  darwinHosts.sycamore = {
    username = "jackbartlett";
    modules = [
      config.flake.modules.darwin.laptop
      (
        { ... }:
        {
          # Declarative Colima VM config + nix remote builder bootstrap.
          # See modules/darwin/colima.nix for the full option schema.
          colima.profiles.default = {
            cpu = 6;
            memory = 16;
            disk = 100;
            arch = "aarch64";
            runtime = "docker";
            vmType = "vz";
            mountType = "virtiofs";
            mountInotify = true;
            forwardAgent = true;
            autoActivate = true;
            network.address = true;
            sshConfig = true;
            sshPort = 0;
            hostname = "colima";
            portForwarder = "ssh";
            rosetta = false;
            binfmt = true;

            builder = {
              enable = true;
              authorizedKey = builtins.readFile ./colima-builder.pub;
              hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvJR2xPpXLBfD+QmKhHz2r6UK+7kASNcYOk6q7H7sl3 root@colima";
              hostName = "192.168.64.2";
              sshKey = "/Users/jackbartlett/.ssh/id_colima_builder";
              maxJobs = 4;
              speedFactor = 5;
              systems = [ "aarch64-linux" ];
              supportedFeatures = [
                "big-parallel"
                "benchmark"
              ];
            };
          };
        }
      )
    ];
  };
}
