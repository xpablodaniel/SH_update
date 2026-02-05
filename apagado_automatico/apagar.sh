#!/bin/bash

# =============================================================================
# APAGADO AUTOMÁTICO - Script Principal
# =============================================================================
# Sistema de apagado automático programado con soporte para días libres
# 
# Versión: 1.0
# Fecha: 05/02/2026
# Uso: Ejecutar desde crontab a las 02:55 para apagado a las 03:00
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# CONFIGURACIÓN
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.sh"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: No se encuentra el archivo de configuración: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# -----------------------------------------------------------------------------
# FUNCIONES
# -----------------------------------------------------------------------------

# Enviar notificación a todos los usuarios
notificar_usuarios() {
    local mensaje="$1"
    
    # Usar wall para enviar mensaje a terminales
    if [ "$USAR_WALL" = true ] && command -v wall &> /dev/null; then
        echo "$mensaje" | wall
        log_event "Mensaje enviado vía wall: $mensaje"
    fi
    
    # Intentar enviar notificaciones de escritorio
    if [ "$USAR_NOTIFY" = true ] && command -v notify-send &> /dev/null; then
        # Enviar a todos los usuarios con sesión X11
        for user_display in $(who | awk '{print $1":"$NF}' | grep -o ':[0-9]*' | sort -u); do
            DISPLAY="$user_display" sudo -u "$USER" notify-send -u critical "Apagado Automático" "$mensaje" 2>/dev/null || true
        done
        log_event "Notificación de escritorio enviada"
    fi
}

# Verificar si es día libre
verificar_dia_libre() {
    init_flag_file
    
    if es_dia_libre; then
        notificar_usuarios "$MSG_DIA_LIBRE"
        log_event "Día libre detectado - Apagado cancelado"
        echo "ℹ️  Día libre detectado. No se ejecuta apagado automático."
        return 0
    else
        log_event "Día laboral detectado - Iniciando secuencia de apagado"
        return 1
    fi
}

# Ejecutar apagado del sistema
ejecutar_apagado() {
    local tiempo="$TIEMPO_AVISO"
    
    # Enviar aviso a usuarios
    notificar_usuarios "$MSG_AVISO"
    log_event "Aviso de apagado enviado - $tiempo minutos restantes"
    
    # Programar apagado
    if [ -x "$SHUTDOWN_CMD" ]; then
        $SHUTDOWN_CMD -h "+$tiempo" "Apagado automático programado" 2>&1 | tee -a "$LOG_FILE"
        log_event "Apagado programado exitosamente para +$tiempo minutos"
        echo "⏰ Apagado programado en $tiempo minutos"
    else
        log_event "ERROR: Comando shutdown no disponible"
        echo "❌ Error: No se pudo ejecutar el comando de apagado"
        exit 1
    fi
}

# Mostrar estado del sistema
mostrar_estado() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  🕐 SISTEMA DE APAGADO AUTOMÁTICO"
    echo "═══════════════════════════════════════════════════════════"
    echo "Fecha/Hora:        $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Estado actual:     $(get_estado)"
    echo "Modo:              $(es_dia_libre && echo '🏖️  DÍA LIBRE (No apaga)' || echo '💼 DÍA LABORAL (Apaga)')"
    echo "Tiempo de aviso:   $TIEMPO_AVISO minutos"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
}

# Cancelar apagado programado (si existe)
cancelar_apagado() {
    if [ -x "$SHUTDOWN_CMD" ]; then
        $SHUTDOWN_CMD -c 2>/dev/null && {
            notificar_usuarios "$MSG_CANCELADO"
            log_event "Apagado cancelado manualmente"
            echo "✅ Apagado cancelado exitosamente"
        } || {
            log_event "No había apagado programado para cancelar"
            echo "ℹ️  No hay apagado programado"
        }
    fi
}

# -----------------------------------------------------------------------------
# MANEJO DE ARGUMENTOS
# -----------------------------------------------------------------------------

mostrar_uso() {
    cat << EOF
Uso: $(basename "$0") [OPCIONES]

Sistema de apagado automático programado con soporte para días libres.

OPCIONES:
    -e, --ejecutar      Ejecutar verificación y apagado (modo normal)
    -c, --cancelar      Cancelar apagado programado
    -s, --estado        Mostrar estado actual del sistema
    -t, --test          Modo prueba (no ejecuta apagado real)
    -h, --help          Mostrar esta ayuda

EJEMPLOS:
    $(basename "$0")                  # Ejecutar verificación normal
    $(basename "$0") -e               # Igual que sin argumentos
    $(basename "$0") -c               # Cancelar apagado
    $(basename "$0") -s               # Ver estado
    $(basename "$0") -t               # Modo prueba

CONFIGURACIÓN:
    Para cambiar entre día libre y laboral:
        ./modo_libre.sh       # Activar día libre (no apaga)
        ./modo_laboral.sh     # Activar día laboral (sí apaga)

CRONTAB:
    Para ejecutar a las 02:55 diariamente:
    55 2 * * * $SCRIPT_DIR/$(basename "$0")

EOF
}

# -----------------------------------------------------------------------------
# FUNCIÓN PRINCIPAL
# -----------------------------------------------------------------------------

main() {
    local modo="ejecutar"
    local test_mode=false
    
    # Procesar argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--ejecutar)
                modo="ejecutar"
                shift
                ;;
            -c|--cancelar)
                modo="cancelar"
                shift
                ;;
            -s|--estado)
                modo="estado"
                shift
                ;;
            -t|--test)
                test_mode=true
                shift
                ;;
            -h|--help)
                mostrar_uso
                exit 0
                ;;
            *)
                echo "❌ Opción desconocida: $1"
                mostrar_uso
                exit 1
                ;;
        esac
    done
    
    # Validar configuración
    validar_config || {
        echo "❌ Error en la configuración"
        exit 1
    }
    
    # Ejecutar según modo
    case "$modo" in
        ejecutar)
            mostrar_estado
            
            if verificar_dia_libre; then
                exit 0
            fi
            
            if [ "$test_mode" = true ]; then
                echo "🧪 MODO PRUEBA: No se ejecutará apagado real"
                log_event "Modo prueba activado - No se ejecuta apagado"
            else
                ejecutar_apagado
            fi
            ;;
        cancelar)
            cancelar_apagado
            ;;
        estado)
            mostrar_estado
            mostrar_config
            ;;
    esac
    
    exit 0
}

# -----------------------------------------------------------------------------
# PUNTO DE ENTRADA
# -----------------------------------------------------------------------------

main "$@"
