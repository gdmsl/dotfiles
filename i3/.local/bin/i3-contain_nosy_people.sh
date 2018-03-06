#!/bin/bash

outputs=`i3-msg -t get_outputs | jq 'foreach .[] as $item ([];if $item.active == true then $item.name else empty end; if $item.active == true then $item.name else empty end)'`

for out in $outputs; do
    outstripped=`echo $out | sed 's/"//g'`
    i3-msg "workspace dist $outstripped"
    i3-msg "move workspace to output $out"
    randnumber=$RANDOM
    echo $randnumber
    modnumber=$((randnumber % 7))
    echo $modnumber
    case $modnumber in
        1)
            termite -e ranger &
            ;;
        2)
            termite -e glances &
            ;;
        [3-5])
            termite &
            ;;
    esac
    randnumber=$RANDOM
    echo $randnumber
    modnumber=$((randnumber % 7))
    echo $modnumber
    case $modnumber in
        1)
            termite -e ranger &
            ;;
        2)
            termite -e glances &
            ;;
        [3-5])
            termite &
            ;;
    esac
    sleep 1s;
done
