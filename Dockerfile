# yt-dlp をホストから隔離して動かすためのイメージ
FROM denoland/deno:bin-2.5.6 AS deno

FROM python:3.13-slim

ARG YTDLP_VERSION=2026.8.19

RUN apt-get update \
 && apt-get install -y --no-install-recommends ffmpeg ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# YouTube の署名解読に JS ランタイムが要る
COPY --from=deno /deno /usr/local/bin/deno

RUN pip install --no-cache-dir "yt-dlp[default]==${YTDLP_VERSION}"

COPY bin/shrink.sh /usr/local/bin/shrink

# root で動かさない
RUN useradd --create-home --uid 1000 app
USER app
WORKDIR /downloads

# --verbose / --newline: docker logs と Docker Desktop で進捗を 1 行ずつ追えるようにする
ENTRYPOINT ["yt-dlp", "--no-update", "--verbose", "--newline", "-o", "/downloads/%(title)s [%(id)s].%(ext)s"]
