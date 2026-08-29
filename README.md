# Motherload 40K : Exterminatus Drill

Jeu 2D de forage, extraction, progression et survie, en vue latérale par tuiles.

## Pitch

Le joueur pilote une foreuse pénale affectée à l'extraction sur **Gehenna-7**, une planète-mine
industrialisée, et doit remplir les quotas en minéraux de l'Imperium et de l'Adeptus Mechanicus.
À mesure qu'il descend, il découvre des galeries interdites, des traces de cultes et une anomalie
enfouie au cœur du monde. La boucle : creuser, collecter, remonter vendre, améliorer sa foreuse,
repartir plus profond.

> **Note de propriété intellectuelle** : projet de *fan game* inspiré de la boucle de jeu de
> *Motherload* et de l'ambiance grimdark de Warhammer 40,000. Toute diffusion commerciale
> impliquerait de remplacer les éléments protégés par un univers original.

## Stack technique

| Élément | Valeur |
|---|---|
| Moteur | **Godot 4.x** |
| Langage | **GDScript** (typage statique systématique) |
| Rendu | `GL Compatibility` (préserve l'export Web) |
| Tuiles | `TileMapLayer` + Custom Data Layers |
| Plateformes cibles | PC, export Web possible |

## Prérequis

**Godot 4.x doit être installé pour lancer et tester le jeu.**

- Version utilisée pour le développement : **Godot 4.7.2 stable** (binaire `godot` dans le `PATH`).
- Toute version **4.x** récente devrait convenir ; les versions **3.x** sont incompatibles
  (`TileMapLayer`, syntaxe des annotations, `move_and_slide()` de Godot 4).
- Téléchargement : <https://godotengine.org/download>

Vérification rapide de l'installation :

```bash
godot --version          # attendu : 4.x.y.stable
```

## Lancer le projet

Le projet Godot n'existe pas encore : il sera créé en story `1.1 - Initialisation du projet Godot 4`.
Une fois `project.godot` présent, depuis la racine du dépôt :

```bash
godot --headless --import      # importe les assets et génère le cache .godot/ (obligatoire au 1er lancement)
godot --headless --quit        # charge le projet sans fenêtre : détecte les erreurs de chargement
godot                          # lance le jeu (mode graphique)
```

## Arborescence du dépôt

État actuel (documentation et pilotage — aucun code de production à ce stade) :

```text
MotherloadW40k/
├─ cahier_des_charges_motherload_40k_godot.md   Cahier des charges de référence (le « quoi »)
├─ README.md                                    Ce fichier
├─ .gitignore                                   Exclusions Godot 4 (.godot/, exports, temporaires)
├─ .claude/                                     Méthodologie, conventions et agents du projet
│  ├─ CLAUDE.md                                 Convention stories/ (fait foi)
│  └─ agents/                                   Rôles : product owner, développeur Godot
├─ stories/                                     Une story par action menée sur le projet
│  ├─ BACKLOG.md                                Phases, sprints, traçabilité MVP
│  ├─ AVANCEMENT.md                             Suivi factuel de l'avancement et des risques
│  └─ <phase>.<n> - <titre>.md                  Stories (statut, critères d'acceptation, notes)
└─ qa/                                          Gate qualité de fin de sprint
   ├─ README.md                                 Fonctionnement de la gate
   ├─ audit-qualite-reference.md                Checklist d'audit code
   ├─ plan-tests-manuels.md                     Plan de tests manuels humains
   ├─ rapport-test-template.md                  Gabarit de rapport
   └─ rapports/                                 Rapports de tests produits
```

Arborescence cible du projet Godot (contractuelle — section « Architecture Godot » du cahier des
charges, mise en place à partir des stories `1.1` / `1.2`) :

```text
res://
├─ scenes/
│  ├─ main/Main.tscn
│  ├─ player/DrillRig.tscn
│  ├─ world/World.tscn
│  └─ ui/HUD.tscn · Shop.tscn · Dialogue.tscn
├─ scripts/
│  ├─ autoload/GameState.gd · GameData.gd
│  ├─ player/DrillRig.gd
│  ├─ systems/MiningSystem.gd · EconomySystem.gd · NarrativeSystem.gd
│  └─ components/FuelSystem.gd
├─ data/
│  ├─ resources.json
│  ├─ upgrades.json
│  └─ events.json
└─ assets/
   ├─ sprites/
   ├─ audio/
   └─ fonts/
```

## Méthode de travail

Le projet avance **une story à la fois**, par phases (1 phase = 1 sprint = 1 commit). Chaque sprint
se clôt par deux gates : un audit qualité de code, puis une session de tests manuels humains.

- Besoin fonctionnel : [`cahier_des_charges_motherload_40k_godot.md`](cahier_des_charges_motherload_40k_godot.md)
- Plan de travail et traçabilité MVP : [`stories/BACKLOG.md`](stories/BACKLOG.md)
- Avancement, risques et écarts : [`stories/AVANCEMENT.md`](stories/AVANCEMENT.md)
- Gate qualité et tests : [`qa/README.md`](qa/README.md)
- Conventions de développement : [`.claude/CLAUDE.md`](.claude/CLAUDE.md)

## État d'avancement

**Phase 0 — Amorçage du projet** (méthodologie, backlog, QA, dépôt). Le MVP jouable est atteint à
la fin de la phase 7. Voir [`stories/AVANCEMENT.md`](stories/AVANCEMENT.md) pour l'état détaillé.
