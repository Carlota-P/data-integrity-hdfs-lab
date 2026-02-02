# Evidencias (plantilla)

Incluye aquí (capturas o logs) con fecha:

## 1) NameNode UI (9870)
- Captura con DataNodes vivos y capacidad
- **Fecha y hora:** 2026-01-19, 19.36
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/eea1c2a5-c633-4eb0-9535-e600b68cc700" />
Se muestra la interfaz web del Namenode, podemos comprobar que en la sección de *In operation* se observan los **4 DataNodes activos**, y la capacidad disponible.
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/921b0efe-1af1-4e71-ae3b-0e8e7c1a5c13" />
Captura adicional del apartado *Overview* del NameNode.

## 2) Auditoría fsck
- Enlace/captura de salida (bloques/locations)
- Resumen (CORRUPT/MISSING/UNDER_REPLICATED)

Fsck de los logs del 2 febrero del 2026
- Comando: DT=2026-01-29 ./30_fsck_audit.sh
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/1b77c4f8-4dcb-4029-9855-81604a530b8b" />

## 3) Backup + validación
- Inventario origen vs destino
- Evidencias de consistencia (tamaños/rutas)
Salida del comando:
DT=2026-01-29 ./40_backup_copy.sh

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/1036f3c7-6405-4e77-85b7-538b14bb2694" />

Salida de:
- DT=2026-01-29 ./50_inventory_compare.sh
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/3c808a77-df53-4ec4-815c-5d38d8ded7ea" />


## 4) Incidente + recuperación
- Qué hiciste, cuándo y qué efecto tuvo
- Evidencia de detección y de recuperación

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/ff24987d-8653-420f-a574-6d16500ced03" />

## 5) Métricas
- Capturas de docker stats durante replicación/copia
- Tabla de tiempos

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/fdaa30ae-40f5-458b-9253-98413a456470" />

