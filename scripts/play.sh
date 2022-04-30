#!/bin/bash

function removeValueFromArray() {
    # convert all arguements to array
    local a=("$@")

    # extract array by taking every element except last one
    local ARRAY="${a[@]::${#a[@]}-1}"

    # extract last element in a variable
    local REMOVE="${a[-1]}"

    REMOVED_ARRAY=()
    for item in ${ARRAY}; do
        if [ "$item" != "$REMOVE" ]; then
            REMOVED_ARRAY+=("$item")
        fi
    done

    echo ${REMOVED_ARRAY[@]}
    return 0
}

TEAMS=$(ls ../teams/)

BATTING_TEAM=$(./utilities/showList "Which team should bat first?" $TEAMS)

echo "BATTING TEAM IS: $BATTING_TEAM"

PLAYERS=($(ls ../teams/$BATTING_TEAM/))
echo "PLAYERS: ${PLAYERS[@]}"

BATSMEN_1=$(./utilities/showList "Who should be 1st batsmen?" ${PLAYERS[@]})

REMAINING_PLAYERS=$(removeValueFromArray ${PLAYERS[@]} $BATSMEN_1)

echo "REMAINING PLAYERS: ${REMAINING_PLAYERS[@]}"

BATSMEN_2=$(./utilities/showList "Who should be 2nd batsmen?" ${REMAINING_PLAYERS[@]})

echo "PLAYING $BATSMEN_1 , $BATSMEN_2"

