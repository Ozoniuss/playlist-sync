#!/bin/bash

# Replace with your API key and playlist ID
YOUTUBE_API_KEY="${YOUTUBE_API_KEY}"
PLAYLIST_ID="${PLAYLIST_ID}"
NEXT_PAGE_TOKEN=""
RESULTS_FILE="test.json"

# this is needed for later merge
echo '[]' > "$RESULTS_FILE"

declare -i cp=0

while :
do
    cp=$((cp+1))
    echo "fetching page ${cp}..."

    RESPONSE=$(curl -s "https://youtube.googleapis.com/youtube/v3/playlistItems" \
        -G \
        --data-urlencode "part=snippet,contentDetails,id,status" \
        --data-urlencode "playlistId=$PLAYLIST_ID" \
        --data-urlencode "maxResults=50" \
        --data-urlencode "pageToken=$NEXT_PAGE_TOKEN" \
        --data-urlencode "key=$YOUTUBE_API_KEY")

    echo $RESPONSE > "debug${cp}"

    ERROR=$(echo "$RESPONSE" | jq '.error')
    if [[ "$ERROR" != "null" ]]; then
        echo "could not retrieve playlist: code $(echo $ERROR | jq '.code'), message $(echo $ERROR | jq '.message')"
        exit 1
    fi

    # merge existing json array with next batch of items
    jq -s '.[0] + .[1].items' "$RESULTS_FILE" <(echo "$RESPONSE") > tmp.json && mv tmp.json "$RESULTS_FILE"

    # use raw otherwise token would be quoted
    NEXT_PAGE_TOKEN=$(echo "$RESPONSE" | jq -r '.nextPageToken')
    echo "using next page token $NEXT_PAGE_TOKEN"

    if [[ -z "$NEXT_PAGE_TOKEN" || "$NEXT_PAGE_TOKEN" == "null" ]]; then
        break
    fi
done

echo "All playlist videos retrieved. Results saved in '$RESULTS_FILE'."
echo "Got a total of $(jq 'length' test.json) entries"

jq -r '.[].contentDetails.videoId' test.json > ids
echo "Written all ids"

# use -c to output compact json, one json per line
# then go through each item and show its privacy status
jq -c '.[] | select (.status.privacyStatus != "public")' test.json | while read -r item; do
    privacy=$(echo "$item" | jq -r '.status.privacyStatus')
    video_id=$(echo "$item" | jq -r '.contentDetails.videoId')
    title=$(echo "$item" | jq -r '.snippet.title')
    owner=$(echo "$item" | jq -r '.snippet.videoOwnerChannelTitle')

    echo "video with video id '$video_id', title '$title' and owner '$owner' has privacy $privacy"
done