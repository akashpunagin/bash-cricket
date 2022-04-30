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

function handleBall() {
    # returns "OUT" if out else returns number of runs
    local CURRENT_BATSMEN=$1
    RES=$(./utilities/showList "How did $CURRENT_BATSMEN handle the ball?" "Scored_Run" "Wicket")

    if [ "$RES" == "Scored_Run" ]; then 
        RUNS=$(./utilities/showList "How much runs was scored?" 0 1 2 3 4 6)
        echo $RUNS
        return 0
    else
        echo "OUT"
        return 0
    fi
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
REMAINING_PLAYERS=$(removeValueFromArray ${REMAINING_PLAYERS[@]} $BATSMEN_2)
echo "REMAINING PLAYERS: ${REMAINING_PLAYERS[@]}"

echo "PLAYING $BATSMEN_1 , $BATSMEN_2"

CURRENT_BATSMEN=$BATSMEN_1


TOTAL_RUNS=0

function getLengthOfArray() {
    # convert all arguements to array
    local a=("$@")
    local ARRAY=${a[@]}

    local count=0
    for i in ${ARRAY[@]}; do 
        count=$(expr $count + 1)
    done

    echo "$count"
}

while (( ${#REMAINING_PLAYERS[@]} )); do
    echo "LENGTH:: ${REMAINING_PLAYERS[@]}"
    BALL_RES=$(handleBall $CURRENT_BATSMEN)

    echo -e "\n"

    if [ $BALL_RES == "OUT" ]; then
        echo "$CURRENT_BATSMEN was out"
        REMAINING_PLAYERS=$(removeValueFromArray ${REMAINING_PLAYERS[@]} $CURRENT_BATSMEN)
        LEN=$(getLengthOfArray $REMAINING_PLAYERS)
        if [ "$LEN" -eq 0 ]; then
            echo "NO PLAYERS LEFT"
            break
        fi
        CURRENT_BATSMEN=$(./utilities/showList "Who should be batsmen?" ${REMAINING_PLAYERS[@]})

    else
        RUNS=$BALL_RES
        echo "$CURRENT_BATSMEN scored $RUNS"
    fi
done

echo "MATCH OVER"