#!/bin/bash

UTILITIES_PATH="./utilities"
CLUB_NAME="RV Cricket Club"

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

function displayScores() {
    TEAMS=($(ls ../total_runs/*))

    MAX_SCORE=$(cat ${TEAMS[0]})
    MAX_TEAM=${TEAMS[0]}

    MIN_SCORE=$(cat ${TEAMS[0]})
    MIN_TEAM=${TEAMS[0]}

    echo -e "\n${B_BLACK}${F_WHITE}Details of the match:${T_RESET}\n"
    for file in "${TEAMS[@]}" ; do
        SCORE=$(cat $file)
        echo "Team \"${F_YELLOW}$(basename $file)${T_RESET}\" has scored ${F_YELLOW}$SCORE${T_RESET} runs"

        # calculating max score
        if [ $SCORE -gt $MAX_SCORE ]; then
            MAX_SCORE=$SCORE
            MAX_TEAM=$file
        fi

        # calculating min score
        if [ $SCORE -lt $MAX_SCORE ]; then
            MIN_SCORE=$SCORE
            MIN_TEAM=$file
        fi
    done

    if [ $MAX_SCORE -ne $MIN_SCORE ]; then
        echo -e "\n${B_BLACK}${F_WHITE}Team ${F_GREEN}$(basename $MAX_TEAM)${F_WHITE} wins this match by ${F_GREEN}$(expr $MAX_SCORE - $MIN_SCORE)${F_WHITE} runs!${T_RESET}"
    else
        echo -e "\n${B_BLACK}${F_WHITE}The match was a ${F_YELLOW}draw${T_RESET}"
    fi
}

function play() {
    
    TEAMS=$(ls ../teams/)
    TEMP_TEAMS=${TEAMS[@]}

    BATTING_TEAM=$(./utilities/showList "Which team should bat first?" $TEAMS)
    echo -e "\nBatting team is: ${F_GREEN}$BATTING_TEAM${T_RESET}"

    ./utilities/showInfo \
        "$CLUB_NAME" \
        "First Innings will be played by team \"$BATTING_TEAM\""

    ./play.sh "$BATTING_TEAM" 1
    OLD_BATTING_TEAM=$BATTING_TEAM

    ./utilities/showInfo \
        "$CLUB_NAME: 1st innings finished" \
        "Team $BATTING_TEAM has scored $(cat ../total_runs/$BATTING_TEAM) runs"

    TEAMS=$(./utilities/removeValueFromArray ${TEAMS[@]} $BATTING_TEAM)
    BATTING_TEAM=${TEAMS[0]}

    ./utilities/showInfo \
        "$CLUB_NAME" \
        "Second Innings will be played by team \"$BATTING_TEAM\""

    ./play.sh "$BATTING_TEAM" 2 $OLD_BATTING_TEAM

    ./utilities/showInfo \
        "$CLUB_NAME: 2nd innings finished" \
        "Team $BATTING_TEAM has scored $(cat ../total_runs/$BATTING_TEAM) runs"

    displayScores
}

### DRIVER CODE ###

if [ -d "../teams" ]; then
    RES=$(./$UTILITIES_PATH/showConfirmation "Players exist" "Do you want to remove existing teams and add new teams?")
    if [ "$RES" -eq 0 ]; then
        # dont add players, play with existing players
        echo "${F_GREEN}Playing with existing players${T_RESET}"
        play
    else
        # add team, players, and play
        bash init.sh
        play
    fi
else
    bash init.sh
    play
fi