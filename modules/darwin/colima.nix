# Declarative Colima VM management for nix-darwin.
# Export as flake.modules.darwin.colima
#
# Provides:
#   - options.colima.profiles.<name>.* mirroring the full colima.yaml schema
#   - YAML rendering to ~/.colima/<name>/colima.yaml via activation script
#   - Optional Nix remote-builder bootstrap inside the VM via provision scripts
#
# Out-of-band steps when enabling the builder on a new host:
#   1. Generate a builder keypair:
#        ssh-keygen -t ed25519 -f ~/.ssh/id_colima_builder -N "" -C "<host>-builder@colima"
#   2. Commit the pubkey to modules/hosts/<host>/colima-builder.pub
#   3. Download the Determinate nix-installer binary to the mounted dir:
#        mkdir -p ~/.local/share/colima-provision
#        curl -fsSL -o ~/.local/share/colima-provision/nix-installer \
#          https://github.com/DeterminateSystems/nix-installer/releases/latest/download/nix-installer-aarch64-linux
#        chmod +x ~/.local/share/colima-provision/nix-installer
#      (The VM's $HOME is mounted via virtiofs, so this binary is accessible
#       inside the VM without needing DNS to work during provisioning.)
#   4. colima restart <profile> (first time, to fire provision scripts)
#   5. After first restart, capture the persisted VM host key:
#        colima ssh -- cat /etc/ssh/ssh_host_ed25519_key.pub
#      and set it as builder.hostKey in the host's darwin config
#   6. darwin-rebuild switch to update known_hosts with the stable host key

{ ... }:
{
  flake.modules.darwin.colima =
    {
      pkgs,
      lib,
      config,
      username,
      vars,
      ...
    }:
    let
      yamlFormat = pkgs.formats.yaml { };

      cfgProfiles = config.colima.profiles;

      # Path to the pre-downloaded nix-installer binary on the macOS host.
      # The VM's $HOME is mounted via virtiofs, so this is accessible inside the VM.
      installerPath = "/Users/${username}/.local/share/colima-provision/nix-installer";

      # Path to persisted SSH host keys on the macOS host.
      sshKeyBackup = "/Users/${username}/.local/share/colima-provision/ssh_host_ed25519_key";

      # Build /etc/nix/nix.custom.conf content for the VM builder.
      # The Determinate installer manages /etc/nix/nix.conf and includes
      # nix.custom.conf for user overrides. We use extra- prefixed settings
      # to ADD to the installer's defaults rather than replacing them.
      mkNixCustomConf = cfg: ''
        extra-substituters = ${lib.concatStringsSep " " cfg.builder.substituters}
        extra-trusted-public-keys = ${lib.concatStringsSep " " cfg.builder.trustedPublicKeys}
        trusted-users = remotebuild root
        builders-use-substitutes = true
        auto-optimise-store = true
      '';

      # Provision script: persist SSH host keys across VM restarts.
      # Colima VMs regenerate SSH host keys on each start, which breaks
      # known_hosts. This script saves keys to the virtiofs-mounted $HOME
      # on first boot and restores them on subsequent boots.
      mkSshKeyProvision = {
        mode = "system";
        script = ''
          # Persist SSH host keys across VM restarts
          if [ -f "${sshKeyBackup}" ]; then
            cp "${sshKeyBackup}" /etc/ssh/ssh_host_ed25519_key
            cp "${sshKeyBackup}.pub" /etc/ssh/ssh_host_ed25519_key.pub
            chmod 600 /etc/ssh/ssh_host_ed25519_key
            chmod 644 /etc/ssh/ssh_host_ed25519_key.pub
            systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || true
          else
            cp /etc/ssh/ssh_host_ed25519_key "${sshKeyBackup}"
            cp /etc/ssh/ssh_host_ed25519_key.pub "${sshKeyBackup}.pub"
          fi
        '';
      };

      # Build the provision script entry that bootstraps the nix builder inside the VM.
      # Runs as root (mode: system). Idempotent — safe to run on every colima start.
      # Uses the pre-downloaded nix-installer binary from the virtiofs mount
      # to avoid DNS resolution issues during VM provisioning.
      mkBuilderProvision = cfg: {
        mode = "system";
        script = ''
          set -e
          # Install nix via pre-downloaded Determinate Systems installer (idempotent)
          if ! command -v nix >/dev/null 2>&1 && [ -x "${installerPath}" ]; then
            "${installerPath}" install --no-confirm --no-modify-profile
          fi
          # Create remotebuild user
          if ! id -u remotebuild >/dev/null 2>&1; then
            useradd -m -s /bin/bash remotebuild
          fi
          mkdir -p /home/remotebuild/.ssh
          chmod 700 /home/remotebuild/.ssh
          echo '${cfg.builder.authorizedKey}' > /home/remotebuild/.ssh/authorized_keys
          chmod 600 /home/remotebuild/.ssh/authorized_keys
          chown -R remotebuild:remotebuild /home/remotebuild/.ssh
          # Enable nix-daemon (installer may already do this — safety net)
          systemctl enable --now nix-daemon 2>/dev/null || true
          # Put nix on PATH for non-interactive SSH (Nix remote-build protocol
          # runs `ssh remotebuild@host nix-store ...` which bypasses profile.d
          # and ~/.bashrc). The Determinate installer was invoked with
          # --no-modify-profile, so neither /etc/profile.d/nix.sh nor the
          # /etc/environment PATH were written. We write both: profile.d for
          # login/interactive shells, and /etc/environment for pam_env (which
          # sshd's PAM session stack reads for every connection, including
          # non-interactive). Idempotent.
          if [ ! -f /etc/profile.d/nix.sh ]; then
            printf '%s\n' \
              'if [ -d "/nix/var/nix/profiles/default/bin" ]; then' \
              '    PATH="/nix/var/nix/profiles/default/bin:$PATH"' \
              'fi' \
              'export PATH' > /etc/profile.d/nix.sh
            chmod 644 /etc/profile.d/nix.sh
          fi
          if ! grep -q '/nix/var/nix/profiles/default/bin' /etc/environment 2>/dev/null; then
            sed -i 's|^PATH="|PATH="/nix/var/nix/profiles/default/bin:|' /etc/environment
          fi
          # Write nix.custom.conf with substituters/trusted-keys from the flake's vars.
          # The Determinate installer manages nix.conf and includes nix.custom.conf.
          mkdir -p /etc/nix
          cat > /etc/nix/nix.custom.conf <<'NIXCUSTOM'
          ${mkNixCustomConf cfg}
          NIXCUSTOM
          systemctl restart nix-daemon 2>/dev/null || true
        '';
      };

      # Combine user-defined provision scripts with builder scripts.
      # SSH key persistence runs first, then builder bootstrap.
      mkProvision =
        cfg:
        let
          builderScripts = lib.optionals cfg.builder.enable [
            mkSshKeyProvision
            (mkBuilderProvision cfg)
          ];
          all = cfg.provision ++ builderScripts;
        in
        if all == [ ] then null else all;

      # Build the colima.yaml config attrs for a profile
      mkYamlConfig = cfg: {
        cpu = cfg.cpu;
        disk = cfg.disk;
        memory = cfg.memory;
        arch = cfg.arch;
        runtime = cfg.runtime;
        modelRunner = cfg.modelRunner;
        hostname = cfg.hostname;
        kubernetes = {
          enabled = cfg.kubernetes.enabled;
          version = cfg.kubernetes.version;
          k3sArgs = cfg.kubernetes.k3sArgs;
          port = cfg.kubernetes.port;
        };
        autoActivate = cfg.autoActivate;
        network = {
          address = cfg.network.address;
          mode = cfg.network.mode;
          interface = cfg.network.interface;
          preferredRoute = cfg.network.preferredRoute;
          dns = cfg.network.dns;
          dnsHosts = cfg.network.dnsHosts;
          hostAddresses = cfg.network.hostAddresses;
          gatewayAddress = cfg.network.gatewayAddress;
        };
        forwardAgent = cfg.forwardAgent;
        docker = cfg.docker;
        vmType = cfg.vmType;
        portForwarder = cfg.portForwarder;
        rosetta = cfg.rosetta;
        binfmt = cfg.binfmt;
        nestedVirtualization = cfg.nestedVirtualization;
        mountType = cfg.mountType;
        mountInotify = cfg.mountInotify;
        cpuType = cfg.cpuType;
        provision = mkProvision cfg;
        sshConfig = cfg.sshConfig;
        sshPort = cfg.sshPort;
        mounts = cfg.mounts;
        diskImage = cfg.diskImage;
        rootDisk = cfg.rootDisk;
        env = cfg.env;
      };

      mkProfileYaml = name: cfg: yamlFormat.generate "colima-${name}.yaml" (mkYamlConfig cfg);
    in
    {
      options.colima = {
        autoRestart = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Auto-restart colima profiles when their config changes during darwin-rebuild switch.";
        };

        profiles = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                cpu = lib.mkOption {
                  type = lib.types.ints.positive;
                  default = 2;
                  description = "Number of CPUs allocated to the VM.";
                };
                disk = lib.mkOption {
                  type = lib.types.ints.positive;
                  default = 100;
                  description = "Disk size in GiB for container data (can only increase after creation).";
                };
                memory = lib.mkOption {
                  type = lib.types.ints.positive;
                  default = 2;
                  description = "Memory in GiB allocated to the VM.";
                };
                arch = lib.mkOption {
                  type = lib.types.enum [
                    "x86_64"
                    "aarch64"
                    "host"
                  ];
                  default = "host";
                  description = "VM architecture (cannot change after creation).";
                };
                runtime = lib.mkOption {
                  type = lib.types.enum [
                    "docker"
                    "containerd"
                    "none"
                  ];
                  default = "docker";
                  description = "Container runtime (cannot change after creation).";
                };
                modelRunner = lib.mkOption {
                  type = lib.types.enum [
                    "docker"
                    "ramalama"
                  ];
                  default = "docker";
                  description = "AI model runner.";
                };
                hostname = lib.mkOption {
                  type = lib.types.str;
                  default = "colima";
                  description = "Hostname for the VM.";
                };
                kubernetes = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      enabled = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                      };
                      version = lib.mkOption {
                        type = lib.types.str;
                        default = "v1.35.0+k3s1";
                      };
                      k3sArgs = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [ "--disable=traefik" ];
                      };
                      port = lib.mkOption {
                        type = lib.types.int;
                        default = 0;
                      };
                    };
                  };
                  default = { };
                };
                autoActivate = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Auto-activate as active Docker/K8s context on startup.";
                };
                network = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      address = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = "Assign a reachable IP to the VM (macOS only).";
                      };
                      mode = lib.mkOption {
                        type = lib.types.enum [
                          "shared"
                          "bridged"
                        ];
                        default = "shared";
                      };
                      interface = lib.mkOption {
                        type = lib.types.str;
                        default = "en0";
                        description = "Network interface for bridged mode.";
                      };
                      preferredRoute = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                      };
                      dns = lib.mkOption {
                        type = lib.types.nullOr (lib.types.listOf lib.types.str);
                        default = null;
                      };
                      dnsHosts = lib.mkOption {
                        type = lib.types.attrsOf lib.types.str;
                        default = { };
                      };
                      hostAddresses = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                      };
                      gatewayAddress = lib.mkOption {
                        type = lib.types.str;
                        default = "192.168.5.2";
                      };
                    };
                  };
                  default = { };
                };
                forwardAgent = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Forward host SSH agent to the VM.";
                };
                docker = lib.mkOption {
                  type = lib.types.attrs;
                  default = { };
                  description = "Docker daemon config (maps to daemon.json).";
                };
                vmType = lib.mkOption {
                  type = lib.types.enum [
                    "krunkit"
                    "qemu"
                    "vz"
                  ];
                  default = "qemu";
                  description = "Virtual Machine type (cannot change after creation).";
                };
                portForwarder = lib.mkOption {
                  type = lib.types.enum [
                    "ssh"
                    "grpc"
                    "none"
                  ];
                  default = "ssh";
                };
                rosetta = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Use rosetta for amd64 emulation (requires vz + Apple Silicon).";
                };
                binfmt = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Enable foreign architecture emulation via binfmt.";
                };
                nestedVirtualization = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                };
                mountType = lib.mkOption {
                  type = lib.types.enum [
                    "virtiofs"
                    "9p"
                    "sshfs"
                  ];
                  default = "sshfs";
                  description = "Volume mount driver (cannot change after creation).";
                };
                mountInotify = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Propagate inotify file events to the VM (experimental).";
                };
                cpuType = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "CPU type for qemu VMs.";
                };
                provision = lib.mkOption {
                  type = lib.types.listOf (
                    lib.types.submodule {
                      options = {
                        mode = lib.mkOption {
                          type = lib.types.enum [
                            "system"
                            "user"
                            "after-boot"
                            "ready"
                          ];
                          default = "system";
                        };
                        script = lib.mkOption {
                          type = lib.types.str;
                        };
                      };
                    }
                  );
                  default = [ ];
                  description = "Custom provision scripts (executed on startup, must be idempotent).";
                };
                sshConfig = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Modify ~/.ssh/config to include a SSH config for the VM.";
                };
                sshPort = lib.mkOption {
                  type = lib.types.int;
                  default = 0;
                  description = "SSH server port (0 = random).";
                };
                mounts = lib.mkOption {
                  type = lib.types.listOf (
                    lib.types.submodule {
                      options = {
                        location = lib.mkOption {
                          type = lib.types.str;
                        };
                        writable = lib.mkOption {
                          type = lib.types.bool;
                          default = true;
                        };
                      };
                    }
                  );
                  default = [ ];
                };
                diskImage = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                };
                rootDisk = lib.mkOption {
                  type = lib.types.ints.positive;
                  default = 20;
                  description = "Root filesystem disk size in GiB.";
                };
                env = lib.mkOption {
                  type = lib.types.attrsOf lib.types.str;
                  default = { };
                  description = "Environment variables for the VM.";
                };

                # ── Nix remote builder ──────────────────────────────────────────
                builder = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      enable = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = "Provision the VM as a Nix remote builder.";
                      };
                      authorizedKey = lib.mkOption {
                        type = lib.types.str;
                        default = "";
                        description = "SSH public key for the remotebuild user.";
                      };
                      hostKey = lib.mkOption {
                        type = lib.types.str;
                        default = "";
                        description = "VM's SSH host public key for known_hosts.";
                      };
                      hostName = lib.mkOption {
                        type = lib.types.str;
                        default = "192.168.64.2";
                        description = "Host/IP for the buildMachines entry.";
                      };
                      sshKey = lib.mkOption {
                        type = lib.types.str;
                        default = "/Users/${username}/.ssh/id_colima_builder";
                        description = "Path to SSH private key for builder connection.";
                      };
                      maxJobs = lib.mkOption {
                        type = lib.types.ints.positive;
                        default = 4;
                      };
                      speedFactor = lib.mkOption {
                        type = lib.types.ints.positive;
                        default = 5;
                        description = "Higher = preferred over other builders.";
                      };
                      supportedFeatures = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [
                          "big-parallel"
                          "benchmark"
                        ];
                      };
                      systems = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [ "aarch64-linux" ];
                      };
                      substituters = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = vars.nixSubstitutersNixOS;
                      };
                      trustedPublicKeys = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = vars.nixTrustedPublicKeysNixOS;
                      };
                    };
                  };
                  default = { };
                  description = "Nix remote builder configuration for this profile.";
                };
              };
            }
          );
          default = { };
          description = "Colima profile configurations.";
        };
      };

      config = {
        # Always install colima — it's the VM manager
        environment.systemPackages = [ pkgs.colima ];

        # Activation: sync rendered YAML to ~/.colima/<profile>/ and restart if changed.
        # nix-darwin only executes a fixed set of activation scripts — custom names are
        # not run. We append to postActivation (types.lines concatenates all definitions).
        system.activationScripts.postActivation.text = lib.mkAfter (
          lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              name: cfg:
              let
                yamlFile = mkProfileYaml name cfg;
                colimaDir = "/Users/${username}/.colima/${name}";
                colimaYaml = "${colimaDir}/colima.yaml";
                colimaBin = "/run/current-system/sw/bin/colima";
              in
              ''
                # Colima profile: ${name}
                if [ -d "${colimaDir}" ]; then
                  if ! diff -q "${yamlFile}" "${colimaYaml}" >/dev/null 2>&1; then
                    echo "colima: updating ${name} config"
                    cp "${yamlFile}" "${colimaYaml}"
                    chown ${username} "${colimaYaml}"
                ${lib.optionalString config.colima.autoRestart ''
                  if ${colimaBin} status ${name} 2>&1 | grep -q "Running"; then
                    echo "colima: restarting ${name} to apply config changes"
                    ${colimaBin} restart ${name}
                  fi
                ''}
                  fi
                fi
              ''
            ) cfgProfiles
          )
        );

        # Add buildMachines entries for profiles with builder enabled
        # List merging concatenates with the maple entry from darwin.core
        nix.buildMachines = lib.flatten (
          lib.mapAttrsToList (
            name: cfg:
            lib.optional cfg.builder.enable {
              hostName = cfg.builder.hostName;
              protocol = "ssh";
              sshUser = "remotebuild";
              sshKey = cfg.builder.sshKey;
              systems = cfg.builder.systems;
              maxJobs = cfg.builder.maxJobs;
              speedFactor = cfg.builder.speedFactor;
              supportedFeatures = cfg.builder.supportedFeatures;
            }
          ) cfgProfiles
        );

        # Add known hosts for builder VMs
        programs.ssh.knownHosts = lib.mapAttrs' (
          name: cfg:
          lib.nameValuePair "colima-${name}" {
            hostNames = [
              cfg.builder.hostName
              "colima"
              "colima-${name}"
            ];
            publicKey = cfg.builder.hostKey;
          }
        ) (lib.filterAttrs (_name: cfg: cfg.builder.enable && cfg.builder.hostKey != "") cfgProfiles);
      };
    };
}
