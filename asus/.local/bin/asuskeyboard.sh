#!/bin/bash
#
#   asuskeyboard.sh
#   AUTHOR: Guido Masella <guido.masella@gmail.com>
#

# This scripts sets the keyboard backlight of an asus UX303 laptop.
#https://wiki.archlinux.org/index.php/ASUS_Zenbook_UX303#Keyboard_backlight

max=$(cat "/sys/class/leds/asus::kbd_backlight/max_brightness")
brightness=$(cat "/sys/class/leds/asus::kbd_backlight/brightness")

case $1 in
"-h")
    echo "Usage: $(basename $0) {up|down|on|off|max|value}"
    echo
    echo "Set the brightness of the keyboard on an Asus Zenbook laptop."
    echo "Tested on Zenbook UX303UB."
    echo
    exit
    ;;
"on") value=1
    ;;
"off")
    value=0
    ;;
"max")
    value=max
    ;;
[0-3])
    value=$1
    ;;
"up")
    if [[ "$brightness" -lt "$max" ]]; then
        value=$((brightness+1))
    else
        value=$brightness
    fi
    ;;
"down")
    if [[ "$brightness" -gt 0 ]]; then
        value=$((brightness-1))
    else
        value=$brightness
    fi

    ;;
*)
    echo "$0: $1: invalid value." 1>&2 
    exit 1;
    ;;
esac

echo $value >> "/sys/class/leds/asus::kbd_backlight/brightness"

