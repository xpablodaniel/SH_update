#!/bin/bash

# =============================================================================
# CONFIGURACIÓN - Módulo Apagado Automático
# =============================================================================
# Configuración para el sistema de apagado automático programado
# Versión: 1.0
# Fecha: 05/02/2026
# =============================================================================

# -----------------------------------------------------------------------------
# RUTAS DE CONFIGURACIÓN
# -----------------------------------------------------------------------------

# Detectar el directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directorio donde se almacena el archivo de estado
CONFIG_DIR="${SCRIPT_DIR}"

# Archivo que controla el modo (ON = día libre, OFF = día laboral)
FLAG_FILE="${CONFIG_DIR}/dia_libre"

# Archivo de log para registrar eventos
LOG_FILE="${CONFIG_DIR}/apagado.log"

# -----------------------------------------------------------------------------
# CONFIGURACIÓN DE APAGADO
# -----------------------------------------------------------------------------

# Hora de ejecución programada (en crontab)
HORA_CRON="02:55"

# Tiempo de espera antes del apagado (en minutos)
TIEMPO_AVISO=5

# Comando de apagado del sistema
SHUTDOWN_CMD="/sbin/shutdown"

# -----------------------------------------------------------------------------
# MENSAJES
# -----------------------------------------------------------------------------

# Mensaje de aviso a usuarios
MSG_AVISO="⚠️  ATENCIÓN: La computadora se apagará en ${TIEMPO_AVISO} minutos. Guarda tu trabajo."

# Mensaje cuando está en modo libre
MSG_DIA_LIBRE="ℹ️  Día libre detectado. No se ejecuta apagado automático."

# Mensaje de apagado cancelado
MSG_CANCELADO="✅ Apagado automático cancelado."

# -----------------------------------------------------------------------------
# ESTADOS VÁLIDOS
# -----------------------------------------------------------------------------

# Estado para días libres (NO apaga)
ESTADO_LIBRE="ON"

# Estado para días laborales (SÍ apaga)
ESTADO_LABORAL="OFF"

# -----------------------------------------------------------------------------
# CONFIGURACIÓN DE NOTIFICACIONES
# -----------------------------------------------------------------------------

# Usar 'wall' para enviar mensajes a todos los usuarios
USAR_WALL=true

# Usar notificaciones de escritorio (notify-send) si está disponible
USAR_NOTIFY=true

# -----------------------------------------------------------------------------
# FUNCIONES DE UTILIDAD
# -----------------------------------------------------------------------------

# Función para inicializar el archivo de estado si no existe
init_flag_file() {
    if [ ! -f "$FLAG_FILE" ]; then
        echo "$ESTADO_LABORAL" > "$FLAG_FILE"
        log_event "Archivo de estado creado con modo: $ESTADO_LABORAL"
    fi
}

# Función para registrar eventos en el log
log_event() {
    local mensaje="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $mensaje" >> "$LOG_FILE"
}

# Función para obtener el estado actual
get_estado() {
    if [ -f "$FLAG_FILE" ]; then
        cat "$FLAG_FILE"
    else
        echo "$ESTADO_LABORAL"
    fi
}

# Función para verificar si es día libre
es_dia_libre() {
    local estado=$(get_estado)
    [ "$estado" = "$ESTADO_LIBRE" ]
}

# Función para validar la configuración
validar_config() {
    local errores=0
    
    # Verificar que el directorio existe
    if [ ! -d "$CONFIG_DIR" ]; then
        echo "Error: El directorio de configuración no existe: $CONFIG_DIR"
        ((errores++))
    fi
    
    # Verificar permisos de escritura
    if [ ! -w "$CONFIG_DIR" ]; then
        echo "Error: No hay permisos de escritura en: $CONFIG_DIR"
        ((errores++))
    fi
    
    # Verificar que el comando shutdown existe
    if [ ! -x "$SHUTDOWN_CMD" ]; then
        echo "Advertencia: Comando shutdown no encontrado en: $SHUTDOWN_CMD"
        echo "Intentando usar: /usr/sbin/shutdown"
        SHUTDOWN_CMD="/usr/sbin/shutdown"
        if [ ! -x "$SHUTDOWN_CMD" ]; then
            echo "Error: No se encuentra el comando shutdown"
            ((errores++))
        fi
    fi
    
    return $errores
}

# Función para mostrar la configuración actual
mostrar_config() {
    echo "═══════════════════════════════════════════════════════════"
    echo "  CONFIGURACIÓN ACTUAL - APAGADO AUTOMÁTICO"
    echo "═══════════════════════════════════════════════════════════"
    echo "Directorio config:    $CONFIG_DIR"
    echo "Archivo de estado:    $FLAG_FILE"
    echo "Archivo de log:       $LOG_FILE"
    echo "Hora programada:      $HORA_CRON"
    echo "Tiempo de aviso:      $TIEMPO_AVISO minutos"
    echo "Estado actual:        $(get_estado)"
    echo "Modo actual:          $(es_dia_libre && echo 'DÍA LIBRE' || echo 'DÍA LABORAL')"
    echo "═══════════════════════════════════════════════════════════"
}

# Exportar variables y funciones
export SCRIPT_DIR CONFIG_DIR FLAG_FILE LOG_FILE
export TIEMPO_AVISO SHUTDOWN_CMD
export MSG_AVISO MSG_DIA_LIBRE MSG_CANCELADO
export ESTADO_LIBRE ESTADO_LABORAL
export USAR_WALL USAR_NOTIFY
export -f init_flag_file log_event get_estado es_dia_libre validar_config mostrar_config
