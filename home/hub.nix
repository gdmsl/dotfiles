# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  hub.nix — hub, a terminal homepage for this setup                          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# `hub` (or Alt-h in fish) opens a terminal homepage with five tabs, in the
# order things usually need you:
#
#   1 Dash      status widgets and service checks, and an Attention strip
#               with everything that needs you across all tabs
#   2 Agents    running Claude Code and Codex sessions with their last prompt
#               and reply; Enter jumps to the session's kitty tab
#   3 Commands  navi cheats (raw/cheats, shared with navi), workflow cards,
#               and an index of scripts, aliases, user units and packages
#   4 Git       every repo: last commit, changes (~), unpushed (↑), unpulled
#               (↓), open MRs (!) and issues (#)
#   5 Todos     open tasks from the Logseq graphs below
#
# It's modal, like vim: 1–5 switch tabs, j/k move, / filters the current tab,
# Space searches everything, ? lists the keys. Enter usually prints a command
# (cd, edit, a filled-in cheat) for the shell; Alt-h puts it on the prompt.
#
# Projects are the git repos in each root, or one level below
# (Code/group/repo), found each time hub opens. MR and issue counts come from
# glab and gh in a few calls for all repos together, cached in
# ~/.cache/hub/forge.tsv so they show at once.
#
# The index is generated here from the rest of the config, so it lists exactly
# what this profile installs and never goes stale.
#
# Workflow cards are Markdown files in raw/hub/, linked rather than copied, so
# a new or edited card shows up without a rebuild. The first line is the
# title. Write one whenever you catch yourself asking "how did I do this?".
#
# A widget is a shell command: the first line of stdout is the summary, the
# rest shows in the preview, and a non-zero exit turns it red.
#
# hub itself lives in its own repo (the `hub` flake input); its README has
# the full config format.

{ config, pkgs, lib, inputs, ... }:

let
  hub = inputs.hub.packages.${pkgs.stdenv.hostPlatform.system}.default;

  home = config.home.homeDirectory;
  dotfiles = "${home}/dotfiles";
  jq = "${pkgs.jq}/bin/jq";

  # Missing directories are fine: a locked ~/Personal, or a machine without
  # some of these, just shows fewer rows.
  graphs = {
    Company = "${home}/QPerfect/Company Notes";
    Knowledge = "${home}/Personal/Knowledge Base";
    Life = "${home}/Personal/Life Notes";
  };
  projectRoots = [
    { name = "Work"; dir = "${home}/Code"; }
    { name = "Personal"; dir = "${home}/Personal/Code"; }
  ];
  # Where each Claude Code / Codex setup keeps its state; see ai.nix and the
  # -personal wrappers in scripts.nix.
  claudeDirs = { claude = "${home}/.claude"; claude-personal = "${home}/Personal/.claude"; };
  codexHomes = { codex = "${home}/.codex"; codex-personal = "${home}/Personal/.codex"; };
  gitlabHosts = [ "gitlab.qperfect.io" ];


  widgets = [
    {
      name = "units";
      cmd = ''
        f=$(systemctl --failed --no-legend --plain; systemctl --user --failed --no-legend --plain)
        [ -z "$f" ] && { echo ok; exit 0; }
        echo "$(printf '%s\n' "$f" | wc -l) failed"; printf '%s\n' "$f"; exit 1
      '';
    }
    {
      name = "dotfiles";
      cmd = ''
        cd ${dotfiles} 2>/dev/null || { echo "no checkout"; exit 0; }
        n=$(git status --porcelain | wc -l)
        [ "$n" -eq 0 ] && echo clean || echo "$n changed"
        git status -sb; [ "$n" -eq 0 ]
      '';
    }
    {
      name = "flake";
      cmd = ''
        t=$(${jq} '.nodes[.nodes.root.inputs.nixpkgs].locked.lastModified' ${dotfiles}/flake.lock 2>/dev/null) || { echo "no lock"; exit 0; }
        d=$(( ($(date +%s) - t) / 86400 ))
        echo "nixpkgs ''${d}d old"; echo "Update: nix flake update"; [ "$d" -le 30 ]
      '';
    }
    {
      name = "disk";
      cmd = ''
        p=$(df --output=pcent / | tail -1 | tr -dc 0-9)
        echo "/ $p%"; df -h -x tmpfs -x devtmpfs -x efivarfs; [ "$p" -lt 90 ]
      '';
    }
    {
      name = "vault";
      cmd = ''mountpoint -q ~/Personal && echo unlocked || echo "locked (unlock-personal)"'';
    }
  ];

  # Prints `host/owner/repo<TAB>open MRs<TAB>open issues`, given every repo's
  # `host/owner/repo` as arguments:
  #   GitLab   every open MR and issue you can see, counted per project, in
  #            one paginated call each per host (the arguments aren't needed)
  #   GitHub   one GraphQL query for all the GitHub repos; missing or private
  #            ones come back null and are skipped
  #   others   asked one repo at a time with fj (Forgejo); hosts fj isn't
  #            logged in to just give nothing
  forge = pkgs.writeShellScript "hub-forge" ''
    for h in ${lib.concatStringsSep " " gitlabHosts}; do
      for kind in merge_requests issues; do
        glab api --hostname "$h" --paginate "$kind?scope=all&state=opened&per_page=100" 2>/dev/null \
          | ${jq} -r --arg k "$kind" '.[] | "\($k)\t\(.web_url | sub("^https?://"; "") | sub("/-/.*"; ""))"'
      done
    done | awk -F'\t' '{ c[$2, $1]++; k[$2] }
      END { for (x in k) printf "%s\t%d\t%d\n", x, c[x, "merge_requests"], c[x, "issues"] }'

    # fj prints "N pull requests" first, with the number in Unicode isolates.
    fjcount() { fj -H "$1" "$2" search -r "$3" 2>/dev/null | head -1 | tr -dc '0-9'; }
    q=; i=0
    for r in "$@"; do
      host=''${r%%/*} path=''${r#*/}
      case "$host" in
        github.com)
          q="$q r$i: repository(owner: \"''${path%%/*}\", name: \"''${path#*/}\") {
            nameWithOwner pullRequests(states: OPEN) { totalCount } issues(states: OPEN) { totalCount } }"
          i=$((i + 1)) ;;
        ${lib.concatStringsSep "|" gitlabHosts}) ;;
        *)
          prs=$(fjcount "$host" pr "$path") issues=$(fjcount "$host" issue "$path")
          [ -n "$prs$issues" ] && printf '%s\t%s\t%s\n' "$r" "''${prs:-0}" "''${issues:-0}" ;;
      esac
    done
    [ -n "$q" ] || exit 0
    gh api graphql -f query="{ $q }" 2>/dev/null | ${jq} -r '.data[] | select(. != null)
      | "github.com/\(.nameWithOwner)\t\(.pullRequests.totalCount)\t\(.issues.totalCount)"'
  '';

  projectPreview = pkgs.writeShellScript "hub-project" ''
    # Runs a forge CLI that prints a JSON list and formats each item with the
    # jq string template $1. Anything that isn't JSON (errors, glab's "No open
    # issues" message) shows as is.
    list() {
      t=$1; shift
      out=$("$@" 2>&1) || { printf '%s\n' "$out"; return; }
      printf '%s' "$out" | ${jq} -r "if length == 0 then \"none\" else .[] | \"$t\" end" 2>/dev/null \
        || printf '%s\n' "$out"
    }
    cd "$1" || exit
    git log -1 --format='last commit %cr: %s'
    git status -sb | head -20
    echo
    case "$(git remote get-url origin 2>/dev/null)" in
      "") echo "no origin remote" ;;
      *github.com*)
        echo "── pull requests"
        list '#\(.number) \(.title) @\(.author.login)' gh pr list -L 10 --json number,title,author
        echo "── issues"
        list '#\(.number) \(.title)' gh issue list -L 10 --json number,title ;;
      ${lib.concatMapStringsSep "|" (h: "*${h}*") gitlabHosts})
        echo "── merge requests"
        list '!\(.iid) \(.title) @\(.author.username)' glab mr list -P 10 --output json
        echo "── issues"
        list '#\(.iid) \(.title)' glab issue list -P 10 --output json ;;
      *)
        # Anything else is taken to be Forgejo; fj finds the host from the
        # remote. Its lists start with a count line and wrap values in
        # Unicode isolates, both dropped here.
        for kind in pr issue; do
          [ $kind = pr ] && echo "── pull requests" || echo "── issues"
          out=$(fj $kind search 2>&1) || { printf '%s\n' "$out"; continue; }
          out=$(printf '%s\n' "$out" | sed 's/\xe2\x81\xa8//g; s/\xe2\x81\xa9//g' | tail -n +2)
          [ -n "$out" ] && printf '%s\n' "$out" || echo none
        done ;;
    esac
  '';

  # Sections of `"name" = "value"` lines, in list order. Written by hand
  # rather than with pkgs.formats.toml, which sorts keys alphabetically; hub
  # shows entries in file order. JSON strings are valid TOML strings.
  toml = sections: lib.concatStrings (lib.mapAttrsToList (section: entries: ''

    [${section}]
    ${lib.concatMapStrings (e: "${builtins.toJSON e.name} = ${builtins.toJSON e.value}\n") entries}'') sections);

  # Tabs and newlines would break the TSV; descriptions sometimes have both.
  clean = s: lib.replaceStrings [ "\t" "\n" ] [ " " " " ] (toString s);
  row = fields: lib.concatMapStringsSep "\t" clean fields;

  aliases = import ./shell/_aliases.nix;

  scripts = lib.filterAttrs (_: f: lib.hasPrefix ".local/bin/" f.target) config.home.file;

  index = lib.concatLines (
    lib.mapAttrsToList (_: f: row [ "script" (baseNameOf f.target) "" (baseNameOf f.target) ]) scripts
    ++ lib.mapAttrsToList (n: v: row [ "alias" n v n ]) (aliases.commands // aliases.listing)
    ++ lib.mapAttrsToList
      (n: s: row [ "unit" n (s.Unit.Description or "") "systemctl --user status ${n}" ])
      config.systemd.user.services
    ++ map
      (p: row [ "pkg" (lib.getName p) (p.meta.description or "") (p.meta.mainProgram or (lib.getName p)) ])
      (lib.filter lib.isDerivation config.home.packages)
  );
in
{
  home.packages = [ hub ];

  xdg.configFile = {
    "hub/index.tsv".text = index;
    "hub/config.toml".text = ''
      preview = ${builtins.toJSON "${projectPreview}"}
      forge = ${builtins.toJSON "${forge}"}
    '' + toml {
      graphs = lib.mapAttrsToList lib.nameValuePair graphs;
      projects = map (p: lib.nameValuePair p.name p.dir) projectRoots;
      claude = lib.mapAttrsToList lib.nameValuePair claudeDirs;
      codex = lib.mapAttrsToList lib.nameValuePair codexHomes;
      cheats = [ (lib.nameValuePair "dotfiles" "${dotfiles}/raw/cheats") ];
      widgets = map (w: lib.nameValuePair w.name "${pkgs.writeShellScript "hub-${w.name}" w.cmd}") widgets;
    };
    "hub/cards".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/raw/hub";
    # Private config, kept in the vault rather than in this public repo. Same
    # layout as config.toml and merged over it; mainly the services to check:
    #
    #   [services]
    #   Jellyfin = "https://jellyfin.example"
    #
    # Read on every start, so edits apply without a rebuild. A missing file
    # (vault locked, another machine) just means no services.
    "hub/local.toml".source = config.lib.file.mkOutOfStoreSymlink "${home}/Personal/.config/hub/local.toml";
  };

  # Alt-h: open hub and put the picked command on the prompt.
  programs.fish.interactiveShellInit = ''
    bind alt-h 'set -l c (hub); and test -n "$c"; and commandline -r -- $c; commandline -f repaint'
  '';
}
