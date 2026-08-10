# meep@ash only: emulators + RSS clients for the uConsole.
{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../../../apps/retroarch.nix
    ../../../apps/newsboat.nix
  ];

  home.packages = [
    # Touch-friendly FreshRSS client; one-time GUI login, stored in gnome-keyring.
    pkgs.unstable.newsflash
    # Wayland clipboard CLI (wl-copy/wl-paste) — nothing else provides one here.
    pkgs.wl-clipboard
  ];

  # newsboat's freshrss-passwordfile. The FreshRSS API password is the same
  # as the login password, which nix-secrets already holds.
  sops.secrets."freshrss/admin-password" = {
    path = "${config.home.homeDirectory}/.config/newsboat/freshrss-password";
    mode = "0400";
  };
}
