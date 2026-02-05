#!/bin/bash

# =============================================================================
# ACTIVAR MODO DÍA LIBRE
# =============================================================================
# Desactiva el apagado automático (modo día libre)
# Versión: 1.0
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.sh"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: No se encuentra el archivo de configuración"
    exit 1
fi

source "$CONFIG_FILE"

# Inicializar archivo si no existe
init_flag_file

# Activar modo día libre
echo "$ESTADO_LIBRE" > "$FLAG_FILE"

echo "✅ Modo DÍA LIBRE activado"
echo "🏖️  El apagado automático NO se ejecutará hasta que cambies al modo laboral"
echo ""
echo "Para volver al modo laboral: ./modo_laboral.sh"

log_event "Modo cambiado a: DÍA LIBRE (ON)"

# Cancelar apagado si hay uno programado
if [ -x "$SHUTDOWN_CMD" ]; then
    $SHUTDOWN_CMD -c 2>/dev/null && {
        echo "ℹ️  Apagado programado cancelado"
        log_event "Apagado cancelado al activar modo libre"
    } || true
fi

exit 0