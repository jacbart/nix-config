{
  config,
  vars,
  ...
}:
{
  imports = [
    ../../apps/lan-mouse.nix
    # ../../apps/wezterm.nix
    # ../../apps/zed-editor.nix
  ];

  # newsboat's freshrss-passwordfile. The FreshRSS API password is the same
  # as the login password, which nix-secrets already holds.
  sops.secrets."freshrss/admin-password" = {
    path = "${config.home.homeDirectory}/.config/newsboat/freshrss-password";
    mode = "0400";
  };

  # home.packages = with pkgs; [
  #   unstable.gitu
  # ];

  # home.file."${config.xdg.configHome}/lan-mouse/config.toml".text = builtins.readFile ./lan-mouse.toml;
}
