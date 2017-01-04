#!/bin/bash

"$@" &

SAVE_CURSOR=$(tput sc)
RESTORE_CURSOR=$(tput rc)
CLEAR=$(tput el)
COUNTER=1

echo -n "    $SAVE_CURSOR" > /dev/tty

while kill -0 $! &> /dev/null; do
    if [[ $COUNTER > 3 ]]; then
        COUNTER=1
        echo -n $RESTORE_CURSOR$CLEAR > /dev/tty
    else
        echo -n '.' > /dev/tty
        let ++COUNTER
    fi
    sleep 1
done

echo -n $RESTORE_CURSOR$CLEAR > /dev/tty
