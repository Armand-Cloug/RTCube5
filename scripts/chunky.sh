#!/bin/bash
# ─────────────────────────────────────────────────────────────────
# RTCube5 – Gestionnaire Chunky (radius 15000)
# ─────────────────────────────────────────────────────────────────

CONTAINER="rtcube5"
RADIUS=15000

rcon() {
    docker exec "$CONTAINER" rcon-cli "$1"
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
        echo "✅ Génération en pause. './chunky.sh resume' pour reprendre."
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
