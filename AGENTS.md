# Nix Config — Agent Guide

Personal [flake-parts](https://flake.parts/) config for NixOS, nix-darwin, and Home Manager (Linux + Darwin). Full human-facing docs in [`README.md`](README.md). This file is the compact map for agents; read the specific files below before editing anything.

## Layout

```
flake.nix                       inputs + top-level flake-parts imports (nothing else)
modules/flake/                  flake machinery: flake-parts, overlays, devshell, templates, formatter, systems
modules/flake/imports.nix       imports non-host flake modules + core module exports (flake.modules.*)
modules/configurations.nix      THE host registry → builds nixos/darwin/homeConfigurations
modules/vars.nix                shared vars (domain, tailscale IPs, builders, DNS records)
modules/hosts/                  one dir per host; home.nix + nixos.nix (or darwin.nix)
modules/hosts/imports.nix       one import per host — add new hosts HERE
modules/nixos/                  core, apps, desktop, hardware, security, services, users, service-profiles
modules/home/                   core, apps, desktop, dev, services, shell, users
modules/darwin/                 core, docker, colima, stevenblack, laptop
modules/pkgs/                   custom/overlay packages (one dir each)
modules/scripts/                script packages (installed via overlays)
templates/                      nix flake init templates (salesforce, go, rust, web, lua, sql, shell)
```

## How it's wired

1. `flake.nix` imports `modules/flake/flake-parts.nix`, `modules/flake/imports.nix`, `modules/hosts/imports.nix`.
2. Host modules define `nixosHosts.<name>`, `darwinHosts.<name>`, or `homeHosts."<user>@<host>"` (see `modules/configurations.nix` for the option schema).
3. `modules/configurations.nix` turns those registries into `flake.nixosConfigurations` / `darwinConfigurations` / `homeConfigurations`.
4. Core modules are exported as `flake.modules.{nixos,darwin,homeManager}.core` and included by each host.

**Special args** passed to modules: `inputs`, `vars`, `stateVersion`, `platform`, `username`, `hostname`, `desktop`, `shellProfile`, `outputs`/`flakeModules`, `overlays`.

## Adding a host

1. Create `modules/hosts/<name>/nixos.nix` (or `darwin.nix`) and `home.nix`.
2. Add an import in `modules/hosts/imports.nix`.
3. Set `desktop` (nixos) and `shellProfile` (`lite` | `zsh-lite` | `dev-heavy`) on the home entry.
4. If it needs disks, add `disks.nix` (disko); add `remote-builder.nix` to join the build fleet.

## Conventions

- **Services**: one file per service under `modules/nixos/services/`; opt-in via the host's `modules` list (often via service profiles in `service-profiles.nix`). A host→service catalog exists in `service-catalog.nix` / `service-catalog-hosts.nix`.
- **Shell profiles**: `modules/home/shell/default.nix` dispatches on `shellProfile` to `profiles/{lite,zsh-lite,dev-heavy}.nix`.
- **Desktops**: `modules/{nixos,home}/desktop/default.nix` imports `./<id>.nix`; per-DE files bundle their own apps (no separate `*-apps.nix`).
- **Secrets**: `inputs.secrets` (`nix-secrets` repo), consumed via `sops-nix`. Never commit secrets.
- **`got` and `secrets` inputs are `git+ssh`** — evaluation needs those remotes reachable (see README).

## Build / test

```sh
# format (must pass)
nix fmt
# evaluate a host
nix flake show
# rebuild a host (from the target machine)
sudo nixos-rebuild switch --flake .            # nixos
nix run nix-darwin -- switch --flake .#<host>  # darwin
home-manager switch -b backup --flake .        # home-manager
```

Before finishing a change: run `nix fmt` and evaluate the affected host with `nix flake check` / a targeted `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` if practical.

## Notes

- The codebase-memory graph is **not** used/indexed for this repo — this is declarative Nix config, not call-graph code. Discover files with glob/grep/read.
- `flake.lock` is auto-generated; don't hand-edit. `nix flake update --flake .` updates inputs (bump `got` rev deliberately).
- `modules/vars.nix` is the single source of truth for fleet IPs, DNS records, and builders.
