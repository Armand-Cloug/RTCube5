# 🟩 RTCube5 – Serveur Minecraft Survie Dockerisé

Serveur Minecraft Survie **whitelist**, avec sauvegarde automatique toutes les **30 minutes**, lancé en un seul `docker compose up`.

---

## 📁 Structure du projet

```
rtcube5/
├── docker-compose.yml      # Orchestration des services
├── .env                    # Variables d'environnement (secrets)
├── .gitignore
├── scripts/
│   └── backup.sh           # Script de sauvegarde automatique
├── data/                   # Données du serveur (généré au 1er démarrage)
│   ├── world/
│   ├── server.properties
│   └── whitelist.json
└── backups/                # Archives .tar.gz des sauvegardes
```

---

## 🚀 Démarrage rapide

### 1. Prérequis

- [Docker](https://docs.docker.com/get-docker/) installé
- [Docker Compose](https://docs.docker.com/compose/install/) v2+

### 2. Configurer la whitelist & les opérateurs

Ouvre `docker-compose.yml` et remplis ces deux variables :

```yaml
WHITELIST: "Joueur1,Joueur2,Joueur3"
OPS: "Joueur1"
```

### 3. Lancer le serveur

```bash
docker compose up -d
```

C'est tout ! Le serveur démarre, génère le monde, et les sauvegardes commencent automatiquement.

---

## 🔧 Commandes utiles

| Action | Commande |
|---|---|
| Démarrer | `docker compose up -d` |
| Arrêter | `docker compose down` |
| Voir les logs serveur | `docker compose logs -f minecraft` |
| Voir les logs backup | `docker compose logs -f backup` |
| Console du serveur | `docker attach rtcube5` (Ctrl+P puis Ctrl+Q pour quitter) |
| Redémarrer le serveur | `docker compose restart minecraft` |

---

## 🛡️ Whitelist

### Ajouter un joueur via la console Docker

```bash
docker exec rtcube5 rcon-cli whitelist add <pseudo>
```

### Retirer un joueur

```bash
docker exec rtcube5 rcon-cli whitelist remove <pseudo>
```

### Voir la whitelist

```bash
docker exec rtcube5 rcon-cli whitelist list
```

---

## 💾 Sauvegardes

Les sauvegardes sont stockées dans `./backups/` sous forme d'archives `.tar.gz` :

```
backups/
├── rtcube5_2024-01-15_12-00-00.tar.gz
├── rtcube5_2024-01-15_12-30-00.tar.gz
└── ...
```

- **Fréquence** : toutes les 30 minutes
- **Rétention** : 7 jours (les plus vieilles sont supprimées automatiquement)
- Pendant la sauvegarde, le serveur avertit les joueurs en jeu

### Restaurer une sauvegarde

```bash
# 1. Arrêter le serveur
docker compose down

# 2. Supprimer l'ancien monde
rm -rf ./data/world ./data/world_nether ./data/world_the_end

# 3. Extraire la sauvegarde choisie
tar -xzf ./backups/rtcube5_YYYY-MM-DD_HH-MM-SS.tar.gz -C ./data/

# 4. Relancer
docker compose up -d
```

---

## ⚙️ Configuration avancée

### Changer la mémoire allouée

Dans `.env` :

```env
MAX_MEMORY=6G
INIT_MEMORY=3G
```

### Changer la difficulté

Dans `docker-compose.yml` :

```yaml
DIFFICULTY: "hard"   # peaceful | easy | normal | hard
```

### Changer le port

```yaml
ports:
  - "25566:25565"    # port_hôte:port_conteneur
```

### Utiliser RCON pour envoyer des commandes

```bash
docker exec rtcube5 rcon-cli "<commande>"

# Exemples :
docker exec rtcube5 rcon-cli "time set day"
docker exec rtcube5 rcon-cli "weather clear"
docker exec rtcube5 rcon-cli "op <pseudo>"
```

---

## 🔌 Port exposé

| Port | Usage |
|---|---|
| `25565` | Connexion Minecraft (TCP) |
| `25575` | RCON (interne uniquement) |

---

## 📦 Image utilisée

Ce projet utilise **[itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server)**, l'image Docker Minecraft la plus complète et maintenue activement.

Le type de serveur est **PaperMC** (fork optimisé de Spigot) pour de meilleures performances.