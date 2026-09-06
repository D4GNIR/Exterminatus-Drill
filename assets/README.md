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
