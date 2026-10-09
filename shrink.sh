#!/usr/bin/env bash
# 使い方: ./shrink.sh <downloads/ 内のファイル名> [目標MB=1900] [高さ=720]
set -euo pipefail
cd "$(dirname "$0")"
docker compose run --name "shrink-$(date +%Y%m%d-%H%M%S)" --label "shrink.input=$1" shrink "$@"
