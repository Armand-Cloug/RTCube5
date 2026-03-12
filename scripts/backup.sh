#!/bin/sh
# ─────────────────────────────────────────────────────────────────────────────
# RTCube5 – Sauvegarde automatique toutes les 30 minutes (ATM10)
# ─────────────────────────────────────────────────────────────────────────────

BACKUP_DIR="/backups"
DATA_DIR="/data"
RETENTION_DAYS=7
INTERVAL=1800

RCON_HOST="minecraft"
RCON_PORT="25575"
RCON_PASS="${RCON_PASSWORD:-changeme}"

apk add --no-cache rcon-cli tar gzip > /dev/null 2>&1

rcon() {
    rcon-cli \
        --host "${RCON_HOST}" \
        --port "${RCON_PORT}" \
        --password "${RCON_PASS}" \
        "$1" 2>/dev/null || true
}

echo "✅ Service de sauvegarde RTCube5 (ATM10) démarré"
echo "   Intervalle : 30 minutes | Rétention : ${RETENTION_DAYS} jours"

# ATM10 met très longtemps à démarrer, on attend bien plus longtemps
echo "⏳ Attente de 10 minutes pour le démarrage du serveur ATM10..."
sleep 600

while true; do
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    ARCHIVE="${BACKUP_DIR}/rtcube5_${TIMESTAMP}.tar.gz"

    echo "──────────────────────────────────────────────────────"
    echo "🕐 [${TIMESTAMP}] Début de la sauvegarde ATM10..."

    rcon "say §6[RTCube5] §eSauvegarde en cours, légère latence possible..."
    rcon "save-off"
    rcon "save-all"
    sleep 10   # ATM10 a besoin de plus de temps pour flusher

    # Sauvegarde des mondes + fichiers essentiels
    tar -czf "${ARCHIVE}" \
        -C "${DATA_DIR}" \
        --exclude="./logs" \
        --exclude="./crash-reports" \
        --exclude="./cache" \
        --exclude="./libraries" \
        --exclude="./mods" \
        world \
        world_nether \
        world_the_end \
        server.properties \
        whitelist.json \
        ops.json \
        banned-players.json \
        banned-ips.json \
        2>/dev/null

    SIZE=$(du -sh "${ARCHIVE}" 2>/dev/null | cut -f1)

    rcon "save-on"
    rcon "say §6[RTCube5] §aSauvegarde terminée §7(${SIZE}) §a✔"

    echo "✅ Archive : ${ARCHIVE} (${SIZE})"

    # Nettoyage
    OLD_COUNT=$(find "${BACKUP_DIR}" -name "rtcube5_*.tar.gz" -mtime +${RETENTION_DAYS} | wc -l)
    if [ "${OLD_COUNT}" -gt 0 ]; then
        echo "🗑️  Suppression de ${OLD_COUNT} ancienne(s) sauvegarde(s)"
        find "${BACKUP_DIR}" -name "rtcube5_*.tar.gz" -mtime +${RETENTION_DAYS} -type f -delete
    fi

    TOTAL=$(find "${BACKUP_DIR}" -name "rtcube5_*.tar.gz" | wc -l)
    echo "📦 Sauvegardes conservées : ${TOTAL} | 💤 Prochaine dans 30 min..."
    sleep ${INTERVAL}
done
