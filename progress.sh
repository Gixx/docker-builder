#!/bin/bash

"$@" &

SAVE_CURSOR=$(tput sc)
RESTORE_CURSOR=$(tput rc)
CLEAR=$(tput el)
COUNTER=1

echo -n "    $SAVE_CURSOR" > /dev/tty

while kill -0 $! &> /dev/null; do
    if [[ $COUNTER > 5 ]]; then
        COUNTER=1
        echo -n $RESTORE_CURSOR$CLEAR > /dev/tty
    fi
    echo -n '.' > /dev/tty
    let ++COUNTER
    sleep 1
done
