# NixOS & Home Manager Configurations

Personal [flake-parts](https://flake.parts/) based Nix configuration managing NixOS systems, macOS via nix-darwin, and Home Manager on Linux and Darwin. Supports `x86_64-linux`, `aarch64-linux`, and `aarch64-darwin`.

## Hosts

| Hostname |     OEM      |            Model             |    OS     |   Role    | Desktop | Status            |
| :------- | :----------: | :--------------------------: | :-------: | :-------: | :-----: | :---------------- |
| ash      | Clockworkpi  | [uConsole (CM-4, 4G Module)] |   NixOS   | Handheld  |  phosh  | partially working |
| boojum   |    Lenovo    |      ThinkPad X1 Gen 6       |   NixOS   |  Laptop   | cosmic  | working           |
| cork     |              |       Tower (3060 Ti)        |   NixOS   |  Desktop  | cosmic  | working           |
| jackjrny |    Apple     |     Macbook Pro M1 2020      |   macOS   |  Laptop   |         | working           |
| maple    |    Pine64    |         [RockPro64]          |   NixOS   |  Server   |         | working           |
| mesquite |  Protectli   |           [FW4B0]            |   NixOS   |  Router   |         | working           |
| oak      | DigitalOcean |             VPS              |   NixOS   |  Server   |         | working           |
| sycamore |    Apple     |     Macbook Pro M5 2020      |   macOS   |  Laptop   |         | working           |
| unicron  |              |        Remote Server         | Home-only |  Server   |         | home manager      |
| iso      |              |      Installation Image      |   NixOS   | Installer |         | working           |

[uConsole (CM-4, 4G Module)]: https://www.clockworkpi.com/uconsole
[RockPro64]: https://www.pine64.org/rockpro64/
[FW4B0]: https://protectli.com/product/fw4b/
[Disko]: https://github.com/nix-community/disko

## Architecture

This flake uses the dendritic pattern with [flake-parts](https://flake.parts/) to organize configuration into composable modules. [`flake.nix`](flake.nix) imports [flake-parts](modules/flake/flake-parts.nix) plus two barrels: shared flake bits in [`modules/flake/imports.nix`](modules/flake/imports.nix) and per-host entries in [`modules/hosts/imports.nix`](modules/hosts/imports.nix) (add new hosts there, not in `flake.nix`).

- **Configuration registry** — Hosts are registered as `nixosHosts`, `darwinHosts`, or `homeHosts` in [`modules/configurations.nix`](modules/configurations.nix), which builds `flake.nixosConfigurations`, `flake.darwinConfigurations`, and `flake.homeConfigurations`.
- **Core modules** — Base configs are exported as `flake.modules.{nixos,darwin,homeManager}.core` and included by each host of that type.
- **NixOS** — `disko`, `sops-nix`, OpenSSH, and the shared security module are appended automatically; [`modules/nixos/desktop/`](modules/nixos/desktop/) is included when the host sets `desktop != null`. Graphical baseline (Plymouth, graphics) lives in `desktop/default.nix`; per-DE files include their app lists inline (no separate `*-apps.nix` split).
- **Home Manager** — Each `homeHosts."user@hostname"` entry can set:
  - `desktop` — optional; if unset, inherits `nixosHosts.<hostname>.desktop` when that NixOS host exists.
  - `shellProfile` — `"lite"` | `"zsh-lite"` (default) | `"dev-heavy"`; selects [`modules/home/shell/profiles/`](modules/home/shell/profiles/) (minimal tools vs full dev stack). See **Shell profiles** below.
  - [`modules/home/desktop/default.nix`](modules/home/desktop/default.nix) imports `./${desktop}.nix` when `desktop` is non-null (aligned with NixOS desktop id).
- **Darwin** — Home Manager is wired automatically. [`modules/darwin/laptop.nix`](modules/darwin/laptop.nix) bundles core + nix-homebrew + docker for the Mac laptops; `flakeModules` is passed in `specialArgs` so nested modules can import flake-exported modules.
- **Overlays** — Custom packages, script packages, Lix-related tweaks, and `pkgs.unstable` are available via [`modules/flake/overlays.nix`](modules/flake/overlays.nix).

## Shell profiles

| Profile   | Typical use   | What you get |
| :-------- | :------------ | :----------- |
| `lite`    | Servers, routers | Minimal CLI: git (no forced `ssh -i`), helix-lite, tmux, bat, fzf, ripgrep, etc.; journal + nix-diff; no zsh plugins bundle from the heavy profile. |
| `zsh-lite` | Default      | `lite` + zsh (zplug, starship), `home.sessionPath` for local bins. |
| `dev-heavy` | Workstations | `zsh-lite` stack + full [`modules/home/shell/tools/default.nix`](modules/home/shell/tools/default.nix) (helix + LSPs, git with `core.sshCommand`, opencode, carapace, extra CLIs). `summarize` maps to the `summarize-commit` script. |

Per-host `shellProfile` is set in each [`modules/hosts/*/home.nix`](modules/hosts/) file.

## Modules

### NixOS (`modules/nixos/`)

| Category | Contents                                                                                                   |
| :------- | :--------------------------------------------------------------------------------------------------------- |
| apps     | firefox, ghostty, rofi, steam, vscode                                                                      |
| services | ~45 services including caddy, docker, tailscale, nextcloud, postgresql, minio, dendrite, zitadel, fail2ban |
| desktop  | cosmic, hyprland, kde, niri, phosh, xfce (each module includes its desktop packages) |
| hardware | fw4b0, hardwarekey, nvidia-3060ti, rockpro64, systemd-boot, uconsole                                       |
| security | sops, ACME (base/hostname/proxy), custom CA certs                                                          |
| users    | meep, ratatoskr, nixos, root                                                                               |

### Home Manager (`modules/home/`)

| Category | Contents                                                                                          |
| :------- | :------------------------------------------------------------------------------------------------ |
| apps     | eww, firefox, ghostty, kitty, lan-mouse, rofi-wayland, rustdesk, wezterm, zed                     |
| desktop  | cosmic, hyprland, kde, niri, phosh, xfce (selected via `desktop` + `home/desktop/default.nix`)   |
| shell    | zsh, profiles (`lite` / `zsh-lite` / `dev-heavy`), starship, helix, tmux, git, eza, zoxide, broot, bottom, fzf, fd, ripgrep, opencode (subset depends on profile) |
| services | dunst, nextcloud-client                                                                           |
| users    | meep, ratatoskr, jackbartlett, jack (with host-specific overrides)                                |

### Darwin (`modules/darwin/`)

| Category | Contents                                          |
| :------- | :------------------------------------------------ |
| core     | Lix, zsh, auto GC, flake support, state version 6 |
| nix-homebrew | Homebrew taps + formulae/casks via nix-homebrew |
| docker   | Colima + Docker CLI (unstable Colima)            |
| laptop   | core + nix-homebrew + docker + primary user      |

## Installing

- Boot off a `.iso` image created by this flake using `nix build .#nixosConfigurations.iso.config.system.build.isoImage`
- Put the `.iso` image on a USB drive
- Boot the target computer from the USB drive
- Two installation options are available:
  1. Use the graphical Calamares installer to install an adhoc system
  2. Run `install-system <hostname> <username>` from a terminal
     - The install script uses [Disko] to automatically partition and format the disks, then uses this flake via `nixos-install` to complete a full-system installation
     - This flake is copied to the target user's home directory as `~/workspace/personal/nix-config`
- Reboot
- Login and run `rebuild-home` (_see below_) from a terminal to complete the Home Manager configuration

### macOS (Darwin)

```bash
nix run nix-darwin -- switch --flake $HOME/workspace/personal/nix-config#<hostname>
```

Laptop hosts (`sycamore`, `jackjrny`) use the shared `darwin.laptop` module (core + Homebrew + Docker tooling).

## Applying Changes

Clone this repo to `~/workspace/personal/nix-config`:

```bash
git clone git@github.com:jacbart/nix-config.git ~/workspace/personal/nix-config
```

### NixOS

A `rebuild-host` alias is provided (zsh profile; uses `nh` when configured):

```bash
sudo nixos-rebuild switch --flake $HOME/workspace/personal/nix-config
```

### Home Manager

A `rebuild-home` alias is provided:

```bash
home-manager switch -b backup --flake $HOME/workspace/personal/nix-config
```

### ISO

Building the ISO requires SSH and age keys to be injected at build time so the live image can access the `nix-secrets` repo. Pass them as environment variables with `--impure`:

```bash
ISO_SSH_KEY=$(cat ~/.ssh/id_github) \
ISO_AGE_KEY=$(cat ~/.config/sops/age/keys.txt) \
  nix build .#nixosConfigurations.iso.config.system.build.isoImage --impure
```

A live image will be left in `./result/iso/`.
