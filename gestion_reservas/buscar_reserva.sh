#!/bin/bash

# =============================================================================
# BÚSQUEDA DE RESERVAS - Script de Consulta Individual
# =============================================================================
# Busca reservas en el CSV por diferentes criterios:
# - Voucher
# - DNI
# - Apellido
# 
# Versión: 1.0
# Fecha: 05/02/2026
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# CONFIGURACIÓN
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.sh"
PARSER_FILE="${SCRIPT_DIR}/parser.sh"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: No se encuentra el archivo de configuración: $CONFIG_FILE"
    exit 1
fi

if [ ! -f "$PARSER_FILE" ]; then
    echo "❌ Error: No se encuentra el parser: $PARSER_FILE"
    exit 1
fi

source "$CONFIG_FILE"
source "$PARSER_FILE"

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

BUSCAR_POR=""
TERMINO_BUSQUEDA=""
MOSTRAR_DETALLE=false
ARCHIVO_ENTRADA_COMPLETO="${ENTRADA_DIR}/${ARCHIVO_ENTRADA}"

# -----------------------------------------------------------------------------
# FUNCIONES
# -----------------------------------------------------------------------------

mostrar_uso() {
    cat << EOF
Uso: $(basename "$0") [OPCIONES]

Busca reservas en el archivo CSV del gestor hotelero.

OPCIONES:
    -v, --voucher NUM       Buscar por número de voucher
    -d, --dni NUM           Buscar por número de DNI
    -a, --apellido TEXTO    Buscar por apellido
    -i, --input FILE        Archivo CSV de entrada (default: config.sh)
    -D, --detalle          Mostrar información detallada
    -h, --help             Mostrar esta ayuda

EJEMPLOS:
    $(basename "$0") -v 164000099              # Buscar por voucher
    $(basename "$0") -d 26421214               # Buscar por DNI
    $(basename "$0") -a MORAMARCO              # Buscar por apellido
    $(basename "$0") -a MORAMARCO -D           # Con detalle completo
    $(basename "$0") -v 164000099 -i otro.csv  # Archivo específico

EOF
}

# Buscar en el CSV
buscar_reservas() {
    if [ ! -f "$ARCHIVO_ENTRADA_COMPLETO" ]; then
        echo "❌ Error: No se encuentra el archivo: $ARCHIVO_ENTRADA_COMPLETO"
        return 1
    fi
    
    echo "🔍 Buscando $BUSCAR_POR: $TERMINO_BUSQUEDA"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    
    local encontrados=0
    local termino_upper=$(normalize_upper "$TERMINO_BUSQUEDA")
    
    # Crear archivo temporal para resultados
    local temp_results=$(mktemp)
    
    # Usar AWK para búsqueda rápida
    case "$BUSCAR_POR" in
        voucher)
            awk -F, -v buscar="$TERMINO_BUSQUEDA" -v detalle="$MOSTRAR_DETALLE" '
            NR==1 { next }
            $7 == buscar {
                encontrados++;
                nombre = toupper($14);
                if (detalle == "true") {
                    print "📋 RESERVA #" encontrados;
                    print "───────────────────────────────────────────────────────────";
                    print "  🎫 Voucher:       " $7;
                    print "  🏨 Habitación:    " $3;
                    print "  👤 Nombre:        " nombre;
                    print "  🆔 DNI:           " $13;
                    print "  🎂 Edad:          " $15 " años";
                    print "  📅 Check-in:      " $9;
                    print "  📅 Check-out:     " $10;
                    print "  🏢 Sede:          " $8;
                    print "  🍽️  Régimen:       " $17;
                    print "  📦 Paquete:       " $18;
                    print "  ⚡ Estado:        " $24;
                    print "";
                } else {
                    print "  ✓ " nombre " | Hab: " $3 " | DNI: " $13 " | Voucher: " $7 " | " $9 " → " $10;
                }
            }
            END { print encontrados }
            ' "$ARCHIVO_ENTRADA_COMPLETO" > "$temp_results"
            ;;
        dni)
            awk -F, -v buscar="$TERMINO_BUSQUEDA" -v detalle="$MOSTRAR_DETALLE" '
            NR==1 { next }
            $13 == buscar {
                encontrados++;
                nombre = toupper($14);
                if (detalle == "true") {
                    print "📋 RESERVA #" encontrados;
                    print "───────────────────────────────────────────────────────────";
                    print "  🎫 Voucher:       " $7;
                    print "  🏨 Habitación:    " $3;
                    print "  👤 Nombre:        " nombre;
                    print "  🆔 DNI:           " $13;
                    print "  🎂 Edad:          " $15 " años";
                    print "  📅 Check-in:      " $9;
                    print "  📅 Check-out:     " $10;
                    print "  🏢 Sede:          " $8;
                    print "  🍽️  Régimen:       " $17;
                    print "  📦 Paquete:       " $18;
                    print "  ⚡ Estado:        " $24;
                    print "";
                } else {
                    print "  ✓ " nombre " | Hab: " $3 " | DNI: " $13 " | Voucher: " $7 " | " $9 " → " $10;
                }
            }
            END { print encontrados }
            ' "$ARCHIVO_ENTRADA_COMPLETO" > "$temp_results"
            ;;
        apellido)
            awk -F, -v buscar="$termino_upper" -v detalle="$MOSTRAR_DETALLE" '
            NR==1 { next }
            toupper($14) ~ buscar {
                encontrados++;
                nombre = toupper($14);
                if (detalle == "true") {
                    print "📋 RESERVA #" encontrados;
                    print "───────────────────────────────────────────────────────────";
                    print "  🎫 Voucher:       " $7;
                    print "  🏨 Habitación:    " $3;
                    print "  👤 Nombre:        " nombre;
                    print "  🆔 DNI:           " $13;
                    print "  🎂 Edad:          " $15 " años";
                    print "  📅 Check-in:      " $9;
                    print "  📅 Check-out:     " $10;
                    print "  🏢 Sede:          " $8;
                    print "  🍽️  Régimen:       " $17;
                    print "  📦 Paquete:       " $18;
                    print "  ⚡ Estado:        " $24;
                    print "";
                } else {
                    print "  ✓ " nombre " | Hab: " $3 " | DNI: " $13 " | Voucher: " $7 " | " $9 " → " $10;
                }
            }
            END { print encontrados }
            ' "$ARCHIVO_ENTRADA_COMPLETO" > "$temp_results"
            ;;
    esac
    
    # Leer resultados
    local resultado=$(cat "$temp_results")
    
    # Extraer número de encontrados (última línea)
    encontrados=$(echo "$resultado" | tail -1)
    
    # Mostrar resultados (todas las líneas excepto la última)
    echo "$resultado" | head -n -1
    
    # Limpiar archivo temporal
    rm -f "$temp_results"
    
    echo "═══════════════════════════════════════════════════════════"
    if [ "$encontrados" -eq 0 ]; then
        echo "❌ No se encontraron resultados"
        return 1
    else
        echo "✅ Se encontraron $encontrados resultado(s)"
    fi
    
    return 0
}

# -----------------------------------------------------------------------------
# PROCESAMIENTO DE ARGUMENTOS
# -----------------------------------------------------------------------------

if [ $# -eq 0 ]; then
    mostrar_uso
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--voucher)
            BUSCAR_POR="voucher"
            TERMINO_BUSQUEDA="$2"
            shift 2
            ;;
        -d|--dni)
            BUSCAR_POR="dni"
            TERMINO_BUSQUEDA="$2"
            shift 2
            ;;
        -a|--apellido)
            BUSCAR_POR="apellido"
            TERMINO_BUSQUEDA="$2"
            shift 2
            ;;
        -i|--input)
            ARCHIVO_ENTRADA="$2"
            ARCHIVO_ENTRADA_COMPLETO="$2"
            shift 2
            ;;
        -D|--detalle)
            MOSTRAR_DETALLE=true
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

# Validar que se especificó un criterio de búsqueda
if [ -z "$BUSCAR_POR" ] || [ -z "$TERMINO_BUSQUEDA" ]; then
    echo "❌ Error: Debes especificar un criterio de búsqueda"
    mostrar_uso
    exit 1
fi

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------

buscar_reservas

exit $?
