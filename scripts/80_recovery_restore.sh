#!/usr/bin/env bash
set -euo pipefail

NN_CONTAINER=${NN_CONTAINER:-namenode}
DT=${DT:-$(date +%F)}

# Debe coincidir con el que paraste en el 70
DN_CONTAINER=${DN_CONTAINER:-clustera-dnnm-1}

# Cuánto esperar (en segundos) a que el NameNode lo reconozca
WAIT_SECS=${WAIT_SECS:-60}

echo "[recovery] DT=$DT"
echo "[recovery] Starting DataNode: $DN_CONTAINER"
echo "[recovery] NameNode: $NN_CONTAINER"

# 1) Arrancar el DataNode
docker start "$DN_CONTAINER" >/dev/null
echo "[recovery] DataNode arrancado: $DN_CONTAINER"

# 2) Esperar un poco para heartbeats
echo "[recovery] Esperando $WAIT_SECS s para que HDFS lo detecte..."
sleep "$WAIT_SECS"

# 3) Evidencia: datanodes vivos según HDFS
echo "[recovery] Evidencia: Live datanodes"
docker exec -it "$NN_CONTAINER" bash -lc "hdfs dfsadmin -report | grep 'Live datanodes'"

# 4) Evidencia: fsck /data (resumen)
echo "[recovery] Evidencia: fsck /data (resumen)"
docker exec -it "$NN_CONTAINER" bash -lc "hdfs fsck /data | grep -E 'HEALTHY|Under-replicated blocks|Missing blocks|Corrupt blocks|Number of data-nodes'"

echo "[recovery] OK"

