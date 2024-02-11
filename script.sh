#!/bin/bash

error_str=" +---------------+\n | RANKFTC USAGE |\n +---------------+\n \n RankFTC compares a specified team with all other teams\n attending a specified match that it is a part of. To do\n this, you must supply a season, match code, and team #.\n Refer to the following instructions to find a match: \n \n -------------------------------------------------------\n \n Searching for Matches \n \n Command:\n \n <command> search <season year> <match name>\n \n \n Description:\n \n You can search for matches using its name. You do not\n need to know the full match name, just a part of it.\n Potential matches will be displayed along with their\n corresponding match codes.\n \n Note that <season year> refers to the FIRST year of\n a season. For example, the 2020-2021 season would be\n written as 2020 and the 2023-2024 season would be 2023.\n \n \n Example:\n \n <command> search 2023 \"Massachusetts State\"\n \n -------------------------------------------------------\n \n Displaying Team Ranking \n \n Command:\n \n <command> rank <season> <match code> <team number>\n \n \n Description:\n \n This will display four tables, one for each OPR ranking\n (overall, auto, tele-op, and endgame OPRs) where every\n team with an OPR ranking higher than the specified team\n are highlighted green, the specified team is bolded and\n is highlighted blue, and the teams below the specified\n team are highlighted red.\n \n The tables will also be saved as tab-seperated-value\n files in the directory the command was executed in.\n \n \n Example:\n \n <command> rank 2023 USMACMP 19460\n \n -------------------------------------------------------\n"

if [ "$#" -lt  2 ]; then
  echo -e "$error_str"
  exit 1
fi

match_type=$(echo "$1" | tr '[:lower:]' '[:upper:]')

season="$2"
season=${season//\"}
third="$2"
fourth="$2"

if [ "$match_type" = "SEARCH" ]; then

  if [ "$#" -lt  3 ]; then
    echo -e "$error_str"
    exit 1
  fi

  third="$3"
  third=${third//\"}

  echo -n "curl 'https://api.ftcscout.org/graphql' -s -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://api.ftcscout.org' --data-binary '{" > rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
  echo -n '"query":"{\n  eventsSearch(season: ' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
  echo -n -e "$season" >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
  echo -n ', searchText: \"' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
  echo -n -e "$third" >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
  echo -n '\") {\n    name,\n    code\n  }\n}"}' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
  echo -n "' --compressed" >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt

  SEARCH_RESULTS=$(cat rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt | bash)

  rm -rf rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt

  formatted_results=$(jq -r '.data.eventsSearch[] | "\(.name)|\(.code)"' <<< "$SEARCH_RESULTS")

  echo -e "\n--- MATCHES ---\n"
  echo "$formatted_results" | column -t -s '|' -N "Match Name,Match Code"
  echo -e ""

  exit 0

else

  if [ "$#" -lt  4 ]; then
    echo -e "$error_str"
    exit 1
  fi

  third="$3"
  third=${third//\"}
  fourth="$4"
  fourth=${fourth//\"}

fi

REQUESTED_TEAM=$(curl 'https://api.ftcscout.org/graphql' -s -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://api.ftcscout.org' --data-binary "{\"query\":\"{\n  teamByNumber(number: $fourth) {\n    events(season: $season) {\n      eventCode\n    }\n  }\n}\"}" --compressed)

REQUESTED_TEAM_RESULT=$(jq --arg third "$third" '.data.teamByNumber.events[] | select(.eventCode == $third)' <<< "$REQUESTED_TEAM")

if [[ -z "$REQUESTED_TEAM_RESULT" ]]; then
    echo -e "The team $third does not seem to be participating in the match $fourth."
    exit 1
fi

TEAM_NAME=$(curl 'https://api.ftcscout.org/graphql' -s -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://api.ftcscout.org' --data-binary "{\"query\":\"{\n  teamByNumber(number: $fourth) {\n    name\n  }\n}\"}" --compressed)

TEAM_NAME=$(echo -e "$TEAM_NAME" | jq -r '.data.teamByNumber.name')

colorize() {

  local GREEN_BG="\033[42m"
  local BLUE_BG="\033[44m"
  local RED_BG="\033[41m"
  local RESET="\033[0m"
  local BOLD="\033[1m"
  local line_count=0
  local hawk_found=false

  while IFS= read -r line; do

    ((line_count++))
    if [[ $line == *"$TEAM_NAME"* ]]; then
      hawk_found=true
    fi

    case $line in
      *"$TEAM_NAME"*)
      echo -e "${BLUE_BG}${BOLD}$line${RESET}"
      ;;
      *)
      if (( line_count <= 1 )); then
        echo -e "${line}${RESET}"
      elif ! $hawk_found && (( line_count >= 2 )); then
        echo -e "${GREEN_BG}${line}${RESET}"
      elif $hawk_found && ! [[ $line == *"$TEAM_NAME"* ]]; then
        echo -e "${RED_BG}${line}${RESET}"
      else
        echo -e "${line}"
      fi
    ;;
    esac

  done

  if (( line_count >   2 )); then
    echo -e "${RESET}"
  fi

}

export -f colorize

save_total() {
  local input=$(cat)
  echo "$input" > total_opr.tsv
  echo "$input"
}
export -f save_total

save_auto() {
  local input=$(cat)
  echo "$input" > auto_opr.tsv
  echo "$input"
}
export -f save_auto

save_teleop() {
  local input=$(cat)
  echo "$input" > teleop_opr.tsv
  echo "$input"
}
export -f save_teleop

save_endgame() {
  local input=$(cat)
  echo "$input" > endgame_opr.tsv
  echo "$input"
}
export -f save_endgame

pad_lines() {

  local input=$(cat)
  local max_length=$(echo "$input" | awk '{ print length, $0 }' | sort -rnk1 | head -n1 | awk '{print $1}')

  echo "$input" | awk -v max_length="$max_length" '{ printf "%-*s\n", max_length, $0 }'

}

export -f pad_lines

insert_hyphens() {

  local input=$(cat)

  IFS=$'\n' read -r -a lines <<< "$input"

  local NEW_INPUT=$(echo "$input" | tail -n +2)
  local LINE_LENGTH=${#lines[0]}

  ((LINE_LENGTH--))
  ((LINE_LENGTH--))
  ((LINE_LENGTH--))
  ((LINE_LENGTH--))

  local HYPHEN_LINE=$(printf '%*s' "$LINE_LENGTH" | tr ' ' '-')

  echo "$HYPHEN_LINE"
  echo -e "$lines"
  echo "$HYPHEN_LINE"
  echo -e "$NEW_INPUT"

}

export -f insert_hyphens

split_and_echo() {

  local line_count=-3

  while IFS= read -r line; do

    ((line_count++))

    if ((line_count < 1)); then
      echo "    $line"
    elif ((line_count < 10)); then
      echo "$line_count   $line"
    elif ((line_count < 100)); then
          echo "$line_count  $line"
    else
      echo "$line_count $line"
    fi

  done

}

export -f split_and_echo

clean_end() {

  head -n -1

  while IFS= read -r line; do
    echo "$line"
  done

  echo -e ""

}

export -f clean_end

echo -n "curl -s 'https://api.ftcscout.org/graphql'" > rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo ' \' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n "         -H 'Accept-Encoding: gzip, deflate, br'" >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo ' \' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n "         -H 'Content-Type: application/json'" >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo ' \' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n "         -H 'Accept: application/json'" >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo ' \' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n "         -H 'Connection: keep-alive'" >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo ' \' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n "         -H 'DNT:   1'" >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo ' \' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n "         -H 'Origin: https://api.ftcscout.org'" >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo ' \' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n "         --data-binary '" >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n '{"query":"{\n  eventByCode(code: \"' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n -e "$third" >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n '\", season:   ' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n -e "$season" >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n ') {\n    teams {\n      team {\n        number,\n        name,\n        quickStats(season:   ' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n -e "$season" >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n ') {\n          tot {\n            value, rank\n          },\n          auto {\n            value, rank\n          },\n          dc {\n            value, rank\n          },\n          eg {\n            value, rank\n          }\n        }\n      }\n    }\n  }\n}"}' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n "' " >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo '\' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
echo -n '--compressed' >> rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt
response=$(bash rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt)
rm -rf rankftc_matchrank_temp_file_hope_no_one_else_uses_this_name_of_file.txt

echo -e "\n"
echo "    RANKINGS BY TOTAL OPR"
echo "$response" | jq -r '.data.eventByCode.teams |= sort_by(.team.quickStats.tot.rank) | .data.eventByCode.teams[] | [.team.name, .team.number, .team.quickStats.tot.rank, (.team.quickStats.tot.value | round), .team.quickStats.auto.rank, (.team.quickStats.auto.value | round), .team.quickStats.dc.rank, (.team.quickStats.dc.value | round), .team.quickStats.eg.rank, (.team.quickStats.eg.value | round)] | @tsv' | column -t -s $'\t' -N "TEAM NAME,TEAM NUMBER,OVERALL RANK,OVERALL OPR,AUTO RANK,AUTO OPR,TELEOP RANK,TELEOP OPR,ENDGAME RANK,ENDGAME OPR" | save_total | pad_lines | colorize | insert_hyphens | split_and_echo | clean_end

echo -e ""
echo "    RANKINGS BY AUTO OPR"
echo "$response" | jq -r '.data.eventByCode.teams |= sort_by(.team.quickStats.auto.rank) | .data.eventByCode.teams[] | [.team.name, .team.number, .team.quickStats.tot.rank, (.team.quickStats.tot.value | round), .team.quickStats.auto.rank, (.team.quickStats.auto.value | round), .team.quickStats.dc.rank, (.team.quickStats.dc.value | round), .team.quickStats.eg.rank, (.team.quickStats.eg.value | round)] | @tsv' | column -t -s $'\t' -N "TEAM NAME,TEAM NUMBER,OVERALL RANK,OVERALL OPR,AUTO RANK,AUTO OPR,TELEOP RANK,TELEOP OPR,ENDGAME RANK,ENDGAME OPR" | save_auto | pad_lines | colorize | insert_hyphens | split_and_echo | clean_end

echo -e ""
echo "    RANKINGS BY TELEOP OPR"
echo "$response" | jq -r '.data.eventByCode.teams |= sort_by(.team.quickStats.dc.rank) | .data.eventByCode.teams[] | [.team.name, .team.number, .team.quickStats.tot.rank, (.team.quickStats.tot.value | round), .team.quickStats.auto.rank, (.team.quickStats.auto.value | round), .team.quickStats.dc.rank, (.team.quickStats.dc.value | round), .team.quickStats.eg.rank, (.team.quickStats.eg.value | round)] | @tsv' | column -t -s $'\t' -N "TEAM NAME,TEAM NUMBER,OVERALL RANK,OVERALL OPR,AUTO RANK,AUTO OPR,TELEOP RANK,TELEOP OPR,ENDGAME RANK,ENDGAME OPR" | save_teleop | pad_lines | colorize | insert_hyphens | split_and_echo | clean_end

echo -e ""
echo "    RANKINGS BY ENDGAME OPR"
echo "$response" | jq -r '.data.eventByCode.teams |= sort_by(.team.quickStats.eg.rank) | .data.eventByCode.teams[] | [.team.name, .team.number, .team.quickStats.tot.rank, (.team.quickStats.tot.value | round), .team.quickStats.auto.rank, (.team.quickStats.auto.value | round), .team.quickStats.dc.rank, (.team.quickStats.dc.value | round), .team.quickStats.eg.rank, (.team.quickStats.eg.value | round)] | @tsv' | column -t -s $'\t' -N "TEAM NAME,TEAM NUMBER,OVERALL RANK,OVERALL OPR,AUTO RANK,AUTO OPR,TELEOP RANK,TELEOP OPR,ENDGAME RANK,ENDGAME OPR" | save_endgame | pad_lines | colorize | insert_hyphens | split_and_echo | clean_end

unset -f colorize
unset -f pad_lines
unset -f insert_hyphens
unset -f split_and_echo
unset -f clean_end
unset -f save_total
unset -f save_auto
unset -f save_teleop
unset -f save_endgame
