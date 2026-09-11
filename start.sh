#!/bin/sh
set -eu

: "${TKS_RUNTIME_BUNDLE_KEY:?TKS_RUNTIME_BUNDLE_KEY is required}"
: "${TKS_RUNTIME_PART_01:?TKS_RUNTIME_PART_01 is required}"
: "${TKS_RUNTIME_PART_02:?TKS_RUNTIME_PART_02 is required}"
: "${TKS_RUNTIME_PART_03:?TKS_RUNTIME_PART_03 is required}"
: "${TKS_RUNTIME_PART_04:?TKS_RUNTIME_PART_04 is required}"
: "${TKS_RUNTIME_PART_05:?TKS_RUNTIME_PART_05 is required}"
: "${TKS_RUNTIME_PART_06:?TKS_RUNTIME_PART_06 is required}"
: "${TKS_RUNTIME_PART_07:?TKS_RUNTIME_PART_07 is required}"
: "${TKS_RUNTIME_PART_08:?TKS_RUNTIME_PART_08 is required}"
: "${TKS_RUNTIME_PART_09:?TKS_RUNTIME_PART_09 is required}"
: "${TKS_RUNTIME_PART_10:?TKS_RUNTIME_PART_10 is required}"

EXPECTED_SHA="2cabb1ea98ff4345541eec87c87ca854293f04eb3a1909f42528770fa764fa65"

rm -rf /app/*
{
  printf '%s' "$TKS_RUNTIME_PART_01"
  printf '%s' "$TKS_RUNTIME_PART_02"
  printf '%s' "$TKS_RUNTIME_PART_03"
  printf '%s' "$TKS_RUNTIME_PART_04"
  printf '%s' "$TKS_RUNTIME_PART_05"
  printf '%s' "$TKS_RUNTIME_PART_06"
  printf '%s' "$TKS_RUNTIME_PART_07"
  printf '%s' "$TKS_RUNTIME_PART_08"
  printf '%s' "$TKS_RUNTIME_PART_09"
  printf '%s' "$TKS_RUNTIME_PART_10"
} | base64 -d > /tmp/tks-runtime.tar.xz.enc

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
