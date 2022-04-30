#!/bin/bash

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

#### DRIVER CODE ####
BATTING_TEAM=$1

PLAYERS=($(ls ../teams/$BATTING_TEAM/))

BATSMEN_1=$(./utilities/showList "Who should be 1st batsmen?" ${PLAYERS[@]})
REMAINING_PLAYERS=$(./utilities/removeValueFromArray ${PLAYERS[@]} $BATSMEN_1)

BATSMEN_2=$(./utilities/showList "Who should be 2nd batsmen?" ${REMAINING_PLAYERS[@]})
REMAINING_PLAYERS=$(./utilities/removeValueFromArray ${REMAINING_PLAYERS[@]} $BATSMEN_2)

CURRENT_BATSMEN=$BATSMEN_1

TOTAL_RUNS=0

function swapCurrentBatsmen() {
    if [ "$CURRENT_BATSMEN" == "$BATSMEN_1" ]; then
        CURRENT_BATSMEN=$BATSMEN_2
    elif [ "$CURRENT_BATSMEN" == "$BATSMEN_2" ]; then
        CURRENT_BATSMEN=$BATSMEN_1
    fi
}

function updatePlayerFile() {
    PLAYER_PATH="../teams/$BATTING_TEAM/$CURRENT_BATSMEN"
    PLAYER_RUNS=$(cat $PLAYER_PATH)

    if [ -n "$PLAYER_RUNS" ]; then
        PLAYER_RUNS=$(expr $PLAYER_RUNS + $RUNS)
    else 
        PLAYER_RUNS="$RUNS"
    fi
    echo "$PLAYER_RUNS" > $PLAYER_PATH
}

N_OVERS=$(cat ../n_overs)
echo "Total overs: $N_OVERS"
N_BALLS=$(expr $N_OVERS \* 6)
echo "Total balls: $N_BALLS"
CURRENT_BALL=0

while (( ${#REMAINING_PLAYERS[@]} )); do
    CURRENT_BALL=$(expr $CURRENT_BALL + 1)

    if [ $CURRENT_BALL -ge $N_BALLS ]; then
        echo "No balls remaining"
        break
    fi

    echo -e "\nBall $CURRENT_BALL of $N_BALLS. Remaining: $(expr $N_BALLS - $CURRENT_BALL) balls"

    BALL_RES=$(handleBall $CURRENT_BATSMEN)

    if [ $BALL_RES == "OUT" ]; then
        echo "$CURRENT_BATSMEN was out"

        REMAINING_PLAYERS=$(./utilities/removeValueFromArray ${REMAINING_PLAYERS[@]} $CURRENT_BATSMEN)
        LEN=$(getLengthOfArray $REMAINING_PLAYERS)
        if [ "$LEN" -eq 0 ]; then
            echo "NO PLAYERS LEFT"
            break
        fi
        CURRENT_BATSMEN=$(./utilities/showList "Who should be batsmen?" ${REMAINING_PLAYERS[@]})
        echo "$CURRENT_BATSMEN was chosen to bat"

    else
        RUNS=$BALL_RES
        echo "$CURRENT_BATSMEN scored $RUNS"

        updatePlayerFile
        
        TOTAL_RUNS=$(expr $TOTAL_RUNS + $RUNS)

        # swap players if odd runs scored
        if [[ $RUNS -eq 1 || $RUNS -eq 3 ]]; then
            echo "SWAP PLAYERS"
            swapCurrentBatsmen
        fi

        echo -e "TOTAL RUNS: $TOTAL_RUNS\n"

    fi
done

echo -e "Match Over\nTotal Score: $TOTAL_RUNS"
echo "$TOTAL_RUNS" > ../total_runs/$BATTING_TEAM

