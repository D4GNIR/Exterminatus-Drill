# Backlog — Motherload 40K : Exterminatus Drill

Liste ordonnée des phases et des stories du projet.
Référence fonctionnelle : `cahier_des_charges_motherload_40k_godot.md` · Méthodologie : `.claude/CLAUDE.md` · Gate qualité : `qa/README.md`.

## Conventions de lecture

- **1 phase = 1 sprint = 1 commit.** Chaque phase se termine par ses deux stories de gate : **audit qualité** puis **tests manuels humains**.
- Statuts : `À faire` · `En cours` · `Terminée` · `Bloquée`. **Une seule story `En cours` à la fois.**
- Les fichiers de stories ne sont créés qu'**à l'ouverture de la phase**. Pour les phases ≥ 2, les numéros affichés sont **prévisionnels** et ne deviennent fermes qu'à la création des fichiers (une story créée ne peut plus être renumérotée).
- **[H]** = critère exigeant un **jugement humain à l'écran** (rendu, ressenti de contrôle, équilibrage, audio, ergonomie). Godot 4.7.2 étant installé, tout ce qui relève de la syntaxe et du chargement est vérifié par les agents en headless — cf. `qa/README.md` §4.

---

## Vue d'ensemble

| Sprint | Phase | Objectif en une ligne | Stories | Statut |
|---|---|---|---|---|
| 0 | **0 — Amorçage du projet** | Aligner la méthodologie, produire le plan de travail, outiller la machine et poser le dépôt | 7 | 🟡 En cours |
| 1 | **1 — Fondations techniques Godot** | Un projet Godot 4 qui démarre : arborescence, Input Map, `GameState`, données, scènes squelettes | 8 | ⬜ À faire |
| 2 | **2 — Foreuse et déplacement** | Piloter la foreuse dans un tunnel : physique, carburant, caméra | ~6 | ⬜ À faire |
| 3 | **3 — Terrain destructible et forage** | Creuser et collecter, en respectant les règles de forage interdites | ~7 | ⬜ À faire |
| 4 | **4 — HUD et interfaces de bord** | Voir son état en temps réel et mettre le jeu en pause | ~6 | ⬜ À faire |
| 5 | **5 — Surface, économie et améliorations** | Fermer la boucle : vendre, ravitailler, améliorer | ~7 | ⬜ À faire |
| 6 | **6 — Zone profonde et anomalie scénarisée** | Donner un but narratif : descendre et déclencher l'anomalie | ~7 | ⬜ À faire |
| 7 | **7 — Sauvegarde locale et recette MVP** | Persister la partie et valider les 7 critères d'acceptation MVP | ~6 | ⬜ À faire |
| 8+ | **Post-MVP** | Extensions du « Backlog après MVP » du CDC | non détaillé | ⬜ À faire |

**MVP jouable atteint à la fin de la phase 7.**

---

## Phase 0 — Amorçage du projet · Sprint 0

Objectif : disposer d'un cadre de travail fiable (méthodologie, plan, dépôt, QA) avant la première ligne de code.

| # | Story | Statut |
|---|---|---|
| 0.1 | Nettoyage du squelette .claude | ✅ Terminée |
| 0.2 | Backlog, squelette QA et suivi d'avancement | ✅ Terminée |
| 0.3 | Initialisation du dépôt Git | ✅ Terminée |
| 0.4 | 🔒 **Gate 1/2** — Audit qualité — Sprint 0 | ⬜ À faire |
| 0.5 | 🔒 **Gate 2/2** — Revue humaine de fin de sprint 0 | ⬜ À faire |
| 0.6 | Installation de Godot 4 et requalification des critères `[H]` | ✅ Terminée |
| 0.7 | Commit et publication anticipés du dépôt *(dérogation demandée par l'utilisateur)* | 🟡 En cours |

> **Ordre d'exécution réel** : `0.1` → `0.2` → `0.6` → `0.3` → `0.7` → `0.4` → `0.5`. La story `0.6` est numérotée après les gates car `0.4`/`0.5` existaient déjà et une story créée ne se renumérote pas.

> Gate adaptée : le sprint 0 ne produit pas de code. L'audit porte sur la cohérence documentaire et le dépôt ; les « tests manuels » prennent la forme d'une revue de recevabilité du plan par l'utilisateur.

---

## Phase 1 — Fondations techniques du projet Godot · Sprint 1

Objectif : un projet Godot 4 qui s'importe, se lance, expose ses contrôles et son état — sans aucune règle de gameplay encore.

| # | Story | Statut | Dépend de |
|---|---|---|---|
| 1.1 | Initialisation du projet Godot 4 | ⬜ À faire | 0.3 |
| 1.2 | Arborescence contractuelle du projet | ⬜ À faire | 1.1 |
| 1.3 | Input Map complet | ⬜ À faire | 1.1 |
| 1.4 | Autoload GameState | ⬜ À faire | 1.2 |
| 1.5 | Socle de données JSON | ⬜ À faire | 1.2, 1.4 |
| 1.6 | Scènes squelettes Main et World | ⬜ À faire | 1.2, 1.4 |
| 1.7 | 🔒 **Gate 1/2** — Audit qualité — Sprint 1 | ⬜ À faire | 1.1 → 1.6 |
| 1.8 | 🔒 **Gate 2/2** — Tests manuels humains — Sprint 1 | ⬜ À faire | 1.7 (verdict Autorisé) |

---

## Phase 2 — Foreuse et déplacement · Sprint 2 *(prévisionnel)*

Objectif : une foreuse pilotable dans un tunnel, soumise à la gravité, au carburant et suivie par la caméra.

| # (prév.) | Story | Statut |
|---|---|---|
| 2.1 | Scène `DrillRig.tscn` (arbre contractuel : Sprite, Collision, Drill/Fuel/Armor/Scanner, Audio) | ⬜ À faire |
| 2.2 | Déplacement et physique (gravité, inertie, `brake`, annulation des directions opposées) | ⬜ À faire |
| 2.3 | Composant `FuelSystem` (consommation, panne sèche : ni forage ni propulsion) | ⬜ À faire |
| 2.4 | Caméra de suivi et limites de monde | ⬜ À faire |
| 2.5 | 🔒 Audit qualité — Sprint 2 | ⬜ À faire |
| 2.6 | 🔒 Tests manuels humains — Sprint 2 | ⬜ À faire |

Couvre : « MVP jouable » 1 et 4 (partiel) · « Règles autorisées » · « Règles interdites » (directions opposées, panne sèche).

---

## Phase 3 — Terrain destructible et forage · Sprint 3 *(prévisionnel)*

Objectif : le cœur du jeu — creuser terre, roche et 2 minerais, avec les interdits de forage réellement appliqués.

| # (prév.) | Story | Statut |
|---|---|---|
| 3.1 | TileSet et Custom Data Layers (`mineable`, `hardness`, `resource_id`, `value`, `hazard_type`, `destructible`) | ⬜ À faire |
| 3.2 | Terrain de test : surface + strates terre/roche + 2 minerais + bordures indestructibles | ⬜ À faire |
| 3.3 | `MiningSystem` : forage bas et latéral, **aucun forage vers le haut**, **aucun forage latéral dans le vide** | ⬜ À faire |
| 3.4 | Collecte des minerais et soute limitée | ⬜ À faire |
| 3.5 | Retour de forage (progression, particules, audio) | ⬜ À faire |
| 3.6 | 🔒 Audit qualité — Sprint 3 | ⬜ À faire |
| 3.7 | 🔒 Tests manuels humains — Sprint 3 | ⬜ À faire |

Couvre : « MVP jouable » 2, 3, 4 · « Données de tuile » · « Règles interdites ou limitées ».

---

## Phase 4 — HUD et interfaces de bord · Sprint 4 *(prévisionnel)*

Objectif : rendre l'état du jeu lisible en temps réel et permettre la pause — prérequis pour tester l'économie du sprint 5.

| # (prév.) | Story | Statut |
|---|---|---|
| 4.1 | `HUD.tscn` : carburant, blindage, crédits, charge de soute, profondeur (branchés aux signaux de `GameState`) | ⬜ À faire |
| 4.2 | Alertes (carburant bas, blindage faible, soute pleine) | ⬜ À faire |
| 4.3 | Menu pause (`pause`) et cohérence des `process_mode` | ⬜ À faire |
| 4.4 | Inventaire / soute (`toggle_inventory`, jeu en pause, inputs étanches) | ⬜ À faire |
| 4.5 | 🔒 Audit qualité — Sprint 4 | ⬜ À faire |
| 4.6 | 🔒 Tests manuels humains — Sprint 4 | ⬜ À faire |

Couvre : critère MVP « L'interface affiche en temps réel carburant, blindage, crédits, charge de soute et profondeur » · « Direction artistique » (UI terminal industriel) · « Direction sonore » (alertes).

---

## Phase 5 — Surface, économie et améliorations · Sprint 5 *(prévisionnel)*

Objectif : fermer la boucle de jeu — remonter, vendre, ravitailler, améliorer, repartir plus profond.

| # (prév.) | Story | Statut |
|---|---|---|
| 5.1 | Zone de surface et station (détection d'arrivée, ouverture de l'interface) | ⬜ À faire |
| 5.2 | `EconomySystem` : vente des minerais et crédits impériaux | ⬜ À faire |
| 5.3 | Ravitaillement carburant et réparation | ⬜ À faire |
| 5.4 | `Shop.tscn` et les 3 améliorations MVP (soute, carburant max, puissance du foret) | ⬜ À faire |
| 5.5 | Application immédiate des améliorations à la statistique associée | ⬜ À faire |
| 5.6 | 🔒 Audit qualité — Sprint 5 | ⬜ À faire |
| 5.7 | 🔒 Tests manuels humains — Sprint 5 | ⬜ À faire |

Couvre : « MVP jouable » 5 et 6 · « Boucle de jeu » · « Économie » · « Améliorations » · critères MVP « boucle non bloquante » et « amélioration immédiate ».

---

## Phase 6 — Zone profonde et anomalie scénarisée · Sprint 6 *(prévisionnel)*

Objectif : donner un but narratif au forage — une strate profonde et une première anomalie déclenchée une seule fois.

| # (prév.) | Story | Statut |
|---|---|---|
| 6.1 | Strate profonde (transition de zone perceptible) | ⬜ À faire |
| 6.2 | `Dialogue.tscn` (messages radio Commissaire / Tech-Prêtre) | ⬜ À faire |
| 6.3 | `NarrativeSystem` et flags narratifs persistants | ⬜ À faire |
| 6.4 | Anomalie MVP scénarisée (déclenchement unique par profondeur) | ⬜ À faire |
| 6.5 | Journal minimal (`toggle_journal`) | ⬜ À faire |
| 6.6 | 🔒 Audit qualité — Sprint 6 | ⬜ À faire |
| 6.7 | 🔒 Tests manuels humains — Sprint 6 | ⬜ À faire |

Couvre : « MVP jouable » 7 · « Scénario » (prologue, progression narrative) · « Contrôles » (`toggle_journal`).

---

## Phase 7 — Sauvegarde locale et recette MVP · Sprint 7 *(prévisionnel)*

Objectif : rendre la partie persistante et prouver, critère par critère, que le MVP du CDC est atteint.

| # (prév.) | Story | Statut |
|---|---|---|
| 7.1 | `SaveSystem` : écriture/lecture dans `user://` (position, ressources, crédits, améliorations, flags) | ⬜ À faire |
| 7.2 | Persistance du terrain creusé | ⬜ À faire |
| 7.3 | Nouvelle partie, chargement, robustesse (fichier absent ou corrompu) | ⬜ À faire |
| 7.4 | Recette MVP et premier passage d'équilibrage | ⬜ À faire |
| 7.5 | 🔒 Audit qualité — Sprint 7 | ⬜ À faire |
| 7.6 | 🔒 Tests manuels humains — Sprint 7 (recette MVP complète) | ⬜ À faire |

Couvre : « MVP jouable » 8 · critère MVP « La sauvegarde restitue position, ressources, crédits, améliorations et flags narratifs » · l'ensemble des « Critères d'acceptation MVP ».

---

## Phases post-MVP *(non détaillées — reprise du « Backlog après MVP » du CDC)*

Ces phases ne seront découpées en stories qu'à leur ouverture, après validation du MVP.

| Phase | Intitulé | Source CDC |
|---|---|---|
| 8 | Génération procédurale par strates | « Backlog après MVP » |
| 9 | Éboulements, gaz et fluides simples | « Backlog après MVP », « Dangers » |
| 10 | Scanner, carte des tunnels, téléportation de surface | « Backlog après MVP », « Améliorations » |
| 11 | Consommables et armes défensives | « Backlog après MVP », « Contrôles » (`use_item_1..3`) |
| 12 | Quêtes du Mechanicus et choix narratifs | « Backlog après MVP », « Économie » (faveur, quota) |
| 13 | Biomes multiples, boss final et fins alternatives | « Backlog après MVP », « Scénario » (3 fins) |
| 14 | Support manette, remappage complet, accessibilité | « Backlog après MVP », « Contrôles » |
| 15 | Direction artistique et sonore définitive, export PC / Web | « Direction artistique », « Direction sonore », « Vision » |

---

## Traçabilité — « MVP jouable » (8 points du CDC)

| # | Point du CDC | Phase(s) |
|---|---|---|
| 1 | Foreuse avec mouvements ZQSD et flèches | 1 (Input Map), 2 |
| 2 | Terrain de tuiles destructibles : terre, roche, 2 minerais | 3 |
| 3 | Forage bas et latéral, aucun forage vers le haut | 3 |
| 4 | Jauge de carburant et soute limitée | 2 (carburant), 3 (soute), 4 (affichage) |
| 5 | Surface pour vendre et refaire le plein | 5 |
| 6 | Trois améliorations : soute, carburant max, puissance du foret | 1 (données), 5 |
| 7 | Zone profonde avec une première anomalie scénarisée | 6 |
| 8 | Sauvegarde locale simple | 7 |

## Traçabilité — « Critères d'acceptation MVP » (7 critères du CDC)

| Critère | Phase de validation | Cas de test |
|---|---|---|
| Partir, creuser, collecter, revenir vendre sans bloquer la partie | 5 | TM-5.8 |
| Tuile détruite seulement si puissance de foret et carburant suffisants | 3, 5 | TM-3.1, TM-3.5, TM-3.9, TM-5.6 |
| Collisions empêchant la traversée des blocs non détruits | 2, 3 | TM-2.6, TM-3.6 |
| Directions opposées : ni mouvement ni comportement instable | 2 | TM-2.2 |
| HUD temps réel (carburant, blindage, crédits, soute, profondeur) | 4 | TM-4.1, TM-4.2 |
| Amélioration achetée ⇒ statistique modifiée immédiatement | 5 | TM-5.5, TM-5.6 |
| Sauvegarde restituant position, ressources, crédits, améliorations, flags | 7 | TM-7.1, TM-7.2 |

---

## Points en attente d'arbitrage utilisateur

Ces points ne sont **pas** tranchés par les agents. Ils doivent l'être avant la phase indiquée.

### Tranchés — arbitrage utilisateur du 2026-08-29

Les quatre points bloquant la phase 1 sont réglés. La décision fait foi pour l'audit : un choix listé ici n'est **pas** un écart au CDC.

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q1 | Renderer et résolution de référence | **`GL Compatibility`** (préserve l'export Web du CDC) · base **1280×720**, `stretch=canvas_items`, `aspect=expand` — résolution à reconfirmer avant `3.2` | Story 1.1 |
| Q2 | Mapping clavier | **`physical_keycode`** : ZQSD sur AZERTY, WASD sur QWERTY, sans code conditionnel. Aucun libellé de touche en dur à l'écran. | Story 1.3 |
| Q3 | Blindage au MVP | **Jauge affichée mais statique.** `armor` / `armor_max` existent dans `GameState` et alimentent le HUD ; rien ne les décrémente avant le post-MVP. | Story 1.4 |
| Q4 | Emplacement du chargeur de données | **Autoload `scripts/autoload/GameData.gd`** — déviation assumée de l'arborescence du CDC, **validée** : conforme au point d'audit A3. Chargé avant `GameState`. | Story 1.5 |

### En attente

| # | Question | À trancher avant | Tracé dans |
|---|---|---|---|
| Q5 | Comportement en **soute pleine** : refus de collecte, ou minerai perdu avec alerte ? | Phase 3 | Story 3.4 (à créer) |
| Q6 | Terrain du MVP : **statique conçu à la main** (recommandé, la génération procédurale est post-MVP) ou déjà semi-procédural ? | Phase 3 | Story 3.2 (à créer) |
| Q7 | Sauvegarde : automatique au retour en surface, manuelle, ou les deux ? | Phase 7 | Story 7.1 (à créer) |
| ~~Q8~~ | ~~Mort de la foreuse (blindage à zéro)~~ | **Sans objet au MVP** — conséquence de Q3 : sans système de dégâts, le blindage ne peut pas atteindre zéro. Repoussée avec les dangers, en post-MVP. | Story 1.4 |
