#!/bin/sh
set -eu

: "${TKS_RUNTIME_BUNDLE_KEY:?TKS_RUNTIME_BUNDLE_KEY is required}"
EXPECTED_SHA="fb4d1fca1a0431351b0b0aab401e891fd5e34a9bf1a2d7c2e7e1cc2685f1f28d"

rm -rf /app/*
cat /opt/tks/runtime.part1.b64 /opt/tks/runtime.part2.b64 /opt/tks/runtime.part3.b64 /opt/tks/runtime.part4.b64 \
  | tr -cd 'A-Za-z0-9+/=' \
  | base64 -d > /tmp/tks-runtime.tar.xz.enc

openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 \
  -in /tmp/tks-runtime.tar.xz.enc \
  -out /tmp/tks-runtime.tar.xz \
  -pass env:TKS_RUNTIME_BUNDLE_KEY

echo "$EXPECTED_SHA  /tmp/tks-runtime.tar.xz" | sha256sum --check --strict
tar -xJf /tmp/tks-runtime.tar.xz -C /app
rm -f /tmp/tks-runtime.tar.xz.enc /tmp/tks-runtime.tar.xz

mkdir -p /data/runs /data/automations /data/state
chown -R node:node /app /data

exec gosu node node /app/app/server.mjs
