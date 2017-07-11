#!/bin/bash
new_dirs="$HOME/var/mail/gmail/inbox/new $HOME/var/mail/uds/inbox/new"

for new_dir in $new_dirs; do
    num_mail=$(ls $new_dir|wc -l)
    if [[ $num_mail -gt 0 ]];then
        for i in $new_dir/*;do
            message="$(grep -m1 '^From: ' $i|sed 's/From: //'|sed 's/ <[^>]*>//')\n$(grep -m1 '^Subject: ' $i|sed 's/Subject: //')\n"
            message="$(echo "$message" | perl -CS -MEncode -ne 'print decode("MIME-Header", $_)')";
            notify-send "New Mail" "$message" -c email.arrived -t 5000 &
        done
    fi
done

notmuch new &

