#!/bin/bash

if [ -f "$1.xoj" ]; then
    xournal $1.xoj
else
    xournal $1
fi
