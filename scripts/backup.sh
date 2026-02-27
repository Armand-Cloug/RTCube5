#!/bin/sh
# ─────────────────────────────────────────────────────────────────────────────
# RTCube5 – Script de sauvegarde automatique toutes les 30 minutes
# ─────────────────────────────────────────────────────────────────────────────

BACKUP_DIR="/backups"
DATA_DIR="/data"
WORLD_NAME="world"
RETENTION_DAYS=7       # Nombre de jours de rétention des sauvegardes
INTERVAL=1800          # 30 minutes en secondes

# Installe les dépendances nécessaires
apk add --no-cache rcon-cli tar gzip > /dev/null 2>&1 || true

echo "✅ Service de sauvegarde RTCube5 démarré (toutes les 30 minutes)"

while true; do
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    ARCHIVE="${BACKUP_DIR}/rtcube5_${TIMESTAMP}.tar.gz"

    echo "──────────────────────────────────────────────"
    echo "🕐 [${TIMESTAMP}] Début de la sauvegarde..."

    # Désactive la sauvegarde automatique du serveur avant la copie
    rcon-cli \
        --host minecraft \
        --port 25575 \
        --password rtcube5_rcon_secret \
        "say §6[RTCube5] §eSauvegarde en cours..." 2>/dev/null || true

    rcon-cli \
        --host minecraft \
        --port 25575 \
        --password rtcube5_rcon_secret \
        "save-off" 2>/dev/null || true

    rcon-cli \
        --host minecraft \
        --port 25575 \
        --password rtcube5_rcon_secret \
        "save-all" 2>/dev/null || true

    # Petite attente pour laisser le flush se terminer
    sleep 5

    # Crée l'archive compressée des worlds
    tar -czf "${ARCHIVE}" \
        -C "${DATA_DIR}" \
        "${WORLD_NAME}" \
        "${WORLD_NAME}_nether" \
        "${WORLD_NAME}_the_end" \
        2>/dev/null || \
    tar -czf "${ARCHIVE}" \
        -C "${DATA_DIR}" \
        "${WORLD_NAME}" \
        2>/dev/null

    # Réactive la sauvegarde automatique
    rcon-cli \
        --host minecraft \
        --port 25575 \
        --password rtcube5_rcon_secret \
        "save-on" 2>/dev/null || true

    rcon-cli \
        --host minecraft \
        --port 25575 \
        --password rtcube5_rcon_secret \
        "say §6[RTCube5] §aSauvegarde terminée ✔" 2>/dev/null || true

    echo "✅ Sauvegarde créée : ${ARCHIVE}"

    # Supprime les sauvegardes plus vieilles que RETENTION_DAYS jours
    OLD=$(find "${BACKUP_DIR}" -name "rtcube5_*.tar.gz" -mtime +${RETENTION_DAYS} -type f)
    if [ -n "${OLD}" ]; then
        echo "🗑️  Suppression des anciennes sauvegardes :"
        echo "${OLD}" | xargs rm -v
    fi

    echo "💤 Prochaine sauvegarde dans 30 minutes..."
    sleep ${INTERVAL}
done