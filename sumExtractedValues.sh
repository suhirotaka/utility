#!/bin/sh

# 以下の形式の行から数値を抜き出して足し合わせる
# ログイン: 5

if [ -z "$1" ]; then
  echo "No file name specified."
  exit 1
fi
filename=$1
grep "ログイン" $filename | sed -e 's/^.*: \([0-9]\{1,\}\)$/\1/' | awk '{sum+=$1}END{print sum}'
