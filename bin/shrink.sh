#!/usr/bin/env bash
# 使い方: shrink <downloads/ 内のファイル名> [目標MB=1900] [高さ=720]
# 2-pass H.264 で目標サイズに収めた "<元名> <高さ>p.mp4" を downloads/ に作る
set -euo pipefail

log() { echo "[shrink $(date -u +%H:%M:%SZ)] $*"; }

IN="/downloads/$1"
TARGET_MB="${2:-1900}"
HEIGHT="${3:-720}"
OUT="/downloads/${1%.*} ${HEIGHT}p.mp4"
PASSLOG="/downloads/.x264pass-$$"
trap 'rm -f "$PASSLOG"*' EXIT

[[ -f "$IN" ]] || { log "入力が見つからない: $IN"; exit 1; }

DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$IN")
AUDIO_K=$(ffprobe -v error -select_streams a:0 -show_entries stream=bit_rate -of csv=p=0 "$IN" | awk '{printf "%d", $1/1000}')
# webm などストリームにビットレートが書かれていない場合は見積もりで代用する
if (( AUDIO_K == 0 )); then
  AUDIO_K=128
  log "音声ビットレートが取れないため ${AUDIO_K}k と見積もる"
fi
VIDEO_K=$(awk -v mb="$TARGET_MB" -v d="$DUR" -v a="$AUDIO_K" 'BEGIN{printf "%d", mb*8000/d - a}')

log "input=$IN"
log "duration=${DUR}s audio=${AUDIO_K}k -> video=${VIDEO_K}k target=${TARGET_MB}MB height=${HEIGHT}"
(( VIDEO_K > 100 )) || { log "目標サイズが小さすぎる (video=${VIDEO_K}k)"; exit 1; }

COMMON=(-hide_banner -loglevel info -nostats -progress pipe:1 -stats_period 30 -y -i "$IN"
        -vf "scale=-2:${HEIGHT}" -c:v libx264 -preset medium -b:v "${VIDEO_K}k" -passlogfile "$PASSLOG")

log "pass 1/2 start"
ffmpeg "${COMMON[@]}" -pass 1 -an -f mp4 /dev/null
log "pass 2/2 start"
ffmpeg "${COMMON[@]}" -pass 2 -c:a copy -movflags +faststart "$OUT"

log "done: $OUT ($(du -h "$OUT" | cut -f1))"
