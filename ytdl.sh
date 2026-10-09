#!/usr/bin/env bash
# 使い方: ./ytdl.sh <URL> [yt-dlp のオプション...]
# 保存先: このディレクトリの downloads/
# 実行後もコンテナを残すので、Docker Desktop の yt-dlp-docker からログを見られる
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p downloads
docker compose run --name "ytdl-$(date +%Y%m%d-%H%M%S)" --label "ytdl.args=$*" ytdl "$@"
