#!/bin/bash

# =============================================================================
# PARSER CSV ROBUSTO
# =============================================================================
# Funciones para parsear CSV manejando correctamente:
# - Comas dentro de campos entre comillas
# - Campos con múltiples líneas
# - Normalización de datos
# =============================================================================

# Función: Parsear línea CSV manejando campos con comillas
# Uso: parse_csv_line "linea,con,campos,\"campo con coma, aquí\",otro"
parse_csv_line() {
    local line="$1"
    local -a fields=()
    local field=""
    local in_quotes=false
    local i
    
    for ((i=0; i<${#line}; i++)); do
        local char="${line:$i:1}"
        
        if [ "$char" = '"' ]; then
            if [ "$in_quotes" = true ]; then
                # Verificar si es comilla de escape ""
                if [ "${line:$((i+1)):1}" = '"' ]; then
                    field+="\"" 
                    ((i++))
                else
                    in_quotes=false
                fi
            else
                in_quotes=true
            fi
        elif [ "$char" = ',' ] && [ "$in_quotes" = false ]; then
            # Fin de campo
            fields+=("$field")
            field=""
        else
            field+="$char"
        fi
    done
    
    # Agregar último campo
    fields+=("$field")
    
    # Imprimir campos separados por ||| (delimitador temporal)
    local IFS='|||'
    echo "${fields[*]}"
}

# Función: Normalizar texto a mayúsculas
# Uso: normalize_upper "texto a normalizar"
normalize_upper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Función: Limpiar espacios extras
# Uso: trim_spaces "  texto con espacios  "
trim_spaces() {
    local text="$1"
    # Eliminar espacios al inicio y final
    text="${text#"${text%%[![:space:]]*}"}"
    text="${text%"${text##*[![:space:]]}"}"
    echo "$text"
}

# Función: Limpiar campo (normalizar + trim)
# Uso: clean_field "  Campo Con Espacios  " [uppercase]
clean_field() {
    local field="$1"
    local uppercase="${2:-false}"
    
    # Eliminar espacios
    field=$(trim_spaces "$field")
    
    # Convertir a mayúsculas si se solicita
    if [ "$uppercase" = true ]; then
        field=$(normalize_upper "$field")
    fi
    
    echo "$field"
}

# Función: Procesar CSV completo con parser robusto
# Uso: process_csv_robust "archivo.csv" columnas_a_extraer uppercase_names
process_csv_robust() {
    local input_file="$1"
    shift
    local -a columns=("$@")
    
    local line_number=0
    local IFS_BACKUP="$IFS"
    
    while IFS= read -r line || [ -n "$line" ]; do
        ((line_number++))
        
        # Saltar encabezado
        [ $line_number -eq 1 ] && continue
        
        # Parsear la línea
        local parsed=$(parse_csv_line "$line")
        
        # Convertir de vuelta a array
        IFS='|||'
        local -a fields=($parsed)
        IFS="$IFS_BACKUP"
        
        # Extraer campos solicitados
        local output_line=""
        local first=true
        
        for col_idx in "${columns[@]}"; do
            # Ajustar índice (bash arrays empiezan en 0, CSV en 1)
            local array_idx=$((col_idx - 1))
            local field="${fields[$array_idx]:-}"
            
            # Limpiar campo
            field=$(trim_spaces "$field")
            
            # Normalizar nombres (columna 14 = Apellido y nombre)
            if [ "$col_idx" -eq 14 ]; then
                field=$(normalize_upper "$field")
            fi
            
            if [ "$first" = true ]; then
                output_line="$field"
                first=false
            else
                output_line+=",${field}"
            fi
        done
        
        echo "$output_line"
        
    done < "$input_file"
}

# Exportar funciones
export -f parse_csv_line
export -f normalize_upper
export -f trim_spaces
export -f clean_field
export -f process_csv_robust
