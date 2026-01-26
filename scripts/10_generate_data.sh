#!/usr/bin/env bash
set -euo pipefail

# TODO: Genera dataset realista (logs e IoT) con tamaño suficiente.
# Recomendación: generar 512MB-2GB totales para observar bloques.

OUT_DIR=${OUT_DIR:-./data_local}
DT=${DT:-$(date +%F)}
DAY_DIR="$OUT_DIR/$DT"
mkdir -p "$DAY_DIR"

YYYYMMDD="${DT//-/}"
LOG_FILE="$DAY_DIR/logs_${YYYYMMDD}.log"
IOT_FILE="$DAY_DIR/iot_${YYYYMMDD}.jsonl"

# Tamaños objetivo aproximados 
LOG_MB=${LOG_MB:-350}   
IOT_MB=${IOT_MB:-350}   

echo "[generate] DT=$DT"
echo "[generate] OUT_DIR=$DAY_DIR"
echo "[generate] Target sizes: logs=${LOG_MB}MB, iot=${IOT_MB}MB"

# --- Generación de LOGS (texto) ---
: > "$LOG_FILE"

# Formato:
# 2026-01-26T12:34:56Z userId=12345 action=LOGIN status=200
generate_log_line() {
  local ts userId action status
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  userId=$((RANDOM % 50000 + 1))

  case $((RANDOM % 5)) in
    0) action="LOGIN" ;;
    1) action="LOGOUT" ;;
    2) action="READ" ;;
    3) action="UPDATE" ;;
    *) action="DELETE" ;;
  esac

  case $((RANDOM % 10)) in
    0) status="500" ;;
    1) status="404" ;;
    *) status="200" ;;
  esac

  printf "%s userId=%d action=%s status=%s\n" \
    "$ts" "$userId" "$action" "$status"
}

echo "[generate] Generando logs en $LOG_FILE ..."
while [ "$(du -m "$LOG_FILE" | awk '{print $1}')" -lt "$LOG_MB" ]; do
  for _ in $(seq 1 20000); do
    generate_log_line >> "$LOG_FILE"
  done
done


# --- Generación de IoT (JSON Lines) ---
: > "$IOT_FILE"

# Formato JSONL (una línea = un JSON):
# {"deviceId":"dev-000123","ts":"2026-01-26T12:34:56Z","metric":"temp","value":23.41}
generate_iot_line() {
  local ts deviceId metric value
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  deviceId="dev-$(printf "%06d" $((RANDOM % 200000 + 1)))"

  case $((RANDOM % 5)) in
    0) metric="temp";    value="$(awk -v r=$RANDOM 'BEGIN{srand(r); printf "%.2f", 10 + rand()*25}')" ;;
    1) metric="hum";     value="$(awk -v r=$RANDOM 'BEGIN{srand(r); printf "%.2f", 20 + rand()*70}')" ;;
    2) metric="press";   value="$(awk -v r=$RANDOM 'BEGIN{srand(r); printf "%.2f", 950 + rand()*100}')" ;;
    3) metric="vib";     value="$(awk -v r=$RANDOM 'BEGIN{srand(r); printf "%.3f", rand()*2}')" ;;
    *) metric="battery"; value="$(awk -v r=$RANDOM 'BEGIN{srand(r); printf "%.2f", 5 + rand()*95}')" ;;
  esac

  printf '{"deviceId":"%s","ts":"%s","metric":"%s","value":%s}\n' \
    "$deviceId" "$ts" "$metric" "$value"
}

echo "[generate] Generando iot en $IOT_FILE ..."
while [ "$(du -m "$IOT_FILE" | awk '{print $1}')" -lt "$IOT_MB" ]; do
  for _ in $(seq 1 20000); do
    generate_iot_line >> "$IOT_FILE"
  done
done

# Pistas:
# - logs: líneas de texto con timestamp, userId, action, status
# - iot: JSON Lines con deviceId, ts, metric, value
# - Para crecer tamaño: bucles, gzip opcional, o dd + plantillas

echo "[generate] OK"
ls -lh "$LOG_FILE" "$IOT_FILE"
