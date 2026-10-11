# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  navi.nix — Interactive cheatsheets                                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# navi lists commands from `.cheat` files, asks for their <variables> with a
# fuzzy picker, and puts the finished command on the prompt. Ctrl-G opens it in
# fish, or run `navi` directly.
#
# The cheats live in raw/cheats/ and are read in place, so edits apply at
# once. hub's Commands tab reads the same files.
#
# Format, in short (`navi info cheats-example` for more):
#
#   % git, branches                  tags for the cheats below
#   # Switch branch                  description
#   git switch <branch>              command with a variable
#   $ branch: git branch --format='%(refname:short)'    suggestions for it

{ config, ... }:

{
  programs.navi = {
    enable = true;
    settings.cheats.paths = [ "${config.home.homeDirectory}/dotfiles/raw/cheats" ];
  };
}
