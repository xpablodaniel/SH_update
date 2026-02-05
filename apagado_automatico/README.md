# ⏰ Apagado Automático

Sistema de apagado automático programado para equipos Linux con soporte para días libres/laborales mediante switch simple.

## 📝 Descripción

Módulo para programar apagados automáticos de equipos con aviso previo a usuarios y control flexible mediante archivo de estado, sin necesidad de editar crontab.

## 📂 Estructura

```
apagado_automatico/
├── config.sh         # Configuración (rutas, tiempos, mensajes)
├── apagar.sh         # Script principal de apagado
├── modo_libre.sh     # Activar día libre (NO apaga)
├── modo_laboral.sh   # Activar día laboral (SÍ apaga)
├── dia_libre         # Archivo de estado (ON/OFF)
├── apagado.log       # Log de eventos
└── README.md         # Este archivo
```

## 🚀 Uso Rápido

### Cambiar entre modos

```bash
cd apagado_automatico/

# Desactivar apagado automático (día libre)
./modo_libre.sh

# Activar apagado automático (día laboral)
./modo_laboral.sh
```

### Ejecutar manualmente

```bash
# Verificar estado actual
./apagar.sh -s

# Ejecutar verificación y apagado
./apagar.sh

# Modo prueba (no ejecuta apagado real)
./apagar.sh -t

# Cancelar apagado programado
./apagar.sh -c

# Ver ayuda
./apagar.sh -h
```

## ⚙️ Instalación

### 1. Dar permisos de ejecución

```bash
chmod +x *.sh
```

### 2. Programar en crontab

Para ejecutar a las **03:00** con aviso de 5 minutos (ejecución a las 02:55):

```bash
crontab -e
```

Agregar:
```
55 2 * * * /ruta/completa/apagado_automatico/apagar.sh
```

**Ejemplo**:
```
55 2 * * * /home/usuario/Sh_update/apagado_automatico/apagar.sh
```

### 3. Verificar instalación

```bash
./apagar.sh -s
```

## 🎯 Flujo de Funcionamiento

```
┌─────────────────────────────────────────┐
│  Cron ejecuta apagar.sh a las 02:55    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Script verifica archivo "dia_libre"    │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴───────┐
       │               │
       ▼               ▼
    ON (Libre)     OFF (Laboral)
       │               │
       │               ▼
       │      ┌─────────────────┐
       │      │ Envía aviso     │
       │      │ (wall + notify) │
       │      └────────┬────────┘
       │               │
       │               ▼
       │      ┌─────────────────┐
       │      │ Apaga en 5 min  │
       │      │ (shutdown -h +5)│
       │      └─────────────────┘
       │
       ▼
┌──────────────────┐
│ No hace nada     │
│ (modo día libre) │
└──────────────────┘
```

## 📋 Configuración

### Archivo: config.sh

Personalizar según necesidades:

```bash
# Tiempo de aviso antes del apagado (minutos)
TIEMPO_AVISO=5

# Mensaje de aviso a usuarios
MSG_AVISO="⚠️  ATENCIÓN: La computadora se apagará en 5 minutos..."

# Activar/desactivar notificaciones
USAR_WALL=true        # Mensajes en terminal
USAR_NOTIFY=true      # Notificaciones de escritorio
```

### Archivo de estado: dia_libre

```bash
# Ver estado actual
cat dia_libre

# Manual: Activar día libre
echo ON > dia_libre

# Manual: Activar día laboral
echo OFF > dia_libre
```

## 🧪 Modo Prueba

Para probar sin ejecutar apagado real:

```bash
./apagar.sh -t
```

**Salida esperada**:
```
═══════════════════════════════════════════════════════════
  🕐 SISTEMA DE APAGADO AUTOMÁTICO
═══════════════════════════════════════════════════════════
Fecha/Hora:        2026-02-05 14:30:00
Estado actual:     OFF
Modo:              💼 DÍA LABORAL (Apaga)
Tiempo de aviso:   5 minutos
═══════════════════════════════════════════════════════════

🧪 MODO PRUEBA: No se ejecutará apagado real
```

## 💡 Casos de Uso

### Escenario 1: Fin de semana largo

```bash
# Viernes por la tarde
cd apagado_automatico/
./modo_libre.sh

# Lunes por la mañana
./modo_laboral.sh
```

### Escenario 2: Feriado inesperado

```bash
# Desde cualquier terminal
cd /ruta/a/apagado_automatico && ./modo_libre.sh
```

### Escenario 3: Cancelar apagado de emergencia

Si se programó un apagado y necesitás cancelarlo:

```bash
./apagar.sh -c
# O directamente:
sudo shutdown -c
```

### Escenario 4: Múltiples equipos

Usar el mismo módulo en varios equipos:

```bash
# En cada equipo
git clone https://github.com/usuario/Sh_update.git
cd Sh_update/apagado_automatico
chmod +x *.sh
crontab -e  # Agregar la línea con la ruta local
```

## 📊 Monitoreo

### Ver log de eventos

```bash
tail -f apagado.log
```

**Ejemplo de log**:
```
[2026-02-05 02:55:00] Día laboral detectado - Iniciando secuencia de apagado
[2026-02-05 02:55:01] Aviso de apagado enviado - 5 minutos restantes
[2026-02-05 02:55:02] Apagado programado exitosamente para +5 minutos
```

### Verificar próxima ejecución

```bash
# Ver crontab actual
crontab -l | grep apagar

# Ver si hay apagado programado
sudo shutdown -c 2>&1 | grep -i shutdown
```

## 🔧 Solución de Problemas

### Error: "shutdown: command not found"

```bash
# Verificar ubicación de shutdown
which shutdown

# Editar config.sh y ajustar:
SHUTDOWN_CMD="/usr/sbin/shutdown"  # o la ruta correcta
```

### No recibo notificaciones

```bash
# Verificar que wall está instalado
which wall

# Probar manualmente
echo "Prueba" | wall

# Para notify-send (opcional)
sudo apt install libnotify-bin
```

### El script no se ejecuta desde cron

```bash
# Verificar permisos
ls -la apagar.sh

# Verificar logs del sistema
sudo grep CRON /var/log/syslog | tail -20

# Usar ruta absoluta en crontab
# ❌ Incorrecto: 55 2 * * * ./apagar.sh
# ✅ Correcto:   55 2 * * * /home/usuario/Sh_update/apagado_automatico/apagar.sh
```

### Cambié a modo libre pero sigue queriendo apagar

```bash
# Verificar contenido del archivo
cat dia_libre

# Debe mostrar: ON
# Si no, ejecutar:
./modo_libre.sh

# Verificar que no haya apagados pendientes
sudo shutdown -c
```

## ⚡ Comandos Útiles

```bash
# Estado completo del sistema
./apagar.sh -s

# Cambiar a modo libre
./modo_libre.sh

# Cambiar a modo laboral
./modo_laboral.sh

# Probar sin ejecutar
./apagar.sh -t

# Cancelar apagado
./apagar.sh -c

# Ver últimos logs
tail -20 apagado.log

# Ver estado actual
cat dia_libre
```

## 🔐 Seguridad

### Permisos recomendados

```bash
# Scripts ejecutables solo por el propietario
chmod 700 *.sh

# Archivo de estado editable
chmod 644 dia_libre

# Log escribible
chmod 644 apagado.log
```

### Ejecución como root

El comando `shutdown` requiere permisos de administrador. Opciones:

**Opción 1: Crontab de root**
```bash
sudo crontab -e
55 2 * * * /ruta/completa/apagar.sh
```

**Opción 2: Sudo sin contraseña (solo para shutdown)**
```bash
sudo visudo
# Agregar:
usuario ALL=(ALL) NOPASSWD: /sbin/shutdown
```

## 📅 Integración con Otros Sistemas

### Activar modo libre desde script remoto

```bash
#!/bin/bash
ssh usuario@equipo1 "cd /ruta/apagado_automatico && ./modo_libre.sh"
ssh usuario@equipo2 "cd /ruta/apagado_automatico && ./modo_libre.sh"
```

### API REST simple (opcional)

Crear endpoint para cambiar modo vía web:

```bash
# Instalar
sudo apt install apache2

# Script CGI
#!/bin/bash
echo "Content-type: text/plain"
echo ""
cd /ruta/apagado_automatico
./modo_libre.sh
```

## 🆚 Comparación con Versión Anterior

| Característica | Versión Original | Versión Actual |
|---------------|------------------|----------------|
| Configuración | Hardcodeada | Modular (config.sh) |
| Logging | No | Sí (apagado.log) |
| Modo prueba | No | Sí (`-t`) |
| Ver estado | No | Sí (`-s`) |
| Cancelar | Manual | Automático (`-c`) |
| Validaciones | Básicas | Completas |
| Notificaciones | Solo wall | wall + notify-send |
| Ayuda | No | Sí (`-h`) |
| Portabilidad | Rutas fijas | Auto-detecta |

## 📝 Licencia

Uso interno - Gestión hotelera

## 👤 Autor

Sistema desarrollado para automatización de apagados programados.

**Última actualización:** 05/02/2026  
**Versión:** 1.0

---

**💡 Tip**: Para gestionar múltiples equipos, considera usar un script central que ejecute SSH a todos los equipos y cambie el modo simultáneamente.