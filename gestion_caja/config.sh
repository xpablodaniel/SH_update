#!/bin/bash
# Configuración compartida para scripts de gestión CSV
# Detecta automáticamente rutas según el sistema operativo

# Función para detectar carpeta de Descargas/Downloads
detectar_descargas() {
    # Orden de prioridad para detección
    local RUTAS_POSIBLES=(
        "$HOME/Descargas"           # Linux/Ubuntu español
        "$HOME/Downloads"           # Linux/Ubuntu inglés
        "/mnt/c/Users/xpabl/Downloads"  # WSL específico
        "/mnt/c/Users/$USER/Downloads"  # WSL genérico
    )
    
    # Probar cada ruta
    for ruta in "${RUTAS_POSIBLES[@]}"; do
        if [ -d "$ruta" ]; then
            echo "$ruta"
            return 0
        fi
    done
    
    # Búsqueda dinámica en WSL (más lenta, último recurso)
    if [[ $(uname -r) == *microsoft* ]]; then
        local ENCONTRADO=$(find /mnt/c/Users -maxdepth 2 -type d -name "Downloads" 2>/dev/null | grep -v "Default\|Public" | head -1)
        if [ -n "$ENCONTRADO" ]; then
            echo "$ENCONTRADO"
            return 0
        fi
    fi
    
    # Fallback: usar HOME/Descargas
    echo "$HOME/Descargas"
    return 1
}

# Detectar el sistema operativo
detectar_so() {
    if [[ $(uname -r) == *microsoft* ]]; then
        echo "WSL"
    elif [ -f /etc/lsb-release ]; then
        echo "Ubuntu"
    else
        echo "Linux"
    fi
}

# Exportar variables para uso en otros scripts
export CSV_DIR=$(detectar_descargas)
export SISTEMA_OP=$(detectar_so)

# Colores para output (portables)
export COLOR_RED='\033[0;31m'
export COLOR_GREEN='\033[0;32m'
export COLOR_YELLOW='\033[1;33m'
export COLOR_BLUE='\033[0;34m'
export COLOR_NC='\033[0m'
