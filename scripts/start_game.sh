#!/bin/bash

UTILITIES_PATH="./utilities"

### DRIVER CODE ###

if [ -d "../teams" ]; then
    RES=$(./$UTILITIES_PATH/showConfirmation "Players exist" "Do you want to remove existing teams and add new teams?")
    if [ "$RES" -eq 0 ]; then
        # dont add players, play with existing players
        echo "Playing with existing players"
    else
        # add team, players, and play
        bash init.sh
    fi
else
    bash init.sh
fi


