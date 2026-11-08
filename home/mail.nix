# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  mail.nix — notmuch mail: work (M365) in ~/Mail, Gmail in ~/Personal/Mail   ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Mail is downloaded into local maildirs, indexed by notmuch and read with aerc.
# Work and personal are two separate notmuch databases ("profiles"), so neither
# search ever sees the other's mail, and everything personal stays inside the
# encrypted ~/Personal vault.
#
#   work      ~/Mail/qperfect      mbsync (IMAP) in, msmtp (SMTP) out.
#                                  Microsoft 365 needs OAuth2: oama holds the
#                                  token in the keyring and hands mbsync/msmtp
#                                  a fresh access token on each run.
#                                  Folders are the source of truth, so Outlook
#                                  and the phone see the same thing.
#
#   personal  ~/Personal/Mail/gmail  lieer (`gmi`) over the Gmail API. Gmail
#                                  labels and notmuch tags are the same thing,
#                                  synced both ways. Sending goes through the
#                                  API too. Its token sits in that directory.
#
# Tags that exist only in notmuch are kept in step between machines with
# `notmuch git`, which stores them in a git repo per profile:
#   work      ~/.local/share/notmuch/default/git  → gitlab.qperfect.io
#   personal  ~/Personal/.local/share/notmuch/git → Forgejo on vestara
#
# The sync timers below run everything every 5 minutes. The personal one only
# runs while ~/Personal is mounted.
#
# ── One-time setup per machine ─────────────────────────────────────────────
# Work:
#   oama authorize microsoft guido.masella@qperfect.io   # device-code login
#   systemctl --user start mail-work                     # first download
#   notmuch git clone <gitlab repo url>                  # or `notmuch git init`
#                                                        # + `git remote add`
#                                                        # on the first machine
# Personal (vault unlocked):
#   mkdir -p ~/Personal/Mail
#   notmuch-personal new                                 # create the database
#   gmi init guido.masella@gmail.com
#   systemctl --user start mail-personal
#   notmuch-personal git clone <forgejo repo url>
#
# Plain `notmuch` is the work database; `notmuch-personal` is the Gmail one.
#
# lieer keeps everything in ~/Personal/Mail/gmail: settings (.gmailieer.json),
# sync state (.state.gmailieer.json), the OAuth token
# (.credentials.gmailieer.json), a lock file, and the messages in mail/.

{ config, pkgs, lib, ... }:

let
  home = config.home.homeDirectory;
  name = "Guido Masella";
  workAddress = "guido.masella@qperfect.io";
  gmailAddress = "guido.masella@gmail.com";

  workRoot = "${home}/Mail";
  personalRoot = "${home}/Personal/Mail";
  workGit = "${config.xdg.dataHome}/notmuch/default/git";
  personalGit = "${home}/Personal/.local/share/notmuch/git";

  # The plain isync package can't do OAuth2; this variant ships the SASL
  # XOAUTH2 plugin and points mbsync at it.
  mbsync = pkgs.isync.override { withCyrusSaslXoauth2 = true; };
  oamaToken = "${pkgs.oama}/bin/oama access ${workAddress}";

  # Push and pull notmuch-only tags, if this profile's tag repo exists yet.
  # Commit first: `pull` overwrites the database with what's in git.
  tagSync = repo: ''
    if [ -d "${repo}" ]; then
      notmuch git commit
      notmuch git pull
      notmuch git push
    fi
  '';

  # systemd user services start with an almost empty PATH. ssh is for the
  # tag-repo remotes.
  servicePath = lib.makeBinPath [ mbsync pkgs.notmuch pkgs.lieer pkgs.git pkgs.openssh pkgs.coreutils ];

  # Gmail has no folders here (enable-maildir = false below), so aerc's
  # sidebar is these saved searches instead.
  personalQueries = pkgs.writeText "aerc-personal-queries" ''
    Inbox=tag:inbox
    Unread=tag:unread
    Starred=tag:flagged
    Sent=tag:sent
    All=*
  '';

  # One desktop notification per sync: the count, then up to five
  # "Author; Subject" lines. `notmuch search` lines look like
  # "thread:… 2 mins. ago [1/1] Author; Subject (tags)", hence the sed.
  notifyNew = account: query: ''
    n=$(${pkgs.notmuch}/bin/notmuch count -- '${query}')
    if [ "$n" -gt 0 ]; then
      body=$(${pkgs.notmuch}/bin/notmuch search --limit=5 -- '${query}' \
        | ${pkgs.gnused}/bin/sed -E 's/^thread:[^ ]+ +[^[]*\[[^]]*\] //; s/ \([^)]*\)$//')
      ${pkgs.libnotify}/bin/notify-send -a aerc -i mail-unread "${account}: $n new" "$body" || true
    fi
  '';

  # Same refusal as the -personal wrappers in scripts.nix: with the vault
  # locked, ~/Personal is an empty directory and writing there would leave
  # unencrypted files behind the mount.
  requireVault = cmd: ''
    ${pkgs.util-linux}/bin/mountpoint -q "$HOME/Personal" || {
      echo "${cmd}: ~/Personal is locked — run 'unlock-personal' first." >&2
      exit 1
    }
  '';
in
{
  home.packages = [
    mbsync pkgs.notmuch pkgs.oama pkgs.msmtp

    # `notmuch-personal search …` is `notmuch search …` on the Gmail database.
    (pkgs.writeShellScriptBin "notmuch-personal" ''
      ${requireVault "notmuch-personal"}
      export NOTMUCH_PROFILE=personal
      exec ${pkgs.notmuch}/bin/notmuch "$@"
    '')

    # lieer is personal-only, so `gmi` itself always targets the Gmail
    # database and its directory, from wherever it's run.
    (pkgs.writeShellScriptBin "gmi" ''
      ${requireVault "gmi"}
      export NOTMUCH_PROFILE=personal
      mkdir -p "${personalRoot}/gmail"
      cd "${personalRoot}/gmail"
      exec ${pkgs.lieer}/bin/gmi "$@"
    '')
  ];

  # ── OAuth2 for Microsoft 365 ────────────────────────────────────────────
  # The client ID is Thunderbird's public one: Microsoft lets any tenant use it
  # for IMAP/SMTP, so no app registration is needed. With no client secret,
  # oama uses the device-code flow (open a URL, type a code). Tokens go to the
  # keyring.
  xdg.configFile."oama/config.yaml".text = ''
    encryption:
      tag: KEYRING
    services:
      microsoft:
        client_id: 9e5f94bc-e8a4-4e73-b8be-63364c29d753
  '';

  # ── Work: IMAP download ─────────────────────────────────────────────────
  # Every server folder is mirrored except the Outlook-only ones that hold
  # calendar and contact data rather than mail. Deletions and moves go both
  # ways, so archiving in aerc also archives in Outlook.
  home.file.".mbsyncrc".text = ''
    IMAPAccount qperfect
    Host outlook.office365.com
    User ${workAddress}
    PassCmd "${oamaToken}"
    AuthMechs XOAUTH2
    TLSType IMAPS

    IMAPStore qperfect-remote
    Account qperfect

    MaildirStore qperfect-local
    Path ${workRoot}/qperfect/
    Inbox ${workRoot}/qperfect/INBOX
    SubFolders Verbatim

    Channel qperfect
    Far :qperfect-remote:
    Near :qperfect-local:
    Patterns * !Calendar* !Contacts* !Journal !Notes !Tasks !"Sync Issues*" !"Conversation History"
    Create Both
    Expunge Both
    SyncState *
    CopyArrivalDate yes
  '';

  # ── Work: SMTP sending ──────────────────────────────────────────────────
  # Exchange saves a copy in Sent Items itself, so aerc doesn't need to.
  xdg.configFile."msmtp/config".text = ''
    account qperfect
    host smtp.office365.com
    port 587
    tls on
    tls_starttls on
    auth xoauth2
    user ${workAddress}
    from ${workAddress}
    passwordeval "${oamaToken}"

    account default : qperfect
  '';

  # ── notmuch profiles ────────────────────────────────────────────────────
  # notmuch reads ~/.config/notmuch/$NOTMUCH_PROFILE/config, with "default"
  # when the variable is unset. Each database lives in .notmuch/ under its
  # mail root, so the personal one is inside the vault.
  xdg.configFile."notmuch/default/config".text = lib.generators.toINI { } {
    database.path = workRoot;
    user = { inherit name; primary_email = workAddress; };
    # `new` marks what the last `notmuch new` added, for the post-new hook.
    new.tags = "new";
    new.ignore = "/^[.]mbsyncstate/;.uidvalidity";
    search.exclude_tags = "deleted;spam";
    # Read/flagged/replied map to maildir filename flags, which mbsync syncs.
    maildir.synchronize_flags = "true";
    git.path = workGit;
  };

  # Runs after each `notmuch new` on work mail. Tagging rules, or an LLM
  # tagger, go above the last line and should only touch `tag:new`.
  xdg.configFile."notmuch/default/hooks/post-new" = {
    executable = true;
    text = ''
      #!/bin/sh
      ${notifyNew "QPerfect" "tag:new and tag:unread and folder:qperfect/INBOX and date:2d.."}
      notmuch tag -new -- tag:new
    '';
  };

  # lieer adds messages to the database and sets their tags itself, so there's
  # no `notmuch new` step and no new.tags here.
  xdg.configFile."notmuch/personal/config".text = lib.generators.toINI { } {
    database.path = personalRoot;
    user = { inherit name; primary_email = gmailAddress; };
    # lieer's own state and token files.
    new.ignore = "/.*[.](json|lock|bak)$/";
    search.exclude_tags = "trash;spam";
    git.path = personalGit;
  };

  # ── aerc ────────────────────────────────────────────────────────────────
  # One tab per account. "notmuch://" is the default profile, "notmuch://personal"
  # the other. accounts.conf holds no secrets (tokens come from oama/lieer), so
  # aerc's check that the file is private is turned off; Home Manager can only
  # write it world-readable.
  programs.aerc = {
    enable = true;
    extraConfig.general.unsafe-accounts-conf = true;
    extraAccounts = {
      QPerfect = {
        source = "notmuch://";
        from = "${name} <${workAddress}>";
        outgoing = "${pkgs.msmtp}/bin/msmtp -a qperfect";
        # Show the maildir folders and make :archive / :delete move files.
        maildir-account-path = "qperfect";
        default = "INBOX";
        archive = "Archive";
        postpone = "Drafts";
        # A message can have one file per folder; act on the one in the
        # current folder.
        multi-file-strategy = "act-dir";
        check-mail-cmd = "systemctl --user start mail-work";
        check-mail-timeout = "60s";
      };
      Personal = {
        source = "notmuch://personal";
        from = "${name} <${gmailAddress}>";
        outgoing = "${pkgs.lieer}/bin/gmi send -t -C ${personalRoot}/gmail";
        # Gmail is labels, not folders. Archive with `:modify-labels -inbox`.
        enable-maildir = false;
        query-map = "${personalQueries}";
        default = "Inbox";
        check-mail-cmd = "systemctl --user start mail-personal";
        check-mail-timeout = "60s";
      };
    };
  };

  # ── Sync services ───────────────────────────────────────────────────────
  systemd.user.services.mail-work = {
    Unit.Description = "Sync work mail (mbsync + notmuch)";
    Service = {
      Type = "oneshot";
      Environment = "PATH=${servicePath}";
      ExecStart = toString (pkgs.writeShellScript "mail-work" ''
        set -e
        mbsync qperfect
        notmuch new --quiet
        ${tagSync workGit}
      '');
    };
  };

  systemd.user.services.mail-personal = {
    Unit = {
      Description = "Sync personal mail (lieer)";
      ConditionPathIsMountPoint = "%h/Personal";
      # Skip quietly until `gmi init` has been run.
      ConditionPathExists = "%h/Personal/Mail/gmail/.gmailieer.json";
    };
    Service = {
      Type = "oneshot";
      Environment = [ "PATH=${servicePath}" "NOTMUCH_PROFILE=personal" ];
      WorkingDirectory = "%h/Personal/Mail/gmail";
      ExecStart = toString (pkgs.writeShellScript "mail-personal" ''
        set -e
        # lieer owns .gmailieer.json (it writes it during init), so settings
        # are applied here rather than linked in. Empty = keep every Gmail
        # label, including the CATEGORY_* ones Gmail sorts mail into.
        # `notified` is local bookkeeping for the notification below and must
        # not become a Gmail label.
        gmi set --ignore-tags-remote "" --ignore-tags-local notified
        # -s, not --quiet: lieer 1.6 crashes on a full pull with --quiet.
        gmi sync -s
        # date:2d.. keeps the first run from announcing years of old unread mail.
        ${notifyNew "Personal" "tag:inbox and tag:unread and not tag:notified and date:2d.."}
        notmuch tag +notified -- 'tag:inbox and tag:unread and not tag:notified and date:2d..'
        ${tagSync personalGit}
      '');
    };
  };

  # Every 5 minutes, and not Persistent: a missed run just happens next slot.
  systemd.user.timers = lib.genAttrs [ "mail-work" "mail-personal" ] (n: {
    Unit.Description = "Periodic ${n} sync";
    Timer.OnCalendar = "*:0/5";
    Install.WantedBy = [ "timers.target" ];
  });
}
