# 📋 Plan de Migración - Sh → Sh_update

Este documento rastrea la migración de scripts desde el repositorio original (`Sh/`) al repositorio público limpio (`Sh_update/`).

---

## 🎯 Objetivo

Crear un repositorio público con versiones refinadas y documentadas de los scripts, manteniendo el repositorio original como histórico privado.

---

## 📊 Estado de Migración

### ✅ Completados

- [x] **Inicialización del repositorio**
  - Git init
  - README.md básico
  - .gitignore configurado
  - Commits: 3

- [x] **Módulo gestion_caja** ✅
  - caja.sh (análisis completo)
  - config.sh (detección de rutas)
  - README.md (12KB documentación)
  - INTEGRACION_CAJADIARIA.md
  - Estado: 100% funcional
  - Commit: `4bdfd2c`

### 🔄 Pendientes

- [ ] **Módulo gestion_csv**
  - borrar.sh
  - planilla.sh
  - **reserva.sh** ← Próximo a refinar/modularizar
  - config.sh
  - test_portabilidad.sh
  - README.md
  - MIGRACION.md

- [ ] **Módulo apagado_automatico**
  - apagar.sh
  - modo_libre.sh
  - modo_laboral.sh
  - test_apagar.sh
  - README.md

- [ ] **README.md principal**
  - Documentación general del repositorio
  - Guías de instalación
  - Índice de módulos

- [ ] **Scripts individuales**
  - app_sigs.sh (pendiente análisis)

---

## 🗓️ Roadmap

### Sesión Actual (04/02/2026)
- ✅ Crear repositorio Sh_update
- ✅ Configurar .gitignore
- ✅ Migrar gestion_caja completo

### Próxima Sesión
- [ ] **Revisar y refinar reserva.sh**
  - Posible creación de módulo `gestion_reservas/` independiente
  - Mejorar funcionalidad
  - Documentar completamente
  
- [ ] Decidir estructura modular vs integrada para gestion_csv

### Futuras Sesiones
- [ ] Migrar apagado_automatico
- [ ] Migrar resto de gestion_csv
- [ ] Crear README.md principal completo
- [ ] Configurar repositorio remoto (GitHub)
- [ ] Primer push público

---

## 🏗️ Estructura Propuesta Final

```
Sh_update/
├── README.md                   # Documentación principal
├── .gitignore                  # Archivos ignorados
├── PLAN.md                     # Este archivo
│
├── apagado_automatico/         # Módulo 1: Apagado automático
│   ├── apagar.sh
│   ├── modo_libre.sh
│   ├── modo_laboral.sh
│   ├── test_apagar.sh
│   └── README.md
│
├── gestion_caja/               # Módulo 2: Análisis de caja ✅
│   ├── caja.sh
│   ├── config.sh
│   ├── README.md
│   └── INTEGRACION_CAJADIARIA.md
│
├── gestion_reservas/           # Módulo 3: Gestión de reservas (propuesto)
│   ├── reserva.sh
│   ├── config.sh
│   └── README.md
│
└── gestion_csv/                # Módulo 4: Utilidades CSV generales
    ├── borrar.sh
    ├── planilla.sh
    ├── config.sh
    ├── test_portabilidad.sh
    ├── README.md
    └── MIGRACION.md
```

---

## 🔧 Convenciones de Commits

Usar **Conventional Commits** para claridad:

- `feat:` - Nueva funcionalidad
- `fix:` - Corrección de bugs
- `docs:` - Cambios en documentación
- `refactor:` - Refactorización de código
- `test:` - Agregar o modificar tests
- `chore:` - Tareas de mantenimiento

### Ejemplos:
```bash
git commit -m "feat: Add módulo gestion_caja completo"
git commit -m "docs: Update README with installation guide"
git commit -m "refactor: Separate reserva.sh into independent module"
```

---

## 📝 Notas de Migración

### Cambios Respecto al Original

1. **Modularización:**
   - Scripts agrupados por funcionalidad
   - Cada módulo independiente y documentado

2. **Documentación:**
   - README.md por módulo
   - Documentos de integración (INTEGRACION_CAJADIARIA.md)
   - Guías de migración (MIGRACION.md)

3. **Portabilidad:**
   - Detección automática de sistema (WSL/Ubuntu)
   - config.sh centralizado
   - Scripts de testing incluidos

4. **Archivos excluidos:**
   - CSVs de datos (sensibles/temporales)
   - Logs y outputs
   - Archivos de respaldo

---

## 🚀 Cuando esté listo para GitHub

```bash
# 1. Crear repositorio en GitHub (web)
# 2. Conectar local con remoto
cd /mnt/c/Users/xpabl/OneDrive/Escritorio/Sh_update
git remote add origin https://github.com/USUARIO/Sh_update.git

# 3. Push inicial
git branch -M main
git push -u origin main

# 4. Futuros commits
git add .
git commit -m "feat: descripción del cambio"
git push
```

---

## 🎓 Decisiones Pendientes

### ¿reserva.sh como módulo independiente?

**Opción A: Módulo `gestion_reservas/`**
- ✅ Independencia total
- ✅ Escalable (agregar más funcionalidades de reservas)
- ❌ Más directorios

**Opción B: Mantener en `gestion_csv/`**
- ✅ Agrupación lógica (procesamiento CSV)
- ✅ Menos estructura
- ❌ Menos enfoque específico

**Decisión:** Pendiente para próxima sesión

---

**Última actualización:** 04 de Febrero de 2026  
**Commits totales:** 3  
**Módulos migrados:** 1/4  
**Estado:** 🟢 En progreso activo
