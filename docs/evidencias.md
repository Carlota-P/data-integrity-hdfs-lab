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
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/7f3816e1-423b-4f23-a2ca-a76cef163ff6" />


## 3) Backup + validación
- Inventario origen vs destino
- Evidencias de consistencia (tamaños/rutas)

## 4) Incidente + recuperación
- Qué hiciste, cuándo y qué efecto tuvo
- Evidencia de detección y de recuperación

## 5) Métricas
- Capturas de docker stats durante replicación/copia
- Tabla de tiempos
