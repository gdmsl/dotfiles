# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  git.nix — Git configuration and delta pager                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Home Manager's `programs.git` generates ~/.config/git/config from the
# options below. This is equivalent to writing a .gitconfig by hand, but
# it's versioned in Nix and can reference Nix store paths.
#
# `programs.delta` configures delta as the git pager — a syntax-highlighting
# diff viewer that makes `git diff` and `git log -p` much more readable.

{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    signing.format = null;  # no commit signing (GPG/SSH)

    lfs.enable = true;  # Git Large File Storage

    settings = {
      # ── Identity ────────────────────────────────────────────────────
      user = {
        name = "Guido Masella";
        email = "guido.masella@gmail.com";
      };

      # ── Core settings ───────────────────────────────────────────────
      color.ui = true;
      push.default = "simple";           # push only the current branch
      merge.conflictstyle = "diff3";     # show base version in conflicts
      pull.rebase = true;                # rebase on pull instead of merge
      diff.colorMoved = "default";       # highlight moved lines in diffs
      init.defaultBranch = "main";
      fetch.prune = true;                # auto-delete stale remote branches

      # ── Aliases ─────────────────────────────────────────────────────
      alias = {
        change-commits = "!f() { VAR=$1; OLD=$2; NEW=$3; shift 3; git filter-branch --env-filter \"if [[ \\\\\"$`echo $VAR`\\\\\" = '$OLD' ]]; then export $VAR='$NEW'; fi\" $@; }; f";
        st = "status -sb";              # short status with branch info
        co = "checkout";
        c = "commit --short";
        ci = "commit --short";
        p = "push";
        l = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --decorate --date=short";
      };

      github.user = "gdmsl";

      # Credential helpers — libsecret stores tokens in gnome-keyring,
      # gh auth provides GitHub-specific token management.
      credential.helper = "/usr/lib/git-core/git-credential-libsecret";

      "credential \"https://github.com\"" = {
        helper = [
          ""  # empty string resets the helper list before adding gh
          "!/usr/bin/gh auth git-credential"
        ];
      };

      "credential \"https://gist.github.com\"" = {
        helper = [
          ""
          "!/usr/bin/gh auth git-credential"
        ];
      };

      # URL shortcut: `git clone aur:package-name`
      "url \"https://aur.archlinux.org/\"" = {
        insteadOf = "aur:";
      };
    };

    # ── Conditional include ─────────────────────────────────────────
    # When working in the QPerfect work directory, use a different
    # email address. `programs.git.includes` appends the [includeIf]
    # block *after* the main [user] section in ~/.config/git/config,
    # so the included settings actually win (entries later in the
    # file override earlier ones). Using `contents = { … }` also lets
    # home-manager generate the include file itself, so we don't have
    # to manage its path separately with `home.file`.
    includes = [
      {
        condition = "gitdir:~/Code/";
        contents = {
          user = {
            email = "guido.masella@qperfect.io";
            name = "Guido Masella";
          };
        };
      }
    ];
  };

  # ── Delta (diff pager) ──────────────────────────────────────────────────
  # Delta replaces the default git pager with syntax-highlighted, line-numbered
  # diffs. `enableGitIntegration` automatically sets git's core.pager to delta.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;             # use n/N to jump between diff sections
      light = false;               # dark terminal background
      side-by-side = false;        # unified diff (not side-by-side)
      line-numbers = true;
      syntax-theme = "TwoDark";
    };
  };

}
