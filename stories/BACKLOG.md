# Backlog — Motherload 40K : Exterminatus Drill

Liste ordonnée des phases et des stories du projet.
Référence fonctionnelle : `cahier_des_charges_motherload_40k_godot.md`, **amendé par `cahier_des_charges_gameplay_addictif.md`** (arbitrage **Q16** du 2026-09-06 — mécaniques de rétention, périmètre MVP) · Méthodologie : `.claude/CLAUDE.md` · Gate qualité : `qa/README.md`.

> **Préséance des deux documents** : l'amendement fait foi pour le loot, l'économie, la courbe de risque et la durée de boucle ; le CDC principal fait foi pour l'univers, les contrôles, les règles de forage, l'architecture Godot et les données de tuile. Détail dans la section « Amendement — Cahier des charges gameplay addictif » du CDC principal.

## Conventions de lecture

- **1 phase = 1 sprint = 1 commit.** Chaque phase se termine par ses deux stories de gate : **audit qualité** puis **tests manuels humains**.
- Statuts : `À faire` · `En cours` · `Terminée` · `Bloquée`. **Une seule story `En cours` à la fois.**
- Les fichiers de stories ne sont créés qu'**à l'ouverture de la phase**. Pour les phases ≥ 2, les numéros affichés sont **prévisionnels** et ne deviennent fermes qu'à la création des fichiers (une story créée ne peut plus être renumérotée).
- **[H]** = critère exigeant un **jugement humain à l'écran** (rendu, ressenti de contrôle, équilibrage, audio, ergonomie). Godot 4.7.2 étant installé, tout ce qui relève de la syntaxe et du chargement est vérifié par les agents en headless — cf. `qa/README.md` §4.

---

## Vue d'ensemble

| Sprint | Phase | Objectif en une ligne | Stories | Statut |
|---|---|---|---|---|
| 0 | **0 — Amorçage du projet** | Aligner la méthodologie, produire le plan de travail, outiller la machine et poser le dépôt | 10 | ✅ Close |
| 1 | **1 — Fondations techniques Godot** | Un projet Godot 4 qui démarre : arborescence, Input Map, `GameState`, données, scènes squelettes | 12 | ✅ Close ⚠️ |
| 2 | **2 — Foreuse et déplacement** | Piloter la foreuse dans un tunnel : physique, carburant, caméra, **socle de dégâts** | ~7 | 🟡 **Phase courante** |
| 3 | **3 — Terrain destructible et forage** | Creuser et collecter sur un terrain **généré**, avec **loot pondéré par couche**, en respectant les règles de forage interdites | ~9 | ⬜ À faire |
| 4 | **4 — HUD et interfaces de bord** | Voir son état en temps réel et mettre le jeu en pause | ~6 | ⬜ À faire |
| 5 | **5 — Surface, économie et améliorations** | Fermer la boucle : vendre, ravitailler, améliorer — **progression infinie sans plafond** | ~9 | ⬜ À faire |
| 6 | **6 — Zone profonde, menaces et anomalie scénarisée** | Descendre, affronter un **risque croissant** et déclencher l'anomalie | ~10 ⚠️ | ⬜ À faire |
| 7 | **7 — Sauvegarde locale et recette MVP** | Persister la partie, **valider la boucle 3-8 min** et les critères d'acceptation MVP | ~8 | ⬜ À faire |
| 8+ | **Post-MVP** | Extensions du « Backlog après MVP » du CDC et du §6 de l'amendement | non détaillé | ⬜ À faire |

**MVP jouable atteint à la fin de la phase 7.**

> **Volumes révisés le 2026-09-06** (story `1.10`, intégration de l'amendement « gameplay addictif », arbitrage **Q19** : extension des phases existantes, aucune phase nouvelle). Total MVP : **59 → 68 stories**. Détail des ajouts : phase 1 `+1` (la story d'intégration elle-même), phase 2 `+1`, phase 3 `+1`, phase 5 `+2`, phase 6 `+3`, phase 7 `+1`.
>
> **Révision du 2026-09-06 (suite, story `1.11`)** : total porté à **69** par la seule story `1.11` (arbitrages Q20-Q22). Les arbitrages `Q20`, `Q21` et `Q22` **ne changent aucun volume de phase** : ils précisent l'objet de stories déjà prévues (`2.5`, `5.7`) et confirment la charge de la phase 6. Addition recalculée : 9 + 11 + 7 + 9 + 6 + 9 + 10 + 8 = **69**.
>
> ⚠️ **Phase 6 en surcharge — ACCEPTÉE par l'utilisateur le 2026-09-06 (`Q22`)** : 7 → **10 stories** (8 de développement + 2 de gate), et changement d'objet — elle porte désormais le système de dégâts et de menaces en plus de la narration. C'est la conséquence directe de la tension entre **Q17** (dégâts et menaces au MVP) et **Q19** (interdiction d'ouvrir une phase dédiée). **Décision `Q22` : un seul sprint, une seule gate**, ni scission ni redistribution vers la phase 4. Le risque n'est pas levé, il est **assumé** ; les deux options écartées restent réactivables si la phase dérape — réexamen possible à la clôture de la phase 5.

---

## Phase 0 — Amorçage du projet · Sprint 0

Objectif : disposer d'un cadre de travail fiable (méthodologie, plan, dépôt, QA) avant la première ligne de code.

| # | Story | Statut |
|---|---|---|
| 0.1 | Nettoyage du squelette .claude | ✅ Terminée |
| 0.2 | Backlog, squelette QA et suivi d'avancement | ✅ Terminée |
| 0.3 | Initialisation du dépôt Git | ✅ Terminée |
| 0.4 | 🔒 **Gate 1/2** — Audit qualité — Sprint 0 | ✅ Terminée — verdict **Autorisé** (2 KO mineurs) |
| 0.5 | 🔒 ~~**Gate 2/2** — Revue humaine de fin de sprint 0~~ | ⛔ **Annulée** (décision utilisateur, story `0.10`) |
| 0.6 | Installation de Godot 4 et requalification des critères `[H]` | ✅ Terminée |
| 0.7 | Commit et publication anticipés du dépôt *(dérogation demandée par l'utilisateur)* | ✅ Terminée |
| 0.8 | Remise à niveau du suivi et portabilité du `.gitignore` *(correction des écarts de l'audit `0.4`)* | ✅ Terminée |
| 0.9 | Correction du prérequis `P1` et des références de gate | ✅ Terminée |
| 0.10 | Annulation de la revue humaine du sprint 0 | ✅ Terminée |

> **Ordre d'exécution réel** : `0.1` → `0.2` → `0.6` → `0.3` → `0.7` → `0.4` → `0.8` → `0.9` → `0.10`. La story `0.5` est **annulée**, non exécutée. La story `0.6` est numérotée après les gates car `0.4`/`0.5` existaient déjà et une story créée ne se renumérote pas.

> **Verdict de l'audit `0.4` (2026-08-29) : Autorisé** — 58 points, 7 OK · 2 KO mineurs · 49 N/A. Aucun KO bloquant `[B]`. Deux KO mineurs tracés : `stories/AVANCEMENT.md` non à jour (I4) et exclusion non portable de `.claude/settings.local.json` (J1). Les deux écarts ont été **levés par la story `0.8`** (créée sur décision de l'utilisateur, traitée avant `0.5` comme recommandé). La gate 1/2 est franchie ; `0.5` est débloquée.

> Gate adaptée : le sprint 0 ne produit pas de code. L'audit porte sur la cohérence documentaire et le dépôt.

> ⛔ **Gate 2/2 annulée pour ce sprint uniquement** (story `0.10`, décision utilisateur du 2026-08-29). La phase 0 est close avec la seule gate d'audit `0.4`. Les cas `TM-0.1` à `TM-0.3` ne seront pas exécutés — dont `TM-0.2` (bloquant), qui vérifiait humainement que les 8 points « MVP jouable » et les 7 critères d'acceptation du CDC sont tous couverts. **Les gates de tests manuels des sprints 1 à 7 restent en vigueur** : elles portent sur du code et sur les critères `[H]`, qu'aucun agent ne peut valider.

---

## Phase 1 — Fondations techniques du projet Godot · Sprint 1

Objectif : un projet Godot 4 qui s'importe, se lance, expose ses contrôles et son état — sans aucune règle de gameplay encore.

| # | Story | Statut | Dépend de |
|---|---|---|---|
| 1.1 | Initialisation du projet Godot 4 | ✅ Terminée | 0.3 |
| 1.2 | Arborescence contractuelle du projet | ✅ Terminée | 1.1 |
| 1.3 | Input Map complet | ✅ Terminée | 1.1 |
| 1.4 | Autoload GameState | ✅ Terminée | 1.2 |
| 1.5 | Socle de données JSON | ✅ Terminée | 1.2, 1.4 |
| 1.6 | Scènes squelettes Main et World | ✅ Terminée | 1.2, 1.4 |
| 1.7 | 🔒 **Gate 1/2** — Audit qualité — Sprint 1 | ✅ Terminée | 1.1 → 1.6 |
| 1.8 | 🔒 **Gate 2/2** — Tests manuels humains — Sprint 1 | ✅ Terminée — **close sur décision, campagne non exécutée** | 1.7 ✅ Autorisé |
| 1.9 | Exception autoload de la règle `ERROR` en `--check-only` | ✅ Terminée | 1.5 |
| 1.10 | Intégration du cahier des charges gameplay addictif *(documentaire, sans code — Q16 à Q19)* | ✅ Terminée | 1.4, 1.5 |
| 1.11 | Arbitrages Q20 à Q22 et alignement des fichiers `.claude/` *(documentaire, sans code)* | ✅ Terminée | 1.10 |
| 1.12 | Correction des procédures de test du rapport sprint 1 *(déblocage de `TM-1.6`, documentaire, sans code)* | ✅ Terminée | 1.6, 1.8 |

> ✅ **Phase 1 close le 2026-09-06.** Les 12 stories sont `Terminée`.
>
> ⚠️ **La gate `1.8` est close SUR DÉCISION de l'utilisateur, campagne NON exécutée** — motif donné : *« c'est pas des points essentiels »*. **0 cas exécuté sur 7** ; aucune case cochée, aucun résultat inventé ; les **9 critères `[H]`** des stories `1.1` à `1.6` restent **non vérifiés**, ni confirmés ni infirmés. Verdict et état détaillé : `qa/rapports/sprint-1-tests-manuels-2026-08-31.md`. Précédent de même nature : la gate `0.5` du sprint 0, annulée par décision utilisateur (story `0.10`).
>
> **Règle de gate satisfaite** : `.claude/CLAUDE.md` interdit de commiter la phase tant que **les deux stories de gate** ne sont pas `Terminée`. `1.7` est `Terminée` (audit **Autorisé**, 0 KO) et `1.8` l'est désormais. **Le commit `Phase 1 — Fondations techniques du projet Godot` est donc autorisé.** La condition remplie est **formelle** : elle ne dit rien de ce qui a été constaté à l'écran, et rien ne l'a été.
>
> **Dette léguée au sprint 2** : les fondations de la phase 1 n'ont jamais été vues dans l'éditeur. La gate du sprint 2 héritera de fait de leur vérification, en plus de la sienne et de `TM-1.5` (déjà reporté par **Q9**). Risque inscrit à `stories/AVANCEMENT.md` §5.

> **Story `1.12` — déblocage de la campagne `1.8`** : le testeur humain était **bloqué sur `TM-1.6`**, dont la procédure était inexécutable (vocabulaire Godot 3, et lecture de variables privées que l'éditeur n'affiche pas). `1.12` corrige **cinq procédures** du rapport `qa/rapports/sprint-1-tests-manuels-2026-08-31.md` — jamais un verdict, jamais une case cochée, jamais la section « Anomalies ». `1.8` reste `En cours` et reprend là où le testeur s'était arrêté.
>
> **Précédent assumé sur `1.10`, `1.11` et `1.12`** : la story est ouverte alors que `1.8` est encore `En cours`, dans les mêmes conditions que `1.9` — `1.8` est une gate **humaine** bloquée sur une action hors agent. Le statut de `1.8` n'est pas modifié, aucun code n'est touché, et **aucun commit de phase 1** n'intervient avant sa clôture.

---

## Phase 2 — Foreuse et déplacement · Sprint 2 *(prévisionnel)*

Objectif : une foreuse pilotable dans un tunnel, soumise à la gravité, au carburant et suivie par la caméra — et dotée du **socle de dégâts** exigé par l'amendement (§4).

| # (prév.) | Story | Statut |
|---|---|---|
| 2.1 | Scène `DrillRig.tscn` (arbre contractuel : Sprite, Collision, Drill/Fuel/Armor/Scanner, Audio) — **élargie par Q17** : `ArmorSystem` cesse d'être un nœud vide, il porte un script | ⬜ À faire |
| 2.2 | Déplacement et physique (gravité, inertie, `brake`, annulation des directions opposées) | ⬜ À faire |
| 2.3 | Composant `FuelSystem` (consommation, panne sèche : ni forage ni propulsion) | ⬜ À faire |
| 2.4 | Caméra de suivi et limites de monde | ⬜ À faire |
| 2.5 | **`ArmorSystem` et dégâts de chute/impact** *(Q17 — annule Q3 et Q8 · Q20)* : dégâts **proportionnels à la vitesse d'impact**, seuil et coefficient **en données** ; décrément réel du blindage ; état de destruction. **Source de dégâts et consommateur livrés dans le même sprint** | ⬜ À faire |
| 2.6 | 🔒 Audit qualité — Sprint 2 | ⬜ À faire |
| 2.7 | 🔒 Tests manuels humains — Sprint 2 | ⬜ À faire |

Couvre : « MVP jouable » 1 et 4 (partiel) · « Règles autorisées » · « Règles interdites » (directions opposées, panne sèche) · **amendement §4.1 et §4.3** (socle du système de dégâts).

> ✅ **`Q20` tranchée le 2026-09-06 : dégâts de chute et d'impact, dès la phase 2.** La story `2.5` livre **la source de dégâts et son consommateur dans le même sprint** : l'`ArmorSystem` n'est donc **jamais un composant sans appelant**, et le point d'audit `B6` (code mort) sortira `OK` à l'audit `2.6` sans exception à plaider. Un cas de test de la phase 2 doit constater un **blindage réellement décrémenté à l'écran** (`TM-2.9`), pas seulement une fonction appelable.
>
> ⚠️ **Ajout de périmètre assumé** : les dégâts de chute ne figurent **ni dans le CDC principal, ni dans l'amendement**. C'est une décision de l'utilisateur, cohérente avec le genre. Ne pas la confondre avec l'« **Éboulement** » de la section « Dangers » du CDC principal, qui reste **post-MVP** : l'éboulement est un événement de terrain, l'impact est une conséquence directe de la physique de `2.2`. Les menaces de la courbe §4.2 (phase 6) s'**ajoutent** aux dégâts d'impact, elles ne les remplacent pas.

---

## Phase 3 — Terrain destructible et forage · Sprint 3 *(prévisionnel)*

Objectif : le cœur du jeu — creuser terre, roche et 2 minerais, avec les interdits de forage réellement appliqués, et **récompenser chaque case creusée** selon une table de loot pondérée par couche.

| # (prév.) | Story | Statut |
|---|---|---|
| 3.1 | TileSet et Custom Data Layers (`mineable`, `hardness`, `resource_id`, `value`, `hazard_type`, `destructible`) | ⬜ À faire |
| 3.2 | **Générateur de terrain semi-procédural** (Q6) : strates terre/roche par profondeur, densité des 2 minerais, bordures indestructibles, **graine explicite et forçable** · `data/generation.json` (Q15) | ⬜ À faire |
| 3.3 | Ancrages déterministes indépendants de la graine : zone de surface, emplacement de l'anomalie | ⬜ À faire |
| 3.4 | `MiningSystem` : forage bas et latéral, **aucun forage vers le haut**, **aucun forage latéral dans le vide** | ⬜ À faire |
| 3.5 | Collecte des minerais et soute limitée — **soute pleine : tuile détruite, minerai perdu** (Q5), avec alerte préalable et perte visible | ⬜ À faire |
| 3.6 | **Table de loot pondérée par couche et tirage reproductible** *(amendement §2.1 à §2.3)* : poids par couche dans `data/generation.json`, tirage par le RNG ensemencé de `3.2`, **jamais 0 % de drop** (§2.4), aucune ressource `actif_mvp=false` tirée (Q12) | ⬜ À faire |
| 3.7 | Retour de forage (progression, particules, audio) — **élargi** : feedback fort et durable sur les raretés hautes, lumière et son distincts (§2.4) | ⬜ À faire |
| 3.8 | 🔒 Audit qualité — Sprint 3 | ⬜ À faire |
| 3.9 | 🔒 Tests manuels humains — Sprint 3 | ⬜ À faire |

Couvre : « MVP jouable » 2, 3, 4 · « Données de tuile » · « Règles interdites ou limitées » · arbitrages **Q5**, **Q6** et **Q19** · **amendement §2** (boucle de récompense variable) et **§7.1** (priorité de développement n° 1).

> ⚠️ **Périmètre élargi par Q6** : la génération procédurale, placée en post-MVP par le CDC, remonte dans ce sprint. Volume révisé à 8 stories. Une **graine fixe** est imposée pendant toute la campagne de tests manuels du sprint, sans quoi aucun résultat n'est reproductible — cf. prérequis `P4` de `qa/plan-tests-manuels.md`.

> **Renumérotation du 2026-08-29** : les entrées provisoires `3.2b` et `7.3b`, non conformes à la nomenclature `<phase>.<sous-tâche>` de `.claude/CLAUDE.md`, ont été résorbées en séquence continue (phase 3 : 8 stories, `3.7`/`3.8` en gate · phase 7 : 7 stories, `7.6`/`7.7` en gate). Opération licite : aucun fichier de story de ces phases n'existe encore, la numérotation restait prévisionnelle.

> **Renumérotation du 2026-09-06** (story `1.10`, intégration de l'amendement) : l'insertion de stories dans les phases 2, 3, 5, 6 et 7 décale les **gates prévisionnelles**, qui restent en dernière position de leur phase — `2.5`/`2.6` → **`2.6`/`2.7`** · `3.7`/`3.8` → **`3.8`/`3.9`** · `5.6`/`5.7` → **`5.8`/`5.9`** · `6.6`/`6.7` → **`6.9`/`6.10`** · `7.6`/`7.7` → **`7.7`/`7.8`**. Opération licite pour la même raison qu'en 2026-08-29 : **aucun fichier de story de ces phases n'existe**, la numérotation y reste prévisionnelle. **Aucun fichier existant n'a été renommé ni renuméroté.**
>
> Conséquence documentaire à traiter côté utilisateur : `.claude/CLAUDE.md` cite en exemple « `3.7` audit → `3.8` tests », qui devient « `3.8` → `3.9` ». Ces exemples sont **explicitement non opposables** (le présent fichier fait foi), mais leur dérive s'accroît — cf. `stories/AVANCEMENT.md` §5.

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

Objectif : fermer la boucle de jeu — remonter, vendre, ravitailler, améliorer, repartir plus profond — avec une **progression économique infinie**, sans plafond dur.

| # (prév.) | Story | Statut |
|---|---|---|
| 5.1 | Zone de surface et station (détection d'arrivée, ouverture de l'interface) | ⬜ À faire |
| 5.2 | `EconomySystem` : vente du loot et crédits impériaux (ressource pivot, §3.1) | ⬜ À faire |
| 5.3 | Ravitaillement carburant et réparation *(la réparation redevient utile : Q17 annule Q3)* | ⬜ À faire |
| 5.4 | `Shop.tscn` et les améliorations actives au MVP — **au moins 4 stats** (§3.2), soute / réacteur / foret / **blindage activé par Q17** | ⬜ À faire |
| 5.5 | Application immédiate des améliorations à la statistique associée — **effet ressenti dès la descente suivante** (§3.3) | ⬜ À faire |
| 5.6 | **Formule de coût exponentielle et progression sans plafond** *(Q18)* : `data/upgrades.json` en `schema_version: 2`, `cout = base × facteur^niveau`, `id` inchangés (Q12), aucun `niveau_max` | ⬜ À faire |
| 5.7 | **Quatrième amélioration active : activation de `blindage` et paliers supérieurs** *(Q21)* — `actif_mvp: false → true` ; le catalogue ne lui déclare aujourd'hui que le palier 1, de coût nul. **Aucun `id` nouveau** (Q12 intacte) | ⬜ À faire |
| 5.8 | 🔒 Audit qualité — Sprint 5 | ⬜ À faire |
| 5.9 | 🔒 Tests manuels humains — Sprint 5 | ⬜ À faire |

Couvre : « MVP jouable » 5 et 6 · « Boucle de jeu » · « Économie » · « Améliorations » · critères MVP « boucle non bloquante » et « amélioration immédiate » · **amendement §3** (progression infinie) et **§7.2** (priorité de développement n° 2).

> ✅ **`Q21` tranchée le 2026-09-06 : quatre améliorations actives au MVP** — `soute`, `reacteur`, `foret`, `blindage`. Le minimum de 4 stats du §3.2 est atteint **sans créer aucun `id`** : `blindage` passe simplement `actif_mvp: true` et reçoit des paliers supérieurs. La contrainte **Q12** (`id` définitifs) reste intacte. La contradiction entre le point 6 du « MVP jouable » (trois améliorations) et le §3.2 (quatre minimum) est donc tranchée en faveur de l'amendement, conformément à la préséance **Q16**.
>
> ⚠️ **Deux non-couvertures assumées du §3.2**, tracées dans la table de traçabilité de l'amendement et **non passées sous silence** : (1) « **profondeur max sûre** » est **reportée post-MVP** — son effet recouvre la courbe de risque de la phase 6 et c'est la moins tangible des quatre au regard de la règle §3.3 ; (2) « **vitesse de forage** » n'est **pas couverte au MVP** — `foret` reste une **puissance** (seuil de `hardness`), conformément au point 6 du « MVP jouable » et à `data/upgrades.json`. **À rouvrir en post-MVP**, où puissance et vitesse pourront devenir deux axes distincts.

---

## Phase 6 — Zone profonde, menaces et anomalie scénarisée · Sprint 6 *(prévisionnel)*

Objectif **élargi par Q17/Q19** : donner un but narratif au forage — une strate profonde et une première anomalie déclenchée une seule fois — **et** rendre la profondeur risquée, en implantant la courbe de risque du §4.2 et le dilemme « remonter vendre ou pousser plus loin » du §4.1.

| # (prév.) | Story | Statut |
|---|---|---|
| 6.1 | Strate profonde (transition de zone perceptible) — **élargie** : les **4 paliers de profondeur** de la courbe §4.2 (0-50 m, 50-150 m, 150-300 m, 300 m+) deviennent une donnée | ⬜ À faire |
| 6.2 | `Dialogue.tscn` (messages radio Commissaire / Tech-Prêtre) | ⬜ À faire |
| 6.3 | `NarrativeSystem` et flags narratifs persistants | ⬜ À faire |
| 6.4 | Anomalie MVP scénarisée (déclenchement unique par profondeur) | ⬜ À faire |
| 6.5 | Journal minimal (`toggle_journal`) | ⬜ À faire |
| 6.6 | **Courbe de risque et spawn de menaces par profondeur** *(§4.1, §4.2)* : probabilité de rencontre par case creusée — 2 % → 8 % → 18 % → 35 % — externalisée en données, RNG **distinct** de celui de la génération, 4 types de menace | ⬜ À faire |
| 6.7 | **Dégâts, perte partielle du cargo et état de destruction** *(§4.3, Q17)* : la menace consomme l'`ArmorSystem` de `2.5` ; à blindage nul, **une fraction du cargo est perdue — jamais la sauvegarde, ni les crédits, ni les améliorations, ni les flags** | ⬜ À faire |
| 6.8 | **Indicateur de danger progressif non chiffré** *(§4.3)* : teinte d'écran et ambiance sonore évoluant par palier, **aucune probabilité affichée** au joueur | ⬜ À faire |
| 6.9 | 🔒 Audit qualité — Sprint 6 | ⬜ À faire |
| 6.10 | 🔒 Tests manuels humains — Sprint 6 | ⬜ À faire |

Couvre : « MVP jouable » 7 · « Scénario » (prologue, progression narrative) · « Contrôles » (`toggle_journal`) · « Direction sonore » (ambiance de danger) · **amendement §4** (risque croissant) et **§7.3 / §7.4** (priorités de développement n° 3 et 4).

> ✅ **`Q22` tranchée le 2026-09-06 : surcharge ACCEPTÉE telle quelle.** **10 stories, un seul sprint, une seule gate.** Ni scission en deux sprints, ni déplacement de `6.8` vers la phase 4 — la phase 4 reste à 6 stories, la phase 6 à 10.
>
> ⚠️ **Le risque n'est pas levé, il est assumé.** La phase reste le sprint le plus chargé du MVP et absorbe l'intégralité du système de dégâts et de menaces, le plus riche en cas limites (état de destruction, perte partielle, remontée forcée, interaction avec la sauvegarde manuelle de Q7). C'est le prix de la contrainte **Q19**, qui interdit d'ouvrir une phase dédiée à **Q17**. Il reste au registre des risques de `stories/AVANCEMENT.md` §5, en sévérité 🔴, **requalifié en risque accepté** avec sa date et son motif.
>
> **Les deux options écartées sont conservées et réactivables** si la phase 6 dérape : (b) scinder le sprint 6 en deux sprints consécutifs **sans créer de phase nouvelle**, avec deux gates successives ; (c) déplacer `6.8` (indicateur de danger) vers la phase 4. **Point de réexamen : la clôture de la phase 5**, dernier moment où la redistribution reste peu coûteuse — aucune story de la phase 6 n'étant alors encore écrite.
>
> **Interaction §4.3 × Q7 à instruire dans `6.7`** : la sauvegarde est manuelle (Q7). Une destruction survenant après une longue descente non sauvegardée ne doit pas être vécue comme une double punition. La règle « la perte n'est jamais totale » porte sur l'état persistant ; le cumul avec Q5 (minerai perdu en soute pleine) et Q7 est à mesurer au playtest de la phase 7.

---

## Phase 7 — Sauvegarde locale et recette MVP · Sprint 7 *(prévisionnel)*

Objectif : rendre la partie persistante, **valider que la boucle de session tient en 3 à 8 minutes**, et prouver critère par critère que le MVP est atteint.

| # (prév.) | Story | Statut |
|---|---|---|
| 7.1 | `SaveSystem` : écriture/lecture dans `user://` (position, ressources, crédits, améliorations, flags) — **sauvegarde manuelle uniquement** (Q7), aucune sauvegarde automatique · **élargie** : la sauvegarde survit à la destruction de la foreuse (§4.3) et tolère `schema_version: 2` (Q18) | ⬜ À faire |
| 7.2 | Persistance du terrain creusé | ⬜ À faire |
| 7.3 | Nouvelle partie, chargement, robustesse (fichier absent ou corrompu) | ⬜ À faire |
| 7.4 | Garde-fous Q7 : rappel non bloquant au retour en surface, confirmation avant de quitter avec progression non sauvegardée | ⬜ À faire |
| 7.5 | Recette MVP et premier passage d'équilibrage | ⬜ À faire |
| 7.6 | **Playtest de la boucle 3-8 min et équilibrage des poids et des coûts** *(§5, §7.5)* : mesure chronométrée de 3 boucles complètes, vérification que le prochain palier d'amélioration reste atteignable en **1 à 3 descentes** (§3.3), ajustements par édition de `data/` uniquement | ⬜ À faire |
| 7.7 | 🔒 Audit qualité — Sprint 7 | ⬜ À faire |
| 7.8 | 🔒 Tests manuels humains — Sprint 7 (recette MVP complète) | ⬜ À faire |

Couvre : « MVP jouable » 8 · critère MVP « La sauvegarde restitue position, ressources, crédits, améliorations et flags narratifs » · l'ensemble des « Critères d'acceptation MVP » · **amendement §5** (boucle de session) et **§7.5** (priorité de développement n° 5).

> **`7.6` est la story de bouclage de l'amendement** : c'est là que se vérifient les trois grandeurs qui ne se mesurent qu'en jouant — durée de boucle (§5), atteignabilité des coûts (§3.3) et distribution réelle du loot (§2.2). Aucun de ces réglages ne doit exiger une modification de code : ils vivent tous dans `data/generation.json` et `data/upgrades.json` (points d'audit `D1`, `K5`, `K7`, `L1`).

---

## Phases post-MVP *(non détaillées — reprise du « Backlog après MVP » du CDC)*

Ces phases ne seront découpées en stories qu'à leur ouverture, après validation du MVP.

| Phase | Intitulé | Source CDC |
|---|---|---|
| 8 | **Enrichissement** de la génération par strates (biomes, poches, structures) — la génération de base remonte en phase 3 du fait de **Q6** | « Backlog après MVP » |
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
| 6 | ~~Trois~~ **Au moins quatre** améliorations *(amendement §3.2, qui prime sur le CDC principal)* : soute, carburant max, foret, blindage, profondeur max sûre | 1 (données), 5 |
| 7 | Zone profonde avec une première anomalie scénarisée **et des menaces croissantes** *(amendement §4)* | 6 |
| 8 | Sauvegarde locale simple | 7 |

## Traçabilité — « Critères d'acceptation MVP » (7 critères du CDC)

| Critère | Phase de validation | Cas de test |
|---|---|---|
| Partir, creuser, collecter, revenir vendre sans bloquer la partie | 5 | TM-5.8 |
| Tuile détruite seulement si puissance de foret et carburant suffisants | 3, 5 | TM-3.1, TM-3.5, TM-3.9, TM-5.6 |
| Collisions empêchant la traversée des blocs non détruits | 2, 3 | TM-2.6, TM-3.6 |
| Directions opposées : ni mouvement ni comportement instable | 2 | TM-2.2 |
| HUD temps réel (carburant, blindage, crédits, soute, profondeur) | 4 | TM-4.1, TM-4.2 |
| **Valeurs de départ de `GameState` observées à l'écran** *(transfert de `TM-1.6`, story `1.12` — variables privées non exportées, non affichables au sprint 1)* | 4 | TM-4.1 |
| Amélioration achetée ⇒ statistique modifiée immédiatement | 5 | TM-5.5, TM-5.6 |
| Sauvegarde restituant position, ressources, crédits, améliorations, flags | 7 | TM-7.1, TM-7.2 |

---

## Traçabilité — amendement « gameplay addictif »

Découpage du document `cahier_des_charges_gameplay_addictif.md` par phase de réalisation.

| § | Contenu | Phase(s) | Story/stories |
|---|---|---|---|
| §2.1 – §2.3 | Table de loot pondérée par couche, tirage par poids | 3 | `3.2`, `3.6` |
| §2.4 | *Règle de design* — jamais 0 % de drop · feedback fort et durable sur les raretés hautes | 3 | `3.6`, `3.7` |
| §3.1 | Crédits impériaux, ressource pivot | 5 | `5.2` |
| §3.2 | 4 stats upgradables minimum, formule de coût exponentielle | 5 | `5.4`, `5.6`, `5.7` |
| §3.2 ⚠️ | **« Vitesse de forage » — NON COUVERTE au MVP** *(Q21)*. `foret` reste une **puissance** (seuil de `hardness`), conformément au point 6 du « MVP jouable » et à `data/upgrades.json`. Écart littéral au §3.2, **assumé et tracé** | **post-MVP** | *à rouvrir — aucune story* |
| §3.2 ⚠️ | **« Profondeur max sûre » — REPORTÉE post-MVP** *(Q21)*. Son effet recouvre la courbe de risque de la phase 6, et c'est la moins tangible des quatre stats au regard de la règle §3.3 | **post-MVP** | *aucune story* |
| §3.3 | *Règle de design* — pas de plafond dur · coût atteignable en 1-3 descentes · effet ressenti immédiatement | 5, 7 | `5.5`, `5.6`, `7.6` |
| §4.1 | Dilemme « remonter vendre / pousser plus loin » | 2, 6 | `2.5`, `6.6` |
| *(hors amendement)* | **Dégâts de chute et d'impact** *(Q20)* — ajout de périmètre décidé par l'utilisateur, **absent des deux cahiers des charges**. Première source de dégâts du jeu, elle donne son appelant à l'`ArmorSystem` dès le sprint 2 | 2 | `2.5` |
| §4.2 | Courbe de risque par profondeur (2 % → 8 % → 18 % → 35 %) | 6 | `6.1`, `6.6` |
| §4.3 | *Règle de design* — la perte n'est jamais totale · indicateur de danger progressif non chiffré | 2, 6 | `2.5`, `6.7`, `6.8` |
| §5 | Boucle de session de 3 à 8 minutes | 7 | `7.6` |
| §6 | Hors scope MVP (streak, leaderboard, multi, near-miss) | — | *exclu — aucun développement* |
| §7 | Ordre de développement conseillé (1 → 5) | 3, 5, 6, 7 | respecté : loot (3) → économie (5) → risque (6) → feedback (3 et 6) → playtest (7) |

### Règles de design et boucle — critères d'acceptation nouveaux

Les règles §2.4, §3.3 et §4.3 et la boucle §5 ne sont pas des fonctionnalités mais des **critères d'acceptation**. Ils s'ajoutent aux 7 « Critères d'acceptation MVP » du CDC principal et sont rattachés à leur phase de validation.

| Nouveau critère d'acceptation MVP | Source | Phase de validation | Cas de test | Point d'audit |
|---|---|---|---|---|
| Aucune couche ne produit 0 % de drop ; la surface elle-même peut récompenser dès la première case | §2.4 | 3 | TM-3.18 | `K9` |
| Un drop de rareté haute est signalé par un retour visuel **et** sonore distinct, visible assez longtemps pour être perçu | §2.4 | 3 | TM-3.19 | — *(critère `[H]`)* |
| La progression n'a **aucun plafond dur** : aucun niveau maximal, le coût suivant est toujours calculable et affiché | §3.3 | 5 | TM-5.10 | `L2` |
| Le prochain palier d'amélioration reste atteignable en **1 à 3 descentes** | §3.3 | 5, 7 | TM-5.11, TM-7.11 | — *(équilibrage, mesure)* |
| Chaque amélioration achetée est **ressentie** à la descente suivante, sans avoir à lire un chiffre | §3.3 | 5 | TM-5.12 | `L5` |
| **La perte n'est jamais totale** : une destruction ne coûte qu'une partie du cargo — jamais la sauvegarde, les crédits, les améliorations ni les flags narratifs | §4.3 | 6 | TM-6.8 | `M3` |
| Le danger est signalé par un indicateur **progressif et non chiffré** (teinte, ambiance sonore) | §4.3 | 6 | TM-6.9 | `M5` |
| Une boucle complète descente → collecte → remontée → vente → amélioration dure **entre 3 et 8 minutes** | §5 | 7 | TM-7.11 | — *(équilibrage, mesure)* |

---

## Points en attente d'arbitrage utilisateur

Ces points ne sont **pas** tranchés par les agents. Ils doivent l'être avant la phase indiquée.

### Tranchés — arbitrage utilisateur du 2026-08-29

Les quatre points bloquant la phase 1 sont réglés. La décision fait foi pour l'audit : un choix listé ici n'est **pas** un écart au CDC.

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q1 | Renderer et résolution de référence | **`GL Compatibility`** (préserve l'export Web du CDC) · base **1280×720**, `stretch=canvas_items`, `aspect=expand` — résolution à reconfirmer avant `3.2` | Story 1.1 |
| Q2 | Mapping clavier | **`physical_keycode`** : ZQSD sur AZERTY, WASD sur QWERTY, sans code conditionnel. Aucun libellé de touche en dur à l'écran. | Story 1.3 |
| ~~Q3~~ | ~~Blindage au MVP~~ | ⛔ **ANNULÉ le 2026-09-06 par Q17.** ~~Jauge affichée mais statique ; rien ne décrémente `armor` avant le post-MVP.~~ Le système de dégâts entre au MVP : `ArmorSystem` devient fonctionnel et `GameState.armor` est réellement décrémenté. Entrée conservée pour l'historique, jamais effacée. | Story 1.4, **annulé par la story `1.10`** |
| Q4 | Emplacement du chargeur de données | **Autoload `scripts/autoload/GameData.gd`** — déviation assumée de l'arborescence du CDC, **validée** : conforme au point d'audit A3. Chargé avant `GameState`. | Story 1.5 |

### Tranchés — arbitrage utilisateur du 2026-08-29 (suite, lors de la revue `0.5`)

L'utilisateur a écarté les trois recommandations du `po`. Décisions retenues et **contraintes d'implémentation qui en découlent** — ces contraintes sont opposables à l'audit du sprint concerné.

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q5 | Comportement en soute pleine | **Tuile détruite, minerai perdu.** Le forage n'est pas empêché ; le minerai qui ne rentre pas est perdu définitivement. | Story 3.5 (à créer) |
| Q6 | Terrain du MVP | **Semi-procédural dès le MVP.** Strates générées par règles simples (densité de minerai par profondeur), et non terrain fixe dessiné à la main. | Story 3.2 (à créer) |
| Q7 | Sauvegarde | **Manuelle uniquement.** Aucune sauvegarde automatique, y compris au retour en surface. | Story 7.1 (à créer) |

**Contraintes d'implémentation dérivées** — à reprendre dans les stories concernées à l'ouverture de la phase :

| Origine | Contrainte | Sprint |
|---|---|---|
| Q5 | **Alerte « soute pleine » obligatoire et antérieure à la perte** : le joueur doit être averti *avant* de forer à perte, sinon le comportement sera rapporté comme un bug aux tests manuels. Alerte visuelle **et** sonore (cf. « Direction sonore » du CDC, qui liste déjà l'alerte soute pleine). | 3, affichage en 4 |
| Q5 | La perte doit être **visible** (message ou compteur de minerai perdu), jamais silencieuse. | 3 |
| Q6 | **Graine (seed) de génération explicite et rejouable**, forçable en configuration. Sans cela, aucun test manuel n'est reproductible et un bug de forage devient impossible à isoler. Une graine fixe est imposée pendant toute la durée des tests d'un sprint. | 3 |
| Q6 | Le placement de l'anomalie scénarisée (phase 6) et de la zone de surface (phase 5) doit rester **déterministe**, indépendant de la graine, sous peine de rendre la progression narrative aléatoire. | 3, 5, 6 |
| Q6 | **Élargissement de périmètre assumé** : la génération procédurale était placée en phase 8 (post-MVP) par le CDC (« Backlog après MVP »). Elle remonte en phase 3. La phase 8 est requalifiée en *enrichissement* de la génération, non en création. | 3 / 8 |
| Q7 | **Rappel de sauvegarde au retour en surface** (message non bloquant), et confirmation avant de quitter avec une progression non sauvegardée. Sans ces deux garde-fous, la perte d'une session entière est quasi certaine et sera rapportée comme un défaut. | 7 |
| Q7 | Le plan de tests manuels doit couvrir explicitement le cas **« quitter sans sauvegarder »** et le documenter comme comportement attendu, non comme anomalie. | 7 |

> **Interaction Q5 × Q7 à surveiller à l'équilibrage** : minerai perdu en soute pleine **et** aucune sauvegarde automatique se cumulent. Une longue descente peut être intégralement perdue, deux fois — à la collecte puis à la fermeture du jeu. Point à réévaluer après les premiers tests manuels du sprint 5, quand la boucle économique sera jouable.
>
> ⚠️ **Aggravé le 2026-09-06 par Q17 — le cumul devient triple (Q5 × Q7 × §4.3)** : une troisième source de perte s'ajoute, la destruction de la foreuse par une menace. Trois pertes indépendantes peuvent se cumuler sur une même descente : minerai non collecté en soute pleine, fraction de cargo perdue à la destruction, et progression non sauvegardée à la fermeture. C'est exactement le contre-exemple visé par la règle de design §4.3 (« la perte ne doit jamais être totale, sinon le joueur arrête de prendre le risque »). **À mesurer au sprint 5 (`TM-5.9`) puis au playtest du sprint 7 (`TM-7.11`)** ; la décision d'ajustement revient à l'utilisateur.

### Tranchés — arbitrage utilisateur du 2026-08-30 (issus de la story `1.3`)

Deux points soulevés à l'implémentation de l'Input Map, sans origine dans le CDC.

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q9 | `TM-1.5` (une action par appui) n'est pas exécutable au sprint 1 : aucun code ne consomme les entrées avant la phase 2 | **Reporté au sprint 2**, identifiant `TM-1.5` **conservé** (un cas de test ne se renumérote pas). Il devient réellement jouable en story `2.2`, quand `DrillRig` consomme les entrées. Aucun code de debug jetable n'est écrit. `TM-1.4` reste au sprint 1. | `qa/plan-tests-manuels.md`, sprints 1 et 2 |
| Q10 | `drill`/Espace, `pause`/Échap, `toggle_inventory`/Tab et les flèches partagent leurs touches avec les actions intégrées `ui_accept`, `ui_cancel`, `ui_focus_next`, `ui_up/down/left/right` | **Discipline `_unhandled_input`.** Le gameplay n'implémente **jamais** `_input()` : toute UI ouverte consomme l'événement avant lui. Les touches du CDC sont préservées, aucune action `ui_*` n'est supprimée. | `qa/audit-qualite-reference.md` `F5`/`F6` |

**Contraintes d'implémentation dérivées de Q10** — opposables dès la phase 2, bloquantes à partir de la phase 4 :

| Contrainte | Sprint |
|---|---|
| Aucun nœud de gameplay n'implémente `_input()`. Lecture ponctuelle exclusivement en `_unhandled_input()`, lecture continue par `Input.is_action_pressed()` dans `_physics_process()`. Contrôle : `grep -rn "func _input(" scripts/ scenes/` ne remonte aucun nœud de gameplay (audit `F5 [B]`) | 2 |
| Toute UI modale (inventaire, boutique, pause, dialogue) consomme l'événement ou appelle `set_input_as_handled()`, pour qu'aucune action de jeu ne se déclenche derrière elle (audit `F6`) | 4 |
| Aucun libellé de touche écrit en dur à l'écran — corollaire de Q2 : avec `physical_keycode`, la touche affichée dépend de la disposition du joueur. Utiliser `DisplayServer.keyboard_get_keycode_from_physical()` | 4 |

### Tranchés — arbitrage utilisateur du 2026-08-30 (préalable à la story `1.5`)

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q11 | Faveur du Mechanicus et quota : présents au CDC, absents des 8 points du MVP | **Omis confirmé.** Déclarés sans écrivain ni lecteur, ils seraient du code mort (audit `B6`) et gonfleraient la surface de la sauvegarde. Réintroduction en phase 12 sans coût : la sauvegarde tolère les clés absentes (audit `H5`). Écart `E7` clos. | Story `1.4`, écart `E7` |
| Q12 | `data/resources.json` : les 6 ressources du CDC ou les 2 du MVP ? | **Les 6, chacune portant un drapeau d'activation au MVP.** Évite une migration de données et de sauvegarde ultérieure ; le générateur de la phase 3 ne place que les ressources actives. | Story `1.5`, puis `3.2` |
| Q13 | Les 13 constantes de départ de `GameState` (carburant 100, soute 50, crédits 0, niveaux MK-I…) | **Migrées vers `data/` en story `1.5`.** `GameState` ne conserve que des garde-fous techniques (bornes minimales, anti-division par zéro), qui ne sont pas des valeurs de gameplay. | Story `1.5` |

**Contraintes d'implémentation dérivées** :

| Origine | Contrainte | Sprint |
|---|---|---|
| Q12 | Le drapeau d'activation doit être **lisible par le générateur de terrain** (`3.2`) et par le testeur : une ressource inactive ne doit jamais apparaître dans le terrain du MVP. Cas de test à prévoir au sprint 3. | 1, 3 |
| Q12 | Les `id` de ressources sont **définitifs dès la story `1.5`** : ils sont réutilisés par le TileSet (`3.1`) et par les sauvegardes (`7.1`). Un `id` renommé après la phase 3 casse les sauvegardes existantes. | 1 |
| Q13 | Après migration, `GameState` ne doit plus contenir **aucune valeur de gameplay ajustable**. Contrôle d'audit : une constante de `GameState` qui n'est ni une borne technique ni un garde-fou est un écart. | 1 |
| Q13 | Les valeurs de départ doivent être **modifiables sans toucher au code** — exigence directe de l'équilibrage du sprint 5 (`TM-5.9`, mesure du cumul Q5 × Q7). | 1, 5 |
| Q11 | Toute réintroduction ultérieure de `faveur`/`quota` passe par une story dédiée, et la sauvegarde doit continuer de tolérer leur absence. | 12 |

### Tranchés — arbitrage utilisateur du 2026-08-30 (issus de la story `1.5`)

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q14 | `--check-only` produit un faux `Identifier not found` sur tout script référençant un autoload, en sortant en 0 — ce qui contredit la règle d'audit « une sortie contenant `ERROR:` est un échec » | **Exception nommée et bornée**, ajoutée à `qa/README.md` §4 avant l'audit `1.7`. Trois conditions cumulatives, commandes de substitution imposées. `--check-only` est conservé : c'est le seul mode qui localise une erreur **fichier par fichier**. | Story `1.9` |
| Q15 | Les phases 2 et 3 ont besoin de données (physique de la foreuse, paramètres de génération exigés par `K5`) qu'aucun des 3 fichiers du CDC n'accueille, et que le code ne peut plus porter depuis Q13 | **Deux nouveaux fichiers dédiés** : `data/drill.json` (gravité, inertie, vitesses, consommation) et `data/generation.json` (strates, densités, graine par défaut). **Seconde déviation assumée** de l'arborescence du CDC, à tracer comme la première (Q4) et à traiter comme conforme au point d'audit A3. | Stories `2.2` et `3.2` (à créer) |

**Contraintes d'implémentation dérivées de Q15** :

| Contrainte | Sprint |
|---|---|
| `data/drill.json` est créé par la story de physique de la foreuse (`2.2`), `data/generation.json` par celle du générateur (`3.2`). Aucun des deux n'est créé par anticipation. | 2, 3 |
| Chaque fichier garde un objet unique et lisible : aucun paramètre de génération dans `drill.json`, aucune donnée de physique dans `generation.json`. Un fichier fourre-tout a été explicitement écarté. | 2, 3 |
| Ils suivent le même contrat de chargement que les 3 fichiers existants — `schema_version`, validation par champ, échec bruyant sans repli silencieux — et sont lus par `GameData`, pas par un chargeur parallèle. | 2, 3 |
| La graine par défaut de `generation.json` doit être **forçable** (point d'audit `K1`) et **journalisée** (`K6`), pour que la campagne de tests du sprint 3 soit reproductible (`P4`). | 3 |

### Tranchés — arbitrage utilisateur du 2026-09-06 (intégration de l'amendement « gameplay addictif », story `1.10`)

Quatre arbitrages rendus à la réception du document `cahier_des_charges_gameplay_addictif.md`. Ils **font foi** et ne sont pas rediscutés. Deux d'entre eux annulent des décisions antérieures ; l'annulation est tracée, jamais effacée.

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q16 | Statut du nouveau document : second cahier des charges, ou complément ? | **Amendement au CDC.** Le document complète et modifie le CDC principal ; ses mécaniques **entrent dans le périmètre MVP**. Il n'y a **pas** de second CDC concurrent. Préséance : l'amendement fait foi pour loot, économie, risque et durée de boucle ; le CDC principal fait foi pour univers, architecture Godot, contrôles et données de tuile. | CDC principal (note en tête + section « Amendement — Cahier des charges gameplay addictif »), ce fichier, `qa/README.md`, `README.md`, story `1.10` |
| Q17 | Système de dégâts et menaces au MVP ? | **OUI.** `ArmorSystem` fonctionnel, décrément réel du blindage, spawn de menaces par profondeur selon la courbe §4.2 (2 % → 8 % → 18 % → 35 %), règle §4.3 (**la perte n'est jamais totale**), indicateur de danger progressif non chiffré, traitement de l'état de destruction de la foreuse. **⛔ Annule et remplace `Q3` et `Q8`.** | Stories `2.1`, `2.5`, `6.1`, `6.6`, `6.7`, `6.8` (à créer) |
| Q18 | Économie : paliers fixes ou progression infinie ? | **`data/upgrades.json` passe en `schema_version: 2`.** Formule exponentielle `cout = base × facteur^niveau`, **sans plafond dur** (§3.2/§3.3). Les `id` restent définitifs (**Q12** intacte). Les paliers fixes actuels deviennent les premiers niveaux calculés, ou leur point de calage. Le §3.2 impose **4 stats upgradables minimum** — à réconcilier avec les 3 améliorations du point 6 du « MVP jouable » et avec le catalogue existant. | Stories `5.4`, `5.6`, `5.7` (à créer) |
| Q19 | Découpage : phase nouvelle ou extension ? | **Extension des phases existantes. Aucune phase nouvelle, aucune renumérotation de phase.** Loot table pondérée → **phase 3** (`3.2` + `data/generation.json`). Économie, formule exponentielle et 4ᵉ stat → **phase 5**. Courbe de risque, dégâts, menaces et feedback de danger → **phase 6**, dont l'objectif s'élargit. Playtest de la boucle 3-8 min et équilibrage → **phase 7**. **Le MVP reste atteint fin de phase 7.** | Vue d'ensemble et tableaux des phases 2, 3, 5, 6 et 7 de ce fichier |

**Arbitrages antérieurs annulés par Q17** — conservés pour l'historique, barrés et annotés :

| # annulé | Décision d'origine (2026-08-29) | Ce qui la remplace |
|---|---|---|
| ~~**Q3**~~ | Blindage au MVP : jauge **affichée mais statique**, `armor`/`armor_max` existent mais rien ne les décrémente avant le post-MVP | **Q17** : `ArmorSystem` fonctionnel, blindage réellement décrémenté par les menaces du §4.2. L'amélioration `blindage` de `data/upgrades.json` passe de `actif_mvp: false` à `actif_mvp: true`. L'écart **E1** de `stories/AVANCEMENT.md`, clos par Q3, est **rouvert** |
| ~~**Q8**~~ | Mort de la foreuse : **sans objet au MVP**, corollaire de Q3 — sans système de dégâts, le blindage ne peut atteindre zéro. Repoussée en post-MVP avec les dangers | **Q17** : l'état « foreuse détruite » existe au MVP et suit la règle §4.3 — **perte d'une partie du cargo, jamais de la sauvegarde**. L'écart **E3**, déclaré sans objet par Q8, est **rouvert** |

**Contraintes d'implémentation dérivées de Q16-Q19** — à reprendre textuellement dans les critères d'acceptation des stories concernées à l'ouverture de leur phase ; elles sont **opposables à l'audit** du sprint :

| Origine | Contrainte | Sprint | Audit |
|---|---|---|---|
| Q16 | En cas de contradiction entre les deux documents, **l'amendement prime** sur le périmètre qu'il décrit (loot, économie, risque, durée de boucle) et **seulement** sur celui-là. Toute application de l'amendement hors de ce périmètre est un écart à justifier. | 3, 5, 6, 7 | `I5` |
| Q16 | La section « Dangers » du CDC principal (roche dure, éboulement, gaz, prométhium, anomalie Warp) reste **post-MVP**. Seules les menaces de la courbe §4.2 entrent au MVP. Les deux listes ne se confondent pas. | 6 | `I5` |
| Q17 | `ArmorSystem` est le **seul** point d'entrée de dégâts : aucune écriture directe de `GameState.armor` depuis un autre nœud. | 2, 6 | `M1` |
| Q17 | Le tirage de menace utilise un **RNG dédié, distinct** de celui de la génération de terrain, lui aussi ensemencé et journalisé — sinon un combat décale le terrain à graine identique et **casse la reproductibilité `K2`** acquise en phase 3. | 6 | `M6`, `K2` |
| Q17 | **La perte n'est jamais totale** (§4.3) : à blindage nul, le code ne supprime ni le fichier de sauvegarde, ni les crédits, ni les améliorations, ni les flags narratifs. Seule une **fraction du cargo** est perdue, et cette fraction est une **donnée**. Toute suppression de sauvegarde est un KO bloquant. | 6 | `M3` |
| Q17 | L'indicateur de danger est **non chiffré à l'écran** : aucune probabilité affichée au joueur ; le retour passe par teinte et ambiance sonore, par palier de profondeur. | 6 | `M5` |
| Q17 | L'état « foreuse détruite » est une **transition d'état explicite**, sans état intermédiaire jouable incohérent (prolonge `H3`). | 2, 6 | `M4` |
| Q17 | La réparation du blindage (story `5.3`) redevient une dépense **utile** : elle était sans objet sous Q3. À prendre en compte dans l'équilibrage économique du sprint 5. | 5 | — |
| Q18 | La formule de coût est **paramétrable en données** (`base`, `facteur` par amélioration) : aucun tableau de paliers en dur, aucune constante numérique de coût dans `EconomySystem`. | 5 | `L1`, `D1` |
| Q18 | **Aucun plafond dur** : ni `niveau_max`, ni borne supérieure sur le niveau, ni message « niveau maximal atteint ». Le coût est calculable pour tout niveau. | 5 | `L2` |
| Q18 | Les `id` d'améliorations sont **inchangés** par la migration `schema_version 1 → 2` (**Q12**), et la lecture reste tolérante à une sauvegarde écrite en `schema_version: 1` (`H5`). | 5, 7 | `L4`, `H5` |
| Q18 | La **valeur** produite par un niveau doit être calculée, pas seulement le coût : sans cela, un niveau 12 coûterait cher sans rien changer, en contradiction directe avec le §3.3. | 5 | `L5` |
| Q18 | Les 4 stats du §3.2 sont **actives au MVP** et chacune est reliée à une statistique **réellement consommée** par le gameplay — pas de statistique morte (`B6`). | 5 | `L5` |
| Q19 | La table de loot vit dans **`data/generation.json`** (fichier créé par la story `3.2`, arbitrage **Q15**), pas dans un quatrième fichier. Le tirage passe par le **RNG ensemencé** de `3.2` : à graine identique, mêmes drops. | 3 | `K7`, `K8` |
| Q19 | **Jamais 0 % de drop** (§2.4) : la table est validée au chargement (somme des poids > 0, poids de « Rien » < 100 % sur chaque couche), avec échec bruyant sinon. | 3 | `K9` |
| Q19 | Le loot ne tire **jamais** une ressource `actif_mvp: false` (**Q12**) : la contrainte, jusqu'ici sans cas de test, en reçoit un (`TM-3.21`). | 3 | `K7` |
| Q19 | Les réglages de la boucle (poids de loot, coûts, probabilités de rencontre) doivent être ajustables **sans toucher au code**, faute de quoi le playtest de la story `7.6` est impraticable. | 3, 5, 6, 7 | `D1`, `K5`, `K7`, `L1`, `M2` |

### Tranchés — arbitrage utilisateur du 2026-09-06 (suite, story `1.11`)

Trois arbitrages rendus après la story `1.10`. Ils **font foi** et ne sont pas rediscutés. Ils closent les deux dernières questions ouvertes du projet (`Q20`, `Q21`) et statuent sur la charge du sprint 6 (`Q22`).

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q20 | Quelle est la **première source de dégâts** du jeu, et à quelle phase arrive-t-elle ? | **Chute et impact, dès la phase 2.** Dégâts **proportionnels à la vitesse d'impact**, avec un **seuil** en deçà duquel aucun dégât n'est infligé et un **coefficient** de conversion — l'un et l'autre **en données**, jamais en dur. Motif : c'est la seule source disponible dès la phase 2, où elle ne dépend que de la physique et des collisions livrées par `2.2`. L'`ArmorSystem` de `2.5` reçoit donc son appelant dans le sprint même où il est écrit, et **n'est jamais du code mort** au sens de `B6`. Corruption warp par profondeur et créatures xenos restent la matière de la **phase 6** (courbe §4.2), en sources **supplémentaires**, non en remplacement. | Stories `2.2`, `2.5` (à créer) · `TM-2.9`, `TM-2.10` |
| Q21 | **Quatre ou cinq** améliorations actives au MVP ? | **Quatre** : `soute`, `reacteur`, `foret`, `blindage`. Le minimum de 4 stats du §3.2 est atteint **sans créer aucun `id` nouveau** — `blindage` passe simplement `actif_mvp: true` et reçoit des paliers supérieurs (il n'a aujourd'hui que le palier 1, de coût nul). Les 4 `id` restent **définitifs** (**Q12** intacte). « Profondeur max sûre » est **reportée post-MVP** : son effet recouvre la courbe de risque de la phase 6 et c'est la moins tangible des quatre au regard du §3.3. La distinction **puissance / vitesse** de foret est **écartée au MVP** : `foret` reste la puissance (seuil de `hardness`), conformément au point 6 du « MVP jouable » et à `data/upgrades.json` — **à rouvrir en post-MVP**. | Stories `5.4`, `5.6`, `5.7` (à créer) · `TM-5.13`, `TM-5.14` · table de traçabilité de l'amendement |
| Q22 | La **surcharge du sprint 6** (10 stories) est-elle acceptée, ou faut-il redistribuer ? | **Acceptée telle quelle.** 10 stories, **un seul sprint, une seule gate**. Ni scission en deux sprints, ni déplacement de `6.8` vers la phase 4 : la phase 4 reste à 6 stories, la phase 6 à 10. Le risque 🔴 du registre **n'est pas levé** — il est **assumé par décision utilisateur**. Les deux options écartées sont **conservées et réactivables** si la phase dérape ; réexamen possible à la clôture de la phase 5. | Tableau de la phase 6 de ce fichier · `stories/AVANCEMENT.md` §5 (risque **accepté**, non atténué) |

**Contraintes d'implémentation dérivées de Q20-Q22** — à reprendre textuellement dans les critères d'acceptation des stories concernées ; elles sont **opposables à l'audit** du sprint :

| Origine | Contrainte | Sprint | Audit |
|---|---|---|---|
| Q20 | **Seuil de vitesse et coefficient de dégâts en données** (`data/drill.json`, fichier créé par `2.2` au titre de **Q15**) : aucune constante d'impact en dur dans `ArmorSystem` ni dans `DrillRig`. Une chute sous le seuil ne doit infliger **aucun** dégât, sinon le déplacement normal devient punitif. | 2 | `M8`, `D1` |
| Q20 | **Source et consommateur livrés dans le même sprint** : la story `2.5` livre les dégâts d'impact **et** l'`ArmorSystem` qui les encaisse. Un sprint qui livrerait l'un sans l'autre manquerait l'objet de l'arbitrage — et rouvrirait le problème de code mort que Q20 est censée fermer. | 2 | `B6`, `M1` |
| Q20 | Un cas de test du sprint 2 doit constater un **blindage réellement décrémenté à l'écran**, pas seulement une fonction appelable. | 2 | — *(`TM-2.9`)* |
| Q20 | Les dégâts d'impact ne se confondent pas avec l'« **Éboulement** » de la section « Dangers » du CDC principal, qui reste **post-MVP**. L'éboulement est un événement de terrain ; l'impact est une conséquence directe de la physique de `2.2`. Ne pas implémenter l'un en croyant livrer l'autre. | 2, post-MVP | `I5` |
| Q20 | Les menaces de la courbe §4.2 (phase 6) **s'ajoutent** aux dégâts d'impact : à la fin du MVP, la foreuse encaisse **deux familles de dégâts**, toutes deux passant par l'unique point d'entrée `ArmorSystem`. | 6 | `M1` |
| Q21 | **Aucun `id` d'amélioration n'est créé ni renommé** : le catalogue reste à `soute`, `reacteur`, `foret`, `blindage`. La quatrième stat active s'obtient par un basculement de drapeau, pas par une entrée nouvelle — **Q12** intacte. | 5 | `L4` |
| Q21 | `blindage` passe `actif_mvp: true` et reçoit des **paliers supérieurs**, calés sur la formule exponentielle de **Q18**. Son palier 1 conserve son **coût nul** : c'est le statut de départ « Plaques de récupération » du CDC principal. | 5 | `L1`, `L5` |
| Q21 | L'effet de `blindage` doit être **ressenti** (§3.3) : après achat, la foreuse encaisse visiblement mieux une chute de même hauteur. Une amélioration de blindage dont on ne perçoit l'effet qu'en lisant un chiffre est un échec — et elle n'est **testable** que parce que Q20 a livré une source de dégâts contrôlable par le joueur. | 5 | `L5` *(`TM-5.13`)* |
| Q21 | **Exactement quatre** améliorations sont actives dans la boutique du MVP. Aucune amélioration « profondeur max sûre » ne doit apparaître : elle est post-MVP. | 5 | `L5` *(`TM-5.14`)* |
| Q21 | La non-couverture de « vitesse de forage » est **visible dans la table de traçabilité** de l'amendement et rouverte en post-MVP. Elle ne doit **pas** être comblée en douce par un agent au détour d'une story. | 5, post-MVP | `I5` |
| Q22 | La phase 6 se clôt par **une seule paire de gates** (`6.9` audit → `6.10` tests). Aucune gate intermédiaire n'est ajoutée, aucune story de la phase 6 n'est déplacée vers une autre phase. | 6 | `I4` |
| Q22 | Le risque de surcharge reste **ouvert et suivi** au registre `stories/AVANCEMENT.md` §5, en sévérité 🔴, requalifié « accepté ». Un risque accepté n'est pas un risque disparu : il est réexaminé à la **clôture de la phase 5**. | 5, 6 | `I4` |

### En attente

*Aucune question ouverte.* `Q20` et `Q21`, les deux dernières, ont été tranchées le 2026-09-06 (bloc ci-dessus), en même temps que `Q22`.

**Points reportés, sans question ouverte associée** — décidés, mais volontairement non couverts au MVP :

| Point | Décision | À rouvrir |
|---|---|---|
| « Vitesse de forage » du §3.2 | Écartée au MVP : `foret` reste une **puissance** (seuil de `hardness`) — `Q21` | post-MVP |
| « Profondeur max sûre » du §3.2 | Reportée : effet recouvrant la courbe de risque §4.2, et peu tangible au sens du §3.3 — `Q21` | post-MVP |
| Distinction puissance / vitesse comme **deux axes d'amélioration** distincts | Non instruite au MVP — conséquence des deux lignes ci-dessus | post-MVP |

> **Historique** : les huit points d'ambiguïté du CDC (Q1 à Q8) ont été tranchés ou déclarés sans objet le 2026-08-29 ; Q9 et Q10 (implémentation) le 2026-08-30, Q11 à Q13 avant la story `1.5`, Q14 et Q15 après. **Q3 et Q8 ont été rouverts puis annulés le 2026-09-06 par Q17.** Q16 à Q19 ont été tranchés le 2026-09-06 (story `1.10`), Q20 à Q22 le même jour (story `1.11`). **Les 22 questions sont closes ; aucune n'est ouverte.**
