# yt-dlp-docker

yt-dlp をコンテナに閉じ込めて実行し、結果だけを `downloads/` に受け取る。

## 使い方

```sh
docker compose build
./ytdl.sh 'https://www.youtube.com/watch?v=XXXX'          # ダウンロード
./ytdl.sh -t mp4 'https://...'                            # mp4 で保存
./ytdl.sh -x --audio-format mp3 'https://...'             # 音声だけ
./shrink.sh '<downloads/ 内のファイル名>' 1900 720         # 1900MB・720p に再エンコード
```

## ログと実行履歴

- 実行ごとに `ytdl-YYYYMMDD-HHMMSS` / `shrink-...` という名前のコンテナが残る
- Docker Desktop の Containers 画面で `yt-dlp-docker` グループに表示され、状態とログを確認できる
- CLI では `docker compose ps -a` / `docker logs -t <名前>`
- yt-dlp は `--verbose --newline`、shrink は段階ログと 30 秒ごとの ffmpeg 進捗を出す
- ログは 1 コンテナあたり 50MB × 3 世代まで。不要な履歴は `docker compose rm` か Desktop から消す

## 隔離の範囲

- ホストで見えるのは `downloads/` だけ（他のファイルはマウントしない）
- root ではなく uid 1000 で実行、capability は全削除、ルートFSは読み取り専用
- ytdl はネットワークを使う。shrink はネットワークなし

## 更新

`Dockerfile` の `YTDLP_VERSION` を書き換えて `docker compose build`。コンテナ内の自己更新は `--no-update` で止めている。
