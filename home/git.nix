{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    signing.format = null;

    lfs.enable = true;

    settings = {
      user = {
        name = "Guido Masella";
        email = "guido.masella@gmail.com";
      };

      color.ui = true;
      push.default = "simple";
      merge.conflictstyle = "diff3";
      pull.rebase = true;
      diff.colorMoved = "default";
      init.defaultBranch = "main";
      fetch.prune = true;

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
    };
  };

  # Delta (pager/diff viewer) — now a separate program in HM
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      side-by-side = false;
      line-numbers = true;
      syntax-theme = "TwoDark";
    };
  };

  # QPerfect gitconfig for conditional include
  home.file."QPerfect/Code/.gitconfig".text = ''
    [user]
    	email = guido.masella@qperfect.io
    	name = Guido Masella
  '';
}
