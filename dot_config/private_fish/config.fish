# Config inspired by folke's dotfiles

set -gx EDITOR (which nvim)
set -gx VISUAL $EDITOR
set -gx SUDO_EDITOR $EDITOR

# Exports
set -x LESS -rF
set -x MANPAGER "nvim +Man!"
set -x MANROFFOPT -c

# NPM
set GOPATH "$HOME/Variable/."
set NPM_PACKAGES "$HOME/.npm-packages"
set PATH $PATH $NPM_PACKAGES/bin
set MANPATH $NPM_PACKAGES/share/man (manpath)

# Cursor styles
set -gx fish_vi_force_cursor 1
set -gx fish_cursor_default block
set -gx fish_cursor_insert line blink
set -gx fish_cursor_visual block
set -gx fish_cursor_replace_one underscore

# Fish
set fish_emoji_width 2

# PATH
set -x fish_user_paths
fish_add_path ~/.local/bin
fish_add_path ~/.luarocks/bin
fish_add_path ~/.cargo/bin
fish_add_path /var/lib/flatpak/exports/bin/

# Tmux
abbr t tmux
abbr tc 'tmux attach'
abbr ta 'tmux attach -t'
abbr tad 'tmux attach -d -t'
abbr tl 'tmux ls'
abbr ts 'tmux new-session -s'
abbr tk 'tmux kill-session -t'
abbr mux tmuxinator

# Files & directories
abbr mv 'mv -iv'
abbr cp 'cp -riv'
abbr mkdir 'mkdir -vp'
alias ls="eza --color=always --icons --group-directories-first"
alias la 'eza --color=always --icons --group-directories-first --all'
alias ll 'eza --color=always --icons --group-directories-first --all --long'
alias tree 'eza --color=always --icons --group-directories-first --tree'
abbr l ll
abbr ncdu 'ncdu --color dark'

# Editor
abbr vim nvim
abbr vi nvim
abbr v nvim
alias vimpager 'nvim - -c "lua require(\'util\').colorize()"'
abbr sv sudoedit
abbr vudo sudoedit
alias lazyvim "NVIM_APPNAME=lazyvim nvim"
abbr lv lazyvim
alias bt "coredumpctl -1 gdb -A '-ex \"bt\" -q -batch' 2>/dev/null | awk '/Program terminated with signal/,0' | bat -l cpp --no-pager --style plain"

# Dev
abbr git hub
abbr g hub
abbr gg lazygit
abbr gl "hub l --color | devmoji --log --color | less -rXF"
abbr gs 'hub st'
abbr gb 'hub checkout -b'
abbr gc 'hub commit'
abbr gpr 'hub pr checkout'
abbr gm "hub branch -l main | rg main > /dev/null 2>&1 && hub checkout main || hub checkout master"
abbr gcp "hub commit -p"
abbr gpp "hub push"
abbr gp "hub pull"

# Other
abbr grep rg
abbr df "grc /bin/df -h"
abbr fda "fd -IH"
abbr rga "rg -uu"

# journalctl
abbr s systemctl
abbr su 'systemctl --user'
abbr ss 'systemctl status'
abbr sl 'systemctl --type service --state running'
abbr slu 'systemctl --user --type service --state running'
abbr sf 'systemctl --failed --all'

# journalctl
abbr jb 'journalctl -b'
abbr jf 'journalctl -f'
abbr jg 'journalctl -b --grep'
abbr ju 'journalctl --unit'
abbr jm 'journalctl --user'

# paru
abbr p paru
abbr pai 'paru -S'
abbr par 'paru -R'
abbr pas 'paru -Ss'
abbr pal 'paru -Q'
abbr paf 'paru -Ql'
abbr pao 'paru -Qo'

# hoock up direnv
direnv hook fish | source

if status is-interactive
    # Commands to run in interactive sessions can go here
end
