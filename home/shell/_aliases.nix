# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  _aliases.nix — Shell aliases shared across fish, bash and zsh             ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# This is *not* a Home Manager module — it's a plain attrset that the shell
# modules (fish.nix, bash.nix, zsh.nix) `import` to avoid duplicating the same
# alias list three times.
#
# Two buckets:
#
#   - `commands`  — short aliases for everyday commands. In fish these are
#                   installed as *abbreviations* (so they expand inline as
#                   you type and you can edit the full command before running);
#                   in bash/zsh they're plain aliases.
#
#   - `listing`   — long-form `eza` invocations and similar. Always installed
#                   as aliases (not abbrs) because we never want them to
#                   expand to a wall of flags on screen.
#
# To add a shortcut everywhere, edit this file. To add one to a single shell,
# put it in that shell's own module.

{
  commands = {
    # Files & directories — safer defaults
    mv = "mv -iv";
    cp = "cp -riv";
    mkdir = "mkdir -vp";

    # Editor
    vim = "nvim";
    vi = "nvim";
    v = "nvim";
    sv = "sudoedit";
    vudo = "sudoedit";

    # Tmux
    t = "tmux";
    tc = "tmux attach";
    ta = "tmux attach -t";
    tl = "tmux ls";
    ts = "tmux new-session -s";
    tk = "tmux kill-session -t";

    # Git
    gg = "lazygit";
    gs = "git st";
    gb = "git checkout -b";
    gc = "git commit";
    gcp = "git commit -p";
    gpp = "git push";
    gp = "git pull";

    # Modern CLI replacements
    grep = "rg";
    fda = "fd -IH";
    rga = "rg -uu";

    # systemctl
    s = "systemctl";
    su = "systemctl --user";
    ss = "systemctl status";
    sl = "systemctl --type service --state running";
    slu = "systemctl --user --type service --state running";
    sf = "systemctl --failed --all";

    # journalctl
    jb = "journalctl -b";
    jf = "journalctl -f";
    jg = "journalctl -b --grep";
    ju = "journalctl --unit";
    jm = "journalctl --user";

    # paru (AUR helper, when in an Arch chroot)
    p = "paru";
    pai = "paru -S";
    par = "paru -R";
    pas = "paru -Ss";
    pal = "paru -Q";
    paf = "paru -Ql";
    pao = "paru -Qo";

    # Encrypted vault — mounts gocryptfs at ~/Personal and starts Syncthing.
    # Lives here (not in fish/bash/zsh modules) because we want the same
    # commands available regardless of which shell the user is in.
    unlock-personal = "gocryptfs ~/.personal-encrypted ~/Personal && systemctl --user start syncthing && systemctl --user restart gcr-ssh-agent.socket";
    lock-personal = "systemctl --user stop syncthing; fusermount -u ~/Personal";
  };

  listing = {
    ls = "eza --color=always --icons --group-directories-first";
    la = "eza --color=always --icons --group-directories-first --all";
    ll = "eza --color=always --icons --group-directories-first --all --long";
    tree = "eza --color=always --icons --group-directories-first --tree";
    l = "ll";
  };
}
