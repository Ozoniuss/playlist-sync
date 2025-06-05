#!/bin/sh

# download_playlist downloads a single playlist passed as an argument by
# playlist id
download_playlist() {
    yt-dlp \
        -v \
        --yes-playlist \
        -o "%(artist)s - %(title)s.%(ext)s" \
        --windows-filenames \
        --abort-on-unavailable-fragment \
        --buffer-size 1M \
        -x \
        --audio-format mp3 \
        --audio-quality 320K \
        --embed-metadata \
        --download-archive _songs.txt "https://www.youtube.com/watch?v=E-h1VCNou6k&list=$1"
}

for dir in ./playlists/*
do
    cd "${dir}"
    plid=$(cat _id.txt)
    echo $plid

    resp=$(curl -s "https://youtube.googleapis.com/youtube/v3/playlists" \
        -G \
        --data-urlencode "part=snippet,contentDetails,status" \
        --data-urlencode "id=$plid" \
        --data-urlencode "key=$YOUTUBE_API_KEY")
    
    echo "Downloading playlist $(echo "$resp" | jq '.items[0].snippet.localized.title') ($plid)"
    download_playlist $plid

    cd ../..
done
