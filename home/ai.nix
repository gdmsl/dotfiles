# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  ai.nix — AI / LLM coding agents                                           ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Shared by the desktop (home/default.nix) and headless (home/tty.nix) profiles.

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    claude-code
    # Claude Code plugin hooks run as `node -e "…"`, and the claude-code
    # wrapper doesn't put node on PATH, so it has to come from here.
    nodejs
    codex            # OpenAI's terminal coding agent (the `codex` command)
  ];
}
