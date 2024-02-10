
Save
New
Duplicate & Edit
Just Text
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
if [[ $line == *"Hawk Robotics --The Ryken Force"* ]]; then
hawk_found=true
fi
case $line in
*"Hawk Robotics --The Ryken Force"*)
echo -e "${BLUE_BG}${BOLD}$line${RESET}"
;;
*)
if (( line_count <=   1 )); then
echo -e "${line}${RESET}"
elif ! $hawk_found && (( line_count >=   2 )); then
echo -e "${GREEN_BG}${line}${RESET}"
elif $hawk_found && ! [[ $line == *"Hawk Robotics --The Ryken Force"* ]]; then
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
echo "   $line"
elif ((line_count < 10)); then
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
response=$(curl -s 'https://api.ftcscout.org/graphql' \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
-H 'Connection: keep-alive' \
-H 'DNT:   1' \
-H 'Origin: https://api.ftcscout.org' \
--data-binary '{"query":"{\n  eventByCode(code: \"USMACMP\", season:   2023) {\n    teams {\n      team {\n        number,\n        name,\n        quickStats(season:   2023) {\n          tot {\n            value, rank\n          },\n          auto {\n            value, rank\n          },\n          dc {\n            value, rank\n          },\n          eg {\n            value, rank\n          }\n        }\n      }\n    }\n  }\n}"}' \
--compressed)
echo -e "\n"
echo "   RANKINGS BY TOTAL OPR"
echo "$response" | jq -r '.data.eventByCode.teams |= sort_by(.team.quickStats.tot.rank) | .data.eventByCode.teams[] | [.team.name, .team.number, .team.quickStats.tot.rank, (.team.quickStats.tot.value | round), .team.quickStats.auto.rank, (.team.quickStats.auto.value | round), .team.quickStats.dc.rank, (.team.quickStats.dc.value | round), .team.quickStats.eg.rank, (.team.quickStats.eg.value | round)] | @tsv' | column -t -s $'\t' -N "TEAM NAME,TEAM NUMBER,OVERALL RANK,OVERALL OPR,AUTO RANK,AUTO OPR,TELEOP RANK,TELEOP OPR,ENDGAME RANK,ENDGAME OPR" | pad_lines | colorize | insert_hyphens | split_and_echo | clean_end
echo -e ""
echo "   RANKINGS BY AUTO OPR"
echo "$response" | jq -r '.data.eventByCode.teams |= sort_by(.team.quickStats.auto.rank) | .data.eventByCode.teams[] | [.team.name, .team.number, .team.quickStats.tot.rank, (.team.quickStats.tot.value | round), .team.quickStats.auto.rank, (.team.quickStats.auto.value | round), .team.quickStats.dc.rank, (.team.quickStats.dc.value | round), .team.quickStats.eg.rank, (.team.quickStats.eg.value | round)] | @tsv' | column -t -s $'\t' -N "TEAM NAME,TEAM NUMBER,OVERALL RANK,OVERALL OPR,AUTO RANK,AUTO OPR,TELEOP RANK,TELEOP OPR,ENDGAME RANK,ENDGAME OPR" | pad_lines | colorize | insert_hyphens | split_and_echo | clean_end
echo -e ""
echo "   RANKINGS BY TELEOP OPR"
echo "$response" | jq -r '.data.eventByCode.teams |= sort_by(.team.quickStats.dc.rank) | .data.eventByCode.teams[] | [.team.name, .team.number, .team.quickStats.tot.rank, (.team.quickStats.tot.value | round), .team.quickStats.auto.rank, (.team.quickStats.auto.value | round), .team.quickStats.dc.rank, (.team.quickStats.dc.value | round), .team.quickStats.eg.rank, (.team.quickStats.eg.value | round)] | @tsv' | column -t -s $'\t' -N "TEAM NAME,TEAM NUMBER,OVERALL RANK,OVERALL OPR,AUTO RANK,AUTO OPR,TELEOP RANK,TELEOP OPR,ENDGAME RANK,ENDGAME OPR" | pad_lines | colorize | insert_hyphens | split_and_echo | clean_end
echo -e ""
echo "   RANKINGS BY ENDGAME OPR"
echo "$response" | jq -r '.data.eventByCode.teams |= sort_by(.team.quickStats.eg.rank) | .data.eventByCode.teams[] | [.team.name, .team.number, .team.quickStats.tot.rank, (.team.quickStats.tot.value | round), .team.quickStats.auto.rank, (.team.quickStats.auto.value | round), .team.quickStats.dc.rank, (.team.quickStats.dc.value | round), .team.quickStats.eg.rank, (.team.quickStats.eg.value | round)] | @tsv' | column -t -s $'\t' -N "TEAM NAME,TEAM NUMBER,OVERALL RANK,OVERALL OPR,AUTO RANK,AUTO OPR,TELEOP RANK,TELEOP OPR,ENDGAME RANK,ENDGAME OPR" | pad_lines | colorize | insert_hyphens | split_and_echo | clean_end
unset -f colorize
unset -f pad_lines
unset -f insert_hyphens
unset -f split_and_echo
unset -f clean_end