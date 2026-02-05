# 📋 Gestión de Reservas

Módulo para procesar archivos CSV del gestor hotelero y extraer columnas específicas para exportar a LibreOffice Calc.

## 📝 Descripción

Este módulo moderniza y modulariza la gestión de reservas hoteleras, permitiendo:
- Procesar archivos CSV con más de 25 columnas
- Extraer solo las columnas necesarias en orden específico
- Aplicar filtros por estado o fecha
- Exportar resultados optimizados para LibreOffice Calc en Ubuntu

## 📂 Estructura

```
gestion_reservas/
├── config.sh          # Configuración de columnas, rutas y filtros
├── parser.sh          # Parser CSV robusto con normalización
├── reservas.sh        # Script principal de procesamiento
├── buscar_reserva.sh  # Búsqueda individual de reservas
└── README.md          # Este archivo
```

## 🚀 Uso Rápido

### Procesamiento masivo (reservas.sh)

```bash
cd gestion_reservas/
chmod +x reservas.sh
./reservas.sh                  # Procesar todas las reservas
./reservas.sh -f O             # Excluir estado "O"
./reservas.sh -t               # Solo check-in de hoy
./reservas.sh -c               # Ver configuración
```

### Búsqueda individual (buscar_reserva.sh) ⭐ NUEVO

```bash
chmod +x buscar_reserva.sh

# Buscar por voucher
./buscar_reserva.sh -v 987654321

# Buscar por DNI
./buscar_reserva.sh -d 11222333

# Buscar por apellido
./buscar_reserva.sh -a PÉREZ

# Con detalle completo
./buscar_reserva.sh -v 987654321 -D
```

## ⚙️ Configuración

### Personalizar columnas a exportar

Edita el archivo [config.sh](config.sh) para personalizar:

1. **Rutas de entrada/salida**:
```bash
ENTRADA_DIR="${HOME}/Descargas"
SALIDA_DIR="${HOME}/Descargas"
ARCHIVO_ENTRADA="consultaRegimenReport.csv"
ARCHIVO_SALIDA="reservas_procesadas.csv"
```

2. **Columnas a exportar** (por defecto 14 columnas):
```bash
declare -a COLUMNAS_EXPORTAR=(3 9 10 6 12 13 14 15 8 17 24 18 7 5)
```

Orden actual de columnas:
- Habitación (col 3)
- Check-in (col 9)
- Check-out (col 10)
- Plazas (col 6)
- Tipo Documento (col 12)
- Nro. Documento (col 13)
- Nombre Completo (col 14)
- Edad (col 15)
- Sede (col 8)
- Régimen (col 17)
- Estado (col 24)
- Paquete (col 18)
- Voucher (col 7)
- Observaciones (col 5)

3. **Encabezados personalizados**:
```bash
declare -a ENCABEZADOS=(
    "Habitación"
    "Check-in"
    "Check-out"
    # ... etc
)
```

4. **Filtros**:
```bash
FILTRO_ESTADO_EXCLUIR="O"      # Excluir estado "O" (Ocupada)
FILTRAR_POR_FECHA_HOY=false    # true para filtrar por fecha de hoy
```

## 📊 Formato del CSV de Entrada

El script espera un CSV con 28 columnas del gestor hotelero:

```
Cód. Alojamiento,Descripción,Nro. habitación,Tipo habitación,Observación habitación,
Cantidad plazas,Voucher,Sede,Fecha de ingreso,Fecha de egreso,Plazas ocupadas,
Tipo documento,Nro. doc.,Apellido y nombre,Edad,Entidad,Servicios,Paquete,
Transporte,Fecha viaje,Hora viaje,Parada,Email,Estado,Fecha de nacimiento,
Teléfono,Celular,Usuario
```

### Estados comunes en columna 24:
- `T` - Titular
- `O` - Ocupada (generalmente se excluye)
- Otros según configuración del gestor

## 📤 Formato del CSV de Salida

El archivo generado incluye solo las columnas seleccionadas con encabezados personalizados:

```csv
Habitación,Check-in,Check-out,Plazas,Tipo Doc,Nro. Documento,Nombre Completo,Edad,Sede,Régimen,Estado,Paquete,Voucher,Observaciones
201,15/3/2024,18/3/2024,2,DNI,11222333,PÉREZ JUAN,38,101 - MAR DEL PLATA,Media Pension,T,TEMPORADA BAJA 2024,987654321,
```

## 🔧 Características Técnicas

### Mejoras respecto a versiones anteriores

✅ **Modularidad**: Configuración separada del código  
✅ **Portabilidad**: Detección automática de rutas  
✅ **Validación**: Verificación de archivos y configuración  
✅ **Manejo de errores**: Modo estricto con `set -euo pipefail`  
✅ **Limpieza automática**: Archivos temporales se eliminan al salir  
✅ **Flexibilidad**: Argumentos de línea de comandos  
✅ **Estadísticas**: Resumen del procesamiento  
✅ **Integración LibreOffice**: Opción de apertura automática  
✅ **Parser CSV robusto**: Maneja comas dentro de campos entre comillas ⭐  
✅ **Normalización**: Nombres automáticamente en MAYÚSCULAS ⭐  
✅ **Búsqueda individual**: Por voucher, DNI o apellido ⭐  

### Requisitos

- Bash 4.0+
- AWK (incluido en Ubuntu por defecto)
- LibreOffice Calc (opcional, para abrir el resultado)

## 📋 Ejemplos de Uso

### Ejemplo 1: Procesar todas las reservas

```bash
./reservas.sh
```

**Salida**:
```
═══════════════════════════════════════════════════════════
  📋 GESTIÓN DE RESERVAS - Procesador CSV
═══════════════════════════════════════════════════════════

🔍 Buscando archivo de reservas...
📄 Archivo encontrado: consultaRegimenReport.csv
📊 Registros totales: 150

⚙️  Procesando datos...

✅ Archivo procesado correctamente
═══════════════════════════════════════════════════════════
📊 ESTADÍSTICAS
═══════════════════════════════════════════════════════════
Registros procesados: 150
Columnas exportadas:  14
Archivo de salida:    /home/user/Descargas/reservas_procesadas.csv
═══════════════════════════════════════════════════════════
```

### Ejemplo 2: Buscar por voucher ⭐

```bash
./buscar_reserva.sh -v 987654321
```

**Salida**:
```
🔍 Buscando voucher: 987654321
═══════════════════════════════════════════════════════════

  ✓ PÉREZ JUAN | Hab: 201 | DNI: 11222333 | Voucher: 987654321 | 15/3/2024 → 18/3/2024
  ✓ GARCÍA MARÍA | Hab: 201 | DNI: 44555666 | Voucher: 987654321 | 15/3/2024 → 18/3/2024
═══════════════════════════════════════════════════════════
✅ Se encontraron 2 resultado(s)
```

### Ejemplo 3: Buscar con detalle completo

```bash
./buscar_reserva.sh -a PÉREZ -D
```

**Salida**:
```
🔍 Buscando apellido: PÉREZ
═══════════════════════════════════════════════════════════

📋 RESERVA #1
───────────────────────────────────────────────────────────
  🎫 Voucher:       987654321
  🏨 Habitación:    201
  👤 Nombre:        PÉREZ JUAN
  🆔 DNI:           11222333
  🎂 Edad:          38 años
  📅 Check-in:      15/3/2024
  📅 Check-out:     18/3/2024
  🏢 Sede:          101 - MAR DEL PLATA
  🍽️  Régimen:       Media Pension
  📦 Paquete:       TEMPORADA BAJA 2024
  ⚡ Estado:        T

═══════════════════════════════════════════════════════════
✅ Se encontraron 1 resultado(s)
```

### Ejemplo 4: Excluir reservas con estado "O"

```bash
./reservas.sh -f O
```

Procesa solo registros donde `Estado != "O"`.

### Ejemplo 5: Buscar por DNI

```bash
./buscar_reserva.sh -d 11222333
```

### Ejemplo 6: Ver configuración actual

```bash
./reservas.sh -c
```

**Salida**:
```
═══════════════════════════════════════════════════════════
  CONFIGURACIÓN ACTUAL
═══════════════════════════════════════════════════════════
Archivo entrada:  /home/user/Descargas/consultaRegimenReport.csv
Archivo salida:   /home/user/Descargas/reservas_procesadas.csv
Columnas a exportar: 14
Filtro estado:    O
Filtro fecha hoy: false
═══════════════════════════════════════════════════════════
```

### Ejemplo 7: Abrir automáticamente en LibreOffice

Después de ejecutar el script, se pregunta:

```
¿Deseas abrir el archivo en LibreOffice? (s/n): s
📊 Abriendo LibreOffice Calc...
```

## 🐛 Solución de Problemas

### Error: No se encuentra el archivo de entrada

**Problema**: `❌ Error: El archivo de entrada no existe`

**Solución**:
1. Verifica que el archivo CSV esté en `~/Descargas/consultaRegimenReport.csv`
2. O especifica la ruta correcta: `./reservas.sh -i /ruta/correcta/archivo.csv`

### Error: Archivo vacío

**Problema**: `⚠️  Advertencia: El archivo está vacío`

**Solución**: Descarga nuevamente el archivo CSV del gestor hotelero.

### Sin permisos de ejecución

**Problema**: `bash: ./reservas.sh: Permission denied`

**Solución**:
```bash
chmod +x reservas.sh
```

## 🔄 Migración desde Scripts Anteriores

### Antes (reserva.sh):
```bash
cd $HOME/Descargas/
awk -F "," '{print ($3",", $9",", ...)}' consultaRegimenReport.csv > reserva_hoy.csv
```

### Ahora (reservas.sh):
```bash
./reservas.sh -f O
```

**Ventajas**:
- ✅ Configuración centralizada y documentada
- ✅ Validaciones automáticas
- ✅ Manejo de errores robusto
- ✅ Fácil personalización sin tocar el código
- ✅ Mensajes informativos
- ✅ Estadísticas de procesamiento

## 📚 Flujo de Trabajo Recomendado

1. **Descargar CSV del gestor hotelero** → `~/Descargas/consultaRegimenReport.csv`

2. **Procesamiento masivo**:
   ```bash
   ./reservas.sh
   ```

3. **Búsquedas individuales** durante check-in:
   ```bash
   # Verificar datos antes de check-in
   ./buscar_reserva.sh -v 987654321 -D
   
   # Buscar por apellido si hay confusión
   ./buscar_reserva.sh -a PÉREZ
   ```

4. **Abrir en LibreOffice** (opcional): automático o manual

5. **Trabajar con datos** en formato optimizado

### Casos de uso comunes

#### Recepción del hotel
```bash
# Buscar reserva por voucher al momento del check-in
./buscar_reserva.sh -v 987654321 -D
```

#### Preparación de habitaciones
```bash
# Generar lista de todas las reservas para hoy
./reservas.sh -t
```

#### Auditoría diaria
```bash
# Procesar todas las reservas excluyendo canceladas
./reservas.sh -f O
```

## 🔐 Seguridad y Buenas Prácticas

- ✅ No se modifican archivos de entrada (solo lectura)
- ✅ Archivos temporales se limpian automáticamente
- ✅ Modo estricto de Bash (`set -euo pipefail`)
- ✅ Validaciones antes de procesar
- ✅ Sin contraseñas o credenciales en el código

## 📅 Historial de Versiones

### v1.0 (05/02/2026)
- ✨ Versión inicial modernizada
- 🔧 Configuración modular
- 📊 Procesamiento de 28 columnas a 14 columnas personalizables
- 🎯 Filtros por estado y fecha
- 📝 Documentación completa
- 🚀 Integración con LibreOffice
- ⭐ Parser CSV robusto (manejo de comas en campos)
- ⭐ Normalización automática a MAYÚSCULAS
- ⭐ Búsqueda individual por voucher/DNI/apellido

## 👤 Autor

**Gestión Hotelera**  
Migrado y modernizado desde scripts legacy

## 📜 Licencia

Uso interno - Gestión hotelera

---

**💡 Tip**: Para agregar o quitar columnas, solo edita el archivo [config.sh](config.sh) sin modificar el código principal.
