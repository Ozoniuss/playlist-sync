#!/bin/bash

onlyPlaylist=$1
BASE_DIR=$(pwd)

# download_playlist downloads a single playlist passed as an argument by
# playlist id
download_playlist() {

    format="%(artist)s - %(title)s [%(id)s].%(ext)s"

    if [[ "$2" == "album" ]]; then
        echo "encountered album, will adjust formatting"
        format="%(playlist_index)02d - %(artist)s - %(title)s [%(id)s].%(ext)s"
    fi

    yt-dlp \
        --yes-playlist \
        -o "$format" \
        --windows-filenames \
        --buffer-size 1M \
        -x \
        --audio-format mp3 \
        --audio-quality 320K \
        --embed-metadata \
        --download-archive 0_songs.txt "https://www.youtube.com/playlist?list=$1"

    echo "exited with status $?"
}

function passDirectory() {
    local dir=$1

    echo "dir $dir"
    cd "${dir}"

    readarray -t lines < 0_id.txt
    plid="${lines[0]}"
    pltyp="${lines[1]}"

    "$BASE_DIR/get_all_videos_info.sh" "$plid"
    
    resp=$(curl -s "https://youtube.googleapis.com/youtube/v3/playlists" \
        -G \
        --data-urlencode "part=snippet,contentDetails,status" \
        --data-urlencode "id=$plid" \
        --data-urlencode "key=$YOUTUBE_API_KEY")

    echo "Downloading playlist $(echo "$resp" | jq '.items[0].snippet.localized.title') ($plid)"
    download_playlist $plid $pltyp

    cd ../..
}

if [[ -n $onlyPlaylist ]]; then
    echo "only downloading playlist $onlyPlaylist"
    passDirectory "./playlist/$onlyPlaylist"
    exit 0
fi

for dir in ./playlist/*
do
    passDirectory $dir
done


