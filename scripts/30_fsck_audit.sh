#!/usr/bin/env bash
set -euo pipefail

NN_CONTAINER=${NN_CONTAINER:-namenode}
DT=${DT:-$(date +%F)}

echo "[fsck] DT=$DT"
echo "[fsck] NameNode container=$NN_CONTAINER"

# Asegurar carpeta de auditoría en HDFS
docker exec -it "$NN_CONTAINER" bash -lc "
  set -e
  hdfs dfs -mkdir -p /audit/fsck/$DT
"

# --- FSCK sobre /data ---
docker exec -it "$NN_CONTAINER" bash -lc "
  set -e
  echo '[fsck] Ejecutando hdfs fsck /data ...'
  hdfs fsck /data -files -blocks -locations | tee /tmp/fsck_data_${DT}.txt

  echo '[fsck] Subiendo salida fsck_data a HDFS...'
  hdfs dfs -put -f /tmp/fsck_data_${DT}.txt /audit/fsck/$DT/fsck_data.txt
"

# --- FSCK sobre /backup (si existe) ---
docker exec -it "$NN_CONTAINER" bash -lc "
  set -e
  if hdfs dfs -test -d /backup; then
    echo '[fsck] Ejecutando hdfs fsck /backup ...'
    hdfs fsck /backup -files -blocks -locations | tee /tmp/fsck_backup_${DT}.txt

    echo '[fsck] Subiendo salida fsck_backup a HDFS...'
    hdfs dfs -put -f /tmp/fsck_backup_${DT}.txt /audit/fsck/$DT/fsck_backup.txt
  else
    echo '[fsck] /backup no existe, se omite.'
  fi
"

# --- Resumen ---
# Nota: Contamos ocurrencias de palabras clave en la salida fsck /data.
# (Para la práctica suele ser suficiente como "conteo de incidencias".)
docker exec -it "$NN_CONTAINER" bash -lc "
  set -e
  echo '[fsck] Generando resumen...'

  CORRUPT=\$(grep -o 'CORRUPT' /tmp/fsck_data_${DT}.txt | wc -l | tr -d ' ')
  MISSING=\$(grep -o 'MISSING' /tmp/fsck_data_${DT}.txt | wc -l | tr -d ' ')
  UNDER_REPL=\$(grep -i -o 'Under replicated' /tmp/fsck_data_${DT}.txt | wc -l | tr -d ' ')

  {
    echo 'dt,corrupt,missing,under_replicated'
    echo '${DT},'\"\$CORRUPT\"','\"\$MISSING\"','\"\$UNDER_REPL\"
  } > /tmp/fsck_summary_${DT}.csv

  hdfs dfs -put -f /tmp/fsck_summary_${DT}.csv /audit/fsck/$DT/fsck_summary.csv

  echo '[fsck] Resumen (local container):'
  cat /tmp/fsck_summary_${DT}.csv
"

# Evidencias en HDFS
docker exec -it "$NN_CONTAINER" bash -lc "
  echo '[fsck] Evidencia HDFS /audit/fsck/$DT:'
  hdfs dfs -ls /audit/fsck/$DT
  hdfs dfs -cat /audit/fsck/$DT/fsck_summary.csv
"

echo "[fsck] OK"

