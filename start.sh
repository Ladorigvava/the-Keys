#!/bin/sh
set -eu

: "${TKS_RUNTIME_BUNDLE_KEY:?TKS_RUNTIME_BUNDLE_KEY is required}"
EXPECTED_SHA="14b6215a1a6735872bc4b5834938bbdaf5f3f8c9b94ee97b824d743a1490c4a2"

rm -rf /app/*
openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 \
  -in /opt/tks/runtime.zip.enc \
  -out /tmp/tks-runtime.zip \
  -pass env:TKS_RUNTIME_BUNDLE_KEY

echo "$EXPECTED_SHA  /tmp/tks-runtime.zip" | sha256sum --check --strict
unzip -q /tmp/tks-runtime.zip -d /app
rm -f /tmp/tks-runtime.zip

mkdir -p /data/runs /data/automations /data/state
chown -R node:node /app /data

exec gosu node node /app/app/server.mjs
