# Cahier des charges — Motherload 40K : Exterminatus Drill

> **Note de propriété intellectuelle** : ce document décrit un projet de fan game inspiré de la boucle de jeu de *Motherload* et de l'ambiance grimdark de Warhammer 40,000. Pour une diffusion commerciale, créer un univers, des noms, factions, visuels et textes originaux plutôt que d'utiliser des éléments protégés.

> ⚠️ **Amendement en vigueur depuis le 2026-09-06** : ce cahier des charges est complété et, sur certains points, **modifié** par [`cahier_des_charges_gameplay_addictif.md`](cahier_des_charges_gameplay_addictif.md), qui définit les mécaniques de rétention (loot pondéré, progression infinie, risque croissant, boucle de session). Ses mécaniques **font partie du périmètre MVP**. Voir la section terminale « Amendement — Cahier des charges gameplay addictif » pour la règle de préséance et la liste des sections concernées. *Arbitrage utilisateur **Q16**, story `1.10`.*

## Vision

- **Titre provisoire** : *Exterminatus Drill*
- **Genre** : jeu 2D de forage, extraction, progression et survie.
- **Plateforme cible** : PC, avec export Web possible.
- **Moteur** : Godot 4.x, GDScript.
- **Vue** : 2D latérale en tuiles, caméra suivant la foreuse.
- **Piliers** : creuser plus profond, rapporter une cargaison, améliorer la foreuse, survivre à des dangers croissants, découvrir un mystère souterrain.

## Pitch

Le joueur pilote une foreuse pénale affectée à l'extraction sur **Gehenna-7**, une planète-mine industrialisée. Il doit remplir des quotas en minéraux pour l'Imperium et l'Adeptus Mechanicus. À mesure qu'il descend, il découvre des galeries interdites, des traces de cultes et une anomalie enfouie au cœur du monde.

## Scénario

### Prologue

> « Condamné, ta dette envers l'Humanité ne peut être remboursée que par le labeur. Ta foreuse est ta cellule, ton quota est ta prière, et les profondeurs seront ton jugement. Extrais. Livre. Survis. »

Le personnage principal est un détenu sans nom, désigné **Opérateur 77-Delta**. Le Commissaire de surface le surveille ; un Tech-Prêtre lui transmet les ordres techniques et les demandes d'échantillons.

### Progression narrative

1. **Croûte industrielle** : tutoriel, minerais basiques, galeries abandonnées et quotas initiaux.
2. **Nécropole oubliée** : structures pré-impériales, signaux inconnus et premières anomalies.
3. **Entrailles hérétiques** : journaux de mineurs disparus, corruption, dangers psychiques.
4. **Cœur de Gehenna-7** : découverte d'un artefact ancien et choix final.

### Fins envisagées

- **Loyale** : remettre l'artefact aux autorités et survivre jusqu'à l'évacuation.
- **Renégate** : saboter l'opération pour fuir avec des données ou une relique.
- **Hérétique** : activer l'anomalie, avec une fin volontairement tragique.

## Boucle de jeu

1. Quitter la surface avec une foreuse approvisionnée.
2. Creuser et collecter les minerais.
3. Éviter les dangers, surveiller carburant, blindage et soute.
4. Remonter à la surface avant la panne ou la destruction.
5. Vendre, réparer, ravitailler et acheter une amélioration.
6. Repartir plus profondément ; débloquer zones et événements.

## Contrôles

Les commandes doivent être configurées dans **Project Settings > Input Map**.

| Action | Input Map | Touches par défaut | Règle |
|---|---|---|---|
| Monter | `move_up` | `Z`, `Flèche haut` | Déplacement dans un tunnel libre ; aucun forage vers le haut |
| Descendre | `move_down` | `S`, `Flèche bas` | Déplacement, forage si le bloc ciblé est minable |
| Aller à gauche | `move_left` | `Q`, `Flèche gauche` | Déplacement, forage latéral sous conditions |
| Aller à droite | `move_right` | `D`, `Flèche droite` | Déplacement, forage latéral sous conditions |
| Forer | `drill` | `Espace` | Active le foret dans la direction de mouvement |
| Freiner/stabiliser | `brake` | `Shift` | Réduit la vitesse et l'inertie |
| Objet rapide 1 | `use_item_1` | `1` | Ex. explosif ou charge de forage |
| Objet rapide 2 | `use_item_2` | `2` | Ex. nanoréparateurs |
| Objet rapide 3 | `use_item_3` | `3` | Ex. balise de rappel |
| Inventaire | `toggle_inventory` | `I`, `Tab` | Ouvre une interface et met le jeu en pause |
| Journal | `toggle_journal` | `J` | Objectifs, logs, encyclopédie |
| Pause | `pause` | `Échap` | Menu pause |

## Règles autorisées

- Se déplacer dans un tunnel déjà creusé dans les quatre directions.
- Forer vers le bas sur une tuile destructible.
- Forer latéralement uniquement lorsque la foreuse est soutenue par un sol solide.
- Monter grâce aux propulseurs uniquement dans un espace vide.
- Traverser une zone dangereuse si la foreuse possède les capacités nécessaires, avec éventuels dégâts ou malus.
- Utiliser un consommable si le joueur possède du stock et que son temps de recharge est terminé.
- Revenir à la surface à tout moment par les galeries existantes ou grâce à une balise très rare.

## Règles interdites ou limitées

- Aucun forage vers le haut.
- Aucun forage latéral lorsque la foreuse est dans le vide.
- Aucune traversée d'une tuile indestructible, d'un bord de carte ou du plafond de la zone.
- Aucune utilisation d'objet pendant une animation de destruction, une interface, une cinématique ou un état de mort.
- Une même paire de directions opposées annule le mouvement : haut + bas ou gauche + droite.
- Les explosifs et réparations sont limités par leur stock et un cooldown.
- Sans carburant, la foreuse ne peut ni forer ni propulser vers le haut ; elle peut toutefois chuter ou se déplacer sur une pente selon le modèle physique choisi.

## Ressources

| Ressource | Rareté | Usage / valeur | Risque |
|---|---:|---|---|
| Fer industriel | Commune | Vente, tutoriel | Aucun |
| Cuivre | Commune | Vente, composants | Aucun |
| Prométhium brut | Peu commune | Vente et ravitaillement | Inflammable dans certaines poches de gaz |
| Adamantium | Rare | Forte valeur, quêtes Mechanicus | Roche dure |
| Cristaux plasma | Très rare | Grande valeur, améliorations avancées | Instabilité et dégâts possibles |
| Relique xéno | Exceptionnelle | Progression narrative | Déclencheurs d'événements |

## Dangers

| Danger | Effet | Contre-mesure |
|---|---|---|
| Roche dure | Foret lent ou inefficace | Foret amélioré, explosif |
| Éboulement | Bloque un tunnel, inflige des dégâts | Blindage, forage rapide, itinéraire alternatif |
| Gaz toxique | Dégâts progressifs | Filtres et systèmes de survie |
| Poche de prométhium | Explosion possible | Détection, distance, blindage |
| Créatures mutées | Attaque ou obstacle mobile | Arme/outils, fuite, blindage |
| Anomalie Warp | Effet aléatoire ou corruption | Modules de protection, choix de risque |

## Améliorations

| Catégorie | Statut de départ | Exemples de progression |
|---|---|---|
| Foret | Foret industriel MK-I | Vitesse, puissance, efficacité énergétique |
| Réacteur | Réacteur faible capacité | Réservoir plus grand, consommation réduite |
| Blindage | Plaques de récupération | Résistance, protection chaleur et toxines |
| Soute | 50 unités | Capacité accrue, soute pressurisée |
| Propulseurs | Montée lente | Vitesse ascendante et contrôle |
| Scanner | Aucun | Détection minerai, danger, artefact |
| Utilitaires | Aucun | Balise, explosifs, réparation, bouclier temporaire |

## Économie

- **Crédits impériaux** : monnaie principale obtenue par la vente des minerais.
- **Faveur du Mechanicus** : récompense de quêtes scientifiques ; nécessaire aux améliorations avancées.
- **Quota** : objectif de livraison périodique ; son échec réduit les récompenses et déclenche des messages narratifs.
- **Réparation et carburant** : dépenses récurrentes, servant à créer une tension économique sans rendre le joueur bloqué trop tôt.

## Direction artistique

- **Palette** : acier gris, rouille, brun poussiéreux, orange industriel, vert toxique et rouge impérial.
- **Décors** : pipelines, câbles, rails, carcasses de machines, chapelles mécaniques et galeries effondrées.
- **UI** : terminal industriel, cadres métalliques, alertes rouges, pictogrammes clairs et lisibles.
- **Animation** : vibrations de la foreuse, particules de poussière, étincelles, fumée et impacts de roche.

## Direction sonore

- Boucle moteur et bruit de foret dépendant de la charge.
- Alertes distinctes pour carburant bas, blindage faible, soute pleine et anomalie proche.
- Musique industrielle discrète avec chœurs graves dans les zones profondes.
- Messages radio courts du Commissaire, du Tech-Prêtre et de l'ordinateur de bord.

## Architecture Godot

```text
res://
├─ scenes/
│  ├─ main/Main.tscn
│  ├─ player/DrillRig.tscn
│  ├─ world/World.tscn
│  ├─ ui/HUD.tscn
│  ├─ ui/Shop.tscn
│  └─ ui/Dialogue.tscn
├─ scripts/
│  ├─ autoload/GameState.gd
│  ├─ player/DrillRig.gd
│  ├─ systems/MiningSystem.gd
│  ├─ systems/EconomySystem.gd
│  ├─ systems/NarrativeSystem.gd
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

### Scène `DrillRig.tscn`

```text
DrillRig (CharacterBody2D)
├─ Sprite2D
├─ CollisionShape2D
├─ DrillSystem (Node)
├─ FuelSystem (Node)
├─ ArmorSystem (Node)
├─ ScannerSystem (Node)
└─ Audio (Node)
   ├─ EngineAudio (AudioStreamPlayer2D)
   ├─ DrillAudio (AudioStreamPlayer2D)
   └─ AlertAudio (AudioStreamPlayer2D)
```

### Scène `Main.tscn`

```text
Main (Node2D)
├─ World (Node2D)
│  ├─ TerrainLayer (TileMapLayer)
│  ├─ OreLayer (TileMapLayer)
│  ├─ DecorationsLayer (TileMapLayer)
│  └─ Hazards (Node2D)
├─ DrillRig (instance)
├─ Camera2D
└─ UI (CanvasLayer)
   ├─ HUD
   ├─ Inventory
   ├─ Shop
   └─ Dialogue
```

## Données de tuile

Chaque tuile minable doit définir des **Custom Data Layers** dans le TileSet :

| Clé | Type | Exemple |
|---|---|---|
| `mineable` | bool | `true` |
| `hardness` | int | `3` |
| `resource_id` | String | `adamantium` |
| `value` | int | `180` |
| `hazard_type` | String | `gas` ou vide |
| `destructible` | bool | `true` |

## MVP jouable

Le premier prototype doit inclure uniquement :

1. Une foreuse avec mouvements ZQSD et flèches.
2. Un terrain de tuiles destructibles avec terre, roche et deux minerais.
3. Un forage vers le bas et latéral ; aucun forage vers le haut.
4. Une jauge de carburant et une soute limitée.
5. Une surface pour vendre les minerais et refaire le plein.
6. Trois améliorations : capacité de soute, carburant maximal, puissance du foret.
7. Une zone profonde avec une première anomalie scénarisée.
8. Une sauvegarde locale simple.

## Critères d'acceptation MVP

- Le joueur peut partir de la surface, creuser, collecter et revenir vendre sans bloquer la partie.
- Une tuile minable disparaît seulement si le foret a assez de puissance et que le joueur a du carburant.
- Les collisions empêchent la traversée des blocs non détruits.
- Les directions opposées ne génèrent ni mouvement ni comportement instable.
- L'interface affiche en temps réel carburant, blindage, crédits, charge de soute et profondeur.
- Après achat, une amélioration modifie immédiatement la statistique associée.
- La sauvegarde restitue position, ressources, crédits, améliorations et flags narratifs.

## Backlog après MVP

- Génération procédurale par strates.
- Éboulements et fluides/gaz simples.
- Scanner, carte des tunnels, téléportation de surface.
- Consommables et armes défensives.
- Quêtes du Mechanicus et choix narratifs.
- Plusieurs biomes, boss final et fins alternatives.
- Support manette, remappage complet et options d'accessibilité.

## Amendement — Cahier des charges gameplay addictif

> Section ajoutée le **2026-09-06** par la story `1.10`, sur arbitrage utilisateur **Q16**. Elle **ne modifie aucune section existante** de ce document : elle en déclare le complément.

Le document [`cahier_des_charges_gameplay_addictif.md`](cahier_des_charges_gameplay_addictif.md) est un **amendement thématique** à ce cahier des charges. Il n'y a pas deux cahiers des charges concurrents : celui-ci reste le document de référence du projet, l'amendement le complète sur les mécaniques de rétention.

### Règle de préséance

| Domaine | Document qui fait foi |
|---|---|
| Loot et récompense variable, économie et coûts d'amélioration, courbe de risque par profondeur, feedback des drops rares, durée de la boucle de session | **Amendement** |
| Univers, pitch, scénario et fins, contrôles et Input Map, règles de forage autorisées et interdites, direction artistique, architecture Godot, données de tuile | **Ce document** |

### Périmètre apporté par l'amendement, et son entrée au MVP

| § de l'amendement | Apport | Phase de réalisation |
|---|---|---|
| §2 — Boucle de récompense variable | Table de loot pondérée par couche de profondeur, tirage par poids, jamais 0 % de drop, feedback fort sur les raretés hautes | 3 |
| §3 — Progression infinie | Coût exponentiel `base × facteur^niveau`, **sans plafond dur**, **4 stats upgradables minimum**, effet ressenti dès la descente suivante | 5 |
| §4 — Risque croissant | Probabilité de rencontre hostile croissante avec la profondeur (2 % → 8 % → 18 % → 35 %), indicateur de danger non chiffré, **perte jamais totale** | 2 (socle `ArmorSystem`), 6 |
| §5 — Boucle de session | Une boucle complète descente → collecte → remontée → vente → amélioration doit durer **3 à 8 minutes** | 7 |
| §6 — Hors scope MVP | Streak / connexion quotidienne, leaderboard, multijoueur, near-miss compétitif — **exclus**, comme le sont les éléments du « Backlog après MVP » ci-dessus | — |

### Sections de ce document que l'amendement complète ou modifie

- **« Boucle de jeu »** — les étapes 2 et 6 se lisent désormais avec la boucle §5 de l'amendement et sa contrainte de durée.
- **« Ressources »** — la rareté des six ressources est croisée avec la table de loot pondérée du §2.2.
- **« Dangers »** — les menaces du §4.2 (créatures xenos, Nécrons, corruption warp, essaims Tyranides) entrent au MVP. Les dangers listés dans le tableau « Dangers » de ce document (roche dure, éboulement, gaz toxique, poche de prométhium, anomalie Warp) restent **post-MVP** : les deux listes ne se confondent pas.
- **« Améliorations »** — les paliers deviennent une **courbe de coût sans plafond**.
- **« Économie »** — les crédits impériaux sont la ressource pivot du §3.1.
- **« Direction sonore »** — s'y ajoutent le son distinct de drop rare (§2.4) et l'ambiance sonore de danger croissant (§4.3).
- **« MVP jouable »** — le point 4 (soute et carburant) est complété par le blindage réellement décrémenté ; le point 6 passe de **trois** à **au moins quatre** améliorations (§3.2 de l'amendement, qui prime) ; le point 7 accueille les menaces en plus de l'anomalie.
- **« Critères d'acceptation MVP »** — quatre critères s'ajoutent, issus des règles de design de l'amendement : jamais 0 % de drop (§2.4), aucun plafond de progression et coût atteignable en 1 à 3 descentes (§3.3), perte jamais totale en cas d'échec (§4.3), boucle de session comprise entre 3 et 8 minutes (§5).
- **« Backlog après MVP »** — inchangé, complété par le §6 de l'amendement.

### Conséquence sur les arbitrages antérieurs

L'entrée du système de dégâts au MVP (**Q17**) **annule** deux arbitrages rendus le 2026-08-29 : **Q3** (blindage affiché mais statique) et **Q8** (mort de la foreuse déclarée sans objet). Le détail et la traçabilité de cette annulation vivent dans `stories/BACKLOG.md` et `stories/AVANCEMENT.md`.
