#!/bin/bash

# Script de análisis de caja - Procesamiento de Reporte_Recibos.csv
# Calcula totales por medio de pago y genera estadísticas

# Cargar configuración (detecta rutas automáticamente)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "╔═══════════════════════════════════════════════════════╗"
echo "║        📊 ANÁLISIS DE CAJA - REPORTE DEL DÍA         ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "Sistema: $SISTEMA_OP | Carpeta: $CSV_DIR"
echo ""

# Cambiar a directorio de CSVs
if [ ! -d "$CSV_DIR" ]; then
    echo -e "${COLOR_RED}✗ Error: No se encuentra la carpeta de descargas${COLOR_NC}"
    exit 1
fi

cd "$CSV_DIR" || exit 1

# Verificar que existe el archivo de entrada
if [ ! -e "Reporte_Recibos.csv" ]; then
    echo -e "${COLOR_RED}✗ Error: No se encuentra Reporte_Recibos.csv${COLOR_NC}"
    echo "  Descarga el archivo desde el sistema externo"
    exit 1
fi

echo -e "${COLOR_BLUE}📄 Procesando: Reporte_Recibos.csv${COLOR_NC}"
NUM_REGISTROS=$(tail -n +2 Reporte_Recibos.csv | wc -l)
echo "   Registros encontrados: $NUM_REGISTROS"
echo ""

# Crear archivos temporales
TEMP_DIR=$(mktemp -d)
ARCHIVO_LIMPIO="$TEMP_DIR/limpio.csv"
REPORTE_FINAL="$CSV_DIR/reporte_caja.txt"

# Limpiar y preparar datos (saltar encabezado)
tail -n +2 Reporte_Recibos.csv > "$ARCHIVO_LIMPIO"

# Función para calcular total por medio de pago
calcular_por_medio() {
    local medio="$1"
    local total=$(awk -F',' -v medio="$medio" '
        tolower($4) ~ tolower(medio) {sum+=$6} 
        END {printf "%.2f", sum}
    ' "$ARCHIVO_LIMPIO")
    echo "$total"
}

# Función para contar transacciones por medio
contar_por_medio() {
    local medio="$1"
    local count=$(awk -F',' -v medio="$medio" '
        tolower($4) ~ tolower(medio) {count++} 
        END {print count+0}
    ' "$ARCHIVO_LIMPIO")
    echo "$count"
}

echo -e "${COLOR_YELLOW}═══════════════════════════════════════════════════════${COLOR_NC}"
echo -e "${COLOR_YELLOW}  ANÁLISIS POR MEDIO DE PAGO${COLOR_NC}"
echo -e "${COLOR_YELLOW}═══════════════════════════════════════════════════════${COLOR_NC}"
echo ""

# Calcular totales por cada medio de pago
EFECTIVO=$(calcular_por_medio "caja seccional")
EFECTIVO_COUNT=$(contar_por_medio "caja seccional")

DEBITO=$(calcular_por_medio "debito")
DEBITO_COUNT=$(contar_por_medio "debito")

CREDITO=$(calcular_por_medio "credito")
CREDITO_COUNT=$(contar_por_medio "credito")

TRANSFERENCIA=$(calcular_por_medio "transferencia")
TRANSFERENCIA_COUNT=$(contar_por_medio "transferencia")

# Calcular total general
TOTAL_GENERAL=$(awk -F',' '{sum+=$6} END {printf "%.2f", sum}' "$ARCHIVO_LIMPIO")

# Mostrar resultados en pantalla
printf "${COLOR_GREEN}%-25s${COLOR_NC}  %3s ops  ${COLOR_YELLOW}%12s${COLOR_NC}\n" \
    "💵 Caja Seccional (Efectivo)" "$EFECTIVO_COUNT" "\$$EFECTIVO"

printf "${COLOR_GREEN}%-25s${COLOR_NC}  %3s ops  ${COLOR_YELLOW}%12s${COLOR_NC}\n" \
    "💳 Débito" "$DEBITO_COUNT" "\$$DEBITO"

printf "${COLOR_GREEN}%-25s${COLOR_NC}  %3s ops  ${COLOR_YELLOW}%12s${COLOR_NC}\n" \
    "💳 Crédito" "$CREDITO_COUNT" "\$$CREDITO"

if (( $(echo "$TRANSFERENCIA > 0" | bc -l) )); then
    printf "${COLOR_GREEN}%-25s${COLOR_NC}  %3s ops  ${COLOR_YELLOW}%12s${COLOR_NC}\n" \
        "🏦 Transferencia" "$TRANSFERENCIA_COUNT" "\$$TRANSFERENCIA"
fi

echo ""
echo -e "${COLOR_BLUE}─────────────────────────────────────────────────────${COLOR_NC}"
printf "${COLOR_GREEN}%-25s${COLOR_NC}  %3s ops  ${COLOR_YELLOW}%12s${COLOR_NC}\n" \
    "📊 TOTAL GENERAL" "$NUM_REGISTROS" "\$$TOTAL_GENERAL"
echo -e "${COLOR_BLUE}─────────────────────────────────────────────────────${COLOR_NC}"

echo ""

# Generar reporte detallado en archivo
{
    echo "═══════════════════════════════════════════════════════"
    echo "        REPORTE DE CAJA - $(date '+%d/%m/%Y %H:%M')"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "Archivo procesado: Reporte_Recibos.csv"
    echo "Total de transacciones: $NUM_REGISTROS"
    echo ""
    echo "---------------------------------------------------"
    echo "RESUMEN POR MEDIO DE PAGO"
    echo "---------------------------------------------------"
    printf "%-30s %10s %15s\n" "Medio de Pago" "Cantidad" "Importe"
    echo "---------------------------------------------------"
    printf "%-30s %10s %15s\n" "Caja Seccional (Efectivo)" "$EFECTIVO_COUNT" "\$$EFECTIVO"
    printf "%-30s %10s %15s\n" "Débito" "$DEBITO_COUNT" "\$$DEBITO"
    printf "%-30s %10s %15s\n" "Crédito" "$CREDITO_COUNT" "\$$CREDITO"
    if (( $(echo "$TRANSFERENCIA > 0" | bc -l) )); then
        printf "%-30s %10s %15s\n" "Transferencia" "$TRANSFERENCIA_COUNT" "\$$TRANSFERENCIA"
    fi
    echo "---------------------------------------------------"
    printf "%-30s %10s %15s\n" "TOTAL GENERAL" "$NUM_REGISTROS" "\$$TOTAL_GENERAL"
    echo "---------------------------------------------------"
    echo ""
    echo "DETALLE DE EFECTIVO (Caja Seccional):"
    echo "---------------------------------------------------"
    printf "%-20s %-35s %15s\n" "Nro. Recibo" "Cliente" "Importe"
    echo "---------------------------------------------------"
    awk -F',' 'tolower($4) ~ /caja seccional/ {printf "%-20s %-35s $%14.2f\n", $1, substr($2,1,35), $6}' "$ARCHIVO_LIMPIO"
    echo "═══════════════════════════════════════════════════════"
} > "$REPORTE_FINAL"

echo -e "${COLOR_GREEN}✓ Reporte detallado generado:${COLOR_NC} reporte_caja.txt"
echo ""

# Crear archivo resumen para compatibilidad con versiones anteriores
echo "$EFECTIVO" > efvo.csv

# Análisis adicional por usuario
echo -e "${COLOR_BLUE}═══════════════════════════════════════════════════════${COLOR_NC}"
echo -e "${COLOR_BLUE}  RESUMEN POR USUARIO${COLOR_NC}"
echo -e "${COLOR_BLUE}═══════════════════════════════════════════════════════${COLOR_NC}"
echo ""

awk -F',' '{
    usuario=$8
    monto=$6
    if (usuario != "" && usuario != "Usuario alta") {
        usuarios[usuario] += monto
        conteo[usuario]++
    }
}
END {
    for (usuario in usuarios) {
        printf "  %-20s %3d ops  $%.2f\n", usuario, conteo[usuario], usuarios[usuario]
    }
}' "$ARCHIVO_LIMPIO" | sort -t'$' -k2 -nr

echo ""

# Generar archivo CSV para LibreOffice (planilla_ingreso.csv)
echo -e "${COLOR_BLUE}═══════════════════════════════════════════════════════${COLOR_NC}"
echo -e "${COLOR_BLUE}  GENERANDO PLANILLA PARA LIBREOFFICE${COLOR_NC}"
echo -e "${COLOR_BLUE}═══════════════════════════════════════════════════════${COLOR_NC}"
echo ""

PLANILLA_CSV="$CSV_DIR/planilla_ingreso.csv"

# Encabezado del CSV para LibreOffice
{
    echo "Nro. recibo,Fecha recibo,Nombre,Nota crédito,Referencia,Lote,Cupon,Importe,Medio de cobranza,Usuario alta"
    
    # Procesar en orden inverso (más reciente primero)
    tail -n +2 "$ARCHIVO_LIMPIO" | tac | while IFS=',' read -r nro_recibo nombre nro_doc medio fecha importe referencia usuario nota estado; do
        # Limpiar campos y escapar comillas
        nro_recibo=$(echo "$nro_recibo" | sed 's/"/""/g')
        nombre=$(echo "$nombre" | sed 's/"/""/g')
        referencia=$(echo "$referencia" | sed 's/"/""/g')
        nota=$(echo "$nota" | sed 's/"/""/g')
        usuario=$(echo "$usuario" | sed 's/"/""/g')
        medio=$(echo "$medio" | sed 's/"/""/g')
        
        # Campos vacíos para Lote y Cupón
        lote=""
        cupon=""
        
        # Agregar comillas si el campo contiene comas o comillas
        [[ "$nro_recibo" == *,* ]] && nro_recibo="\"$nro_recibo\""
        [[ "$nombre" == *,* ]] && nombre="\"$nombre\""
        [[ "$referencia" == *,* ]] && referencia="\"$referencia\""
        [[ "$nota" == *,* ]] && nota="\"$nota\""
        [[ "$usuario" == *,* ]] && usuario="\"$usuario\""
        [[ "$medio" == *,* ]] && medio="\"$medio\""
        
        echo "$nro_recibo,$fecha,$nombre,$nota,$referencia,$lote,$cupon,$importe,$medio,$usuario"
    done
} > "$PLANILLA_CSV"

echo -e "${COLOR_GREEN}✓ Planilla de ingresos generada:${COLOR_NC} planilla_ingreso.csv"
echo "  Formato: Compatible con LibreOffice Calc / Excel"
LINEAS_PLANILLA=$(tail -n +2 "$PLANILLA_CSV" | wc -l)
echo "  Registros: $LINEAS_PLANILLA transacciones"
echo ""

# Limpiar archivos temporales
rm -rf "$TEMP_DIR"

echo -e "${COLOR_GREEN}═══════════════════════════════════════════════════════${COLOR_NC}"
echo -e "${COLOR_GREEN}  Proceso completado exitosamente${COLOR_NC}"
echo -e "${COLOR_GREEN}═══════════════════════════════════════════════════════${COLOR_NC}"
echo ""
echo "Archivos generados:"
echo "  📄 $CSV_DIR/reporte_caja.txt"
echo "  📊 $CSV_DIR/planilla_ingreso.csv (para LibreOffice)"
echo "  💾 efvo.csv (compatibilidad)"
echo ""

cd "$HOME"
