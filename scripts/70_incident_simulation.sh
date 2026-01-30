#!/usr/bin/env bash
set -euo pipefail

# Simulación de incidente (Opción 1): caída de un DataNode
# Por defecto para clustera-dnnm-1, puedes cambiarlo al ejecutar:
#   DN_CONTAINER=clustera-dnnm-2 ./70_incident_simulation.sh

DN_CONTAINER=${DN_CONTAINER:-clustera-dnnm-1}

echo "[incident] Parando DataNode: $DN_CONTAINER"

# Comprobación mínima
if ! docker ps --format '{{.Names}}' | grep -qx "$DN_CONTAINER"; then
  echo "[incident][ERROR] No existe o no está arrancado: $DN_CONTAINER"
  echo "[incident] DataNodes activos ahora:"
  docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "clustera-dnnm|namenode" || true
  exit 1
fi

docker stop "$DN_CONTAINER" >/dev/null

echo "[incident] OK. DataNode parado: $DN_CONTAINER"
echo "[incident] Estado actual (datanodes):"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "clustera-dnnm|namenode" || true

