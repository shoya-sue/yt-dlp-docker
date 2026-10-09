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

# root で動かさない
RUN useradd --create-home --uid 1000 app
USER app
WORKDIR /downloads

ENTRYPOINT ["yt-dlp", "--no-update", "-o", "/downloads/%(title)s [%(id)s].%(ext)s"]
