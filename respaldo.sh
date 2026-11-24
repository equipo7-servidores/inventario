#!/usr/bin/env bash
# ============================================================
#  respaldo.sh - Respaldo lógico de la base de datos "inventario"
#  Sistema de Inventario Tecnológico - Clínica Veterinaria Pata Verde
#
#  Uso (desde cualquier carpeta):
#     ~/inventario/respaldo.sh
#  Genera ~/respaldos/inventario_AAAA-MM-DD_HHMM.sql, fuera del
#  proyecto y del volumen de MySQL. El respaldo NO se sube a Git.
#
#  Restauración:
#     cd ~/inventario
#     docker compose exec -T db sh -c 'mysql -u root -p"$MYSQL_ROOT_PASSWORD"' < ~/respaldos/ARCHIVO.sql
# ============================================================
set -euo pipefail

PROYECTO="$(cd "$(dirname "$0")" && pwd)"
DESTINO="${HOME}/respaldos"
ARCHIVO="${DESTINO}/inventario_$(date +%F_%H%M).sql"

mkdir -p "$DESTINO"
cd "$PROYECTO"

# mysqldump se ejecuta dentro del contenedor db; la contraseña se lee de su
# propia variable de entorno y el aviso de la contraseña no entra al archivo.
docker compose exec -T db sh -c \
  'mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" --databases inventario 2>/dev/null' > "$ARCHIVO"

if [ ! -s "$ARCHIVO" ] || ! head -n 1 "$ARCHIVO" | grep -q "MySQL dump"; then
  echo "ERROR: el respaldo no se generó correctamente: $ARCHIVO" >&2
  rm -f "$ARCHIVO"
  exit 1
fi

echo "Respaldo generado: $ARCHIVO ($(du -h "$ARCHIVO" | cut -f1))"
echo "Equipos en el respaldo: $(grep -o "),(" "$ARCHIVO" | wc -l | awk '{print $1+1}')"
