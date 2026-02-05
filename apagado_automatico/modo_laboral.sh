#!/bin/bash

# =============================================================================
# ACTIVAR MODO DÍA LABORAL
# =============================================================================
# Activa el apagado automático (modo día laboral)
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

# Activar modo día laboral
echo "$ESTADO_LABORAL" > "$FLAG_FILE"

echo "✅ Modo DÍA LABORAL activado"
echo "💼 El apagado automático se ejecutará según la programación (02:55)"
echo ""
echo "Próxima verificación: Mañana a las 02:55"
echo "Para desactivar: ./modo_libre.sh"

log_event "Modo cambiado a: DÍA LABORAL (OFF)"

exit 0