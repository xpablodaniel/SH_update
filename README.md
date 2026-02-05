# 🏨 Scripts de Gestión Hotelera - Sh_update

Sistema modular de automatización para gestión operativa hotelera en Ubuntu/WSL.

## 📦 Módulos Disponibles

### ✅ Módulo apagado_automatico (v1.0)
Sistema de apagado automático programado con switch de días libres/laborales.
- Apagado programado con aviso previo (5 minutos)
- Control simple mediante archivos de estado
- Modo libre/laboral sin editar crontab
- Logging automático de eventos
- [Ver documentación completa →](apagado_automatico/README.md)

### ✅ Módulo gestion_caja (v1.0)
Análisis completo de movimientos de caja diaria.
- Extracción automática de datos desde imágenes
- Validación de cálculos
- Generación de informes con estadísticas
- [Ver documentación completa →](gestion_caja/README.md)

### ✅ Módulo gestion_reservas (v1.0)
Procesamiento de reservas del gestor hotelero.
- Parser CSV robusto (maneja comas en campos)
- Normalización automática a MAYÚSCULAS
- Búsqueda individual por voucher/DNI/apellido
- Exportación optimizada para LibreOffice
- [Ver documentación completa →](gestion_reservas/README.md)

### 🔄 Módulos Pendientes
- **gestion_csv/** - Utilidades CSV adicionales

---

## 🚀 Inicio Rápido

### Apagado Automático
```bash
cd apagado_automatico/

# Activar/desactivar apagado
./modo_libre.sh       # Desactivar (día libre)
./modo_laboral.sh     # Activar (día laboral)

# Ver estado
./apagar.sh -s
```

### Gestión de Caja
```bash
cd gestion_caja/
./caja.sh
```

### Gestión de Reservas
```bash
cd gestion_reservas/

# Procesar todas las reservas
./reservas.sh

# Buscar reserva específica
./buscar_reserva.sh -v 123456789      # Por voucher
./buscar_reserva.sh -d 12345678       # Por DNI
./buscar_reserva.sh -a APELLIDO       # Por apellido
./buscar_reserva.sh -v 123456789 -D   # Con detalle completo
```

---

## 📋 Requisitos

- **Sistema Operativo**: Ubuntu 20.04+ o WSL2
- **Shell**: Bash 4.0+
- **Herramientas**: AWK, grep, sed (incluidos por defecto)
- **Opcional**: LibreOffice Calc (para abrir resultados)

---

## 📁 Estructura del Proyecto

```
Sh_update/
├── README.md                  # Este archivo
├── PLAN.md                    # Roadmap del proyecto
├── .gitignore                 # Archivos ignorados
│
├── apagado_automatico/        # Módulo 1: Apagado automático ✅
│   ├── apagar.sh
│   ├── modo_libre.sh
│   ├── modo_laboral.sh
│   ├── config.sh
│   └── README.md
│
├── gestion_caja/              # Módulo 2: Análisis de caja ✅
│   ├── caja.sh
│   ├── config.sh
│   ├── README.md
│   └── INTEGRACION_CAJADIARIA.md
│
└── gestion_reservas/          # Módulo 3: Gestión de reservas ✅
    ├── config.sh
    ├── parser.sh
    ├── reservas.sh
    ├── buscar_reserva.sh
    └── README.md
```

---

## 🔐 Privacidad y Datos

Este repositorio **NO contiene datos reales de pasajeros**. Todos los ejemplos en la documentación usan datos ficticios.

**Para uso en producción:**
- Los archivos CSV con datos reales deben almacenarse en `~/Descargas/` (no se versionan)
- Configurar `.gitignore` para excluir archivos sensibles
- Nunca commitear datos personales al repositorio

---

## 📝 Licencia

Uso interno - Gestión hotelera

---

## 👤 Autor

Sistema desarrollado para automatización de tareas hoteleras operativas.

**Última actualización:** 05/02/2026  
**Versión:** 1.0

