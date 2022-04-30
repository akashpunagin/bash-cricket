#!/bin/bash

UTILITIES_PATH="./utilities"
CLUB_NAME="RV Cricket Club"

function displayScores() {
    TEAMS=($(ls ../total_runs/*))

    MAX_SCORE=$(cat ${TEAMS[0]})
    MAX_TEAM=${TEAMS[0]}

    MIN_SCORE=$(cat ${TEAMS[0]})
    MIN_TEAM=${TEAMS[0]}

    echo "Details of the match"
    for file in "${TEAMS[@]}" ; do
        SCORE=$(cat $file)
        echo "Team \"$(basename $file)\" has scored $SCORE runs"

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
        echo -e "\nTeam \"$(basename $MAX_TEAM)\" wins this match by $(expr $MAX_SCORE - $MIN_SCORE) runs!"
    else
        echo -e "\nThe match between Team \"$(basename $MAX_TEAM) and\" Team \"$(basename $MIN_TEAM)\" was a draw"
    fi

}

function play() {
    
    TEAMS=$(ls ../teams/)
    TEMP_TEAMS=${TEAMS[@]}

    BATTING_TEAM=$(./utilities/showList "Which team should bat first?" $TEAMS)
    echo "BATTING TEAM IS: $BATTING_TEAM"

    ./utilities/showInfo \
        "$CLUB_NAME" \
        "First Innings will be played by team \"$BATTING_TEAM\""

    ./play.sh "$BATTING_TEAM"

    ./utilities/showInfo \
        "$CLUB_NAME: 1st innings finished" \
        "Team $BATTING_TEAM has scored $(cat ../total_runs/$BATTING_TEAM) runs"

    TEAMS=$(./utilities/removeValueFromArray ${TEAMS[@]} $BATTING_TEAM)
    BATTING_TEAM=${TEAMS[0]}

    ./utilities/showInfo \
        "$CLUB_NAME" \
        "Second Innings will be played by team \"$BATTING_TEAM\""

    ./play.sh "$BATTING_TEAM"

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