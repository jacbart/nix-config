# apex/soql/sosl tree-sitter grammars for Helix, built from the same rev as the
# vendored highlight queries in modules/home/dev/salesforce/queries/.
{
  tree-sitter,
  fetchFromGitHub,
  runCommandLocal,
}:
let
  rev = "27a3091a1a444ce19d6099e00cd3788f019d0c2b";
  src = fetchFromGitHub {
    owner = "aheber";
    repo = "tree-sitter-sfapex";
    inherit rev;
    hash = "sha256-Pg8zZmjGFcLftPNPiASt0uUxYG6CRcsB9qKhTMC5G7U=";
  };
  mkGrammar =
    language:
    tree-sitter.buildGrammar {
      inherit language src;
      version = "0-unstable-${builtins.substring 0 7 rev}";
      location = language;
    };
in
runCommandLocal "tree-sitter-sfapex" { } ''
  install -D ${mkGrammar "apex"}/parser $out/apex.so
  install -D ${mkGrammar "soql"}/parser $out/soql.so
  install -D ${mkGrammar "sosl"}/parser $out/sosl.so
''
