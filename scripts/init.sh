#!/bin/bash

UTILITIES_PATH="./utilities"

function addTeam() {
    local TEAM_PATH=$1
    mkdir $TEAM_PATH
}

function addPlayers() {
    local N_PLAYERS=$1
    local TEAM_NAME=$2
    local TEAM_PATH=$3
    
    for ((i=1; i<=$N_PLAYERS; i++)); do

        while : ; do

            NAME=$($UTILITIES_PATH/prompt \
                "Player Details of $TEAM_NAME" \
                "Enter name of player-$i" \
                "Please enter valid name for player-$i")

            if [ -f ./$TEAM_PATH/$NAME ]; then
                ./$UTILITIES_PATH/showWarning "Player \"$NAME\" already exists"
                continue
            else
                touch ./$TEAM_PATH/$NAME
                break
            fi
        done
    done

    ./$UTILITIES_PATH/showInfo "Players Added" "Players added to team: $2"
}

### DRIVER CODE ###

rm -rf ../teams
mkdir ../teams

rm -rf ../total_runs 
mkdir ../total_runs

read -p "Enter the number of overs: " N_OVERS
echo "$N_OVERS" > ../n_overs

read -p "Enter team A name: " TEAM_A

read -p "Enter team B name: " TEAM_B

TEAM_A_PATH="../teams/$TEAM_A"
TEAM_B_PATH="../teams/$TEAM_B"

addTeam $TEAM_A_PATH
addTeam $TEAM_B_PATH

read -p "Enter members in each team: " N_PLAYERS

addPlayers $N_PLAYERS $TEAM_A $TEAM_A_PATH
addPlayers $N_PLAYERS $TEAM_B $TEAM_B_PATH