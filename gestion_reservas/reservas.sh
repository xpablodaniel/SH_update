#!/bin/bash

# =============================================================================
# GESTIÓN DE RESERVAS - Script Principal
# =============================================================================
# Procesa archivos CSV del gestor hotelero y extrae columnas específicas
# para exportar a LibreOffice Calc
# 
# Versión: 1.0
# Fecha: 05/02/2026
# Autor: Gestión Hotelera
# =============================================================================

set -euo pipefail  # Modo estricto: salir en errores

# -----------------------------------------------------------------------------
# CONFIGURACIÓN
# -----------------------------------------------------------------------------

# Cargar archivo de configuración
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
# VARIABLES GLOBALES
# -----------------------------------------------------------------------------

ARCHIVO_ENTRADA_COMPLETO="${ENTRADA_DIR}/${ARCHIVO_ENTRADA}"
ARCHIVO_SALIDA_COMPLETO="${SALIDA_DIR}/${ARCHIVO_SALIDA}"
TEMP_FILE=$(mktemp)
ERRORES=0

# -----------------------------------------------------------------------------
# FUNCIONES
# -----------------------------------------------------------------------------

# Limpiar archivos temporales al salir
cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT

# Mostrar uso del script
mostrar_uso() {
    cat << EOF
Uso: $(basename "$0") [OPCIONES]

Procesa el archivo CSV de reservas del gestor hotelero y extrae las columnas
configuradas en config.sh para exportar a LibreOffice.

OPCIONES:
    -i, --input FILE     Archivo CSV de entrada (por defecto: desde config.sh)
    -o, --output FILE    Archivo CSV de salida (por defecto: desde config.sh)
    -f, --filter ESTADO  Excluir reservas con este estado (ej: O)
    -t, --today          Filtrar solo reservas con check-in hoy
    -c, --config         Mostrar configuración actual
    -h, --help           Mostrar esta ayuda

EJEMPLOS:
    $(basename "$0")                    # Usar configuración por defecto
    $(basename "$0") -f O               # Excluir estado "O"
    $(basename "$0") -t                 # Solo check-in de hoy
    $(basename "$0") -i archivo.csv     # Usar archivo específico

EOF
}

# Validar que el archivo de entrada existe y no está vacío
validar_entrada() {
    echo "$MSG_BUSCANDO"
    
    if [ ! -f "$ARCHIVO_ENTRADA_COMPLETO" ]; then
        echo "$MSG_ERROR_NO_EXISTE"
        echo "Ruta esperada: $ARCHIVO_ENTRADA_COMPLETO"
        return 1
    fi
    
    if [ ! -s "$ARCHIVO_ENTRADA_COMPLETO" ]; then
        echo "$MSG_ERROR_VACIO"
        return 1
    fi
    
    # Contar líneas (excluyendo encabezado)
    local lineas=$(wc -l < "$ARCHIVO_ENTRADA_COMPLETO")
    local registros=$((lineas - 1))
    
    echo "📄 Archivo encontrado: $ARCHIVO_ENTRADA"
    echo "📊 Registros totales: $registros"
    
    return 0
}

# Generar encabezados para el CSV de salida
generar_encabezados() {
    if [ "$INCLUIR_ENCABEZADOS" = true ]; then
        local primera=true
        for encabezado in "${ENCABEZADOS[@]}"; do
            if [ "$primera" = true ]; then
                echo -n "$encabezado"
                primera=false
            else
                echo -n "${DELIMITADOR}${encabezado}"
            fi
        done
        echo
    fi
}

# Construir el comando AWK para extraer y reordenar columnas
construir_comando_awk() {
    local awk_script='BEGIN { FS=","; OFS="," } '
    
    # Saltar la primera línea (encabezado del CSV original)
    awk_script+='NR==1 { next } '
    
    # Aplicar filtro de estado si está definido
    if [ -n "$FILTRO_ESTADO_EXCLUIR" ]; then
        awk_script+="{ if (\$24 == \"$FILTRO_ESTADO_EXCLUIR\") next } "
    fi
    
    # Aplicar filtro de fecha si está activado
    if [ "$FILTRAR_POR_FECHA_HOY" = true ]; then
        local fecha_hoy=$(date +"%d/%m/%Y")
        # Nota: Asumiendo que la fecha de ingreso está en formato dd/mm/yyyy en columna 9
        awk_script+="{ if (\$9 != \"$fecha_hoy\") next } "
    fi
    
    # Construir la expresión de columnas
    awk_script+='{ print '
    local primera=true
    for col in "${COLUMNAS_EXPORTAR[@]}"; do
        if [ "$primera" = true ]; then
            awk_script+="\$$col"
            primera=false
        else
            awk_script+=", \$$col"
        fi
    done
    awk_script+=' }'
    
    echo "$awk_script"
}

# Procesar el archivo CSV
procesar_csv() {
    echo "$MSG_PROCESANDO"
    
    # Generar encabezados
    generar_encabezados > "$TEMP_FILE"
    
    # Usar parser robusto
    local line_num=0
    while IFS= read -r line || [ -n "$line" ]; do
        ((line_num++))
        
        # Saltar encabezado
        [ $line_num -eq 1 ] && continue
        
        # Parsear línea manejando comas en campos
        local parsed=$(parse_csv_line "$line")
        IFS='|||' read -ra fields <<< "$parsed"
        
        # Aplicar filtros
        local estado="${fields[23]:-}"
        if [ -n "$FILTRO_ESTADO_EXCLUIR" ] && [ "$estado" = "$FILTRO_ESTADO_EXCLUIR" ]; then
            continue
        fi
        
        # Filtro por fecha si está activado
        if [ "$FILTRAR_POR_FECHA_HOY" = true ]; then
            local fecha_ingreso="${fields[8]:-}"
            local fecha_hoy=$(date +"%d/%m/%Y" 2>/dev/null || date +"%m/%d/%Y")
            [ "$fecha_ingreso" != "$fecha_hoy" ] && continue
        fi
        
        # Construir línea de salida con columnas seleccionadas
        local output_line=""
        local first=true
        
        for col_idx in "${COLUMNAS_EXPORTAR[@]}"; do
            local array_idx=$((col_idx - 1))
            local field="${fields[$array_idx]:-}"
            
            # Normalizar nombres a MAYÚSCULAS (columna 14)
            if [ "$col_idx" -eq 14 ]; then
                field=$(normalize_upper "$field")
            fi
            
            # Limpiar espacios
            field=$(trim_spaces "$field")
            
            if [ "$first" = true ]; then
                output_line="$field"
                first=false
            else
                output_line+="${DELIMITADOR}${field}"
            fi
        done
        
        echo "$output_line" >> "$TEMP_FILE"
        
    done < "$ARCHIVO_ENTRADA_COMPLETO"
    
    # Mover el archivo temporal al destino final
    mv "$TEMP_FILE" "$ARCHIVO_SALIDA_COMPLETO" || {
        echo "❌ Error al guardar el archivo de salida"
        return 1
    }
    
    return 0
}

# Mostrar estadísticas del procesamiento
mostrar_estadisticas() {
    local lineas_salida=0
    
    if [ "$INCLUIR_ENCABEZADOS" = true ]; then
        lineas_salida=$(($(wc -l < "$ARCHIVO_SALIDA_COMPLETO") - 1))
    else
        lineas_salida=$(wc -l < "$ARCHIVO_SALIDA_COMPLETO")
    fi
    
    echo ""
    echo "$MSG_EXITO"
    echo "═══════════════════════════════════════════════════════════"
    echo "📊 ESTADÍSTICAS"
    echo "═══════════════════════════════════════════════════════════"
    echo "Registros procesados: $lineas_salida"
    echo "Columnas exportadas:  ${#COLUMNAS_EXPORTAR[@]}"
    echo "Archivo de salida:    $ARCHIVO_SALIDA_COMPLETO"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "💡 Tip: Puedes abrir el archivo con:"
    echo "   libreoffice --calc \"$ARCHIVO_SALIDA_COMPLETO\""
    echo ""
}

# Abrir el archivo en LibreOffice (opcional)
abrir_en_libreoffice() {
    if command -v libreoffice &> /dev/null; then
        read -p "¿Deseas abrir el archivo en LibreOffice? (s/n): " respuesta
        if [[ "$respuesta" =~ ^[SsYy]$ ]]; then
            libreoffice --calc "$ARCHIVO_SALIDA_COMPLETO" &
            echo "📊 Abriendo LibreOffice Calc..."
        fi
    fi
}

# -----------------------------------------------------------------------------
# PROCESAMIENTO DE ARGUMENTOS
# -----------------------------------------------------------------------------

procesar_argumentos() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--input)
                ARCHIVO_ENTRADA="$2"
                ARCHIVO_ENTRADA_COMPLETO="$2"
                shift 2
                ;;
            -o|--output)
                ARCHIVO_SALIDA="$2"
                ARCHIVO_SALIDA_COMPLETO="$2"
                shift 2
                ;;
            -f|--filter)
                FILTRO_ESTADO_EXCLUIR="$2"
                shift 2
                ;;
            -t|--today)
                FILTRAR_POR_FECHA_HOY=true
                shift
                ;;
            -c|--config)
                mostrar_config
                exit 0
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
}

# -----------------------------------------------------------------------------
# FUNCIÓN PRINCIPAL
# -----------------------------------------------------------------------------

main() {
    # Procesar argumentos de línea de comandos
    procesar_argumentos "$@"
    
    # Validar configuración
    validar_config || {
        echo "❌ Error en la configuración. Revisa el archivo config.sh"
        exit 1
    }
    
    # Mostrar banner
    echo "═══════════════════════════════════════════════════════════"
    echo "  📋 GESTIÓN DE RESERVAS - Procesador CSV"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Validar archivo de entrada
    validar_entrada || exit 1
    
    echo ""
    
    # Procesar el CSV
    procesar_csv || exit 1
    
    # Mostrar estadísticas
    mostrar_estadisticas
    
    # Opcionalmente abrir en LibreOffice
    abrir_en_libreoffice
    
    exit 0
}

# -----------------------------------------------------------------------------
# PUNTO DE ENTRADA
# -----------------------------------------------------------------------------

main "$@"
