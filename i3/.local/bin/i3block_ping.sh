#!/bin/bash
ping -c 1 $BLOCK_INSTANCE | grep -m 1 -o "[0-9]*.[0-9]* ms" -
