#!/usr/bin/env bash
set -euo pipefail

# Variante A (base): copiar dentro del mismo clúster a /backup
# Variante B (avanzada): usar DistCp hacia otro clúster (no incluido en este starter)

NN_CONTAINER=${NN_CONTAINER:-namenode}
DT=${DT:-$(date +%F)}

echo "[backup] DT=$DT"
echo "[backup] NameNode container=$NN_CONTAINER"

# 1) Preparar destino en HDFS
docker exec -it "$NN_CONTAINER" bash -lc "
  set -e
  hdfs dfs -mkdir -p /backup/logs/raw/dt=$DT
  hdfs dfs -mkdir -p /backup/iot/raw/dt=$DT
  hdfs dfs -mkdir -p /audit/backup/$DT
"

# 2) Copiar (Variante A) /data -> /backup (solo dt=$DT)
docker exec -it "$NN_CONTAINER" bash -lc "
  set -e

  echo '[backup] Copiando logs...'
  hdfs dfs -cp -f /data/logs/raw/dt=$DT/* /backup/logs/raw/dt=$DT/ 2>&1 | tee /tmp/backup_logs_${DT}.log

  echo '[backup] Copiando iot...'
  hdfs dfs -cp -f /data/iot/raw/dt=$DT/* /backup/iot/raw/dt=$DT/ 2>&1 | tee /tmp/backup_iot_${DT}.log

  echo '[backup] Subiendo logs de copia a HDFS (/audit/backup/$DT)...'
  hdfs dfs -put -f /tmp/backup_logs_${DT}.log /audit/backup/$DT/backup_logs.log
  hdfs dfs -put -f /tmp/backup_iot_${DT}.log /audit/backup/$DT/backup_iot.log
"

# 3) Validar que existen rutas en destino + evidencias
docker exec -it "$NN_CONTAINER" bash -lc "
  set -e

  echo '[backup] Evidencia destino logs:'
  hdfs dfs -ls /backup/logs/raw/dt=$DT
  hdfs dfs -du -h /backup/logs/raw/dt=$DT

  echo '[backup] Evidencia destino iot:'
  hdfs dfs -ls /backup/iot/raw/dt=$DT
  hdfs dfs -du -h /backup/iot/raw/dt=$DT

  echo '[backup] Evidencia logs auditoría backup:'
  hdfs dfs -ls /audit/backup/$DT
"

echo "[backup] OK"

