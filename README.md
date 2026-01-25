# NixOS & Home Manager Configurations

| Hostname |     OEM     |            Model             |  OS   |   Role   | Status            |
| :------- | :---------: | :--------------------------: | :---: | :------: | :---------------- |
| boojum   |   Lenovo    |        Thinkpad Gen 6        | NixOS |  Laptop  | working           |
| jryjack  |    Apple    |     Macbook Pro M1 2020      | MacOS |  Laptop  | home manager      |
| sycamore |    Apple    |     Macbook Pro M5 2020      | MacOS |  Laptop  | home manager      |
| cork     |             |            Tower             | NixOS | Desktop  | working           |
| maple    |   Pine64    |         [RockPro64]          | NixOS |   NAS    | working           |
| ash      | Clockworkpi | [uConsole (CM-4, 4G Module)] | NixOS | Handheld | partially working |

[uConsole (CM-4, 4G Module)]: https://www.clockworkpi.com/uconsole
[RockPro64]: https://www.pine64.org/rockpro64/

## Installing

- Boot off a .iso image created by this flake using `rebuild-iso-desktop` or `rebuild-iso-console` (_see below_)
- Put the .iso image on a USB drive
- Boot the target computer from the USB drive
- Two installation options are available:
  1 Use the graphical Calamares installer to install an adhoc system
  2 Run `install-system <hostname> <username>` from a terminal
  - The install script uses [Disko] to automatically partition and format the disks, then uses my flake via `nixos-install` to complete a full-system installation
  - This flake is copied to the target user's home directory as `~/workspace/personal/nix-config`
- Reboot
- Login and run `rebuild-home` (_see below_) from a terminal to complete the Home Manager configuration.

If the target system is booted from something other than the .iso image created by this flake, you can still install the system using the following:

<!-- ```bash -->
<!-- curl -sL https://raw.githubusercontent.com/jacbart/nix-config/main/scripts/install.sh | bash -s <hostname> <username> -->
<!-- ``` -->

## Applying Changes

I clone this repo to `~/workspace/personal/nix-config`. NixOS and Home Manager changes are applied separately because I have some non-NixOS hosts.

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

Aliases for `rebuild-iso-desktop` (_desktop_) and `rebuild-iso-console` (_console only_) are provided that create .iso images from this flake. They do the following:

```bash
pushd $HOME/workspace/personal/nix-config
nix build .#nixosConfigurations.iso.config.system.build.isoImage
popd
```

A live image will be left in `~/$HOME/workspace/personal/nix-config/result/iso/`. These .iso images are also periodically built and published via [GitHub Actions](./.github/workflows) and available in [this project's Releases](https://github.com/jacbart/nix-config/releases).
