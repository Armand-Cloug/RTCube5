#!/bin/bash
# ─────────────────────────────────────────────────────────────────
# RTCube5 – Gestionnaire Chunky (radius 15000)
# ─────────────────────────────────────────────────────────────────

CONTAINER="rtcube5"
RADIUS=15000
RCON_PORT=25575

# Charge le .env depuis la racine du projet (un niveau au-dessus de scripts/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../.env"

if [ -f "$ENV_FILE" ]; then
    RCON_PASSWORD=$(grep '^RCON_PASSWORD=' "$ENV_FILE" | cut -d'=' -f2 | tr -d '"')
else
    echo "❌ Fichier .env introuvable à ${ENV_FILE}"
    exit 1
fi

if [ -z "$RCON_PASSWORD" ]; then
    echo "❌ RCON_PASSWORD vide dans le .env"
    exit 1
fi

rcon() {
    sudo docker exec "$CONTAINER" rcon-cli \
        --host localhost \
        --port "$RCON_PORT" \
        --password "$RCON_PASSWORD" \
        "$1"
}

case "$1" in
    start)
        echo "🗺️  Démarrage de la pré-génération (radius ${RADIUS} blocs)..."
        rcon "chunky radius ${RADIUS}"
        rcon "chunky start"
        echo "✅ Génération lancée ! Utilise './chunky.sh progress' pour suivre."
        ;;
    stop)
        echo "⏹️  Arrêt de la génération..."
        rcon "chunky cancel"
        echo "✅ Génération annulée."
        ;;
    progress)
        echo "📊 Progression :"
        rcon "chunky progress"
        ;;
    pause)
        echo "⏸️  Mise en pause..."
        rcon "chunky pause"
        echo "✅ Génération en pause. Utilise './chunky.sh resume' pour reprendre."
        ;;
    resume)
        echo "▶️  Reprise..."
        rcon "chunky continue"
        echo "✅ Génération reprise."
        ;;
    *)
        echo ""
        echo "  Usage : ./chunky.sh <commande>"
        echo ""
        echo "  start     → Lance la génération (radius ${RADIUS} blocs)"
        echo "  stop      → Annule"
        echo "  progress  → Affiche la progression"
        echo "  pause     → Met en pause"
        echo "  resume    → Reprend"
        echo ""
        ;;
esac