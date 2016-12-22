#!/bin/bash

"$@" &

echo ""

while kill -0 $! &> /dev/null; do
    printf '.' > /dev/tty
    sleep 1
done
