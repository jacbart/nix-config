{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "goodreads";
  version = "0.3.2";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-OgsxGgsaazW7/wm55n6Ap27Ld3ILLoGmgqxeAYrTVEU=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ requests ];

  doCheck = false;
  pythonImportsCheck = [ "goodreads" ];

  meta = with lib; {
    description = "Python wrapper for the Goodreads API";
    homepage = "https://github.com/sefakilic/goodreads";
    license = licenses.mit;
  };
}
