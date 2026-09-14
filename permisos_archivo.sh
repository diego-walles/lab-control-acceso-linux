#!/bin/bash
# permisos_archivo.sh  ->  Uso: ./permisos_archivo.sh <archivo>
# Imprime parejas (usuario, permisos) con el permiso EFECTIVO de cada usuario
# del sistema sobre el archivo, expandiendo el grupo a usuarios individuales.
archivo="$1"
[ -z "$archivo" ] && { echo "Uso: $0 <archivo>"; exit 1; }
[ ! -e "$archivo" ] && { echo "Error: el archivo '$archivo' no existe."; exit 1; }
propietario=$(stat -c '%U' "$archivo"); grupo=$(stat -c '%G' "$archivo")
gid_grupo=$(stat -c '%g' "$archivo")
octal=$(stat -c '%a' "$archivo"); octal=$(printf '%03d' "$(( 10#$octal % 1000 ))")
octal_a_rwx(){ local d=$1 r='-' w='-' x='-'; (( d & 4 )) && r='r'; (( d & 2 )) && w='w'; (( d & 1 )) && x='x'; printf '%s%s%s' "$r" "$w" "$x"; }
p_prop=$(octal_a_rwx "${octal:0:1}"); p_grup=$(octal_a_rwx "${octal:1:1}"); p_otro=$(octal_a_rwx "${octal:2:1}")
miembros_sup=" $(getent group "$grupo" | cut -d: -f4 | tr ',' ' ') "
echo "Archivo: $archivo (propietario=$propietario, grupo=$grupo, permisos=$octal $p_prop$p_grup$p_otro)"
echo "Lista (usuario, permisos):"
getent passwd | while IFS=: read -r usuario _ uid gid _ _ _; do
    if [ "$uid" -ne 0 ] && { [ "$uid" -lt 1000 ] || [ "$uid" -eq 65534 ]; }; then continue; fi
    if [ "$usuario" = "$propietario" ]; then perm=$p_prop
    elif [ "$gid" -eq "$gid_grupo" ] || [[ "$miembros_sup" == *" $usuario "* ]]; then perm=$p_grup
    else perm=$p_otro; fi
    [ "$perm" != "---" ] && echo "($usuario, $perm)"
done
