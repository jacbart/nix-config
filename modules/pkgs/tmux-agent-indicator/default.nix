# tmux-agent-indicator — visual feedback for AI agent states
# (running / needs-input / done) via pane borders, window titles, and status
# bar icons.  Not in nixpkgs tmuxPlugins, so built here with mkTmuxPlugin.
{
  pkgs,
  ...
}:
pkgs.tmuxPlugins.mkTmuxPlugin {
  pluginName = "agent-indicator";
  rtpFilePath = "agent-indicator.tmux";
  version = "unstable-2026-08-14";
  src = pkgs.fetchFromGitHub {
    owner = "accessd";
    repo = "tmux-agent-indicator";
    rev = "553c3cca8bea6fe17e0709ec04f737417de42141";
    hash = "sha256-VCq7Muvpke9goN1RTcIChW+c/SkFHUSJdoEGKH+CaMQ=";
  };
  meta = with pkgs.lib; {
    homepage = "https://github.com/accessd/tmux-agent-indicator";
    description = "Tmux plugin giving visual feedback for AI agent states";
    license = licenses.mit;
    maintainers = with maintainers; [ jacbart ];
  };
}
