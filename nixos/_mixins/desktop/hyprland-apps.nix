{ pkgs, ... }: {
  imports = [
    ../services/flatpak.nix
    ../services/sane.nix
  ];

  environment.systemPackages = with pkgs; [
    kitty
    wezterm
    waybar
    dunst
    libnotify
    rofi-wayland
  ];

  systemd.services.configure-appcenter-repo = {
    wantedBy = ["multi-user.target"];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists appcenter https://flatpak.elementary.io/repo.flatpakrepo
    '';
  };
}