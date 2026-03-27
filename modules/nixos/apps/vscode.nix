{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      inherit (unstable) vscode;
      vscodeExtensions = [
        unstable.vscode-extensions.serayuzgur.crates
        unstable.vscode-extensions.rust-lang.rust-analyzer
        unstable.vscode-extensions.tamasfe.even-better-toml
        unstable.vscode-extensions.github.copilot
        unstable.vscode-extensions.bbenoist.nix
        # ]
        # ++ pkgs.unstable.vscode-utils.extensionsFromVscodeMarketplace [
        #   {
        #     name = "slint";
        #       publisher = "slint";
        #       version = "1.2.1";
        #       sha256 = "";
        #   }
      ];
    })
  ];

  services.vscode-server.enable = true;
  # May require the service to be enable/started for the user
  # - systemctl --user enable auto-fix-vscode-server.service --now
}
