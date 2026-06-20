#!/usr/bin/env bash
# restore.sh — Restaura un backup de RippedAndRenew en un servidor nuevo
#
# Uso:
#   bash restore.sh <FECHA_BACKUP> [OPCIONES]
#
# Ejemplos:
#   bash restore.sh 2026-06-18
#   bash restore.sh 2026-06-18 --skip-db
#   bash restore.sh 2026-06-18 --ssh-key ~/.ssh/id_rsa
#
# El script espera que el servidor destino tenga:
#   - Docker y Docker Compose instalados
#   - Usuario ladmin con acceso sudo
#   - Puerto SSH 9922 abierto
#
# Variables de entorno opcionales:
#   BACKUP_BASE   ruta local al directorio de backups
#   SSH_HOST      host o IP del servidor destino
#   SSH_PORT      puerto SSH (default: 9922)
#   SSH_USER      usuario SSH (default: ladmin)
#   SSH_KEY       ruta a la clave SSH privada

set -euo pipefail

# ─── Configuración por defecto ────────────────────────────────────────────────
BACKUP_BASE="${BACKUP_BASE:-C:/Users/d3c0d3s/iCloudDrive/Documents/Projects/MirandasGroup/Backups/RippedAndRenew}"
SSH_HOST="${SSH_HOST:-dokploy.mirandasgroup.com}"
SSH_PORT="${SSH_PORT:-9922}"
SSH_USER="${SSH_USER:-ladmin}"
SSH_KEY="${SSH_KEY:-}"
REMOTE_DIR="/etc/dokploy/compose/rippedandrenew-wger/code"
COMPOSE_PROJECT="rippedandrenew-wger"
COMPOSE_FILE="docker-compose.prod.dokploy.yml"

SKIP_DB=false
SKIP_MEDIA=false

# ─── Argumentos ───────────────────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
  echo "Uso: bash restore.sh <FECHA_BACKUP> [--skip-db] [--skip-media] [--ssh-key RUTA]"
  echo "Ejemplo: bash restore.sh 2026-06-18"
  exit 1
fi

BACKUP_DATE="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-db)    SKIP_DB=true ;;
    --skip-media) SKIP_MEDIA=true ;;
    --ssh-key)    SSH_KEY="$2"; shift ;;
    --host)       SSH_HOST="$2"; shift ;;
    --port)       SSH_PORT="$2"; shift ;;
    --user)       SSH_USER="$2"; shift ;;
    *) echo "Opción desconocida: $1"; exit 1 ;;
  esac
  shift
done

BACKUP_DIR="${BACKUP_BASE}/${BACKUP_DATE}"
PUBLIC_DIR="${BACKUP_DIR}/wger-public"
PRIVATE_DIR="${BACKUP_DIR}/rnr-private"

# ─── Helpers ──────────────────────────────────────────────────────────────────
log()  { echo "[$(date '+%H:%M:%S')] $*"; }
ok()   { echo "[$(date '+%H:%M:%S')] ✓ $*"; }
err()  { echo "[$(date '+%H:%M:%S')] ✗ $*" >&2; exit 1; }

# Construir argumentos SSH
SSH_ARGS="-o StrictHostKeyChecking=no -p ${SSH_PORT}"
[[ -n "$SSH_KEY" ]] && SSH_ARGS="${SSH_ARGS} -i ${SSH_KEY}"
[[ -n "${SSH_AUTH_SOCK:-}" ]] && export SSH_AUTH_SOCK

ssh_run()  { ssh ${SSH_ARGS} "${SSH_USER}@${SSH_HOST}" "$@"; }
scp_send() { scp -P "${SSH_PORT}" ${SSH_KEY:+-i "$SSH_KEY"} "$@"; }

# ─── Validaciones ─────────────────────────────────────────────────────────────
log "Verificando backup local: ${BACKUP_DIR}"
[[ -d "$BACKUP_DIR" ]]   || err "Directorio de backup no encontrado: ${BACKUP_DIR}"
[[ -d "$PUBLIC_DIR" ]]   || err "Subcarpeta wger-public no encontrada"
[[ -d "$PRIVATE_DIR" ]]  || err "Subcarpeta rnr-private no encontrada"

[[ -f "${PUBLIC_DIR}/${COMPOSE_FILE}" ]]      || err "No se encontró ${COMPOSE_FILE}"
[[ -f "${PUBLIC_DIR}/config/nginx.conf" ]]    || err "No se encontró nginx.conf"
[[ -f "${PRIVATE_DIR}/config/prod.env" ]]     || err "No se encontró prod.env"

log "Conectando al servidor ${SSH_HOST}:${SSH_PORT}..."
ssh_run "echo 'Conexión OK'" || err "No se pudo conectar al servidor"
ok "Conexión SSH establecida"

# ─── 1. Crear directorios remotos ─────────────────────────────────────────────
log "Creando directorios remotos..."
ssh_run "
  mkdir -p ${REMOTE_DIR}/config
  mkdir -p ${REMOTE_DIR}/services/config-powersync
"
ok "Directorios creados"

# ─── 2. Subir archivos de configuración ───────────────────────────────────────
log "Subiendo archivos de configuración..."

scp_send \
  "${PUBLIC_DIR}/${COMPOSE_FILE}" \
  "${SSH_USER}@${SSH_HOST}:${REMOTE_DIR}/"

scp_send \
  "${PUBLIC_DIR}/config/nginx.conf" \
  "${SSH_USER}@${SSH_HOST}:${REMOTE_DIR}/config/"

scp_send \
  "${PRIVATE_DIR}/config/prod.env" \
  "${SSH_USER}@${SSH_HOST}:${REMOTE_DIR}/config/"

if [[ -f "${PUBLIC_DIR}/services/config-powersync/powersync.yaml" ]]; then
  scp_send \
    "${PUBLIC_DIR}/services/config-powersync/powersync.yaml" \
    "${PUBLIC_DIR}/services/config-powersync/sync_rules.yaml" \
    "${SSH_USER}@${SSH_HOST}:${REMOTE_DIR}/services/config-powersync/"
fi

ssh_run "
  chmod 600 ${REMOTE_DIR}/config/prod.env
"
ok "Archivos subidos"

# ─── 3. Crear redes Docker ────────────────────────────────────────────────────
log "Creando redes Docker..."
ssh_run "
  docker network create rippedandrenew-wger 2>/dev/null || echo 'Red rippedandrenew-wger ya existe'
  docker network inspect dokploy-network >/dev/null 2>&1 || docker network create dokploy-network
"
ok "Redes listas"

# ─── 4. Levantar servicios ────────────────────────────────────────────────────
log "Levantando servicios (esto puede tardar ~5 min en primer inicio)..."
ssh_run "
  cd ${REMOTE_DIR}
  docker compose -p ${COMPOSE_PROJECT} -f ${COMPOSE_FILE} up -d
"
ok "Servicios iniciados"

# ─── 5. Esperar a que db esté healthy ─────────────────────────────────────────
if [[ "$SKIP_DB" == false ]]; then
  DB_DUMP="${PRIVATE_DIR}/db/wger_dump.sql"

  if [[ ! -f "$DB_DUMP" ]]; then
    log "AVISO: No se encontró dump de base de datos en ${DB_DUMP} — omitiendo restauración de DB"
    SKIP_DB=true
  else
    log "Esperando a que PostgreSQL esté healthy..."
    RETRIES=30
    until ssh_run "docker exec ${COMPOSE_PROJECT}-db-1 pg_isready -U wger" >/dev/null 2>&1 || [[ $RETRIES -eq 0 ]]; do
      sleep 5
      RETRIES=$((RETRIES - 1))
      echo -n "."
    done
    echo ""
    [[ $RETRIES -eq 0 ]] && err "PostgreSQL no respondió a tiempo"
    ok "PostgreSQL healthy"
  fi
fi

# ─── 6. Restaurar base de datos ───────────────────────────────────────────────
if [[ "$SKIP_DB" == false ]]; then
  log "Restaurando base de datos..."
  DB_DUMP="${PRIVATE_DIR}/db/wger_dump.sql"

  # Subir dump al servidor y restaurar
  scp_send "$DB_DUMP" "${SSH_USER}@${SSH_HOST}:/tmp/wger_dump.sql"

  ssh_run "
    docker exec -i ${COMPOSE_PROJECT}-db-1 psql -U wger -d wger < /tmp/wger_dump.sql
    rm /tmp/wger_dump.sql
  "
  ok "Base de datos restaurada"
fi

# ─── 7. Restaurar archivos media ──────────────────────────────────────────────
if [[ "$SKIP_MEDIA" == false ]]; then
  MEDIA_ARCHIVE="${PRIVATE_DIR}/media/media.tar.gz"

  if [[ ! -f "$MEDIA_ARCHIVE" ]]; then
    log "AVISO: No se encontró media.tar.gz — omitiendo restauración de media"
  else
    log "Restaurando archivos media..."
    scp_send "$MEDIA_ARCHIVE" "${SSH_USER}@${SSH_HOST}:/tmp/media.tar.gz"
    ssh_run "
      docker exec ${COMPOSE_PROJECT}-web-1 bash -c 'tar -xzf /tmp/media.tar.gz -C / 2>/dev/null || true'
      rm /tmp/media.tar.gz
    "
    ok "Media restaurada"
  fi
fi

# ─── 8. Verificación final ────────────────────────────────────────────────────
log "Verificando estado de contenedores..."
ssh_run "docker ps --format 'table {{.Names}}\t{{.Status}}' | grep ${COMPOSE_PROJECT}"

echo ""
echo "════════════════════════════════════════════════════"
ok "Restauración completada desde backup ${BACKUP_DATE}"
echo ""
echo "Próximos pasos manuales (ver DEPLOY_GUIDE.md §9):"
echo "  1. Cambiar contraseña admin wger"
echo "  2. Crear usuario powersync_storage en PostgreSQL"
echo "  3. Regenerar JWT keys y actualizar prod.env"
echo "════════════════════════════════════════════════════"
