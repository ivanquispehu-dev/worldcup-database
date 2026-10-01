#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.


echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")

get_team_id() {
  # returns the id of a team, inserting it first if it doesn't exist
  local TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$1'")
  if [[ -z $TEAM_ID ]]
  then
    TEAM_ID=$($PSQL "INSERT INTO teams(name) VALUES('$1') RETURNING team_id" | head -1)
  fi
  echo $TEAM_ID
}

tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  WINNER_ID=$(get_team_id "$WINNER")
  OPPONENT_ID=$(get_team_id "$OPPONENT")

  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
  then
    echo "Inserted game: $YEAR $ROUND, $WINNER vs $OPPONENT"
  fi
done
