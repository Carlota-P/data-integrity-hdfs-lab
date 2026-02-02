#!/usr/bin/env bash
set -euo pipefail

NN_CONTAINER=${NN_CONTAINER:-namenode}
DT=${DT:-$(date +%F)}
LOCAL_DIR=${LOCAL_DIR:-./data_local/$DT}

LOG_FILE="logs_${DT//-/}.log"
IOT_FILE="iot_${DT//-/}.jsonl"

TMP_DIR="/tmp/ingest/$DT"

echo "[ingest] DT=$DT"
echo "[ingest] Local dir=$LOCAL_DIR"
echo "[ingest] NameNode container=$NN_CONTAINER"

# Comprobación mínima (host)
if [ ! -f "$LOCAL_DIR/$LOG_FILE" ]; then
  echo "[ingest][ERROR] No existe: $LOCAL_DIR/$LOG_FILE"
  exit 1
fi
if [ ! -f "$LOCAL_DIR/$IOT_FILE" ]; then
  echo "[ingest][ERROR] No existe: $LOCAL_DIR/$IOT_FILE"
  exit 1
fi

# 1) Copiar ficheros al contenedor (host -> container)
echo "[ingest] Copiando ficheros al contenedor..."
docker exec -it "$NN_CONTAINER" bash -lc "mkdir -p '$TMP_DIR'"
docker cp "$LOCAL_DIR/$LOG_FILE" "$NN_CONTAINER:$TMP_DIR/$LOG_FILE"
docker cp "$LOCAL_DIR/$IOT_FILE" "$NN_CONTAINER:$TMP_DIR/$IOT_FILE"

# 2) Subir a HDFS en rutas particionadas
docker exec -it "$NN_CONTAINER" bash -lc "
  set -e
  echo '[ingest] Subiendo logs a HDFS...'
  hdfs dfs -put -f $TMP_DIR/$LOG_FILE /data/logs/raw/dt=$DT/

  echo '[ingest] Subiendo iot a HDFS...'
  hdfs dfs -put -f $TMP_DIR/$IOT_FILE /data/iot/raw/dt=$DT/
"

# 3) Evidencias (-ls y -du)
docker exec -it "$NN_CONTAINER" bash -lc "
  echo '[ingest] Evidencia HDFS logs:'
  hdfs dfs -ls /data/logs/raw/dt=$DT
  hdfs dfs -du -h /data/logs/raw/dt=$DT

  echo '[ingest] Evidencia HDFS iot:'
  hdfs dfs -ls /data/iot/raw/dt=$DT
  hdfs dfs -du -h /data/iot/raw/dt=$DT
"

echo "[ingest] OK"

