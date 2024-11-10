{ config, pkgs, lib, ... }: let
  inherit (pkgs.stdenv) isLinux;
in {
  home.packages = [
    pkgs.nixd # nix deamon
    pkgs.dockerfile-language-server-nodejs # dockerfile language server
    pkgs.gofumpt # go formatter
    pkgs.gopls # go language server
    pkgs.nil # nix language server
    pkgs.marksman # markdown language server
    pkgs.markdown-oxide # markdown language server
    pkgs.dprint # code formatter [ markdown ]
    pkgs.taplo # TOML language server
    pkgs.terraform-ls # language server for [ .hcl, .tf, .tfvars, .koi, .jaws ]
    pkgs.yaml-language-server # YAML language server
    pkgs.vscode-langservers-extracted # [ vscode-css-language-server vscode-eslint-language-server vscode-html-language-server vscode-json-language-server vscode-markdown-language-server ]
  ] ++ lib.optionals isLinux [ pkgs.unstable.zed-editor ];

  # fix weird nix bin name
  programs.zsh.shellAliases = { zed = "zeditor"; };
  # add in settings.json
  home.file."${config.xdg.configHome}/zed/settings.json".text = builtins.readFile ./zed-editor.json;
}
