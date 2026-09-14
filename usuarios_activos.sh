#!/bin/bash
# usuarios_activos.sh -> usuarios con sesion activa o procesos en ejecucion.
echo "=== Usuarios con sesion activa (who) ==="
who | awk '{print $1}' | sort -u
echo; echo "=== Usuarios ejecutando procesos (ps) ==="
ps -eo user= | sort -u
echo; echo "=== Union: usuarios con actividad en el sistema ==="
{ who | awk '{print $1}'; ps -eo user=; } | sort -u
