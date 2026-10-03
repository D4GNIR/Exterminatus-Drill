# Assets — Motherload 40K : Exterminatus Drill

Emplacement contractuel des ressources brutes du jeu (`res://assets/`), posé par la story
`stories/1.2 - Arborescence contractuelle du projet.md`.

| Dossier | Contenu attendu | Formats |
|---|---|---|
| `sprites/` | Foreuse, tuiles de terrain et de minerai, décors, pictogrammes et cadres d'UI, particules | `.png` |
| `audio/` | Boucle moteur, foret, alertes, musique, voix radio | `.ogg` (musique et boucles), `.wav` (impacts courts) |
| `fonts/` | Polices de l'UI « terminal industriel » | `.ttf`, `.otf` |

## Convention de nommage

Les conventions de code du projet (`PascalCase.gd`, `PascalCase.tscn`, `snake_case.json`) ne couvrent
pas les assets. Règle retenue ici :

- **`snake_case` pour tout fichier d'asset**, sans accent, sans espace, sans majuscule.
  Motif : les chemins `res://` sont sensibles à la casse à l'export alors que macOS et Windows ne le
  sont pas — un nom tout en minuscules supprime la classe de bugs « fonctionne en éditeur, casse à
  l'export ».
- **Préfixe de famille**, pour que le tri alphabétique regroupe ce qui va ensemble :
  - sprites : `drill_`, `tile_`, `ore_`, `prop_`, `fx_`, `ui_`
  - audio : `sfx_`, `amb_`, `mus_`, `voice_`
- **Suffixe d'état ou de variante** en fin de nom : `_idle`, `_drilling`, `_damaged`, `_01`, `_02`.
- **Feuilles de sprites** : suffixe `_sheet`, dimensions de cellule rappelées dans le nom si elles
  s'écartent de la grille de tuile (`_32x32`).

Exemples : `drill_rig_idle.png`, `tile_rock_hard.png`, `ore_promethium_01.png`,
`ui_frame_hud.png`, `sfx_drill_loop.ogg`, `voice_commissaire_alert_fuel.ogg`.

### Fichiers `.import`

Godot 4 génère un `<asset>.import` **à côté** de chaque asset : ces fichiers portent l'UID de la
ressource et sont **versionnés** (seul `.godot/` est ignoré). Après tout ajout d'asset, lancer
`godot --headless --import` depuis la racine avant d'ouvrir une scène qui le référence.

### Dérogation de nommage — police fournie

Les fichiers de `fonts/` sont conservés **sous le nom et à l'emplacement fournis par l'utilisateur**
(espaces et majuscules compris), par décision `Q46` du 2026-10-01 (story `4.8`) : c'est la seule
dérogation tracée à la règle `snake_case` ci-dessus. Ils ne sont référencés **que par le thème**
`scenes/ui/UiTheme.tres` ; aucun agent ne les renomme.

## Crédits et licences

### Police « Inquisitor » — `fonts/`

| Élément | Valeur |
|---|---|
| Famille | **Inquisitor** |
| Fonderie / auteur | **Pixel Sagas** — Neale Davidson — http://www.pixelsagas.com |
| Fichiers | `Inquisitor.otf`, `Inquisitor Bold.otf`, `Inquisitor Italic.otf`, `Inquisitor Bold Italic.otf` |
| Licence | **Pixel Sagas Freeware Fonts EULA** — texte intégral : `fonts/Font License.txt`, versionné avec les polices |
| Fournie par | l'utilisateur, le 2026-10-01 (arbitrage `Q46`, story `4.8`) |

Ce que la licence permet et interdit (résumé ; seul `fonts/Font License.txt` fait foi) :

- **Usage personnel non commercial : gratuit.**
- **Intégration dans un logiciel autorisée** (« embedded for web, publication, or general software use »).
- **Usage commercial : payant**, licence commerciale à acheter sur pixelsagas.com.
- **Redistribution en téléchargement direct interdite** sans autorisation écrite de l'auteur, et vente
  de la police interdite.
- La mention du nom de la police et de l'auteur dans les crédits est **appréciée** (non obligatoire) :
  c'est l'objet de cette section, à reprendre dans les crédits du jeu.

> ⚠️ **Versionnement sous condition** (arbitrage `Q50` du 2026-10-01, story `4.8`) : les `.otf` sont
> versionnés parce que le dépôt GitHub est **privé** et le projet **non commercial**. Rendre le dépôt
> **public** mettrait les fichiers en téléchargement direct ; un usage **commercial** exigerait la
> licence payante. Dans l'un ou l'autre cas, la licence **doit être revue avant** : achat de la
> licence commerciale ou exclusion des fichiers du dépôt. Risque suivi dans
> `stories/AVANCEMENT.md` §5.

### Sons générés — `audio/`

Tous les sons de `audio/` sont des **placeholders générés par un agent** (`godot-dev`), sans
échantillon tiers, au format `.wav` PCM 16 bits mono 22 050 Hz. Ceux de la story `4.2` sont une
synthèse procédurale (sinus, carré, dents de scie, bruit filtré) écrite en Python standard
(`wave`, `math`) ; la méthode exacte de ceux de `3.7` n'a pas été consignée à l'époque (`Q34`).
Celui de la story `6.6` (arbitrage `Q69` (a), 2026-10-02) suit la même méthode que ceux de `4.2` :
synthèse procédurale en Python standard (`wave`, `math`, `random` à graine fixe), même format.
Les trois **ambiances de palier** de la story `6.8` (arbitrage `Q69` (a), générées le 2026-10-03) sont
synthétisées en Python avec **numpy** (graine fixe 68), même format : **boucles parfaites de 12 s** (toutes
les fréquences, vibratos et houles font un nombre entier de cycles sur la durée, bruit filtré par FFT
circulaire), importées en boucle (`edit/loop_mode=2`, Forward, dans leur `.import`). Les voix des
« chœurs graves » (CDC « Direction sonore ») sont des harmoniques d'une fondamentale grave pondérées par
des formants de voyelle sombre, plusieurs voix légèrement désaccordées. Le flux de chaque palier est
désigné par son chemin dans `data/generation.json` (bloc `indicateur_danger`) : remplacer le fichier sous
le même nom, ou changer ce chemin, suffit. Le premier palier n'a volontairement **aucune** ambiance.
Le son d'alerte « anomalie proche » de la story `6.4` (arbitrage `Q69` (a), généré le 2026-10-03) est
synthétisé en Python avec **numpy** (graine fixe 64), même format, **non bouclé** ; il est joué par le
lecteur `AlertAudio` de `scenes/world/AnomalyDetector.tscn`, distinct du lecteur d'alertes de la foreuse.
**Aucune licence tierce** : œuvres originales du projet. Ils sont **substituables sans toucher au code** :
remplacer le fichier sous le même nom suffit (le flux est référencé par la scène, jamais par un
chemin dans un script). Le script générateur n'est pas versionné (outil jetable, hors dépôt).

| Fichier | Story · arbitrage | Emploi | Signature sonore |
|---|---|---|---|
| `sfx_drill_loop.wav` | `3.7` · `Q34` | Forage (boucle, import `loop_mode` Forward) | Grondement grave en boucle |
| `sfx_rare_drop.wav` | `3.7` · `Q34` | Drop de rareté haute | Arpège ascendant carillonné, 1,3 s |
| `sfx_alert_fuel_low.wav` | `4.2` · `Q45` | Carburant bas | Deux paires de bips carrés descendants 880 → 660 Hz, 0,76 s |
| `sfx_alert_fuel_depleted.wav` | `4.2` · `Q45` | Panne sèche | Glissando grave en dents de scie 420 → 70 Hz, « moteur qui s'éteint », 0,9 s |
| `sfx_alert_armor_low.wav` | `4.2` · `Q45` | Blindage faible | Klaxon : trois impulsions dents de scie à deux voix battantes (220 + 233 Hz), 0,48 s |
| `sfx_alert_cargo_full.wav` | `4.2` · `Q45` | Soute pleine | Deux coups de cloche métallique (partiels inharmoniques), grave puis aigu, 0,64 s |
| `sfx_drill_refused.wav` | `4.2` · `Q45` | Forage refusé | Choc sourd et bref (sinus 110 Hz + bruit filtré), 0,16 s |
| `sfx_threat_encounter.wav` | `6.6` · `Q69` (a) — généré le 2026-10-02 | Rencontre hostile (courbe de risque §4.2), joué par `DrillFeedback.tscn` (`ThreatAudio`) | Choc grave (sinus 95 → 45 Hz) et gravats (bruit filtré bref), puis cri strident en dents de scie 1150 → 620 Hz à vibrato, 0,62 s |
| `sfx_alert_anomaly_near.wav` | `6.4` · `Q69` (a) — généré le 2026-10-03 | Alerte « anomalie proche » (CDC « Direction sonore »), joué par `AnomalyDetector.tscn` (`AlertAudio`) à l'entrée dans le rayon d'alerte | Trois « pings » de sonar spectral montants (sinus 1180 → 1320 → 1480 Hz modulés en anneau à 47 Hz, écho à l'octave inférieure) sur une nappe grave murmurante (70 → 95 Hz, trémolo lent), 1,4 s — ni bip carré, ni klaxon, ni cloche, ni choc ou cri de rencontre |
| `amb_depth_necropolis.wav` | `6.8` · `Q69` (a) — généré le 2026-10-03 | Ambiance du palier 2 « Nécropole oubliée » (indicateur de danger, `DangerIndicator.tscn`), boucle | Drone grave battant (41 / 41,5 Hz) et harmoniques, vent souterrain (bruit filtré à houle lente), coups sourds de pierre et de métal toutes les 4 s, 12 s |
| `amb_depth_entrails_choir.wav` | `6.8` · `Q69` (a) — généré le 2026-10-03 | Ambiance du palier 3 « Entrailles hérétiques », boucle | **Chœur grave** en voyelle « ou » (ré 2 + la 2, quinte à vide, trois voix par note), houle lente, drone à l'octave inférieure et souffle sourd, 12 s |
| `amb_depth_core_choir.wav` | `6.8` · `Q69` (a) — généré le 2026-10-03 | Ambiance du palier 4 « Cœur de Gehenna-7 », boucle | **Chœur grave dissonant** en voyelle « a » (ré 2, mi♭ 2, sol♯ 2 : seconde mineure et triton), grondement sismique, battement lent oppressant à 0,75 Hz, 12 s |

Le bip de **destruction** reste le flux embarqué de `DrillRig.tscn` (sous-ressource
`AudioStreamWAV_alert`, story `2.3`). Reconnaissance à l'oreille et confort à la répétition :
recette `7.8`.

### Sprites de décor générés — `sprites/`

Placeholders **générés par un agent** (`godot-dev`) : pixel art dessiné par un script Python jetable
(Pillow, primitives rectangulaires, bruit de rouille à graine fixe), **hors dépôt**. Celui de la story
`6.4` (arbitrage `Q69` (a), généré le 2026-10-03) suit la même méthode, avec **numpy** (graine fixe 64)
pour le halo et les fissures. **Aucune licence
tierce** : œuvres originales du projet. Substituables **sans toucher au code ni à la scène** :
remplacer le fichier sous le même nom suffit.

| Fichier | Story · arbitrage | Emploi | Contenu |
|---|---|---|---|
| `prop_surface_station.png` | `5.1` · `Q55` | Station de surface (`scenes/world/SurfaceStation.tscn`, sous `World/DecorationsLayer`) | 192 × 128 px (6 × 4 tuiles), fond transparent : hangar d'acier riveté à porte à lames, rampe lumineuse orange, bannière rouge impérial à aigle stylisé, tour de communication à balise, réservoir de promethium rouillé, plateforme à bandes de signalisation. **Le pied de l'image est la ligne de surface** : le script pose le bas de la texture sur `y = 0`, quelle que soit sa taille. |
| `prop_anomaly_necropolis.png` | `6.4` · `Q69` (a) — généré le 2026-10-03 | Anomalie scénarisée (`scenes/world/AnomalyMarker.tscn`, sous `World/DecorationsLayer`), à l'ancrage de `data/generation.json` | 96 × 96 px (3 × 3 tuiles), fond transparent : monolithe d'obsidienne pré-impérial à pointe, glyphes et œil central vert spectral, socle de gravats, fissures lumineuses rayonnantes, halo vert diffus. **Le centre de l'image est le centre de la cellule d'ancrage** (sprite centré), quelle que soit sa taille. |

Lisibilité à l'écran, cohérence avec l'atlas de tuiles et filtrage (aucun `texture_filter` n'est posé,
comme pour le reste du projet) : recette `7.8`.

## Palette de référence (CDC — « Direction artistique »)

Six teintes structurent l'ensemble du jeu :

| Teinte | Emploi principal |
|---|---|
| **Acier gris** | Foreuse, structures métalliques, cadres d'UI |
| **Rouille** | Usure, tuyauteries, carcasses de machines |
| **Brun poussiéreux** | Strates de terre, poussière en suspension |
| **Orange industriel** | Signalétique, éclairages, particules d'étincelles |
| **Vert toxique** | Gaz, fluides, anomalie et zones profondes |
| **Rouge impérial** | Alertes critiques, iconographie de l'Imperium |

Repères visuels associés : pipelines, câbles, rails, carcasses de machines, chapelles mécaniques,
galeries effondrées. UI de type terminal industriel, pictogrammes lisibles.

> **Les valeurs hexadécimales ne sont pas encore figées.** Le CDC nomme les teintes sans les coder ;
> leur définition relève de la story de direction artistique définitive (phase 15). Toute valeur
> utilisée d'ici là est provisoire et ne doit pas être considérée comme contractuelle.
