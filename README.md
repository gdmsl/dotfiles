dotfiles by GDMSL
=================

```
                                            ##
       ##                        :####      ##     ####
       ##              ##        #####      ##     ####
       ##              ##        ##                  ##
  :###.##   .####.   #######   #######    ####       ##       .####:    :#####.
 :#######  .######.  #######   #######    ####       ##      .######:  ########
 ###  ###  ###  ###    ##        ##         ##       ##      ##:  :##  ##:  .:#
 ##.  .##  ##.  .##    ##        ##         ##       ##      ########  ##### .
 ##    ##  ##    ##    ##        ##         ##       ##      ########  .######:
 ##.  .##  ##.  .##    ##        ##         ##       ##      ##           .: ##
 ###  ###  ###  ###    ##.       ##         ##       ##:     ###.  :#  #:.  :##
 :#######  .######.    #####     ##      ########    #####   .#######  ########
  :###.##   .####.     .####     ##      ########    .####    .#####:  . ####

```

## How do I compute

**I use [Arch](https://www.archlinux.org), btw.**

In order to install software from the **AUR** I use a tool called `pacaur`

I **browse the internet** mainly with firefox.

I use `termite` as my default choice of **terminal emulator**

I **code and edit text files** using neovim from the terminal.

I use zsh as my default **shell** keeping dash and fish as secondary choices.

I use **i3** as my default window manager in a custom desktop envirorment
(with ranger as file manager).

I **listen to music** using `mpd + ncmpcpp` and my default player, both for
audio and video is the excellent `mpv`.

## Software

 * i3 - an improved dynamic tiling window manager,
 * i3blocks - define blocks for your i3bar status line,
 * i3lock - an improved screenlocker based upon XCB and PAM,
 * zsh - a very advanced and programmable command interpreter (shell) for UNIX,
 * xrandr - primitive command line interface to RandR extension,
 * rofi - popup window switcher roughly based on superswitcher, requiring only xlib and xft,
 * copyq - clipboard manager with searchable and editable history,
 * network-manager-applet - applet for managing network connections,
 * glances - CLI curses-based monitoring tool,
 * pavucontrol - PulseAudio Volume Control,
 * compton  - X compositor that may fix tearing issues,
 * tty-clock - display a clock in the terminal,
 * redshift - adjusts the color temperature of your screen according to your surroundings,
 * dunst  - customizable and lightweight notification-daemon,
 * neovim - fork of Vim aiming to improve user experience, plugins, and GUIs,
 * stow - manage installation of multiple softwares in the same directory tree,
 * mpv - a free, open source, and cross-platform media player,
 * wheechat - fast, light and extensible IRC client (curses UI),
 * zathura - minimalistic document viewer,
 * termite - a simple VTE-based terminal.

## Installation
I use `GNU stow` to create and manage the symlinks from the `dotfiles`
directory to my home directory. Each directory in the repo is a module for
stow. This will allow to create only symbolic links for the software needed.

In short:

```
$ cd ~
$ git clone https://github.com/dotfiles.git
$ cd dotfiles
$ stow -t $HOME --no-folding <name of the module>
```

and for unistall a module:
```
$ stow -t $HOME --no-folding -D <name of the module>
```

If you use Arch Linux please consider to remove my personal informations from `~/.makepkg.conf`

