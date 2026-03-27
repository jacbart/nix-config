{
  inputs,
  outputs,
  stateVersion,
  vars,
  ...
}:
let
  helpers = import ./helpers.nix {
    inherit
      inputs
      outputs
      stateVersion
      vars
      ;
  };
in
{
  inherit (helpers) mkHome;
  inherit (helpers) mkHost;
  inherit (helpers) mkDarwinHost;
  inherit (helpers) forAllSystems;
}
