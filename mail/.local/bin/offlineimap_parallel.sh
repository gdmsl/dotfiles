#!/bin/bash

offlineimap -a gmail & pid1=$!
offlineimap -a outlook & pid2=$!
offlineimap -a uds & pid3=$!
offlineimap -a uds-etu & pid4=$!

wait $pid1
wait $pid2
wait $pid3
wait $pid4
echo "Last execution: $(date)"
