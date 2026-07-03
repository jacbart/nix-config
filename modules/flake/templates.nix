# Flake templates: `nix flake init -t github:jacbart/nix-config#<name>`.
#
# salesforce routes its devShell through this repo (it needs the custom SF
# packages). The rest are self-contained flakes pinned only to nixpkgs, so a
# scaffolded project carries no private git+ssh inputs and stays lightweight.
{ ... }:
{
  flake.templates = {
    salesforce = {
      path = ../../templates/salesforce;
      description = "Salesforce (Apex/LWC/SOQL) project dev environment";
    };
    go = {
      path = ../../templates/go;
      description = "Go project dev environment (gopls, gofumpt, delve, golangci-lint)";
    };
    rust = {
      path = ../../templates/rust;
      description = "Rust project dev environment (cargo, rust-analyzer, clippy, rustfmt)";
    };
    web = {
      path = ../../templates/web;
      description = "Web (JS/HTML/CSS) project dev environment (node, ts-language-server, prettier)";
    };
    lua = {
      path = ../../templates/lua;
      description = "Lua project dev environment (lua-language-server, stylua)";
    };
    sql = {
      path = ../../templates/sql;
      description = "SQL project dev environment (sqls, sqlfluff, psql)";
    };
    shell = {
      path = ../../templates/shell;
      description = "Shell (bash/zsh) project dev environment (shfmt, shellcheck, bash-language-server)";
    };
  };
}
