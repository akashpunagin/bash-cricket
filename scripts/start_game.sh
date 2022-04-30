#!/bin/bash

UTILITIES_PATH="./utilities"

function play() {
    TEAMS=$(ls ../teams/)

    BATTING_TEAM=$(./utilities/showList "Which team should bat first?" $TEAMS)
    echo "BATTING TEAM IS: $BATTING_TEAM"

    ./play.sh "$BATTING_TEAM"

    TEAMS=$(./utilities/removeValueFromArray ${TEAMS[@]} $BATTING_TEAM)
    BATTING_TEAM=${TEAMS[0]}

    ./play.sh "$BATTING_TEAM"


    
}

### DRIVER CODE ###

if [ -d "../teams" ]; then
    RES=$(./$UTILITIES_PATH/showConfirmation "Players exist" "Do you want to remove existing teams and add new teams?")
    if [ "$RES" -eq 0 ]; then
        # dont add players, play with existing players
        echo "Playing with existing players"
        play
    else
        # add team, players, and play
        bash init.sh
        play
    fi
else
    bash init.sh
fi


