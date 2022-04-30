function prompt() {
    # args
    # 1. title of dialog
    # 2. text of text field
    # 3. text of warning if input from user is invalid

    NAME=$(zenity --entry --title="$1" --text="$2")

    # if the length of string is zero then read value again
    while [ -z "$NAME" ]; do
        zenity --warning --text="$3" --no-wrap
        NAME=$(zenity --entry --title="$1" --text="$2")
    done

    echo $NAME
    return 0
}


# read -p "Enter team A name: " TEAM_A

# read -p "Enter team B name: " TEAM_B

read -p "Enter members in each team: " N_PLAYERS

echo "TOTAL PLAYERS: $(echo $N_PLAYERS | bc)"

for ((i=1; i<=$N_PLAYERS; i++)); do
    prompt "Player Details" "Enter name of player-$i" "Please enter valid name for player-$i"
    # echo "$i"
done
