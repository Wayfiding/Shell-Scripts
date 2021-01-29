



#!/bin/bash

sleep 10 & PID=$! #simulate a long process
echo
echo
echo "THIS MAY TAKE A WHILE, PLEASE BE PATIENT WHILE ______ IS RUNNING..."
printf "["
# While process is running...
while kill -0 $PID 2> /dev/null; do 
    printf  "▓"
    sleep 0.15
done

printf "] done!"
echo
echo
echo
