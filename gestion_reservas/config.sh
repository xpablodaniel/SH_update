#!/bin/bash

# =============================================================================
# CONFIGURACIÓN - Módulo Gestión de Reservas
# =============================================================================
# Archivo de configuración para el procesamiento de reservas hoteleras
# Versión: 1.0
# Fecha: 05/02/2026
# =============================================================================

# -----------------------------------------------------------------------------
# CONFIGURACIÓN DE RUTAS
# -----------------------------------------------------------------------------

# Detectar el directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ruta predeterminada de entrada (donde está el CSV del gestor hotelero)
ENTRADA_DIR="${HOME}/Descargas"

# Ruta de salida (donde se guardará el archivo procesado)
SALIDA_DIR="${HOME}/Descargas"

# Nombre del archivo CSV de entrada (del gestor hotelero)
ARCHIVO_ENTRADA="consultaRegimenReport.csv"

# Nombre del archivo CSV de salida (procesado)
ARCHIVO_SALIDA="reservas_procesadas.csv"

# -----------------------------------------------------------------------------
# CONFIGURACIÓN DE COLUMNAS
# -----------------------------------------------------------------------------
# Columnas del archivo CSV original (28 columnas totales)
# Índice: Nombre de la columna
# -----------------------------------------------------------------------------
# 1:  Cód. Alojamiento
# 2:  Descripción
# 3:  Nro. habitación
# 4:  Tipo habitación
# 5:  Observación habitación
# 6:  Cantidad plazas
# 7:  Voucher
# 8:  Sede
# 9:  Fecha de ingreso
# 10: Fecha de egreso
# 11: Plazas ocupadas
# 12: Tipo documento
# 13: Nro. doc.
# 14: Apellido y nombre
# 15: Edad
# 16: Entidad
# 17: Servicios
# 18: Paquete
# 19: Transporte
# 20: Fecha viaje
# 21: Hora viaje
# 22: Parada
# 23: Email
# 24: Estado
# 25: Fecha de nacimiento
# 26: Teléfono
# 27: Celular
# 28: Usuario

# -----------------------------------------------------------------------------
# COLUMNAS A EXPORTAR (en el orden deseado)
# -----------------------------------------------------------------------------
# Definir qué columnas extraer y en qué orden
# Formato: número de columna del CSV original

# Orden de columnas para LibreOffice:
# 1. Nro. habitación (col 3)
# 2. Fecha de ingreso (col 9)
# 3. Fecha de egreso (col 10)
# 4. Cantidad plazas (col 6)
# 5. Tipo documento (col 12)
# 6. Nro. doc. (col 13)
# 7. Apellido y nombre (col 14)
# 8. Edad (col 15)
# 9. Sede (col 8)
# 10. Servicios (col 17)
# 11. Estado (col 24)
# 12. Paquete (col 18)
# 13. Voucher (col 7)
# 14. Observación habitación (col 5)

# Array con el orden de columnas a exportar
declare -a COLUMNAS_EXPORTAR=(3 9 10 6 12 13 14 15 8 17 24 18 7 5)

# Encabezados para el archivo de salida
declare -a ENCABEZADOS=(
    "Habitación"
    "Check-in"
    "Check-out"
    "Plazas"
    "Tipo Doc"
    "Nro. Documento"
    "Nombre Completo"
    "Edad"
    "Sede"
    "Régimen"
    "Estado"
    "Paquete"
    "Voucher"
    "Observaciones"
)

# -----------------------------------------------------------------------------
# FILTROS DE DATOS
# -----------------------------------------------------------------------------

# Filtrar por estado (columna 24)
# Valores posibles: T (Titular), O (Ocupada), etc.
# Dejar vacío para no filtrar
FILTRO_ESTADO_EXCLUIR="O"  # Excluir reservas con estado "O"

# Filtrar por fecha (si se desea procesar solo reservas de hoy)
FILTRAR_POR_FECHA_HOY=false

# -----------------------------------------------------------------------------
# OPCIONES DE FORMATO
# -----------------------------------------------------------------------------

# Delimitador del CSV de salida
DELIMITADOR=","

# Incluir encabezados en el archivo de salida
INCLUIR_ENCABEZADOS=true

# Eliminar espacios extras en los campos
LIMPIAR_ESPACIOS=true

# -----------------------------------------------------------------------------
# MENSAJES
# -----------------------------------------------------------------------------

MSG_BUSCANDO="🔍 Buscando archivo de reservas..."
MSG_PROCESANDO="⚙️  Procesando datos..."
MSG_EXITO="✅ Archivo procesado correctamente"
MSG_ERROR_NO_EXISTE="❌ Error: El archivo de entrada no existe"
MSG_ERROR_VACIO="⚠️  Advertencia: El archivo está vacío"

# -----------------------------------------------------------------------------
# FUNCIONES DE UTILIDAD
# -----------------------------------------------------------------------------

# Función para validar la configuración
validar_config() {
    local errores=0
    
    # Validar que el directorio de entrada existe
    if [ ! -d "$ENTRADA_DIR" ]; then
        echo "Error: El directorio de entrada no existe: $ENTRADA_DIR"
        ((errores++))
    fi
    
    # Validar que el directorio de salida existe o se puede crear
    if [ ! -d "$SALIDA_DIR" ]; then
        echo "Advertencia: El directorio de salida no existe. Se creará: $SALIDA_DIR"
        mkdir -p "$SALIDA_DIR" 2>/dev/null || {
            echo "Error: No se puede crear el directorio de salida"
            ((errores++))
        }
    fi
    
    # Validar que hay columnas definidas
    if [ ${#COLUMNAS_EXPORTAR[@]} -eq 0 ]; then
        echo "Error: No hay columnas definidas para exportar"
        ((errores++))
    fi
    
    # Validar que el número de encabezados coincide con el de columnas
    if [ ${#ENCABEZADOS[@]} -ne ${#COLUMNAS_EXPORTAR[@]} ]; then
        echo "Error: El número de encabezados (${#ENCABEZADOS[@]}) no coincide con el número de columnas (${#COLUMNAS_EXPORTAR[@]})"
        ((errores++))
    fi
    
    return $errores
}

# Función para mostrar la configuración actual
mostrar_config() {
    echo "═══════════════════════════════════════════════════════════"
    echo "  CONFIGURACIÓN ACTUAL"
    echo "═══════════════════════════════════════════════════════════"
    echo "Archivo entrada:  $ENTRADA_DIR/$ARCHIVO_ENTRADA"
    echo "Archivo salida:   $SALIDA_DIR/$ARCHIVO_SALIDA"
    echo "Columnas a exportar: ${#COLUMNAS_EXPORTAR[@]}"
    echo "Filtro estado:    ${FILTRO_ESTADO_EXCLUIR:-ninguno}"
    echo "Filtro fecha hoy: ${FILTRAR_POR_FECHA_HOY}"
    echo "═══════════════════════════════════════════════════════════"
}

# Exportar variables para que estén disponibles en otros scripts
export SCRIPT_DIR ENTRADA_DIR SALIDA_DIR ARCHIVO_ENTRADA ARCHIVO_SALIDA
export DELIMITADOR INCLUIR_ENCABEZADOS LIMPIAR_ESPACIOS
export FILTRO_ESTADO_EXCLUIR FILTRAR_POR_FECHA_HOY
export MSG_BUSCANDO MSG_PROCESANDO MSG_EXITO MSG_ERROR_NO_EXISTE MSG_ERROR_VACIO
