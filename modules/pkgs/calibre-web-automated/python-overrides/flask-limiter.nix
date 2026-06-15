# CWA pins Flask-Limiter to <3.13.0 and passes the v3 Limiter() keyword
# argument `auto_check`, which was removed in 4.x. Pin to a 3.x release
# until CWA upgrades.
{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  setuptools,
  flask,
  limits,
  ordered-set,
  rich,
  typing-extensions,
  markdown,
}:

buildPythonPackage rec {
  pname = "Flask-Limiter";
  version = "3.12";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    pname = "flask_limiter";
    inherit version;
    hash = "sha256-+ePj0MSs0NH/v6cp4XGY3RBC9NI8EwrhYARPyTDiEwA=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    flask
    limits
    ordered-set
    rich
    typing-extensions
    markdown
  ];

  pythonRelaxDeps = [ "rich" ];

  doCheck = false;
  pythonImportsCheck = [ "flask_limiter" ];

  meta = with lib; {
    description = "Flask-Limiter (pinned to 3.x for CWA compatibility)";
    homepage = "https://github.com/alisaifee/flask-limiter";
    license = licenses.mit;
  };
}
