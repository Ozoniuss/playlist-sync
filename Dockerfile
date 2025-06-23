FROM alpine:3.14

RUN apk add --no-cache --upgrade ffmpeg bash curl jq python3 py3-pip

RUN pip install yt-dlp==2025.5.22

COPY download.sh /download.sh
COPY get_all_videos_info.sh /get_all_videos_info.sh

CMD [ "/download.sh" ]