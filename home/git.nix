{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Guido Masella";
    userEmail = "guido.masella@gmail.com";

    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = false;
        line-numbers = true;
        syntax-theme = "TwoDark";
      };
    };

    lfs.enable = true;

    extraConfig = {
      color.ui = true;

      push.default = "simple";

      merge.conflictstyle = "diff3";

      pull.rebase = true;

      diff.colorMoved = "default";

      interactive.diffFilter = "delta --color-only";

      init.defaultBranch = "main";

      alias = {
        change-commits = "!f() { VAR=$1; OLD=$2; NEW=$3; shift 3; git filter-branch --env-filter \"if [[ \\\\\"$`echo $VAR`\\\\\" = '$OLD' ]]; then export $VAR='$NEW'; fi\" $@; }; f";
        st = "status -sb";
        co = "checkout";
        c = "commit --short";
        ci = "commit --short";
        p = "push";
        l = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --decorate --date=short";
      };

      github.user = "gdmsl";

      credential.helper = "/usr/lib/git-core/git-credential-libsecret";

      "credential \"https://github.com\"" = {
        helper = [
          ""
          "!/usr/bin/gh auth git-credential"
        ];
      };

      "credential \"https://gist.github.com\"" = {
        helper = [
          ""
          "!/usr/bin/gh auth git-credential"
        ];
      };

      # Conditional include for QPerfect work
      "includeIf \"gitdir:~/QPerfect/Code/\"" = {
        path = "~/QPerfect/Code/.gitconfig";
      };

      "url \"https://aur.archlinux.org/\"" = {
        insteadOf = "aur:";
      };

      fetch.prune = true;
    };
  };

  # QPerfect gitconfig for conditional include
  home.file."QPerfect/Code/.gitconfig".text = ''
    [user]
    	email = guido.masella@qperfect.io
    	name = Guido Masella
  '';
}
