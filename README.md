dotfiles by GDMSL
=================

## How I compute

My default distro is of course **Arch Linux**.

I use **my own AUR helper** to compile and install pkgs from the Arch User Repository, it is called AURshield (`aurshield`), it's written in python (v3) and you can find it on [bitbucket](https://bitbucket.org/gdmsl/aurshield).

I **browse the internet** with firefox, avoiding flash content and using chromium (with pepper-flash) only when absolutely needed.

I use urxvt as my default choice of **terminal emulator**

I **code and edit text files** using vim from the terminal, keeping it slim (no completion tools) or atom-editor from the GUI.

I use zsh as my default **shell** keeping dash and fish as secondary choices.

I use **i3** as my default window manager in a custom desktop envirorment
(with ranger as file manager). I also use **XFCE** as my fallback DE of choice.

I **listen to music** using `lollypop` or `mpd + ncmpcpp` and my default player, both for audio and video is the excellent `mpv`.

## Requirements

 * zsh
 * git
 * stow
 * xrandr

Common requirements for *both* **i3** and **openbox**

 * dmenu-xft
 * alsa-utils
 * clipit
 * network-manager-applet
 * glances
 * pavucontrol
 * compton (AUR)
 * tty-clock

These are the requirements for using the **i3 desktop** (archlinux packages):

 * i3
 * ranger
 * i3blocks-git (AUR)

 For the **openbox** desktop:

  * openbox
  * tint2


## Installation
I use `GNU stow` to create and manage the symlinks from the `dotfiles`
directory to my home directory. Each directory in the repo is a module for
stow. This will allow to create only symlinks for the software needed.

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

I also have a script to generate menus for openbox but I do not remember how to use it. I think you have just to include the generated file for the menu in the `menu.xml` from openbox configurations.
