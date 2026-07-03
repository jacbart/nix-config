{ pkgs }:
with pkgs;
[
  delve
  delta
  docker-compose-language-service # provides `docker-compose-langserver` (helix's built-in docker-compose LSP)
  dockerfile-language-server
  gofumpt
  gopls
  helm-ls # provides `helm_ls` (helix's built-in helm LSP)
  jdt-language-server
  jq-lsp # provides `jq-lsp` (helix's built-in jq LSP)
  just-lsp # provides `just-lsp` (helix's built-in just LSP)
  kdlfmt # provides `kdlfmt` (helix's built-in kdl formatter)
  lldb # provides `lldb-dap` (helix's rust/C debug adapter)
  lua-language-server # helix's built-in lua LSP
  markdown-oxide
  nil
  nixd
  nixfmt
  prettier
  protols # provides `protols` (helix's built-in protobuf LSP)
  ruff
  scooter
  shfmt
  sqls
  steel
  stylua
  systemd-language-server
  taplo
  terraform-ls
  typescript-language-server
  vscode-langservers-extracted
  yaml-language-server
]
