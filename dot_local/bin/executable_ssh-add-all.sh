#!/bin/sh

echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
echo "HOSTNAME=$HOSTNAME"

for key in ${HOME}/.ssh/id_*.${HOSTNAME}.pub; do
	echo "Adding $key"
	ssh-add ${key/.pub/} < /dev/null
done

for key in ${HOME}/.ssh/id_*.pub; do
	if echo "$key" | grep ${HOSTNAME} >/dev/null; then
		continue
	fi

	echo "Adding $key"
	ssh-add ${key/.pub/} < /dev/null
done
