# 🟩 RTCube5 – All The Mods 10 (ATM10) Dockerisé

Serveur **All The Mods 10** sur Minecraft 1.21.1 (NeoForge), whitelist,
sauvegarde automatique toutes les 30 minutes, lancé en un `docker compose up`.

---

## 📁 Structure du projet

```
rtcube5/
├── docker-compose.yml        # Orchestration
├── .env                      # 🔒 Clé API CurseForge + RCON
├── .gitignore
├── server-icon.png           # Icône 64x64 du serveur
├── chunky.sh                 # Pré-génération de la map
├── scripts/
│   └── backup.sh             # Sauvegarde automatique 30 min
│
├── extra-mods/               # Mods supplémentaires par-dessus ATM10
├── config/                   # Configs personnalisées des mods
│
├── data/                     # Données serveur (généré au 1er démarrage)
└── backups/                  # Archives de sauvegarde .tar.gz
```

---

## 🚀 Démarrage rapide

### 1. Obtenir une clé API CurseForge (OBLIGATOIRE)

ATM10 est téléchargé automatiquement depuis CurseForge, ce qui nécessite
une clé API **gratuite** :

1. Va sur → https://console.curseforge.com/#/api-keys
2. Connecte-toi (ou crée un compte gratuit)
3. Génère une clé API
4. Colle-la dans le fichier `.env` :

```env
CF_API_KEY=ta_cle_ici
```

### 2. Configurer `.env`

```env
CF_API_KEY=ta_cle_api_curseforge
RCON_PASSWORD=un_mot_de_passe_solide
```

### 3. Ajouter tes joueurs dans `docker-compose.yml`

```yaml
WHITELIST: "Clougounette,Volio,AutreJoueur"
OPS: "Clougounette"
```

### 4. Lancer

```bash
docker compose up -d
docker compose logs -f minecraft
```

> ⚠️ Le **premier démarrage prend 10 à 20 minutes** : téléchargement du
> modpack ATM10 (~500 Mo) + installation NeoForge + génération du spawn.
> C'est normal, ne pas redémarrer !

Tu verras cette ligne quand c'est prêt :
```
[Server thread/INFO]: Done (Xs)! For help, type "help"
```

---

## 🎮 Connexion client

Les joueurs doivent utiliser le **launcher CurseForge ou le launcher ATM**
avec le modpack **All The Mods 10** installé côté client.

- Version : **Minecraft 1.21.1**
- Modpack : **All The Mods 10** (même version que le serveur)

---

## 🔧 Commandes utiles

| Action | Commande |
|---|---|
| Démarrer | `docker compose up -d` |
| Arrêter | `docker compose down` |
| Logs serveur | `docker compose logs -f minecraft` |
| Logs backup | `docker compose logs -f backup` |
| Console | `docker attach rtcube5` (quitter : Ctrl+P puis Ctrl+Q) |
| Redémarrer | `docker compose restart minecraft` |

---

## 🛡️ Whitelist

```bash
docker exec rtcube5 rcon-cli "whitelist add <pseudo>"
docker exec rtcube5 rcon-cli "whitelist remove <pseudo>"
docker exec rtcube5 rcon-cli "whitelist list"
```

---

## 🗺️ Pré-génération de la map (Chunky)

Chunky est inclus dans ATM10. Lance la pré-génération une fois le serveur
démarré pour éviter tout lag d'exploration :

```bash
chmod +x chunky.sh
./chunky.sh start     # Lance (radius 15 000 blocs, ~3-5h)
./chunky.sh progress  # Suivi
./chunky.sh pause     # Pause
./chunky.sh resume    # Reprendre
./chunky.sh stop      # Annuler
```

---

## 🧩 Ajouter des mods supplémentaires

Dépose tes `.jar` NeoForge 1.21.1 dans `./extra-mods/` et redémarre :

```bash
cp MonMod.jar ./extra-mods/
docker compose restart minecraft
```

> ⚠️ Les plugins Bukkit/Spigot ne sont **pas compatibles** avec NeoForge.
> Pour les fonctionnalités habituellement couvertes par des plugins,
> utilise ces mods équivalents :

| Besoin | Mod équivalent NeoForge |
|---|---|
| /home, /warp, /tpa | **FTB Essentials** |
| Protection de zones | **FTB Chunks** (inclus ATM10) |
| Économie | **FTB Money** |
| Chat Discord ↔ Minecraft | **DiscordIntegration** (mod Forge) |
| Anti-grief / logs | **Forge Utilities** |
| Tablist custom | **Model Name** ou **Neat** |

---

## 💾 Sauvegardes

```
backups/
├── rtcube5_2024-01-15_12-00-00.tar.gz
├── rtcube5_2024-01-15_12-30-00.tar.gz
└── ...
```

- Fréquence : **toutes les 30 minutes**
- Rétention : **7 jours**
- Contenu : worlds + server.properties + whitelist/ops/bans

### Restaurer

```bash
docker compose down
rm -rf ./data/world ./data/world_nether ./data/world_the_end
tar -xzf ./backups/rtcube5_YYYY-MM-DD_HH-MM-SS.tar.gz -C ./data/
docker compose up -d
```

---

## ⚙️ Configuration avancée

### Figer la version du modpack (recommandé en prod)

Récupère le `File ID` sur la page CurseForge d'ATM10, puis dans
`docker-compose.yml` décommente :

```yaml
CF_FILE_ID: "XXXXXXX"
```

### Mémoire

Avec 12 Go de RAM sur le VPS, la config actuelle alloue **10 Go** à Java.
Si tu as d'autres services qui tournent, réduis à `8G` :

```yaml
MAX_MEMORY: "8G"
INIT_MEMORY: "4G"
```

---

## 🔌 Ports

| Port | Usage |
|---|---|
| `25565` | Connexion Minecraft |
| `25575` | RCON (interne Docker) |
