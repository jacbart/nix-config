{ config, pkgs, lib, ... }: let
  inherit (pkgs.stdenv) isLinux;
in {
  home.packages = with pkgs; [
    nixd
    dockerfile-language-server-nodejs # dockerfile language server
    gofumpt # go formatter
    gopls # go language server
    nil # nix language server
    marksman # markdown language server
    markdown-oxide # markdown language server
    dprint # code formatter [ markdown ]
    taplo # TOML language server
    terraform-ls # language server for [ .hcl, .tf, .tfvars, .koi, .jaws ]
    yaml-language-server # YAML language server
    vscode-langservers-extracted # [ vscode-css-language-server vscode-eslint-language-server vscode-html-language-server vscode-json-language-server vscode-markdown-language-server ]
  ] ++ lib.optionals isLinux [ pkgs.unstable.zed-editor ];
  
  # add in settings.json
  home.file."${config.xdg.configHome}/zed/settings.json".text = builtins.readFile ./zed-editor.json;
}
