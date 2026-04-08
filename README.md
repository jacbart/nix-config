# NixOS & Home Manager Configurations

Personal [flake-parts](https://flake.parts/) based Nix configuration managing NixOS systems, macOS via nix-darwin, and Home Manager on non-NixOS hosts. Supports `x86_64-linux`, `aarch64-linux`, and `aarch64-darwin`.

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

This flake uses the dendritic pattern with [flake-parts](https://flake.parts/) to organize configuration into composable modules:

- **Configuration registry** -- Hosts are registered as `nixosHosts`, `darwinHosts`, or `homeHosts` in a central module (`modules/configurations.nix`) that builds the respective `flake.*Configurations` outputs
- **Core modules** -- Base configurations exported as `flake.modules.{nixos,darwin,homeManager}.core`, included by every host of that type
- **Shared inputs** -- `sops-nix` and `disko` are automatically included for NixOS hosts; `home-manager` integration is automatic for Darwin hosts
- **Overlays** -- Custom packages, script packages, Lix replacements, and unstable nixpkgs are available as overlays

## Modules

### NixOS (`modules/nixos/`)

| Category | Contents                                                                                                   |
| :------- | :--------------------------------------------------------------------------------------------------------- |
| apps     | firefox, ghostty, rofi, steam, vscode                                                                      |
| services | ~45 services including caddy, docker, tailscale, nextcloud, postgresql, minio, dendrite, zitadel, fail2ban |
| desktop  | cosmic, hyprland, kde, niri, phosh, xfce (each with app bundles)                                           |
| hardware | fw4b0, hardwarekey, nvidia-3060ti, rockpro64, systemd-boot, uconsole                                       |
| security | sops, ACME (base/hostname/proxy), custom CA certs                                                          |
| users    | meep, ratatoskr, nixos, root                                                                               |

### Home Manager (`modules/home/`)

| Category | Contents                                                                                          |
| :------- | :------------------------------------------------------------------------------------------------ |
| apps     | eww, firefox, ghostty, kitty, lan-mouse, rofi-wayland, rustdesk, wezterm, zed                     |
| desktop  | cosmic, hyprland, kde, niri, phosh, xfce                                                          |
| shell    | zsh, starship, carapace, helix, tmux, git, eza, zoxide, broot, bottom, fzf, fd, ripgrep, opencode |
| services | dunst, nextcloud-client                                                                           |
| users    | meep, ratatoskr, jackbartlett, jack (with host-specific overrides)                                |

### Darwin (`modules/darwin/`)

| Category | Contents                                          |
| :------- | :------------------------------------------------ |
| core     | Lix, zsh, auto GC, flake support, state version 6 |

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

## Applying Changes

Clone this repo to `~/workspace/personal/nix-config`:

```bash
git clone jacbart/nix-config ~/workspace/personal/nix-config
```

### NixOS

A `rebuild-host` alias is provided that does the following:

```bash
sudo nixos-rebuild switch --flake $HOME/workspace/personal/nix-config
```

### Home Manager

A `rebuild-home` alias is provided that does the following:

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
