# Salesforce project dev environment

Reproducible Apex / LWC / SOQL toolchain (`sf` CLI, Apex LSP, LWC language server,
`prettier-apex`, `apex-impls`, JDK 21, Node 24) sourced from
[`jacbart/nix-config`](https://github.com/jacbart/nix-config).

## Quickstart

```sh
# 1. Scaffold this template into a new project dir
mkdir my-sf-project && cd my-sf-project
nix flake init -t github:jacbart/nix-config#salesforce

# 2. Enter the shell
nix develop

# 3. Scaffold the Salesforce DX project in place
sf project generate --name my-sf-project

# 4. Authorize an org
sf org login web --alias dev
```

Opening the project in Helix (on a host with the salesforce home module, e.g.
`sycamore`) then activates the Apex/LWC LSPs and syntax highlighting — they key off
the `sfdx-project.json` that `sf project generate` creates.

## Notes

- This flake takes `jacbart/nix-config` as an input, which locks its transitive
  inputs (including private `git+ssh` sources). It resolves on Jack's machines
  with SSH access; the `flake.lock` will be large.
- Editor wiring (LSP config, tree-sitter grammars, queries) is host-level and not
  part of this shell — this shell only vends the CLI toolchain.
