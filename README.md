# yt-dlp-docker

yt-dlp をコンテナに閉じ込めて実行し、結果だけを `downloads/` に受け取る。

## 使い方

```sh
docker build -t yt-dlp-sandbox .
./ytdl.sh 'https://www.youtube.com/watch?v=XXXX'
./ytdl.sh -x --audio-format mp3 'https://...'   # 音声だけ
```

## 隔離の範囲

- ホストで見えるのは `downloads/` だけ（他のファイルはマウントしない）
- root ではなく uid 1000 で実行、capability は全削除、ルートFSは読み取り専用
- ネットワークは使える（ダウンロードに必要なため）

## 更新

`Dockerfile` の `YTDLP_VERSION` を書き換えて再ビルドする。コンテナ内の自己更新は `--no-update` で止めている。
