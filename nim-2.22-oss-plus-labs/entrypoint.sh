#!/bin/sh
set -e

: "${NIM_ENDPOINT:?NIM_ENDPOINT env var is required}"

if ! command -v nginx-agent >/dev/null 2>&1; then
  echo "[INFO] Installing NIM-compatible nginx-agent"

  curl -k "https://${NIM_ENDPOINT}/install/nginx-agent" \
       -o /tmp/install-nginx-agent.sh

  chmod +x /tmp/install-nginx-agent.sh
  sh /tmp/install-nginx-agent.sh
fi

echo "[INFO] Starting NGINX OSS..."
nginx

sleep 2

echo "[INFO] Starting NGINX Agent..."
exec nginx-agent