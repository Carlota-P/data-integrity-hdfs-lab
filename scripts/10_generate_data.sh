#!/usr/bin/env bash
set -euo pipefail

OUT_DIR=${OUT_DIR:-./data_local}
DT=${DT:-$(date +%F)}
DAY_DIR="$OUT_DIR/$DT"
mkdir -p "$DAY_DIR"

YYYYMMDD="${DT//-/}"
LOG_FILE="$DAY_DIR/logs_${YYYYMMDD}.log"
IOT_FILE="$DAY_DIR/iot_${YYYYMMDD}.jsonl"

LOG_MB=${LOGS_MB:-300}
IOT_MB=${IOT_MB:-300}

echo "[generate] DT=$DT"
echo "[generate] OUT_DIR=$DAY_DIR"
echo "[generate] Target sizes: logs=${LOG_MB}MB, iot=${IOT_MB}MB"

get_mb() {
  local bytes
  bytes=$(stat -c%s "$1" 2>/dev/null || echo 0)
  echo $((bytes / 1024 / 1024))
}

# ---------------- LOGS ----------------
: > "$LOG_FILE"
echo "[generate] Generando logs en $LOG_FILE ..."

log_mb="$(get_mb "$LOG_FILE")"
while [ "$log_mb" -lt "$LOG_MB" ]; do
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"   # 1 timestamp por BLOQUE

  {
    i=0
    while [ "$i" -lt 200000 ]; do
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

      printf "%s userId=%d action=%s status=%s\n" "$ts" "$userId" "$action" "$status"
      i=$((i+1))
    done
  } >> "$LOG_FILE"

  log_mb="$(get_mb "$LOG_FILE")"
  echo "[generate] logs size: ${log_mb}MB / ${LOG_MB}MB"
done

# ---------------- IOT ----------------
: > "$IOT_FILE"
echo "[generate] Generando iot en $IOT_FILE ..."

iot_mb="$(get_mb "$IOT_FILE")"
while [ "$iot_mb" -lt "$IOT_MB" ]; do
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"  # 1 timestamp por BLOQUE

  {
    i=0
    while [ "$i" -lt 200000 ]; do
      device_num=$((RANDOM % 200000 + 1))

      case $((RANDOM % 5)) in
        0) metric="temp";    value_int=$((1000 + (RANDOM % 2501))) ;;   # 10.00..35.00
        1) metric="hum";     value_int=$((2000 + (RANDOM % 7001))) ;;   # 20.00..90.00
        2) metric="press";   value_int=$((95000 + (RANDOM % 10001))) ;; # 950.00..1050.00
        3) metric="vib";     value_int=$((RANDOM % 2001)) ;;            # 0.000..2.000 (milésimas)
        *) metric="battery"; value_int=$((500 + (RANDOM % 9501))) ;;    # 5.00..100.00
      esac

      if [ "$metric" = "vib" ]; then
        value="$(printf "%d.%03d" $((value_int/1000)) $((value_int%1000)))"
      else
        value="$(printf "%d.%02d" $((value_int/100)) $((value_int%100)))"
      fi

      printf '{"deviceId":"dev-%06d","ts":"%s","metric":"%s","value":%s}\n' \
        "$device_num" "$ts" "$metric" "$value"

      i=$((i+1))
    done
  } >> "$IOT_FILE"

  iot_mb="$(get_mb "$IOT_FILE")"
  echo "[generate] iot size: ${iot_mb}MB / ${IOT_MB}MB"
done

echo "[generate] OK"
ls -lh "$LOG_FILE" "$IOT_FILE"

