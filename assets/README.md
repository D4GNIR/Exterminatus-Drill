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

Le bip de **destruction** reste le flux embarqué de `DrillRig.tscn` (sous-ressource
`AudioStreamWAV_alert`, story `2.3`). Reconnaissance à l'oreille et confort à la répétition :
recette `7.8`.

### Sprites de décor générés — `sprites/`

Placeholders **générés par un agent** (`godot-dev`) : pixel art dessiné par un script Python jetable
(Pillow, primitives rectangulaires, bruit de rouille à graine fixe), **hors dépôt**. **Aucune licence
tierce** : œuvres originales du projet. Substituables **sans toucher au code ni à la scène** :
remplacer le fichier sous le même nom suffit.

| Fichier | Story · arbitrage | Emploi | Contenu |
|---|---|---|---|
| `prop_surface_station.png` | `5.1` · `Q55` | Station de surface (`scenes/world/SurfaceStation.tscn`, sous `World/DecorationsLayer`) | 192 × 128 px (6 × 4 tuiles), fond transparent : hangar d'acier riveté à porte à lames, rampe lumineuse orange, bannière rouge impérial à aigle stylisé, tour de communication à balise, réservoir de promethium rouillé, plateforme à bandes de signalisation. **Le pied de l'image est la ligne de surface** : le script pose le bas de la texture sur `y = 0`, quelle que soit sa taille. |

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
