#!/usr/bin/env bash
#
# AUTHOR: Guido Masella <guido.masella@gmail.com>
#

temp=`sensors coretemp-isa-0000 | awk '/Physical/ { print $4 }' | grep -m 1 --color=none -o "[0-9]\{1,\}" - | head -n 1`

bef='<span  letter_spacing="-4800" rise="00">'
aft='</span>'
small='<span font="6">'
replay='<span font="8"  letter_spacing="-11500">'

echo -e "$temp°C\n$temp°C"
case "$temp" in
    1[0-9]|2[0-9] ) echo "#03a9f4" ;;
    3[0-9]|4[0-9] ) echo "#76ff03" ;;
    5[0-9]|6[0-9] ) echo "#e0e0e0" ;;
    7[0-9]|8[0-9] ) echo "#ffeb3b" ;;
    9[0-9]|10[0-9]) echo "#f44336" ;;
    *             ) echo "bad" ;;
esac
