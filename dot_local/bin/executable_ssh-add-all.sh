#!/bin/sh

cd $HOME/.ssh

for key in ${HOME}/.ssh/id_*.pub; do
    ssh-add ${key/.pub/} < /dev/null
done

