#!/bin/bash

# download_playlist downloads a single playlist passed as an argument by
# playlist id
download_playlist() {

    format="%(artist)s - %(title)s [%(id)s].%(ext)s"

    if [[ "$2" == "album" ]]; then
        echo "encountered album, will adjust formatting"
        format="%(playlist_index)02d - %(artist)s - %(title)s [%(id)s].%(ext)s"
    fi

    yt-dlp \
        -v \
        --yes-playlist \
        -o "$format" \
        --windows-filenames \
        --abort-on-unavailable-fragment \
        --buffer-size 1M \
        -x \
        --audio-format mp3 \
        --audio-quality 320K \
        --embed-metadata \
        --download-archive 0_songs.txt "https://www.youtube.com/playlist?list=$1"
}

for dir in ./playlist/*
do

    echo "dir $dir"
    cd "${dir}"

    readarray -t lines < 0_id.txt
    plid="${lines[0]}"
    pltyp="${lines[1]}"

    ../../get_all_videos_info.sh "$plid"
    
    resp=$(curl -s "https://youtube.googleapis.com/youtube/v3/playlists" \
        -G \
        --data-urlencode "part=snippet,contentDetails,status" \
        --data-urlencode "id=$plid" \
        --data-urlencode "key=$YOUTUBE_API_KEY")

    echo "Downloading playlist $(echo "$resp" | jq '.items[0].snippet.localized.title') ($plid)"
    download_playlist $plid $pltyp

    cd ../..
done
