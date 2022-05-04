#!/bin/bash

# Reset
T_RESET=`tput sgr0`

# Foreground
F_RED=`tput setaf 1`
F_GREEN=`tput setaf 2`
F_WHITE=`tput setaf 7`
F_YELLOW=`tput setaf 3`

# Background
B_BLACK=`tput setab 0`
B_RED=`tput setab 1`
B_GREEN=`tput setab 2`
B_WHITE=`tput setab 7`


function handleBall() {
    # returns "OUT" if out
    # "WIDE" if wide
    # "NO_BALL" if no ball
    # else returns number of runs
    
    local CURRENT_BATSMEN=$1
    RES=$(./utilities/showList "How did $CURRENT_BATSMEN handle the ball?" "Scored_Run" "Wicket" "Extras")

    if [ "$RES" == "Scored_Run" ]; then 
        RUNS=$(./utilities/showList "How much runs was scored?" 0 1 2 3 4 6)
        echo $RUNS
        return 0
    elif [ "$RES" == "Extras" ]; then
        EXTRA=$(./utilities/showList "Which extra?" "WIDE" "NO_BALL")
        echo $EXTRA
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

function playSound() {
    local BALL_RES=$1

    if [ "$BALL_RES" == "4" ]; then
        ./sounds/four
    elif [ "$BALL_RES" == "6" ]; then
        ./sounds/six
    elif [ "$BALL_RES" == "OUT" ]; then
        ./sounds/out
    fi
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

function displayTotalRuns() {
    local TOTAL_RUNS=$1
    echo -e "${B_BLACK}${F_GREEN}Total Runs: $TOTAL_RUNS${T_RESET}\n"
}

function displayFreeHit() {
    echo "${B_GREEN}${F_WHITE}Free Hit${T_RESET}"
}

N_OVERS=$(cat ../n_overs)
echo "Total overs: $N_OVERS"
N_BALLS=$(expr $N_OVERS \* 6)
echo "Total balls: $N_BALLS"
CURRENT_BALL=0

function displayEndMatchMessage() {
    local MESSAGE=$1

    echo -e "\n${F_RED}${MESSAGE}${T_RESET}"
}

IS_NO_BALL=0
while (( ${#REMAINING_PLAYERS[@]} )); do
    CURRENT_BALL=$(expr $CURRENT_BALL + 1)

    if [ $CURRENT_BALL -ge $N_BALLS ]; then
        displayEndMatchMessage "No balls remaining"
        break
    fi

    echo -e "\nBall ${F_YELLOW}$CURRENT_BALL${F_WHITE} of ${F_YELLOW}$N_BALLS${F_WHITE}. Remaining: ${F_GREEN}$(expr $N_BALLS - $CURRENT_BALL)${F_WHITE} balls"

    BALL_RES=$(handleBall $CURRENT_BATSMEN)

    playSound $BALL_RES

    if [ $BALL_RES == "OUT" ]; then

        if [ $IS_NO_BALL -eq 1 ]; then
            echo "${B_RED}${F_YELLOW}$CURRENT_BATSMEN was out${T_RESET}, but it was a $(displayFreeHit)"
            IS_NO_BALL=0    
        else
            echo "${B_RED}${F_YELLOW}$CURRENT_BATSMEN was out${T_RESET}"

            REMAINING_PLAYERS=$(./utilities/removeValueFromArray ${REMAINING_PLAYERS[@]} $CURRENT_BATSMEN)
            LEN=$(getLengthOfArray $REMAINING_PLAYERS)
            if [ "$LEN" -eq 0 ]; then
                displayEndMatchMessage "No players left"
                break
            fi
            CURRENT_BATSMEN=$(./utilities/showList "Who should be batsmen?" ${REMAINING_PLAYERS[@]})
            echo "${F_GREEN}$CURRENT_BATSMEN${T_RESET} was chosen to bat"
        fi

    elif [ $BALL_RES == "WIDE" ]; then
        N_BALLS=$(expr $N_BALLS + 1)
        TOTAL_RUNS=$(expr $TOTAL_RUNS + 1)
        displayTotalRuns $TOTAL_RUNS
    elif [ $BALL_RES == "NO_BALL" ]; then
        IS_NO_BALL=1
        displayFreeHit
    else
        RUNS=$BALL_RES
        echo "${F_GREEN}$CURRENT_BATSMEN${F_WHITE} scored ${F_YELLOW}$RUNS${T_RESET} runs"

        updatePlayerFile
        
        TOTAL_RUNS=$(expr $TOTAL_RUNS + $RUNS)

        # swap players if odd runs scored
        if [[ $RUNS -eq 1 || $RUNS -eq 3 ]]; then
            swapCurrentBatsmen
        fi

        displayTotalRuns $TOTAL_RUNS

    fi
done

echo -e "\nMatch Over\n${B_BLACK}Total Score: $TOTAL_RUNS${T_RESET}"
echo "$TOTAL_RUNS" > ../total_runs/$BATTING_TEAM

