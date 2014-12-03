dotfiles by GDMSL
=================

## How I compute

My default distro is of course **Arch Linux**.

I use **my own AUR helper** to compile and install pkgs from the Arch User Repository, it is called AURshield (`aurshield`), it's written in python (v3) and you can find it on [bitbucket](https://bitbucket.org/gdmsl/aurshield).

I **browse the internet** with firefox, avoiding flash content and using chromium (with pepper-flash) only when absolutely needed.

I use urxvt as my default choice of **terminal emulator**

I **code and edit text files** using vim from the terminal, keeping it slim (no completion tools) or atom-editor from the GUI.

I use zsh as my default **shell** keeping dash and fish as secondary choices.

I use *GNOME* as my default, full featured **DE** but i switch to i3 (i3, urxvt, vim, ranger plus other tools) for intensive task which require high concentration and/or a big amount of terminals (urxvt). The openbox desktop is an experiment.

I **listen to music** using `lollypop` or `mpd + ncmpcpp` and my default player, both for audio and video is the excellent `mpv`.

## Requirements

 * zsh
 * git

Common requirements for *both* **i3** and **openbox**

 * dmenu-xft
 * alsa-utils
 * clipit
 * network-manager-applet

These are the requirements for using the **i3 desktop** (archlinux packages):

 * i3
 * ranger
 * i3blocks-git (AUR)

 For the **openbox** desktop:

  * openbox
  * compton (AUR)
  * tint2


## Installation
To install these files clone the repository and then run in order the script `lndotfiles.sh` from the repo dir and `.local/bin/gdmslinstall.sh`. The first script will create the directory and symlink all the stuff from the *dotfiles* repository to your home folder replacing quietly all the files you already have (so make backups if you need them). The second script will install ohmyzsh, vim bundles using vundle and my personal color scheme using base16-builder. Read the script before executing it.

NOTE: to install correctly the color scheme for gnome-terminal make sure that you have modified at least once the default profile (in order to create the keys for dconf)

In short:

```
$ cd ~
$ git clone https://github.com/dotfiles.git
$ cd dotfiles
$ ./lndotfiles.sh
$ .local/bin/gdmslinstall.sh
```

If you use Arch Linux please consider to remove my personal informations from `~/.makepkg.conf`

I also have a script to generate menus for openbox but I do not remember how to use it. I think you have just to include the generated file for the menu in the `menu.xml` from openbox configurations.
