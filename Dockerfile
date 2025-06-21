FROM alpine:3.14

ENV YT_DLP_VERSION=2025.05.22

RUN apk add --no-cache --upgrade ffmpeg bash curl jq 

RUN curl --fail -L "https://github.com/yt-dlp/yt-dlp/releases/download/${YT_DLP_VERSION}/yt-dlp_linux" -o /usr/local/bin/yt-dlp \
    && chmod +x /usr/local/bin/yt-dlp

COPY download.sh /download.sh
COPY get_all_videos_info.sh /get_all_videos_info.sh

CMD [ "/download.sh" ]