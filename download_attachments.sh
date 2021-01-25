#!/bin/bash
jq -r '.[] | [.id, ([(.attachments[] | .url)] | join(" "))] | select(.[1] != "") | join(" ")' "$1" | while read -r id urls; do
	for url in $urls; do
		filename="${id}_${url##*/}"
		curl "$url" -o "$filename"
	done
done
	

