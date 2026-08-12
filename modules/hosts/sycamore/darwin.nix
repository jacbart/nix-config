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

          # macOS Screen Sharing (VNC on :5900) for remote access over
          # Tailscale. The ARD kickstart activates the agent, enables access
          # for all users, and turns on legacy VNC so standard VNC clients
          # (e.g. TigerVNC viewer on ash) can connect. Auth is the macOS
          # user's login credentials. The Tailscale cask is installed via
          # nix-homebrew.nix; open the Tailscale app once to log in.
          # NOTE: Screen Sharing listens on all interfaces — macOS's
          # Application Firewall (if enabled) scopes it to allowed clients.
          # For Tailscale-only access, ensure the firewall is on and deny
          # public network access, or rely on the Tailscale IP for connectivity.
          system.activationScripts.enableScreenSharing.text = ''
            /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
              -activate \
              -configure -access -on \
              -configure -allowAccessFor -allUsers \
              -configure -clientopts -setvnclegacy -vnclegacy yes \
              -configure -restart -agent -privs -all
          '';
        }
      )
    ];
  };
}
