#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-/opt/dsaialap/backend/docker-compose.prod.yml}"
API_CONTAINER="${API_CONTAINER:-backend-api-1}"
MEM_LIMIT_MB="${MEM_LIMIT_MB:-450}"
HEALTH_URL="${HEALTH_URL:-https://dsaialap.banglarvoice24news.com/health}"
LOG="/var/log/dsaialap_monitor.log"

ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
log() { echo "[$(ts)] $*" | tee -a "$LOG"; }

restart_api() {
  log "restarting $API_CONTAINER"
  docker compose -f "$COMPOSE_FILE" restart api >/dev/null 2>&1 || docker restart "$API_CONTAINER" >/dev/null 2>&1 || true
}

rss_mb() {
  docker stats --no-stream --format "{{.MemUsage}}" "$API_CONTAINER" 2>/dev/null \
    | awk '{print $1}' \
    | sed 's/MiB//;s/GiB/*1024/;s/MB//;s/GB/*1024/' \
    | awk '{printf "%d", $1}'
}

health_ok() {
  curl -fsS --max-time 5 "$HEALTH_URL" | grep -q '"ok":true'
}

socket_ok() {
  curl -fsS --max-time 5 -o /dev/null -w "%{http_code}" \
    "https://dsaialap.banglarvoice24news.com/socket.io/?EIO=4&transport=polling" \
    | grep -Eq '^(200|400)$'
}

mem=$(rss_mb || echo 0)
if [ "${mem:-0}" -ge "$MEM_LIMIT_MB" ]; then
  log "memory ${mem}MB >= ${MEM_LIMIT_MB}MB"
  restart_api
  exit 0
fi

if ! health_ok; then
  log "health check failed"
  restart_api
  exit 0
fi

if ! socket_ok; then
  log "socket.io probe failed"
  restart_api
  exit 0
fi

log "ok mem=${mem}MB"
