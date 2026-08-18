# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  _aliases.nix — Shell aliases shared across fish, bash and zsh             ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Not a Home Manager module — a plain attrset that fish.nix, bash.nix and
# zsh.nix each import, so the list isn't written three times.
#
#   commands   short shortcuts. Fish installs these as abbreviations, which
#              expand as you type so you can see and edit the real command;
#              bash and zsh get plain aliases.
#   listing    long eza invocations. Always aliases, never abbreviations —
#              expanding them would fill the line with flags.
#
# Add here for all three shells, or in one shell's own module for just that one.

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

    # Hardware info — readable defaults. In fish these expand inline as
    # abbreviations, so you can edit the flags before running.
    inxi = "inxi -Fxxxz";   # full report (-z redacts MACs/IPs)
    lshw = "lshw -short";   # brief table (prepend sudo for full detail)
    lspci = "lspci -tv";    # tree view with verbose device names
    lsusb = "lsusb -tv";    # tree view of USB topology

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

    # unlock-personal / lock-personal are in ../personal-vault.nix — they
    # differ per machine, which needs the module system this file doesn't have.
  };

  listing = {
    ls = "eza --color=always --icons --group-directories-first";
    la = "eza --color=always --icons --group-directories-first --all";
    ll = "eza --color=always --icons --group-directories-first --all --long";
    tree = "eza --color=always --icons --group-directories-first --tree";
    l = "ll";
  };
}
