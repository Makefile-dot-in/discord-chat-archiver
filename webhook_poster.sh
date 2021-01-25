#!/bin/bash
channel="" # channel id
guild="" # guild id
webhook="" # webhook endpoint
pfp() {
	echo "https://cdn.discordapp.com/avatars/$1/$2.png"
}
run_jq() {
	echo "$2" | jq -r "$1"
}
parse_messages() {
declare -A messages
while read -r message; do
	referenced_message="$(run_jq '.message_reference.message_id' "$message")"
	echo "$referenced_message"
	msg_id="$(run_jq '.id' "$message")"
	payload_json="$(echo "$message" | jq -c -f webhook_template.jq --arg ref_msg "${messages[$referenced_message]}" --arg channel "$channel" --arg guild "$guild")"
	file_data=""
	for file in ${msg_id}_*; do
		file_data="$file_data -F file='@$file'"
	done
	response="$(echo $payload_json | curl -X POST $file_data -F payload_json='<-' "$webhook?wait=true")"
	echo "$response"
	retry_after="$(run_jq ".retry_after" "$response")"
	sleep $retry_after 2>/dev/null&& echo "Cooling down." || echo "Not being rate limited. Nyooom!"
	new_id="$(run_jq '.id' "$response")"
	messages["$msg_id"]="$new_id"
	echo "$msg_id"
	echo "$new_id"
	echo "$messages"
	sleep 2 # discord does not like when you use a ton of messages quickly
done

}
jq -c ".[]" "$1" | parse_messages
