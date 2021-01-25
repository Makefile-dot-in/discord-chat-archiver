#!/bin/bash
(
before=0 # set this to the final message
limit=100
total_count=1028 # set this to the total message count (by searching something that is true for every message. `after: 1970-01-01` works for this on desktop for a group dm; for a channel, use `in: [channel]`
retrieve_messages() {
	# your curl command here
}
for _ in $(seq 0 $limit $total_count); do
	retrieve_messages | tee /tmp/last_messages.json | tee /dev/stderr
	before=$(jq -s ".[-1] | .[-1].id | tonumber" /tmp/last_messages.json)
done
) | jq -s 'add | reverse' > archive.json
