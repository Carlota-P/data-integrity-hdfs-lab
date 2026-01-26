#!/usr/bin/env bash
set -euo pipefail

# TODO: Ajusta el nombre del contenedor namenode si difiere
NN_CONTAINER=${NN_CONTAINER:-namenode}

# Fecha de trabajo (dt=YYYY-MM-DD). Por defecto hoy.
DT=${DT:-$(date +%F)}

echo "[bootstrap] NN_CONTAINER=$NN_CONTAINER"
echo "[bootstrap] DT=$DT"

# Creamos estructura base en HDFS:
docker exec -it "$NN_CONTAINER" bash -lc "
set -e
echo '[bootstrap] Creando estructura HDFS...'

# Ingesta particionada
hdfs dfs -mkdir -p /data/logs/raw/dt=$DT/
hdfs dfs -mkdir -p /data/iot/raw/dt=$DT/ 

# Auditoría (salidas fsck + inventarios)
hdfs dfs -mkdir -p /audit/fsck/$DT
hdfs dfs -mkdir -p /audit/inventory/$DT

# Destino backup (si lo usáis dentro de HDFS)
hdfs dfs -mkdir -p /backup

  echo '[bootstrap] Estructura creada.'
  echo '[bootstrap] /data:'
  hdfs dfs -ls /data || true
  echo '[bootstrap] /audit:'
  hdfs dfs -ls /audit || true
  echo '[bootstrap] /backup:'
  hdfs dfs -ls /backup || true
"
#   /data/logs/raw/dt=$DT/
#   /data/iot/raw/dt=$DT/
#   /backup/... (si Variante A)
#   /audit/fsck/$DT/
#   /audit/inventory/$DT/
# Pista:
#   docker exec -it $NN_CONTAINER bash -lc "hdfs dfs -mkdir -p ..."

echo "[bootstrap] OK"
