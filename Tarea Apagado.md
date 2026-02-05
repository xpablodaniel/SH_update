# 🗂️ Programar Tarea de Apagado Automático con Switch de Días Libres

## 🎯 Objetivo

Implementar un sistema de apagado automático en equipos Linux a las 03:00 AM, con aviso previo a los usuarios, y con la posibilidad de **desactivar el apagado en días libres** sin necesidad de editar el crontab.

## 🧩 1\. Estructura de archivos

´´´Code  
**/home/usuario/DockerExe/**  
**│**  
**├── apagar.sh        \# Script principal de apagado**  
**└── dia\_libre        \# Archivo-switch para activar/desactivar apagado**

## 🧩 2\. Archivo-switch: `dia_libre`

Este archivo controla si el apagado debe ejecutarse o no.

Valores posibles:

* `ON`  → Día libre (NO se apaga)  
* `OFF` → Día laboral (SÍ se apaga)

Ejemplos de uso:

´´´bash  
**echo ON \> /home/usuario/DockerExe/dia\_libre     \# Desactiva apagado**  
**echo OFF \> /home/usuario/DockerExe/dia\_libre    \# Activa apagado**

# 

# 

# 

## 🧩 3\. Script principal: `apagar.sh`

´´´bash  
**\#\!/bin/bash**

**FLAG="/home/usuario/DockerExe/dia\_libre"**  
**MSG="ATENCIÓN: La computadora se apagará en 5 minutos. Guarda tu trabajo."**

**\# Si el archivo indica día libre, no se ejecuta el apagado**  
**if \[ \-f "$FLAG" \] && grep \-q "ON" "$FLAG"; then**  
    **echo "Día libre detectado. No se ejecuta apagado automático." | wall**  
    **exit 0**  
**fi**

**\# Aviso global**  
**echo "$MSG" | wall**

**\# Apagado en 5 minutos**  
**/sbin/shutdown \-h \+5**

Dar permisos:

´´´bash  
**chmod \+x /home/usuario/DockerExe/apagar.sh**

## 🧩 4\. Programación en `crontab`

Para que el apagado ocurra a las **03:00**, el script debe ejecutarse a las **02:55**:

´´´Code  
**55 2 \* \* \* /home/usuario/DockerExe/apagar.sh**

Este cron **no se toca nunca más**.

El control queda totalmente delegado al archivo `dia_libre`.

## 🧩 5\. Flujo de funcionamiento

1. Cron ejecuta `apagar.sh` todos los días a las 02:55.  
2. El script revisa el archivo `dia_libre`.  
3. Si dice `ON` → envía aviso y **no apaga**.  
4. Si dice `OFF` → envía aviso y **apaga en 5 minutos**.  
5. Los usuarios reciben el mensaje vía `wall`.

# 

## 🧩 6\. Ventajas de esta solución

* No requiere editar el crontab.  
* Fácil de activar/desactivar con un solo comando.  
* Compatible con entornos multiusuario.  
* Aviso garantizado gracias a `wall`.  
* Escalable a otros equipos del hotel.  
* Ideal para días libres irregulares.

## 🧩 7\. Sugerencia para tu repo `Sh`

Podés agregar un archivo `README.md` con esta documentación y un pequeño script auxiliar tipo:

´´´Code  
**modo libre**  
**modo laboral**

