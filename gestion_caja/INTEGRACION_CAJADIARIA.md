# 🔗 Integración con Proyecto cajaDiaria

Documentación de la integración entre el script `caja.sh` y el repositorio remoto [cajaDiaria](https://github.com/xpablodaniel/cajaDiaria).

---

## 🎯 Objetivo

Unificar las funcionalidades de análisis de caja del repositorio local Bash con el proyecto web/Python del repositorio remoto, manteniendo compatibilidad de formatos y extendiendo capacidades.

---

## 📦 Comparación de Proyectos

### Repositorio Local: gestion_csv/caja.sh

**Tecnología:** Bash + AWK  
**Entorno:** Terminal (WSL/Ubuntu)  
**Fortalezas:**
- ✅ Rápido y ligero
- ✅ Sin dependencias externas
- ✅ Integrado con flujo diario de scripts
- ✅ Portable entre sistemas Unix

**Funcionalidades:**
- Análisis por medio de pago (Efectivo, Débito, Crédito, Transferencia)
- Estadísticas por usuario/cajero
- Reporte de texto detallado
- **NUEVO:** Exportación a CSV para LibreOffice

### Repositorio Remoto: cajaDiaria

**Tecnología:** HTML/JavaScript + Python  
**Entorno:** Navegador Web + CLI  
**Fortalezas:**
- ✅ Interfaz visual amigable
- ✅ Parser CSV robusto
- ✅ Impresión formateada
- ✅ Doble implementación (Web + CLI)

**Funcionalidades:**
- Carga de CSV desde navegador
- Cálculo de totales
- Descarga de planilla_ingreso.csv
- Vista de impresión HTML
- Script Python para automatización

---

## 🔄 Integración Implementada

### Formato de Salida Unificado

Ambos proyectos ahora generan `planilla_ingreso.csv` con el mismo formato:

```csv
Nro. recibo,Fecha recibo,Nombre,Nota crédito,Referencia,Lote,Cupon,Importe,Medio de cobranza,Usuario alta
```

**Características:**
- Columnas en orden específico para LibreOffice
- Datos en orden inverso (más recientes primero)
- Campos vacíos para Lote y Cupón (reservados)
- Escape correcto de comillas y comas

### Flujos de Trabajo Compatibles

#### Flujo 1: Terminal (caja.sh)
```bash
cd gestion_csv/
./caja.sh
# Genera: reporte_caja.txt + planilla_ingreso.csv
```

#### Flujo 2: Navegador (cajaDiaria.html)
```
1. Abrir cajaDiaria.html en navegador
2. Cargar CSV
3. Ver totales en pantalla
4. Descargar planilla_ingreso.csv
```

#### Flujo 3: Python CLI (rendicion_diaria.py)
```bash
python3 rendicion_diaria.py -i Reporte_Recibos.csv -o planilla_ingreso.csv
```

**Resultado:** Los tres métodos generan archivos compatibles entre sí.

---

## 📊 Casos de Uso

### Caso 1: Uso Diario en el Hotel

**Escenario:** Procesamiento rápido en terminal Ubuntu  
**Script:** `caja.sh` (local)

```bash
# Rutina diaria
./borrar.sh                  # Limpiar CSVs antiguos
# Descargar Reporte_Recibos.csv del sistema externo
./caja.sh                    # Procesar y generar reportes
```

**Salida:**
- Terminal: Totales por medio de pago y usuario
- Archivo: reporte_caja.txt (para registros)
- Archivo: planilla_ingreso.csv (para LibreOffice)

### Caso 2: Revisión Visual por Gerencia

**Escenario:** Usuario no técnico necesita ver y verificar datos  
**Script:** `cajaDiaria.html` (remoto)

```
1. Abrir cajaDiaria.html en navegador
2. Arrastrar y soltar Reporte_Recibos.csv
3. Ver totales inmediatamente
4. Imprimir planilla formateada
5. Descargar CSV para análisis adicional
```

### Caso 3: Automatización Nocturna

**Escenario:** Cron job que procesa CSVs automáticamente  
**Script:** `rendicion_diaria.py` (remoto) o `caja.sh` (local)

```bash
# Crontab
0 4 * * * /path/to/caja.sh >> /var/log/caja_diaria.log 2>&1
```

---

## 🛠️ Diferencias Técnicas

### Parsing de CSV

**caja.sh:**
```bash
# AWK procesa línea por línea
awk -F',' '{...}' archivo.csv
```
- Rápido y simple
- Funciona bien con CSVs sin comillas complejas

**cajaDiaria.html:**
```javascript
// Parser robusto que maneja comillas y escape
function parseCSV(text) {
  // Maneja: campos entre comillas, comillas escapadas, comas internas
}
```
- Más robusto
- Maneja casos edge

### Formato de Importes

**Ambos soportan:**
- `1234.56` (punto decimal)
- `1.234,56` (coma decimal europea)
- `1234,56` (coma decimal)
- `$1,234.56` (con símbolo)

**caja.sh:**
```bash
# AWK procesa números directamente
awk '{sum+=$6}'
```

**cajaDiaria:**
```javascript
function parseAmount(str) {
  // Normaliza formato y convierte a float
  s = s.replace(/[$€\s]/g, '');
  // ... lógica de conversión
}
```

---

## 📈 Ventajas de Cada Enfoque

### caja.sh (Bash) - Local

**Cuándo usar:**
- ✅ Flujo de trabajo ya establecido en terminal
- ✅ Integración con otros scripts del sistema
- ✅ Rapidez (sin iniciar navegador)
- ✅ Automatización via cron
- ✅ Análisis adicional por usuario

**Fortalezas únicas:**
- Resumen por usuario/cajero
- Reporte de texto para logs
- Sin dependencias (solo herramientas Unix)
- Portable WSL/Ubuntu automáticamente

### cajaDiaria (Web/Python) - Remoto

**Cuándo usar:**
- ✅ Usuarios no técnicos
- ✅ Revisión visual inmediata
- ✅ Impresión formateada necesaria
- ✅ Drag & drop de archivos
- ✅ Sin instalación requerida (HTML)

**Fortalezas únicas:**
- Interfaz visual amigable
- Vista de impresión HTML
- Logo y branding
- Previsualización de datos
- Doble implementación (web + Python)

---

## 🔧 Mantenimiento y Sincronización

### Mantener Compatibilidad

Para que ambos proyectos generen archivos compatibles:

1. **Mismo orden de columnas:**
   ```
   Nro. recibo, Fecha recibo, Nombre, Nota crédito, 
   Referencia, Lote, Cupon, Importe, Medio de cobranza, 
   Usuario alta
   ```

2. **Mismo encoding:** UTF-8

3. **Misma convención de escape:** Comillas dobles para campos con comas

4. **Mismo orden de datos:** Inverso (más reciente primero)

### Testing Cruzado

Verificar compatibilidad:

```bash
# 1. Generar con caja.sh
cd gestion_csv/
./caja.sh

# 2. Verificar formato
head -3 /path/Downloads/planilla_ingreso.csv

# 3. Abrir en LibreOffice
libreoffice --calc /path/Downloads/planilla_ingreso.csv

# 4. Comparar con salida de cajaDiaria.html (si disponible)
diff planilla_bash.csv planilla_web.csv
```

---

## 🚀 Mejoras Futuras

### Para caja.sh (Local)

- [ ] Opción `--html` para generar vista de impresión
- [ ] Gráficos de resumen (ASCII art o gnuplot)
- [ ] Exportar a formato ODS directo
- [ ] Validación de datos de entrada

### Para Integración

- [ ] API REST compartida (Flask/FastAPI)
- [ ] Base de datos común (SQLite)
- [ ] Sincronización de configuración
- [ ] Dashboard unificado

---

## 📚 Referencias

### Repositorios

- **Local:** `/mnt/c/Users/xpabl/OneDrive/Escritorio/Sh/gestion_csv/`
- **Remoto:** https://github.com/xpablodaniel/cajaDiaria

### Documentación

- [README.md local](README.md) - Documentación completa del módulo gestion_csv
- [README.md remoto](https://github.com/xpablodaniel/cajaDiaria/blob/main/README.md) - Documentación del proyecto cajaDiaria

---

## 🎓 Lecciones Aprendidas

### Buenas Prácticas

1. **Formatos estándar:** Usar CSV estándar facilita integración
2. **Documentación clara:** Especificar formato de entrada/salida
3. **Ejemplos de datos:** Incluir CSVs de muestra
4. **Múltiples interfaces:** CLI + Web cubre más usuarios
5. **Compatibilidad:** Mantener mismo formato de salida

### Arquitectura

- **Separación de responsabilidades:** Parsing vs Cálculo vs Presentación
- **Reutilización:** Lógica compartida entre implementaciones
- **Testing:** Verificar con datos reales
- **Portabilidad:** Considerar diferentes entornos desde el inicio

---

## ✅ Checklist de Compatibilidad

Verificar antes de cada release:

- [ ] Orden de columnas idéntico
- [ ] Formato de fecha consistente
- [ ] Escape de caracteres especiales
- [ ] Encoding UTF-8
- [ ] Totales calculados correctamente
- [ ] Archivo abre en LibreOffice sin errores
- [ ] Datos en orden inverso (más recientes primero)

---

**Última actualización:** 04 de Febrero de 2026  
**Versión caja.sh:** 2.1 (con exportación LibreOffice)  
**Repositorio remoto:** cajaDiaria (HTML/JS + Python)  
**Estado:** ✅ Integración completada y funcional
