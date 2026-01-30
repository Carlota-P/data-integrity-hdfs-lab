#!/usr/bin/env bash
set -euo pipefail

NN_CONTAINER=${NN_CONTAINER:-namenode}
DT=${DT:-$(date +%F)}

AUDIT_DIR="/audit/inventory/$DT"

SRC_LOGS="/data/logs/raw/dt=$DT"
SRC_IOT="/data/iot/raw/dt=$DT"
DST_LOGS="/backup/logs/raw/dt=$DT"
DST_IOT="/backup/iot/raw/dt=$DT"

echo "[inventory] DT=$DT"

# 1) Crear directorio de auditoría
docker exec -it "$NN_CONTAINER" bash -lc "
  hdfs dfs -mkdir -p $AUDIT_DIR
"

# 2) Inventario ORIGEN (rutas + tamaño)
docker exec -it "$NN_CONTAINER" bash -lc "
  hdfs dfs -ls -R $SRC_LOGS $SRC_IOT \
  | awk '\$1 ~ /^-/ {print \$8 \",\" \$5}' \
  | sed 's#^/data##' \
  | grep -E '\.(log|jsonl)$' \
  | sort > /tmp/inventory_src_${DT}.csv
"

# 3) Inventario DESTINO (rutas + tamaño)
docker exec -it "$NN_CONTAINER" bash -lc "
  hdfs dfs -ls -R $DST_LOGS $DST_IOT \
  | awk '\$1 ~ /^-/ {print \$8 \",\" \$5}' \
  | sed 's#^/backup##' \
  | grep -E '\.(log|jsonl)$' \
  | sort > /tmp/inventory_dst_${DT}.csv
"
# 4) Subir inventarios a HDFS
docker exec -it "$NN_CONTAINER" bash -lc "
  hdfs dfs -put -f /tmp/inventory_src_${DT}.csv $AUDIT_DIR/inventory_src.csv
  hdfs dfs -put -f /tmp/inventory_dst_${DT}.csv $AUDIT_DIR/inventory_dst.csv
"

# 5) Comparación: missing
docker exec -it "$NN_CONTAINER" bash -lc "
  cut -d, -f1 /tmp/inventory_src_${DT}.csv | sort > /tmp/src_paths_${DT}.txt
  cut -d, -f1 /tmp/inventory_dst_${DT}.csv | sort > /tmp/dst_paths_${DT}.txt
  comm -23 /tmp/src_paths_${DT}.txt /tmp/dst_paths_${DT}.txt > /tmp/missing_${DT}.txt
"

# 6) Comparación: size mismatch
docker exec -it "$NN_CONTAINER" bash -lc "
  join -t, /tmp/inventory_src_${DT}.csv /tmp/inventory_dst_${DT}.csv \
  | awk -F, '\$2 != \$3 {print}' > /tmp/size_mismatch_${DT}.csv || true
"

# 7) Resumen
docker exec -it "$NN_CONTAINER" bash -lc "
  MISSING=\$(wc -l < /tmp/missing_${DT}.txt | tr -d ' ')
  MISMATCH=\$(wc -l < /tmp/size_mismatch_${DT}.csv | tr -d ' ')

  echo \"dt,missing,size_mismatch\" > /tmp/summary_${DT}.csv
  echo \"$DT,\$MISSING,\$MISMATCH\" >> /tmp/summary_${DT}.csv

  hdfs dfs -put -f /tmp/missing_${DT}.txt $AUDIT_DIR/missing.txt
  hdfs dfs -put -f /tmp/size_mismatch_${DT}.csv $AUDIT_DIR/size_mismatch.csv
  hdfs dfs -put -f /tmp/summary_${DT}.csv $AUDIT_DIR/summary.csv
"

# 8) FSCK sobre /backup
docker exec -it "$NN_CONTAINER" bash -lc "
  hdfs fsck /backup -files -blocks -locations > /tmp/fsck_backup_${DT}.txt
  hdfs dfs -put -f /tmp/fsck_backup_${DT}.txt $AUDIT_DIR/fsck_backup.txt
"

# 9) Evidencia final
docker exec -it "$NN_CONTAINER" bash -lc "
  hdfs dfs -ls $AUDIT_DIR
  hdfs dfs -cat $AUDIT_DIR/summary.csv
"

echo "[inventory] OK"

