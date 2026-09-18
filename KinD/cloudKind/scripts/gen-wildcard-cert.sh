#!/usr/bin/env bash
set -euo pipefail

DOMAIN="0a0f122c.nip.io"
OUT_DIR="./certs"
mkdir -p "$OUT_DIR"

openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout "${OUT_DIR}/wildcard.key" \
  -out "${OUT_DIR}/wildcard.crt" \
  -days 365 \
  -subj "/CN=*.${DOMAIN}/O=homelab-dev" \
  -addext "subjectAltName=DNS:*.${DOMAIN},DNS:${DOMAIN}"

kubectl create namespace network --dry-run=client -o yaml | kubectl apply -f -

kubectl -n network create secret tls wildcard-tls \
  --cert="${OUT_DIR}/wildcard.crt" \
  --key="${OUT_DIR}/wildcard.key" \
  --dry-run=client -o yaml | kubectl apply -f -
