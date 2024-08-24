{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    cosmic-applets
    cosmic-applibrary
    cosmic-bg
    cosmic-comp
    cosmic-design-demo
    cosmic-edit
    cosmic-emoji-picker
    cosmic-files
    cosmic-greeter
    cosmic-icons
    cosmic-launcher
    cosmic-notifications
    cosmic-osd
    cosmic-panel
    cosmic-protocols
    cosmic-randr
    cosmic-screenshot
    cosmic-session
    cosmic-settings-daemon
    cosmic-settings
    cosmic-store
    cosmic-tasks
    cosmic-term
    cosmic-workspaces-epoch
    libcosmicAppHook
    pop-launcher
    xdg-desktop-portal-cosmic
  ];


  services.desktopManager = {
    cosmic.enable = true;
    cosmic-greeter.enable = true;
  };
}
