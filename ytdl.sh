#!/usr/bin/env bash
# 使い方: ./ytdl.sh <URL> [yt-dlp のオプション...]
# 保存先: このディレクトリの downloads/
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p downloads

docker run --rm \
  --read-only \
  --tmpfs /tmp:rw,size=512m \
  --tmpfs /home/app:rw,size=64m \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  --memory 2g \
  -v "$PWD/downloads:/downloads:rw" \
  yt-dlp-sandbox "$@"
