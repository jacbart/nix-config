{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  libpq,
}:

bundlerApp {
  gemdir = ./.;
  pname = "pgsync";
  exes = [ "pgsync" ];

  buildInputs = [ libpq ];

  passthru.updateScript = bundlerUpdateScript "pgsync";

  meta = {
    description = "Sync data between Postgres databases (Ruby 3.4 compatible — bigdecimal bundled)";
    homepage = "https://github.com/ankane/pgsync";
    license = lib.licenses.mit;
    mainProgram = "pgsync";
  };
}
