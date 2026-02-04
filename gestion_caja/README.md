# 💰 Módulo de Gestión de Caja

Sistema completo de análisis de caja diaria para hotel. Procesa reportes CSV del sistema externo y genera múltiples formatos de salida con estadísticas detalladas.

---

## 📋 Contenido

- [Descripción](#descripción)
- [Características](#características)
- [Instalación](#instalación)
- [Uso](#uso)
- [Archivos Generados](#archivos-generados)
- [Integración](#integración)
- [Ejemplos](#ejemplos)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Descripción

`caja.sh` es un script Bash avanzado que procesa el archivo `Reporte_Recibos.csv` generado por el sistema de gestión hotelera y produce:

1. **Análisis por medio de pago** (Efectivo, Débito, Crédito, Transferencia)
2. **Estadísticas por usuario/cajero**
3. **Reporte de texto** para registros internos
4. **Exportación CSV** compatible con LibreOffice Calc/Excel

---

## ✨ Características

### Análisis Completo

- ✅ **Totales por medio de pago**
  - Efectivo (Caja Seccional)
  - Tarjeta de Débito
  - Tarjeta de Crédito
  - Transferencia Bancaria

- ✅ **Estadísticas por cajero/usuario**
  - Número de operaciones realizadas
  - Monto total recaudado
  - Identificación automática de usuarios

- ✅ **Múltiples formatos de salida**
  - Terminal: Resumen visual con colores
  - TXT: Reporte detallado para archivo
  - CSV: Compatible con LibreOffice/Excel

### Portabilidad

- ✅ **Detección automática de sistema**
  - WSL (Windows Subsystem for Linux)
  - Ubuntu nativo
  - Cualquier distribución Linux

- ✅ **Rutas dinámicas**
  - Detecta ~/Downloads o ~/Descargas
  - Maneja rutas WSL (/mnt/c/Users/...)
  - Sin configuración manual necesaria

### Robustez

- ✅ **Validación de entrada**
  - Verifica existencia del CSV fuente
  - Detecta archivos vacíos o corruptos
  - Mensajes de error descriptivos

- ✅ **Cálculos precisos**
  - Usa `bc` para aritmética de punto flotante
  - Maneja formatos monetarios variables
  - Suma verificada contra total general

---

## 📥 Instalación

### Requisitos

- **Sistema Operativo:** Linux, Ubuntu, WSL
- **Shell:** Bash 4.0+
- **Herramientas:** awk, sed, grep, bc

### Instalación Rápida

```bash
# 1. Clonar o descargar el módulo
cd ~/
mkdir -p scripts
cd scripts
# (Copiar archivos aquí)

# 2. Dar permisos de ejecución
chmod +x gestion_caja/caja.sh

# 3. Verificar instalación
./gestion_caja/caja.sh --help
```

### Instalación desde Portable

```bash
# Si tienes el tarball portable
tar -xzf gestion_caja_portable.tar.gz
cd gestion_caja/
./caja.sh
```

---

## 🚀 Uso

### Uso Básico

```bash
cd gestion_caja/
./caja.sh
```

El script busca automáticamente `Reporte_Recibos.csv` en:
- `~/Downloads/Reporte_Recibos.csv`
- `~/Descargas/Reporte_Recibos.csv`
- `/mnt/c/Users/*/Downloads/Reporte_Recibos.csv` (WSL)

### Uso Avanzado

```bash
# Con archivo CSV específico
./caja.sh /ruta/al/Reporte_Recibos.csv

# Ver ayuda
./caja.sh --help

# Modo debug (ver procesamiento)
bash -x caja.sh
```

### Integración con Otros Scripts

```bash
# Flujo completo diario
cd ~/scripts/gestion_csv/
./borrar.sh -f          # Limpiar CSVs antiguos

# Descargar Reporte_Recibos.csv del sistema externo
# (manualmente o via script de descarga)

cd ../gestion_caja/
./caja.sh               # Procesar caja del día

# Resultados disponibles en ~/Downloads/
```

---

## 📄 Archivos Generados

### 1. reporte_caja.txt

**Ubicación:** `~/Downloads/reporte_caja.txt`

**Formato:** Texto plano con resumen completo

**Contenido:**
```
═══════════════════════════════════════════════════
    REPORTE DE CAJA - 04/02/2026
═══════════════════════════════════════════════════

RESUMEN POR MEDIO DE PAGO
─────────────────────────────────────────────────

  💵 Efectivo (Caja Seccional)
     Cantidad de operaciones: 12
     Total: $45,678.90

  💳 Tarjeta de Débito
     Cantidad de operaciones: 8
     Total: $23,456.78

  💳 Tarjeta de Crédito
     Cantidad de operaciones: 15
     Total: $67,890.12

  🏦 Transferencia Bancaria
     Cantidad de operaciones: 5
     Total: $12,345.67

─────────────────────────────────────────────────
  TOTAL GENERAL: $149,371.47
═══════════════════════════════════════════════════

ESTADÍSTICAS POR USUARIO
─────────────────────────────────────────────────

  👤 USUARIO1
     Operaciones: 20
     Total: $78,901.23

  👤 USUARIO2
     Operaciones: 15
     Total: $45,678.90

  👤 USUARIO3
     Operaciones: 5
     Total: $24,791.34

═══════════════════════════════════════════════════
```

### 2. planilla_ingreso.csv

**Ubicación:** `~/Downloads/planilla_ingreso.csv`

**Formato:** CSV compatible con LibreOffice Calc/Excel

**Columnas:**
1. Nro. recibo
2. Fecha recibo
3. Nombre (cliente/huésped)
4. Nota crédito
5. Referencia
6. Lote
7. Cupon
8. Importe
9. Medio de cobranza
10. Usuario alta

**Características:**
- Orden inverso (más recientes primero)
- Compatible con LibreOffice Calc
- Listo para importar y analizar
- Campos vacíos para Lote y Cupón (reservados para uso futuro)

### 3. Salida en Terminal

**Formato:** Texto con colores ANSI

**Incluye:**
- Resumen por medio de pago
- Total general destacado
- Estadísticas por usuario
- Rutas de archivos generados
- Mensajes de éxito/error

---

## 🔗 Integración

### Con Repositorio cajaDiaria

Este módulo está diseñado para ser compatible con el proyecto [cajaDiaria](https://github.com/xpablodaniel/cajaDiaria).

Ver [INTEGRACION_CAJADIARIA.md](INTEGRACION_CAJADIARIA.md) para detalles completos sobre:
- Formatos compatibles
- Flujos de trabajo alternativos (Web, Python CLI)
- Diferencias técnicas
- Casos de uso combinados

### Con Otros Módulos

**gestion_csv:** Comparte `config.sh` para detección de rutas

```bash
# Usar config compartido
source ../gestion_csv/config.sh
```

---

## 💡 Ejemplos

### Ejemplo 1: Procesamiento Diario Estándar

```bash
# Terminal en el hotel
cd ~/scripts/gestion_caja/
./caja.sh

# Salida:
# ✓ CSV fuente encontrado: ~/Downloads/Reporte_Recibos.csv
# ✓ Procesando 45 transacciones...
# ✓ Reporte generado: reporte_caja.txt
# ✓ Planilla generada: planilla_ingreso.csv
# ✓ Total del día: $149,371.47
```

### Ejemplo 2: Análisis de Archivo Específico

```bash
# Procesar CSV de fecha anterior
./caja.sh ~/Archivos/Reporte_Recibos_2026-02-03.csv

# El script genera archivos con fecha específica
```

### Ejemplo 3: Automatización con Cron

```bash
# Editar crontab
crontab -e

# Agregar línea (ejecutar a las 23:00 todos los días)
0 23 * * * /home/usuario/scripts/gestion_caja/caja.sh >> /var/log/caja_diaria.log 2>&1
```

### Ejemplo 4: Flujo Completo con Limpieza

```bash
#!/bin/bash
# Script: proceso_diario.sh

# Limpiar CSVs antiguos (más de 30 días)
cd ~/scripts/gestion_csv/
./borrar.sh -f

# Esperar descarga manual de CSV o usar wget/curl
echo "Esperando Reporte_Recibos.csv..."
while [ ! -f ~/Downloads/Reporte_Recibos.csv ]; do
  sleep 5
done

# Procesar caja
cd ~/scripts/gestion_caja/
./caja.sh

# Notificar
echo "Proceso completado. Archivos en ~/Downloads/"
```

---

## 🔧 Troubleshooting

### Error: "No se encontró el archivo CSV"

**Problema:** El script no encuentra `Reporte_Recibos.csv`

**Soluciones:**
```bash
# 1. Verificar ubicación del archivo
ls -la ~/Downloads/Reporte_Recibos.csv
ls -la ~/Descargas/Reporte_Recibos.csv

# 2. Especificar ruta manualmente
./caja.sh /ruta/completa/al/Reporte_Recibos.csv

# 3. Verificar permisos de lectura
chmod 644 ~/Downloads/Reporte_Recibos.csv
```

### Error: "bc: comando no encontrado"

**Problema:** Falta la herramienta `bc` para cálculos

**Solución:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install bc

# Fedora/RHEL
sudo dnf install bc

# Arch Linux
sudo pacman -S bc
```

### Error: "Formato de CSV no reconocido"

**Problema:** El CSV tiene formato diferente al esperado

**Soluciones:**
```bash
# 1. Ver primeras líneas del CSV
head -5 ~/Downloads/Reporte_Recibos.csv

# 2. Verificar delimitador (debe ser coma)
file ~/Downloads/Reporte_Recibos.csv

# 3. Verificar encoding (debe ser UTF-8)
file -i ~/Downloads/Reporte_Recibos.csv

# 4. Convertir si es necesario
iconv -f ISO-8859-1 -t UTF-8 archivo.csv > archivo_utf8.csv
```

### Totales No Coinciden

**Problema:** El total calculado difiere del esperado

**Diagnóstico:**
```bash
# Ver procesamiento detallado
bash -x caja.sh 2>&1 | grep -A5 "calcular_por_medio"

# Verificar formato de importes en CSV
awk -F',' '{print $6}' ~/Downloads/Reporte_Recibos.csv | head -10

# Contar líneas procesadas
wc -l ~/Downloads/Reporte_Recibos.csv
```

### Problemas de Portabilidad WSL/Ubuntu

**Problema:** Rutas diferentes entre WSL y Ubuntu nativo

**Solución:**
```bash
# Verificar detección de sistema
source config.sh
detectar_so
echo "Sistema: $SISTEMA_OPERATIVO"

# Verificar detección de Downloads
detectar_descargas
echo "Carpeta: $CARPETA_DESCARGAS"

# Si falla, configurar manualmente
export CARPETA_DESCARGAS="/ruta/personalizada/Downloads"
./caja.sh
```

---

## 📊 Especificaciones Técnicas

### Entrada

**Archivo:** `Reporte_Recibos.csv`

**Formato:**
- Delimitador: coma (`,`)
- Encoding: UTF-8
- Primera línea: encabezados

**Columnas esperadas:**
1. Número de recibo
2. Fecha
3. Nombre del cliente
4. Nota de crédito
5. Referencia
6. **Importe** (columna crítica)
7. **Medio de cobranza** (columna crítica)
8. Usuario que registró

### Procesamiento

**Medios de pago reconocidos:**
- `Efectivo`, `Caja`, `Cash` → **Efectivo (Caja Seccional)**
- `Débito`, `Debit`, `Tarjeta Débito` → **Tarjeta de Débito**
- `Crédito`, `Credit`, `Tarjeta Crédito` → **Tarjeta de Crédito**
- `Transferencia`, `Transfer`, `Wire` → **Transferencia Bancaria**

**Algoritmo:**
1. Leer CSV línea por línea con AWK
2. Extraer medio de pago y monto
3. Acumular totales por categoría
4. Acumular totales por usuario
5. Generar archivos de salida

### Salida

**reporte_caja.txt:**
- Formato: Texto plano UTF-8
- Estructura: Encabezado + Resumen + Estadísticas
- Separadores: Líneas de guiones y caracteres box-drawing

**planilla_ingreso.csv:**
- Formato: CSV estándar UTF-8
- Delimitador: coma
- Escape: Comillas dobles para campos con comas
- Orden: Inverso (más reciente primero)

---

## 🔄 Actualizaciones

### Versión 2.1 (Actual)

- ✅ Exportación a CSV para LibreOffice
- ✅ Integración con repositorio cajaDiaria
- ✅ Estadísticas por usuario/cajero
- ✅ Reporte de texto mejorado
- ✅ Módulo independiente

### Versión 1.0 (Original)

- ✅ Cálculo básico de efectivo
- ✅ Total general

---

## 📚 Ver También

- [INTEGRACION_CAJADIARIA.md](INTEGRACION_CAJADIARIA.md) - Integración con proyecto remoto
- [config.sh](config.sh) - Configuración de rutas y sistema
- [../gestion_csv/README.md](../gestion_csv/README.md) - Módulo de gestión de CSVs
- [../apagado_automatico/README.md](../apagado_automatico/README.md) - Módulo de apagado

---

## 👤 Autor

Desarrollado como parte del sistema de automatización hotelera.

---

## 📄 Licencia

Uso interno. No distribuir sin autorización.

---

**Última actualización:** 04 de Febrero de 2026  
**Versión:** 2.1  
**Estado:** ✅ Producción - Completamente funcional
