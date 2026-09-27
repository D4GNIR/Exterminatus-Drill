# Backlog — Motherload 40K : Exterminatus Drill

Liste ordonnée des phases et des stories du projet.
Référence fonctionnelle : `cahier_des_charges_motherload_40k_godot.md`, **amendé par `cahier_des_charges_gameplay_addictif.md`** (arbitrage **Q16** du 2026-09-06 — mécaniques de rétention, périmètre MVP) · Méthodologie : `.claude/CLAUDE.md` · Gate qualité : `qa/README.md`.

> **Préséance des deux documents** : l'amendement fait foi pour le loot, l'économie, la courbe de risque et la durée de boucle ; le CDC principal fait foi pour l'univers, les contrôles, les règles de forage, l'architecture Godot et les données de tuile. Détail dans la section « Amendement — Cahier des charges gameplay addictif » du CDC principal.

## Conventions de lecture

- **1 phase = 1 sprint = 1 commit.** Chaque phase se termine par **une seule story de gate : l'audit qualité**. *(Depuis la décision du 2026-09-26, story `2.8` — voir l'encadré ci-dessous.)*
- Statuts : `À faire` · `En cours` · `Terminée` · `Bloquée` · `Reportée` · `Annulée`. **Une seule story `En cours` à la fois.**
- **Règle de dénombrement** *(formalisée le 2026-09-27, story `2.12`)* : une story **`Annulée`** est **exclue** du total MVP — elle ne sera jamais faite ; une story **`Reportée`** y est **incluse** — elle sera faite, plus tard et ailleurs. `ls stories/*.md` donne donc un nombre **supérieur** au total affiché, l'écart valant exactement le nombre de stories `Annulée` (une seule à ce jour : `0.5`). Le total est **recalculé, jamais recopié** : point d'audit **`I7 [B]`**. *Depuis `Q39` (story `3.15`), ce total n'est tenu que dans `stories/AVANCEMENT.md`.*
- Les fichiers de stories ne sont créés qu'**à l'ouverture de la phase**. Pour les phases ≥ 2, les numéros affichés sont **prévisionnels** et ne deviennent fermes qu'à la création des fichiers (une story créée ne peut plus être renumérotée).
- **[H]** = critère exigeant un **jugement humain à l'écran** (rendu, ressenti de contrôle, équilibrage, audio, ergonomie). Godot 4.7.2 étant installé, tout ce qui relève de la syntaxe et du chargement est vérifié par les agents en headless — cf. `qa/README.md` §4. **Un `[H]` reste « en attente » jusqu'à la recette `7.8`** : il n'est jamais coché par un agent, jamais réputé satisfait.

> ⛔ **Régime de vérification changé le 2026-09-26 — décision utilisateur, story `2.8`.** Plus de campagne de tests manuels humains par sprint : **la vérification humaine est regroupée en fin de projet**, dans la recette unique `7.8`. Conséquences : la gate de sprint se réduit à l'**audit qualité** (verdict **Autorisé** ⇒ commit de phase autorisé) ; les gates `2.7`, `3.9`, `4.6`, `5.9` et `6.10` passent **Reportée** vers `7.8`, fichiers conservés et numéros inchangés ; le plan `qa/plan-tests-manuels.md` est intégralement conservé et devient le plan de la recette finale. Coût assumé et registre du risque : story `2.8` et `stories/AVANCEMENT.md` §5.

---

## Vue d'ensemble

| Sprint | Phase | Objectif en une ligne | Statut |
|---|---|---|---|
| 0 | **0 — Amorçage du projet** | Aligner la méthodologie, produire le plan de travail, outiller la machine et poser le dépôt | ✅ Close |
| 1 | **1 — Fondations techniques Godot** | Un projet Godot 4 qui démarre : arborescence, Input Map, `GameState`, données, scènes squelettes | ✅ Close ⚠️ · commit `9eb6479` |
| 2 | **2 — Foreuse et déplacement** | Piloter la foreuse dans un tunnel : physique, carburant, caméra, **socle de dégâts** | ✅ Close ⚠️ · commit `a0daf4c` — toutes `Terminée` sauf `2.7` `Reportée`, gate **Autorisé** |
| 3 | **3 — Terrain destructible et forage** | Creuser et collecter sur un terrain **généré**, avec **loot pondéré par couche**, en respectant les règles de forage interdites | 🟡 **Ouverte le 2026-09-27** — gate `3.8` **Autorisé**, toutes les stories `Terminée` sauf `3.9` `Reportée` : **prête au commit** · numérotation **ferme** |
| 4 | **4 — HUD et interfaces de bord** | Voir son état en temps réel et mettre le jeu en pause | ⬜ À faire |
| 5 | **5 — Surface, économie et améliorations** | Fermer la boucle : vendre, ravitailler, améliorer — **progression infinie sans plafond** | ⬜ À faire |
| 6 | **6 — Zone profonde, menaces et anomalie scénarisée** | Descendre, affronter un **risque croissant** et déclencher l'anomalie | ⬜ À faire |
| 7 | **7 — Sauvegarde locale et recette MVP** | Persister la partie, **valider la boucle 3-8 min**, les critères d'acceptation MVP et **toute la recette humaine du projet** (`7.8`) | ⬜ À faire |
| 8+ | **Post-MVP** | Extensions du « Backlog après MVP » du CDC et du §6 de l'amendement | ⬜ À faire |

**MVP jouable atteint à la fin de la phase 7.**

> 📊 **Compteurs : source unique `stories/AVANCEMENT.md`** (arbitrage **`Q39`**, story `3.15`). Effectifs par phase, total MVP, nombre de stories `Terminée`, avancement et registre des critères `[H]` ne sont tenus **que** là. Ce fichier ne porte que le **statut de chaque story**, dans les tables de phase ci-dessous.

> **Volumes révisés le 2026-09-06** (story `1.10`, intégration de l'amendement « gameplay addictif », arbitrage **Q19** : extension des phases existantes, aucune phase nouvelle). Total MVP : **59 → 68 stories**. Détail des ajouts : phase 1 `+1` (la story d'intégration elle-même), phase 2 `+1`, phase 3 `+1`, phase 5 `+2`, phase 6 `+3`, phase 7 `+1`.
>
> **Révision du 2026-09-06 (suite, story `1.11`)** : total porté à **69** par la seule story `1.11` (arbitrages Q20-Q22). Les arbitrages `Q20`, `Q21` et `Q22` **ne changent aucun volume de phase** : ils précisent l'objet de stories déjà prévues (`2.5`, `5.7`) et confirment la charge de la phase 6. Addition recalculée : 9 + 11 + 7 + 9 + 6 + 9 + 10 + 8 = **69**. ⚠️ *Le terme « 11 » de cette addition est **erroné** : la phase 1 compte **12** fichiers de story (`1.1` à `1.12`). Correction portée par la story `2.9` — voir la révision du 2026-09-26 ci-dessous.*
>
> **Ouverture de la phase 3 (2026-09-27)** : **total INCHANGÉ à 75.** La création des 9 fichiers `3.1` à `3.9` ne fait que **rendre ferme** un effectif déjà compté comme prévisionnel. Addition **recalculée** : 9+12+12+**9**+6+9+10+8 = **75**. Contrôle par les fichiers : **43** fichiers de story existent (phases 0 à 3), moins **1** `Annulée` (`0.5`) = **42** comptés ; plus **33** prévisionnelles pour les phases 4 à 7 (6+9+10+8) = **75**. Relevé des statuts par lecture des 43 fichiers : **32 `Terminée` · 8 `À faire` (`3.1`–`3.8`) · 2 `Reportée` (`2.7`, `3.9`) · 1 `Annulée` (`0.5`) · 0 `En cours` · 0 `Bloquée`**. *Deux corrections de dénombrement ont été portées au passage, au titre de `I7 [B]` : la phase 2 était décrite « 11 fichiers » et « 10 Terminée » alors qu'elle en compte **12** dont **11 `Terminée`** (la story `2.12` n'avait pas été reportée dans le récit de phase) ; le total, lui, était déjà juste.*
>
> 🗄️ **Encadrés de révision ci-dessous : HISTORIQUES, figés le 2026-09-27** (arbitrage **`Q39`**). Ils tracent l'évolution du total MVP jusqu'à la story `3.15` ; **aucun nouvel encadré n'est ajouté**, et les compteurs courants vivent dans `stories/AVANCEMENT.md`.
>
> **Révision du 2026-09-27 (story `3.15`)** : total **80 → 81** (phase 3 : 14 → **15**), par la troisième story de correction de l'audit `3.8`, créée par le `po` à l'issue de l'itération 3 (verdict **KO**, `I7 [B]`). Addition vérifiée : 9+12+12+15+6+9+10+8 = **81**. Contrôle `I7` : **49** fichiers existent (phases 0 à 3), dont **48** comptés — l'écart de 1 est la `0.5` `Annulée` — plus **33** prévisionnelles pour les phases 4 à 7. ⚠️ **Écart connu et non corrigé ici, objet de `3.15`** (critère 1) : la vue d'ensemble compte encore la phase 0 à « 10 » au lieu de 9 ; la somme de sa colonne « Stories » fait donc 82, pour 81 comptées.
>
> **Révision du 2026-09-27 (story `3.14`)** : total **79 → 80** (phase 3 : 13 → **14**), par la seconde story de correction de l'audit `3.8`. Addition vérifiée : 9+12+12+14+6+9+10+8 = **80**. Contrôle `I7` : **48** fichiers existent (phases 0 à 3), dont **47** comptés — l'écart de 1 est la `0.5` `Annulée` — plus **33** prévisionnelles pour les phases 4 à 7. **Vue d'ensemble corrigée** : elle affichait encore « 9 » stories et « 8 À faire » pour la phase 3, état de l'ouverture (KO `I7` de l'itération 2 de `3.8`).
>
> **Révision du 2026-09-27 (story `3.13`)** : total **78 → 79** (phase 3 : 12 → **13**), par la story de correction issue de l'audit `3.8`. Addition vérifiée : 9+12+12+13+6+9+10+8 = **79**. Contrôle `I7` : **47** fichiers existent (phases 0 à 3), dont **46** comptés — l'écart de 1 est la `0.5` `Annulée` — plus **33** prévisionnelles pour les phases 4 à 7.
>
> **Révision du 2026-09-27 (story `3.12`)** : total **77 → 78** (phase 3 : 11 → **12**), par la story d'arbitrages `Q34`-`Q37` tranchés avant `3.7`. Addition vérifiée : 9+12+12+12+6+9+10+8 = **78**. Contrôle `I7` : **46** fichiers existent (phases 0 à 3), dont **45** comptés — l'écart de 1 est la `0.5` `Annulée` — plus **33** prévisionnelles pour les phases 4 à 7.
>
> **Révision du 2026-09-27 (story `3.11`)** : total **76 → 77** (phase 3 : 10 → **11**), par la story d'arbitrages `Q31`-`Q33` tranchés après `3.4`, avant `3.5`. Addition vérifiée : 9+12+12+11+6+9+10+8 = **77**. Contrôle `I7` : **45** fichiers existent (phases 0 à 3), dont **44** comptés — l'écart de 1 est la `0.5` `Annulée` — plus **33** prévisionnelles pour les phases 4 à 7.
>
> **Révision du 2026-09-27 (story `3.10`)** : total **75 → 76** (phase 3 : 9 → **10**), par la story d'arbitrages `Q27`-`Q30` tranchés avant le démarrage de `3.1`. Addition vérifiée : 9+12+12+10+6+9+10+8 = **76**. Contrôle `I7` : **44** fichiers existent (phases 0 à 3), dont **43** comptés — l'écart de 1 est la `0.5` `Annulée` — plus **33** prévisionnelles pour les phases 4 à 7.
>
> **Révision du 2026-09-27 (story `2.12`)** : total **74 → 75** (phase 2 : 11 → **12**), par la story de corrections issue de la revue `po`. Addition vérifiée : 9+12+12+9+6+9+10+8 = **75**. *Rappel de la règle de dénombrement ci-dessus : `0.5` `Annulée` est exclue, les gates `Reportée` sont incluses. Contrôle : **34** fichiers de story existent (phases 0 à 2), dont **33** comptés — l'écart de **1** est exactement la story `Annulée`. Les 42 stories des phases 3 à 7 restent **prévisionnelles**, sans fichier : 33 + 42 = **75**.*
>
> **Révision du 2026-09-27 (story `2.11`)** : total **73 → 74** (phase 2 : 10 → **11**), par la story d'arbitrages `Q23`-`Q25` demandée avant le commit. Addition vérifiée : 9+12+11+9+6+9+10+8 = **74**.
>
> **Révision du 2026-09-26 (story `2.10`)** : total **72 → 73** (phase 2 : 9 → **10**), par la story de correction issue de l'audit `2.6`. Addition vérifiée : 9+12+10+9+6+9+10+8 = **73**.
>
> **Révision du 2026-09-26 (story `2.9`)** : **correction d'un dénombrement, pas d'un périmètre.** La phase 1 était comptée **11** ici et **12** dans `stories/AVANCEMENT.md`, d'où deux totaux MVP divergents (70 et 71). Arbitrage par le fait : `ls stories/1.*.md` compte **12** fichiers (`1.1` à `1.12`). Le total retenu est donc **72** après `2.9` — addition vérifiée : 9 + 12 + 9 + 9 + 6 + 9 + 10 + 8 = **72** (phase 2 portée à **9** par `2.8` puis `2.9`). Les deux documents affichent désormais la même valeur.
>
> **Révision du 2026-09-26 (story `2.8`)** : total porté à **70** par la seule story `2.8` (phase 2 : 7 → **8**). Les cinq gates **Reportée** (`2.7`, `3.9`, `4.6`, `5.9`, `6.10`) **restent comptées** dans les effectifs de leur phase : elles ne sont ni supprimées ni renumérotées, seul le moment de leur exécution change — elles se jouent à `7.8`.
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

> ⛔ **Gate 2/2 annulée pour ce sprint uniquement** (story `0.10`, décision utilisateur du 2026-08-29). La phase 0 est close avec la seule gate d'audit `0.4`. Les cas `TM-0.1` à `TM-0.3` ne seront pas exécutés — dont `TM-0.2` (bloquant), qui vérifiait humainement que les 8 points « MVP jouable » et les 7 critères d'acceptation du CDC sont tous couverts. ~~**Les gates de tests manuels des sprints 1 à 7 restent en vigueur**~~ — *énoncé dépassé le 2026-09-26 (story `2.8`)* : elles sont désormais **toutes regroupées dans la recette unique `7.8`**. La portée limitée de `0.10` au seul sprint 0 est donc devenue sans objet, non par extension de `0.10`, mais par une décision distincte et postérieure.

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
> ⚠️ **La gate `1.8` est close SUR DÉCISION de l'utilisateur, campagne NON exécutée** — motif donné : *« c'est pas des points essentiels »*. **0 cas exécuté sur 7** ; aucune case cochée, aucun résultat inventé ; les **9 critères `[H]`** des stories `1.1` à `1.6` restent **non vérifiés**, ni confirmés ni infirmés. *[Erratum du 2026-09-27, story `3.16` (`Q41`) : ce « 9 » compte les lignes du rapport du sprint 1, une par cas de test, et non les critères. Le décompte des critères `[H]` fait foi dans le registre de `stories/AVANCEMENT.md`.]* Verdict et état détaillé : `qa/rapports/sprint-1-tests-manuels-2026-08-31.md`. Précédent de même nature : la gate `0.5` du sprint 0, annulée par décision utilisateur (story `0.10`).
>
> **Règle de gate satisfaite** : `.claude/CLAUDE.md` interdit de commiter la phase tant que **les deux stories de gate** ne sont pas `Terminée`. `1.7` est `Terminée` (audit **Autorisé**, 0 KO) et `1.8` l'est désormais. **Le commit `Phase 1 — Fondations techniques du projet Godot` est donc autorisé.** La condition remplie est **formelle** : elle ne dit rien de ce qui a été constaté à l'écran, et rien ne l'a été.
>
> **Dette léguée au sprint 2** : les fondations de la phase 1 n'ont jamais été vues dans l'éditeur. La gate du sprint 2 héritera de fait de leur vérification, en plus de la sienne et de `TM-1.5` (déjà reporté par **Q9**). Risque inscrit à `stories/AVANCEMENT.md` §5.

> **Story `1.12` — déblocage de la campagne `1.8`** : le testeur humain était **bloqué sur `TM-1.6`**, dont la procédure était inexécutable (vocabulaire Godot 3, et lecture de variables privées que l'éditeur n'affiche pas). `1.12` corrige **cinq procédures** du rapport `qa/rapports/sprint-1-tests-manuels-2026-08-31.md` — jamais un verdict, jamais une case cochée, jamais la section « Anomalies ». `1.8` reste `En cours` et reprend là où le testeur s'était arrêté.
>
> **Précédent assumé sur `1.10`, `1.11` et `1.12`** : la story est ouverte alors que `1.8` est encore `En cours`, dans les mêmes conditions que `1.9` — `1.8` est une gate **humaine** bloquée sur une action hors agent. Le statut de `1.8` n'est pas modifié, aucun code n'est touché, et **aucun commit de phase 1** n'intervient avant sa clôture.

---

## Phase 2 — Foreuse et déplacement · Sprint 2

Objectif : une foreuse pilotable dans un tunnel, soumise à la gravité, au carburant et suivie par la caméra — et dotée du **socle de dégâts** exigé par l'amendement (§4).

> ✅ **Phase ouverte le 2026-09-06, close et commitée le 2026-09-27 (`a0daf4c`). Numérotation FERME — 12 fichiers.** 7 à l'ouverture, puis **5 stories non prévues** créées en cours de sprint : `2.8` (régime de gate), `2.9` (checklist opposable), `2.10` (correction des KO de l'audit), `2.11` (arbitrages `Q23`-`Q25`) et `2.12` (corrections issues de la revue `po`). **11 `Terminée`, 1 `Reportée`** (`2.7` → `7.8`). Une story créée ne se renumérote plus (`.claude/CLAUDE.md`, *Interdits*) : le tableau ci-dessous est donc trié **par numéro**, non par ordre d'exécution. **Ordre d'exécution réel** : `2.1` → `2.2` → `2.3` → `2.4` → `2.8` → `2.5` → `2.9` → `2.6` → `2.10` → `2.11` → `2.12`.
>
> ⚠️ **Correction de dénombrement portée le 2026-09-27 à l'ouverture de la phase 3** (point d'audit `I7 [B]`) : cet encadré annonçait **11 fichiers** et la vue d'ensemble **« 10 Terminée »**, alors que `ls stories/2.*.md` en compte **12**, dont **11 `Terminée`**. La story `2.12` n'avait pas été reportée dans le récit de la phase. Le **total MVP reste 75** : il comptait déjà la phase 2 à 12.

| # | Story | Statut | Dépend de |
|---|---|---|---|
| 2.1 | Scène `DrillRig.tscn` et arbre contractuel (Sprite, Collision, Drill/Fuel/Armor/Scanner, Audio) + instanciation dans `Main.tscn` | ✅ Terminée | 1.2, 1.6 |
| 2.2 | Déplacement et physique (gravité, inertie, `brake`, directions opposées) · **`data/drill.json`** (Q15) · **discipline `_unhandled_input`** (Q10) · `TM-1.5` : volet déplacement jouable, volet `echo` **transféré au sprint 3** (Q9) | ✅ Terminée | 2.1, 1.3, 1.5 |
| 2.3 | Composant `FuelSystem` (consommation, panne sèche : ni forage ni propulsion) · alerte « carburant bas » **sonore** | ✅ Terminée — volet « ni forage » **N/A** jusqu'à `3.4` | 2.1, 2.2 |
| 2.4 | Caméra de suivi et limites de monde · bords de carte **hébergés** dans `data/drill.json`, à migrer en `3.2` | ✅ Terminée | 2.1, 2.2 |
| 2.5 | **`ArmorSystem` et dégâts de chute/impact** *(Q17 — annule Q3 et Q8 · Q20)* : dégâts **proportionnels à la vitesse**, seuil et coefficient **en données**, seuil non nul ; décrément réel du blindage ; état de destruction. **Source et consommateur livrés dans le même sprint** (`M9`) | ✅ Terminée — saturation du coût de chute **rééquilibrée par `Q23`** (story `2.11`) : plage portée de 8,5 à **25 tuiles**, en données seules · **confinement aux bords de carte** désormais détenu par `2.11` (`Q24`), relevé par les bordures indestructibles de `3.2` | 2.1, 2.2 |
| 2.6 | 🔒 **Gate unique** — Audit qualité — Sprint 2 | ✅ Terminée — **Autorisé** (90 points · 50 OK · 2 KO mineurs · 38 N/A) · **itération 2 : les 2 KO levés** | 2.1 → 2.5 |
| 2.7 | ~~🔒 **Gate 2/2** — Tests manuels humains — Sprint 2~~ · charge transférée à `7.8` | ⏭ **Reportée** vers `7.8` (story `2.8`) | — |
| 2.8 | Suspension des tests manuels humains jusqu'à la fin du projet *(décision du 2026-09-26)* | ✅ Terminée | 2.1 |
| 2.9 | Corrections des contrôles opposables de l'audit *(doublon `F5`, contrôle `F1`, exception `1.9` élargie, compteurs, écart `E14`)* — **documentaire** | ✅ Terminée | 2.2, 2.3, 2.4 · **avant `2.6`** |
| 2.10 | Correction des deux KO mineurs de l'audit `2.6` (`B6` fonction morte · `D2` rejet silencieux) | ✅ Terminée — audit `2.6` **itération 2 : 2 OK, 0 KO** | 2.6 |
| 2.12 | **Corrections issues de la revue `po`** : `E15` (palier « 300 m+ » rendu atteignable) · point d'audit **`I7 [B]`** sur la cohérence des compteurs · règle de dénombrement écrite · renvois `2.2` · point d'apparition tracé et reporté à `3.3` | ✅ Terminée | revue `po` · 2.11 |
| 2.11 | **Arbitrages `Q23` à `Q25` de fin de sprint** : équilibrage du coût de chute (données seules) · propriété du **confinement aux bords de carte** · liste de scripts du CDC déclarée **indicative**, `E14` clos | ✅ Terminée | 2.4, 2.5, 2.9, 2.10 |

Couvre : « MVP jouable » 1 et 4 (partiel) · « Règles autorisées » · « Règles interdites » (directions opposées, panne sèche) · **amendement §4.1 et §4.3** (socle du système de dégâts).

> ✅ **`Q20` tranchée le 2026-09-06 : dégâts de chute et d'impact, dès la phase 2.** La story `2.5` livre **la source de dégâts et son consommateur dans le même sprint** : l'`ArmorSystem` n'est donc **jamais un composant sans appelant**, et le point d'audit `B6` (code mort) sortira `OK` à l'audit `2.6` sans exception à plaider. Un cas de test de la phase 2 doit constater un **blindage réellement décrémenté à l'écran** (`TM-2.9`), pas seulement une fonction appelable.
>
> ⏭ **`2.7` est reportée — sa charge part en totalité vers `7.8`** (story `2.8`, 2026-09-26). Elle devait exécuter 18 cas : les 7 du sprint 1 jamais joués (`TM-1.1`–`TM-1.4`, `TM-1.6`–`TM-1.8`), `TM-1.5` (reporté par **Q9**) et les 11 du sprint 2 (`TM-2.1`–`TM-2.11`), plus la confirmation des **9 critères `[H]`** des stories `1.1`–`1.6`. *[Erratum du 2026-09-27, story `3.16` (`Q41`) : ce « 9 » compte les lignes du rapport du sprint 1, une par cas de test, et non les critères. Le décompte des critères `[H]` fait foi dans le registre de `stories/AVANCEMENT.md`.]* Rien n'est supprimé : tout est différé à la recette finale. **La gate de la phase 2 est donc l'audit `2.6` seul** — verdict **Autorisé** ⇒ commit de phase autorisé. Risque aggravé, inscrit à `stories/AVANCEMENT.md` §5.

> ⚠️ **Ajout de périmètre assumé** : les dégâts de chute ne figurent **ni dans le CDC principal, ni dans l'amendement**. C'est une décision de l'utilisateur, cohérente avec le genre. Ne pas la confondre avec l'« **Éboulement** » de la section « Dangers » du CDC principal, qui reste **post-MVP** : l'éboulement est un événement de terrain, l'impact est une conséquence directe de la physique de `2.2`. Les menaces de la courbe §4.2 (phase 6) s'**ajoutent** aux dégâts d'impact, elles ne les remplacent pas.

---

## Phase 3 — Terrain destructible et forage · Sprint 3 · 🟡 **PHASE COURANTE**

Objectif : le cœur du jeu — creuser terre, roche et 2 minerais, avec les interdits de forage réellement appliqués, et **récompenser chaque case creusée** selon une table de loot pondérée par couche.

> 🗄️ *État à l'ouverture de la phase (2026-09-27), historique — l'état courant des stories est dans la table ci-dessous :* ✅ **Phase ouverte le 2026-09-27 — les 9 fichiers de stories `3.1` à `3.9` sont créés, la numérotation devient FERME.** Aucune ne peut plus être renumérotée ni renommée (`.claude/CLAUDE.md`, *Interdits*). Toutes sont `À faire`, sauf `3.9` créée directement **`Reportée`** vers `7.8` sous le régime institué par `2.8`. **Aucune n'est démarrée** : c'est `godot-dev` qui ouvrira `3.1`. **Une seule story `En cours` à la fois.**
>
> ✅ **Les quatre arbitrages ouverts à l'ouverture de cette phase ont été TRANCHÉS le 2026-09-27** (story `3.10`, **avant le démarrage de `3.1`**) : `Q27` — `TileSet` en sous-ressource de `World.tscn`, aucune déviation d'arborescence · `Q28` — **exclusif, la tuile décide** : `resource_id` non vide ⇒ minerai, tuile stérile ⇒ tirage · `Q29` — **quatre ressources actives**, `promethium_brut` et `relique_xeno` activés sans créer d'`id`, `TM-3.19` redevient jouable · `Q30` — **un seul découpage de profondeur**, les quatre paliers du §4.2. Le blocage de `3.6` est **levé**. Détail et contraintes dérivées : section « Tranchés le 2026-09-27 » de ce fichier.
>
> ✅ **Assets tranchés le 2026-09-27 (décision utilisateur)** : la story `3.1` produit `assets/sprites/tile_atlas_32x32.png`, **atlas placeholder généré**, six tuiles, **substituable sans toucher au code**. **Taille de tuile confirmée à 32 × 32** — la réconciliation de `pixels_par_metre` demandée en `3.1` devient un **verrouillage**, pas un changement.
>
> **Cinq dettes de la phase 2 sont reprises explicitement**, chacune dans un critère d'acceptation nommé : bloc `monde` migré (`3.2` critère 5) · `pixels_par_metre` verrouillé (`3.1` critère 8) · palier « 300 m+ » atteignable pour toute graine, écart `E15` (`3.2` critère 6) · foreuse posée au sol au lancement (`3.3` critère 4) · volet « ni forage » de `G4` repris (`3.4` critère 3, audit `3.8` critère 5).

| # | Story | Statut |
|---|---|---|
| 3.1 | TileSet et Custom Data Layers (`mineable`, `hardness`, `resource_id`, `value`, `hazard_type`, `destructible`) · **atlas placeholder `assets/sprites/tile_atlas_32x32.png`**, 6 tuiles, substituable sans toucher au code *(décision utilisateur du 2026-09-27)* · ⚠️ **taille de tuile verrouillée à 32 × 32** et `pixels_par_metre` cessant d'être provisoire · ⚠️ emplacement de la ressource `TileSet` = **`Q27` ouvert** | ✅ Terminée — ⏭ critères 9 et 10 (fonction d'accès aux cellules) **transférés à `3.4`** : sans appelant ici, ce serait du `B6` |
| 3.2 | **Générateur de terrain semi-procédural** (Q6) : strates terre/roche par profondeur, densité des 2 minerais, bordures indestructibles, **graine explicite et forçable** · `data/generation.json` (Q15) · ⚠️ **reprend le bloc `monde` de `data/drill.json`** (bords de carte hébergés par la story `2.4`) : les déplacer ici, `GameData.get_world_bounds()` restant la façade, et `pixels_par_metre` à réconcilier avec la taille de tuile de `3.1` · ⚠️ **écart `E15`** — le fond de carte provisoire est à **300,0 m** (profondeur atteignable mesurée : 299,5 m), ce qui rend **hors d'atteinte** le palier « 300 m+ » de la courbe de risque §4.2 : dimensionner la carte pour que ce palier soit jouable, et n'avoir **qu'une** source de vérité pour le générateur et le confinement (`Q24`) | ✅ Terminée — carte 100 × 321 rangées creusables, **320,5 m atteignables** (`E15` refermé) · bloc `monde` migré **en tuiles** · 🔴 défaut « graine ignorée » (`_rng.state = 0`) **trouvé et corrigé** en vérification · `Q1` honorée : **1280×720 reconfirmée** · 146 assertions, 0 échec |
| 3.3 | Ancrages déterministes indépendants de la graine : zone de surface, emplacement de l'anomalie · ⚠️ **inclut le point d'apparition de la foreuse, posé au sol** — relevé par la revue `po` du 2026-09-27 : en phase 2, faute de terrain, la foreuse **chute du haut au fond de la carte en ~9,7 s au lancement et perd 54,6 points de blindage avant toute action du joueur**. C'est le premier écran que verrait un testeur. Différé ici **sur décision utilisateur** : les bords de la phase 2 sont provisoires | ✅ Terminée — ancrages en données (`generation.json` → `ancrages`), identiques pour toute graine · apparition **dérivée** de la colonne 0, foreuse posée au sol : **0 point de blindage perdu en 10 s** · anomalie (23, 305) = marqueur, sans minerai · 193 assertions, 0 échec · ⚠️ vigilance transmise à `7.2` (colonne d'apparition creusée) |
| 3.4 | `MiningSystem` : forage bas et latéral, **aucun forage vers le haut**, **aucun forage latéral dans le vide** · ⚠️ **reprend le volet « ni forage » de `G4`**, sorti `N/A` à l'audit `2.6` · ⚠️ porte le **coût en carburant du forage** et la comparaison **puissance de `foret` contre `hardness`** (critère MVP « tuile détruite seulement si puissance et carburant suffisants », `TM-3.9`, `TM-3.5`) — **aucune autre story de la phase ne les portait** · ⚠️ **reçoit les critères 9 et 10 de `3.1`** : la **fonction d'accès aux cellules** — `get_cell_tile_data()` + `get_custom_data()`, jamais de déduction sur l'`atlas_coords` (`E2`) — et ses **cas limites** (cellule vide, hors carte, tuile indestructible, `E3`). Écrite en `3.1`, elle aurait été sans appelant | ✅ Terminée — `MiningSystem` sur `DrillSystem` · `G1`/`G2`/`G4` vérifiés **par comportement** · coût 0,25/tuile, durée 0,15 + 0,15 × hardness · accès aux cellules `CellInfo` (critères 9-10 de `3.1`) · 🔴 empreinte foreuse **32 → 28 px** (un corps de 32 px ne descend pas dans un puits de 32 px) · `echo` de `TM-1.5` → **phase 4** · ⚠️ roche > 120 m inforable au foret MK-I · 242 assertions, 0 échec |
| 3.5 | Collecte des minerais et soute limitée — **soute pleine : tuile détruite, minerai perdu** (Q5), avec alerte préalable et perte visible · ⚠️ **volet visuel de l'alerte transféré à `4.2`** (aucun HUD avant la phase 4) : `TM-3.11`, bloquant, n'est pleinement jouable qu'après la phase 4 | ✅ Terminée — `CargoSystem` (objet, `scripts/systems/`) · tuile de minerai = `masse_soute` unités, **tout ou rien** · `G9` **par construction** : alerte au remplissage **ou** au début du forage d'un minerai qui ne rentre pas, journal ordonné vérifié · perte observable (`ore_lost` + compteur) · visuel → `4.2` · ⚠️ **contrat pour `5.2`** : la soute compte des unités de masse, la vente doit diviser par `masse_soute` · 268 assertions, 0 échec |
| 3.6 | **Table de loot pondérée par couche et tirage reproductible** *(amendement §2.1 à §2.3)* : poids par couche dans `data/generation.json`, tirage par le RNG ensemencé de `3.2`, **jamais 0 % de drop** (§2.4), aucune ressource `actif_mvp=false` tirée (Q12) · 🔴 **ne peut être close sans les arbitrages `Q28` et `Q29`** (cumul collecte/loot ; correspondance des 5 raretés du §2.2 avec 2 seules ressources actives — `TM-3.19` en est injouable) | ✅ Terminée — `LootSystem` : tirage **par case** (graine de génération + coordonnées), journalisé · table 5 entrées × 4 paliers dans `generation.json`, validée (jamais 0 % de drop, aucune ressource inactive) · 🔴 tirage **au début du forage** pour que la soute alerte avant la perte d'un drop (`G9`) · distribution mesurée, écart max 0,82 pt · 330 assertions, 0 échec |
| 3.7 | Retour de forage (progression, particules, audio) — **élargi** : feedback fort et durable sur les raretés hautes, lumière et son distincts (§2.4) | ✅ Terminée — scène `DrillFeedback` instanciée sous `World` (aucun arbre contractuel modifié) : fissures à opacité = progression, débris, son de forage en boucle · jackpot (lumière, étincelles, son distinct, 4 s en données) sur **drop tiré** rare/légendaire seulement · 3 assets générés (`Q34`) · ⚠️ **objet non vérifié** : ses critères `[H]` sont en attente de `7.8` (registre dans `stories/AVANCEMENT.md`) · 363 assertions, 0 échec |
| 3.8 | 🔒 Audit qualité — Sprint 3 | ✅ Terminée — **Autorisé** à l'itération 5 (agent principal, `Q44`) ; itérations 1 à 4 **KO** (documentation) → corrections `3.13` à `3.16` ; KO mineurs `I4` → `3.17` |
| 3.9 | ~~🔒 Tests manuels humains — Sprint 3~~ | ⏭ **Reportée** vers `7.8` (story `2.8`) |
| 3.10 | **Arbitrages `Q27` à `Q30` d'ouverture de phase** : emplacement du `TileSet` · exclusivité tuile/loot · **quatre ressources actives** · un seul découpage de profondeur · *dépend de : ouverture de la phase 3 · **avant `3.1`*** | ✅ Terminée |
| 3.11 | **Arbitrages `Q31` à `Q33` après le forage** : mur des 120 m **conservé** · empreinte foreuse **28 × 28 validée** · cas **`TM-3.22`** (point d'apparition) ajouté · *dépend de : après `3.4` · **avant `3.5`*** | ✅ Terminée |
| 3.12 | **Arbitrages `Q34` à `Q37` avant le feedback** : sons en `.wav` générés · raretés hautes = rare + légendaire (en données) · feedback sur les drops tirés seulement · `valeur_credits` = prix **par tuile** · *dépend de : après `3.6` · **avant `3.7`*** | ✅ Terminée |
| 3.13 | **Corrections issues de l'audit `3.8`** : `C3` précisé dans la checklist (`Q38`, code inchangé) · compteurs d'`AVANCEMENT.md` remis en cohérence (`I7`) · 6 éléments sans appelant supprimés (`B6`) · commentaire obsolète retiré (`B7`) · `_load_loot()` scindée (`B5`) · *dépend de : `3.8` itération 1* | ✅ Terminée |
| 3.14 | **Correction du compteur de phase 3 du backlog** : vue d'ensemble remise en cohérence (`I7`, itération 2 de `3.8`), total 79 → 80, règle de relecture étendue à la vue d'ensemble · *dépend de : `3.8` itération 2* | ✅ Terminée |
| 3.15 | **Corrections issues de l'itération 3 de l'audit `3.8`** : volume de la phase 0 dans la vue d'ensemble · effectif de la phase 3 dans les récits de phase et au §3.4 d'`AVANCEMENT` · registre des critères `[H]` réconcilié · synthèse périmée · recherche plein texte des compteurs (`I7 [B]`, `I4`) — documentaire · *dépend de : `3.8` itération 3* | ✅ Terminée |
| 3.16 | **Corrections issues de l'itération 4 de l'audit `3.8`** : compteurs `[H]` et de stories restés vivants dans la prose d'`AVANCEMENT.md` (§1, §3.3, §5, §6) · compte `[H]` de la ligne `3.7` de ce fichier · tables §3.2/§3.3 et recommandations périmées (`I7 [B]`, `I4`) — documentaire · *dépend de : `3.8` itération 4* | ✅ Terminée — historique d'`AVANCEMENT.md` archivé (`Q43`) |
| 3.17 | **Corrections mineures issues de l'itération 5 de l'audit `3.8`** : ligne « Dépôt Git » d'`AVANCEMENT.md`, recommandations 10 et 23 rendues autoportantes (`I4`) · *dépend de : `3.8` itération 5* | ✅ Terminée |

Couvre : « MVP jouable » 2, 3, 4 · « Données de tuile » · « Règles interdites ou limitées » · arbitrages **Q5**, **Q6** et **Q19** · **amendement §2** (boucle de récompense variable) et **§7.1** (priorité de développement n° 1).

> ⚠️ **Périmètre élargi par Q6** : la génération procédurale, placée en post-MVP par le CDC, remonte dans ce sprint. Volume prévisionnel révisé à 8 stories, puis à 9 par l'ajout du loot pondéré (`Q19`, story `1.10`) — *historique* : l'effectif **courant** de la phase, arbitrages et corrections compris, est tenu dans `stories/AVANCEMENT.md` (`Q39`). Une **graine fixe** est imposée pendant toute la campagne de tests manuels — désormais la campagne unique `7.8` —, sans quoi aucun résultat n'est reproductible : cf. prérequis `P4` de `qa/plan-tests-manuels.md`.

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
| 4.6 | ~~🔒 Tests manuels humains — Sprint 4~~ | ⏭ **Reportée** vers `7.8` (story `2.8`) |

Couvre : critère MVP « L'interface affiche en temps réel carburant, blindage, crédits, charge de soute et profondeur » · « Direction artistique » (UI terminal industriel) · « Direction sonore » (alertes).

---

## Phase 5 — Surface, économie et améliorations · Sprint 5 *(prévisionnel)*

Objectif : fermer la boucle de jeu — remonter, vendre, ravitailler, améliorer, repartir plus profond — avec une **progression économique infinie**, sans plafond dur.

| # (prév.) | Story | Statut |
|---|---|---|
| 5.1 | Zone de surface et station (détection d'arrivée, ouverture de l'interface) | ⬜ À faire |
| 5.2 | `EconomySystem` : vente du loot et crédits impériaux (ressource pivot, §3.1) · ⚠️ **`Q37`** : `valeur_credits` est un **prix par tuile**, et la soute compte en unités de masse (`3.5`) : la vente paie **`valeur_credits × unités ÷ masse_soute`**, jamais `valeur × unités` | ⬜ À faire |
| 5.3 | Ravitaillement carburant et réparation *(la réparation redevient utile : Q17 annule Q3)* | ⬜ À faire |
| 5.4 | `Shop.tscn` et les améliorations actives au MVP — **au moins 4 stats** (§3.2), soute / réacteur / foret / **blindage activé par Q17** | ⬜ À faire |
| 5.5 | Application immédiate des améliorations à la statistique associée — **effet ressenti dès la descente suivante** (§3.3) | ⬜ À faire |
| 5.6 | **Formule de coût exponentielle et progression sans plafond** *(Q18)* : `data/upgrades.json` en `schema_version: 2`, `cout = base × facteur^niveau`, `id` inchangés (Q12), aucun `niveau_max` | ⬜ À faire |
| 5.7 | **Quatrième amélioration active : activation de `blindage` et paliers supérieurs** *(Q21)* — `actif_mvp: false → true` ; le catalogue ne lui déclare aujourd'hui que le palier 1, de coût nul. **Aucun `id` nouveau** (Q12 intacte) | ⬜ À faire |
| 5.8 | 🔒 Audit qualité — Sprint 5 | ⬜ À faire |
| 5.9 | ~~🔒 Tests manuels humains — Sprint 5~~ | ⏭ **Reportée** vers `7.8` (story `2.8`) |

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
| 6.10 | ~~🔒 Tests manuels humains — Sprint 6~~ | ⏭ **Reportée** vers `7.8` (story `2.8`) |

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
| 7.8 | 🔒 **Recette humaine unique du projet** — campagne complète `TM-1.x` → `TM-7.x` (absorbe `2.7`, `3.9`, `4.6`, `5.9`, `6.10`) · ~60 cas, plusieurs séances | ⬜ À faire |

Couvre : « MVP jouable » 8 · critère MVP « La sauvegarde restitue position, ressources, crédits, améliorations et flags narratifs » · l'ensemble des « Critères d'acceptation MVP » · **amendement §5** (boucle de session) et **§7.5** (priorité de développement n° 5).

> ⛔ **`7.8` est désormais la recette humaine unique de tout le projet** (story `2.8`, 2026-09-26) : elle exécute le plan `qa/plan-tests-manuels.md` **en entier**, des cas du sprint 1 à ceux du sprint 7, et c'est la **première fois** que le jeu est jugé à l'écran. Prévoir plusieurs séances, et anticiper qu'elle puisse ouvrir des stories de correction touchant **n'importe quelle phase antérieure** — créées dans la phase 7, sans renumérotation des phases closes.
>
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

### ✅ TRANCHÉS le 2026-09-27 — les quatre questions ouvertes à l'ouverture de la phase 3

**Plus aucune question n'est ouverte.** Les quatre questions relevées par la revue `po` ont été tranchées par l'utilisateur **avant que `godot-dev` ne démarre `3.1`** — story `3.10`. Les deux qui bloquaient la clôture de `3.6` sont levées.

| # | Question | Décision | Appliquée dans |
|---|---|---|---|
| **Q27** | Où vit la ressource `TileSet` ? L'arborescence contractuelle ne prévoit aucun emplacement pour un `.tres`. | **Sous-ressource de `World.tscn`.** Aucun fichier créé, donc **aucune déviation d'arborescence** : `A1` et `A2`, bloquants, restent satisfaits sans amendement. Procédé déjà éprouvé en `2.1` (texture de la foreuse) et `2.3` (bip d'alerte). Contrepartie : scène plus lourde, `TileSet` non réutilisable — sans objet, il n'y a qu'un monde. *L'**atlas** `.png` reste un fichier réel : c'est la ressource qui est embarquée, pas l'image.* | `3.1` · `3.10` |
| **Q28** | La collecte de tuile et le tirage de loot se cumulent-ils ? | **Exclusif : la tuile décide.** `resource_id` non vide ⇒ la tuile donne ce minerai, **aucun tirage** ; tuile stérile ⇒ **tirage** selon la table de sa couche. Seule option respectant les deux documents : `E1` **bloquant** exige les Custom Data Layers, et la table gouverne les cases nues, majorité du terrain. Le cumul aurait fait payer une tuile rare deux fois ; le tout-par-tirage aurait supprimé la lecture visuelle du terrain. | `3.4`, `3.5`, `3.6` · audit `3.8` |
| **Q29** | À quoi correspondent les cinq raretés du §2.2, alors que deux ressources seulement sont plaçables ? | **Quatre ressources actives** : `promethium_brut` et `relique_xeno` passent `actif_mvp: true`. La table reçoit ses cinq entrées et **`TM-3.19` redevient jouable sans être réécrit**. **Aucun `id` créé ni renommé** — `Q12` intacte, même procédé que `Q21` pour `blindage`. `cristaux_plasma` et `cuivre` restent inactifs : élargissement **borné à deux** ressources. Élargissement de périmètre MVP assumé. | `data/resources.json` · `3.1`, `3.6` · `3.10` |
| **Q30** | Trois couches de loot (§2.2) ou quatre paliers de risque (§4.2) ? | **Un seul découpage, les quatre paliers** : 0-50 / 50-150 / 150-300 / 300 m+. Argument textuel : le §2.2 s'intitule « *exemple, à ajuster en playtest* », le §4.2 donne des **valeurs**. La 4ᵉ colonne de loot est **interpolée** depuis les trois points d'ancrage. Vaut aussi pour **`6.1`**, qui lira le même découpage. | `3.2`, `3.6` · `6.1` · `3.10` |

**Contraintes dérivées, opposables à l'audit `3.8`**

| Origine | Contrainte | Phase | Point d'audit |
|---|---|---|---|
| **Q27** | Aucun fichier `.tres` dans le dépôt pour le `TileSet` : il vit en sous-ressource de `World.tscn`. Une seconde scène de terrain en post-MVP rouvrirait `Q27` — ce serait alors le bon moment. | 3 | `A1`, `A2` |
| **Q28** | **Une seule source de gain par case.** `MiningSystem` détermine la source **avant** de détruire la tuile ; un code appelant la collecte **et** le tirage sur la même case est un écart. | 3 | `E2`, `G8`, `K10` |
| **Q28** | La règle « jamais 0 % de drop » (§2.4) porte sur la **table**, donc sur les cases **stériles**. « Rien » reste une entrée légitime ; aucune **couche** ne peut avoir 0 % de chance de donner quelque chose. | 3 | `K9` |
| **Q29** | Les **six `id`** de `data/resources.json` restent définitifs : l'activation n'en crée ni n'en renomme aucun. | 3, 5, 7 | `D3`, `L4` |
| **Q29** | Le générateur ne place **jamais** `cuivre` ni `cristaux_plasma`, restés `actif_mvp: false`. | 3 | `K10` |
| **Q29** | L'atlas de tuiles porte **huit** cases et non six : les deux minerais activés ont besoin de leur tuile. | 3 | `E1`, `J5` |
| **Q30** | `data/generation.json` ne porte **qu'un** découpage de profondeur. Deux découpages divergeraient au premier réglage d'équilibrage, et une divergence de frontières entre loot et risque ne se révèle pas au playtest : elle se manifeste comme une vague incohérence. | 3, 6 | `K5`, `K7` |

> **Trois points connexes, qui ne sont PAS des arbitrages mais des obligations en retard**, et qui doivent être honorés pendant la phase 3 :
> 1. **`Q1` — « résolution à reconfirmer avant `3.2` »** : inscrite le 2026-08-29, **jamais honorée**. La taille de tuile étant désormais verrouillée à 32 px, il ne reste qu'à reconfirmer ou changer **1280×720**, et à le **consigner** (`3.1`, `3.2`).
> 2. **Volet visuel de l'alerte `Q5`** : `TM-3.11` est un cas **bloquant** qui exige une alerte **visuelle et sonore**, or aucun HUD n'existe avant `4.2`. La story `3.5` livre signal et son ; le volet visuel est **transféré et tracé** (`I5`), et le cas n'est jouable qu'après la phase 4.
> 3. **Volet `echo` de `TM-1.5`** : transféré au sprint 3 par `2.2` faute d'action ponctuelle. Si `drill` est implémenté en lecture **continue** — le plus probable, `TM-3.1` décrivant un appui maintenu —, il n'y a **toujours** pas d'action ponctuelle et le volet doit être **re-transféré à la phase 4** (`pause`, `toggle_inventory`), en le traçant. **Interdit** : fabriquer une action ponctuelle pour le test (`A5`).

### Tranchés — arbitrage utilisateur du 2026-08-29

Les quatre points bloquant la phase 1 sont réglés. La décision fait foi pour l'audit : un choix listé ici n'est **pas** un écart au CDC.

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q1 | Renderer et résolution de référence | **`GL Compatibility`** (préserve l'export Web du CDC) · base **1280×720**, `stretch=canvas_items`, `aspect=expand` — ✅ **résolution reconfirmée le 2026-09-27** par l'utilisateur (story `3.2`) | Story 1.1 |
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
| Q23 | Le **coût de chute saturait** au-delà de 8,5 tuiles : au-delà, toute chute coûtait identiquement 33,6 points. Faut-il ajuster, et comment ? | **Relever la vitesse de chute maximale ET adoucir le coût.** `vitesse_chute_max_px_s` 700 → **1200**, `degats_par_px_s` 0,12 → **0,07**. Le **seuil reste à 420** : c'est lui qui rend le déplacement ordinaire gratuit (`M8`). La sévérité croît désormais de **3 à 25 tuiles** (au lieu de 3 à 8,5), pour un maximum de **54,6 points** sur 100. **Aucune ligne de code modifiée** : ajustement entièrement en données. | `data/drill.json` · story `2.11` · rejugé au playtest `7.6` |
| Q24 | Le **confinement de la foreuse aux bords de carte**, écrit en `2.5`, relève des « limites de monde » de `2.4`. Où est consigné son périmètre ? | **Dans une story dédiée, `2.11`, qui en devient propriétaire.** `2.4` et `2.5` reçoivent un **renvoi** en Notes ; **aucun de leurs critères n'est réécrit**, aucun statut ne change. Motif du rattachement initial à `2.5` : sans sol, la source de dégâts d'impact était inatteignable et `M9` insatisfiable. | Story `2.11` · renvois en `2.4` et `2.5` |
| Q25 | La **liste de scripts** de la section « Architecture Godot » du CDC est-elle limitative ou indicative ? | **Indicative.** Elle illustre l'organisation, elle n'énumère pas les fichiers autorisés. Restent contraignants : l'**arborescence** (`A1`, `A2`), le **rattachement à une story** (`I1`) et les conventions de nommage (`A4`). Portée **rétroactive** : couvre `CameraSystem.gd`, `GameData.gd` (jusqu'ici arbitré isolément par **Q4**) et les scripts d'UI des phases 4 à 6. L'écart **`E14` est clos**. | Story `2.11` · `stories/AVANCEMENT.md` §4 |
| Q26 | Le critère 2 de la story `2.11` exigeait une croissance de la sévérité de chute sur **plus de 30 tuiles** ; le résultat mesuré est **25**. Faut-il pousser le réglage ? | **Non — 25 tuiles sont acceptées, `degats_par_px_s` reste à 0,07.** Le seuil de 30 provenait d'une **estimation erronée de l'agent**, non d'une exigence du cahier des charges, et l'objectif réel de `Q23` est atteint : la saturation passe de 8,5 à 25 tuiles. Atteindre 30 aurait exigé un plafond de 1320 px/s, portant la chute maximale à **63 points sur 100** — plus punitif que ce qui avait été retenu. **Le critère 2 reste affiché « partiellement satisfait »** : il est assoupli par décision tracée, jamais réécrit pour coller au résultat. | Story `2.11` · rejugé au playtest `7.6` |

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
| Q23 | Le **seuil d'impact reste non nul et n'est pas un levier d'équilibrage** : le relever rétrécirait la plage de sévérité au lieu de l'étendre, et un seuil nul est refusé au chargement par `GameData`. | 2 | `M8` |
| Q23 | Tout ajustement ultérieur de la sévérité de chute se fait **en données**, jamais en code. La démonstration est faite : `Q23` n'a modifié **aucune ligne de `.gd`**. | 2, 7 | `D1`, `M8` |
| Q23 | À vitesse de chute maximale, le déplacement par frame doit rester **inférieur à la taille d'une tuile** (32 px), sans quoi la foreuse traverserait le sol. À 1200 px/s et 60 im/s : **20 px**, marge conservée. **Tout relèvement futur du plafond doit refaire ce calcul.** | 2, 3 | `G5` |
| Q24 | Le confinement aux bords de carte est une mesure de **phase 2**, **relevée mais non remplacée** par la ceinture de tuiles indestructibles de `3.2` : il reste en seconde barrière, notamment pour une position restaurée hors carte par une sauvegarde corrompue (phase 7). | 2, 3, 7 | `G5`, `K4` |
| Q24 | Les bords de `data/drill.json` (bloc `monde`) et les dimensions du générateur de `3.2` doivent désigner **la même carte**. Deux sources divergentes produiraient une bande infranchissable mais vide, ou un terrain débordant la zone atteignable. La migration du bloc `monde` vers `data/generation.json` referme ce risque. | 3 | `K5` |
| Q25 | Un script hors de la liste du CDC reste soumis à l'**arborescence contractuelle** et doit être **rattaché à une story**. La décision porte sur la liste, **pas sur la discipline**. | toutes | `A2`, `I1` |
| Q26 | Un critère d'acceptation **non satisfait** ne se réécrit pas pour coller au résultat obtenu : il reste affiché tel quel et l'écart est **assoupli par un arbitrage tracé**. Clore une story dans ce cas **exige une décision explicite de l'utilisateur**. | toutes | `I3`, `I5` |

### En attente

*Aucune question ouverte* (dernières tranchées : `Q43` et `Q44`, le 2026-09-27, story `3.16`). *Mention d'origine :* `Q20` et `Q21`, les deux dernières, ont été tranchées le 2026-09-06 (bloc ci-dessus), en même temps que `Q22`.

**Points reportés, sans question ouverte associée** — décidés, mais volontairement non couverts au MVP :

| Point | Décision | À rouvrir |
|---|---|---|
| « Vitesse de forage » du §3.2 | Écartée au MVP : `foret` reste une **puissance** (seuil de `hardness`) — `Q21` | post-MVP |
| « Profondeur max sûre » du §3.2 | Reportée : effet recouvrant la courbe de risque §4.2, et peu tangible au sens du §3.3 — `Q21` | post-MVP |
| Distinction puissance / vitesse comme **deux axes d'amélioration** distincts | Non instruite au MVP — conséquence des deux lignes ci-dessus | post-MVP |

### Tranchés — décision utilisateur du 2026-09-27 (assets de la phase 3)

Cette décision **fait foi pour l'audit `3.8`** : ce qui y est listé n'est **pas** un écart au CDC.

| Objet | Décision | Tracé dans |
|---|---|---|
| **Assets de tuiles** | **Atlas placeholder généré par `godot-dev`**, fichier réel `assets/sprites/tile_atlas_32x32.png`, **six tuiles** : `tile_dirt`, `tile_rock`, `tile_rock_hard`, `tile_bedrock`, `ore_fer_industriel`, `ore_adamantium`. Palette du CDC (« Direction artistique »), tuiles visuellement distinctes. **Substitution ultérieure sans coût** : remplacer le `.png` à nom, grille et dimensions identiques n'exige **aucune modification de code ni de `.tscn`**. | Story `3.1`, critères 2 à 5 |
| **Minerais dessinés** | **Deux seulement** — `fer_industriel` et `adamantium`. Les quatre ressources `actif_mvp: false` (`cuivre`, `promethium_brut`, `cristaux_plasma`, `relique_xeno`) **n'ont pas de tuile**, `Q12` interdisant au générateur de les placer. | Story `3.1`, critère 3 |
| **Taille de tuile** | **32 × 32, confirmée.** La valeur était déjà celle de `pixels_par_metre` et de l'empreinte de collision de `2.1` : la « réconciliation » demandée en `3.1` devient un **verrouillage** (et la mention « provisoire » du commentaire de `data/drill.json` tombe), non un changement. | Story `3.1`, critère 8 |
| **Reste des assets** | **Non bloquant, hors phase 3** : police et cadres d'UI (phase 4), portraits radio (phase 6), boucles audio. | — |

> ⚠️ **Deux conséquences à ne pas perdre** : (1) l'atlas étant un **fichier**, il doit figurer dans les **artefacts produits** de la story `3.1`, sans quoi l'audit le relèvera en `A5` (orphelin) ; (2) `EngineAudio` et `DrillAudio` de `DrillRig.tscn` sont **sans flux**, et `play()` sans flux est un **no-op totalement silencieux** sur Godot 4.7 (mesuré en `2.3`) — le retour sonore de forage de `3.7` exigera un **flux réel**, fourni ou généré et embarqué.

### Tranchés — arbitrage utilisateur du 2026-09-27 (après le forage, story `3.11`)

Soulevés par la story `3.4`, tranchés **avant l'ouverture de `3.5`**. Ils **font foi pour l'audit `3.8`**.

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q31 | Au foret de départ (puissance 2), la roche profonde (dureté 3, sous **120 m**) et l'adamantium sont inforables : le palier « 300 m+ » du §4.2 exige d'acheter le foret niveau 2. Garder ce mur ? | **Mur CONSERVÉ.** C'est la boucle « creuser → vendre → améliorer » : le foret niveau 2 est la première décision économique du joueur. **Aucune donnée modifiée.** Le palier « 300 m+ » reste atteignable **géométriquement pour toute graine** (`E15` refermé par `3.2`), mais **ludiquement après un achat**. La recette `7.8` devra l'éprouver avec un foret amélioré. Valeurs à rejuger au playtest `7.6`. | Story `3.11` ; Notes de `3.4` |
| Q32 | L'empreinte de la foreuse a été portée de 32 × 32 à **28 × 28** (sprite **et** collision) par `3.4`, parce qu'un corps de 32 px ne descend pas dans un puits de 32 px. Valider ? | **Validée.** Sprite et collision restent **identiques**, avec 2 px de jeu de chaque côté. La réconciliation annoncée par `2.1` (« à réconcilier avec la taille de tuile réelle en phase 3 ») est close. | Story `3.11` ; Notes de `3.4` et de `2.1` |
| Q33 | Aucun cas de test manuel ne vérifie le point d'apparition (lacune signalée en `3.3`, recommandation 41). Quand l'ajouter ? | **Maintenant.** Cas **`TM-3.22`** ajouté à `qa/plan-tests-manuels.md`, dans le prolongement de la numérotation du sprint 3, sans renumérotation. Il couvre le critère `[H]` 11 de `3.3`. Il sera exécuté à la recette `7.8`, comme tout le sprint. | Story `3.11` ; `qa/plan-tests-manuels.md` ; Notes de `3.3` et `3.9` |

### Tranchés — arbitrage utilisateur du 2026-09-27 (avant le feedback, story `3.12`)

Tranchés **avant l'ouverture de `3.7`**. Ils **font foi pour l'audit `3.8`** et, pour `Q37`, pour l'audit de la phase 5.

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q34 | Aucun fichier audio n'existe : d'où viennent le son de forage et le son distinct des drops rares ? | **Fichiers `.wav` générés** par `godot-dev` dans `assets/audio/` (préfixe `sfx_`, `.import` versionné), placeholders **substituables sans toucher au code**, comme l'atlas de `3.1`. Listés en artefacts de `3.7` (`A5`). | Story `3.12` ; Notes de `3.7` |
| Q35 | Quelles raretés déclenchent le feedback « jackpot » du §2.4 ? | **Relique rare + artefact légendaire**, un seul niveau d'intensité, conformément à `TM-3.19`. Marquage **en données** sur l'entrée de loot (`K7`), jamais en dur. | Story `3.12` ; Notes de `3.7` |
| Q36 | Une tuile de minerai minée déclenche-t-elle aussi ce feedback ? | **Non : drops tirés seulement.** Le §2.4 parle du drop, surprise par définition ; une tuile est visible avant d'être forée. Le signal doit distinguer **gain de tuile** et **gain tiré** (`Q28`). | Story `3.12` ; Notes de `3.7` |
| Q37 | La soute compte en unités de masse (`3.5`) : comment s'entend `valeur_credits` à la vente ? | **Prix par tuile.** La vente de `5.2` paie **`valeur_credits × unités ÷ masse_soute`**. Le poids pèse sur la soute (dilemme §4.1), pas sur le prix. Payer `valeur × unités` serait un écart : l'adamantium serait payé deux fois, la relique xeno trois fois. | Story `3.12` ; ligne `5.2` du backlog |

### Tranché — arbitrage utilisateur du 2026-09-27 (audit `3.8`, story `3.13`)

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q38 | `C3 [B]` interdit « tout appel direct à un nœud d'une autre branche ». `MiningSystem` (sous `DrillRig`) interroge et commande `TerrainSystem` (sous `World`) par une référence **injectée par la scène**. KO bloquant à la lettre ? | **`C3` PRÉCISÉ, code inchangé.** Une référence injectée par `@export NodePath`, servant une **requête synchrone** vers un type nommé, est conforme ; un chemin littéral ou une **notification** hors signal restent en KO. Note opposable ajoutée à `qa/audit-qualite-reference.md` §C, sur le modèle de `C1`. | Story `3.13` ; audit `3.8` itération 2 |

### Tranchés — arbitrage utilisateur du 2026-09-27 (itération 3 de l'audit `3.8`, story `3.15`)

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q39 | Les compteurs (stories, `Terminée`, %, total MVP, `[H]`) sont recopiés à une dizaine d'endroits dans deux documents, et chaque itération d'audit en trouve un nouveau faux. Comment casser la boucle ? | **Source unique : `stories/AVANCEMENT.md`.** `BACKLOG.md` ne garde que le statut de chaque story et renvoie vers `AVANCEMENT.md` pour les totaux ; ses encadrés « Révision du … » sont figés comme historiques. Le point `I7` de la checklist est précisé en conséquence. | Story `3.15`, critères 12 et 13 |
| Q40 | La vue d'ensemble affichait 10 pour la phase 0 (fichiers, annulée incluse), alors que les additions comptent 9. Quelle convention ? | **Stories comptées, l'annulée en mention** : « 9 (+1 annulée) ». Une colonne de comptes par phase se somme au total MVP. | Story `3.15`, critère 1 |
| Q41 | Le registre des critères `[H]` est faux en phase 3 (12 annoncés, 9 réels) et incertain en phase 1 (9 annoncés, 7 relevés). Quand le réconcilier ? | **Dans la story `3.15`**, pour toutes les phases ouvertes, recompté fichier par fichier. | Story `3.15`, critère 4 |
| Q42 | Les KO mineurs `I4` (synthèses périmées) sont-ils corrigés maintenant ? | **Oui, dans la story `3.15`.** | Story `3.15`, critères 5 à 7 |

### Tranchés — arbitrage utilisateur du 2026-09-27 (itération 4 de l'audit `3.8`, story `3.16`)

| # | Question | Décision | Tracé dans |
|---|---|---|---|
| Q43 | Les compteurs sont justes aux emplacements de référence d'`AVANCEMENT.md`, mais des copies subsistent dans sa prose, historique compris (§1, §3.x, §5, §6). Faut-il une règle interne, restreindre `I7`, ou archiver ? | **Archiver l'historique.** Tout ce qui est historique dans `AVANCEMENT.md` (contextes précédents, encadrés de révision, tables des phases closes, risques et recommandations résolus, énoncés d'origine barrés) est **transféré** dans `stories/AVANCEMENT-historique.md`, **figé** et **exclu de `I7`**. `AVANCEMENT.md` redevient un tableau de bord court : compteurs aux seuls emplacements de référence (§1, table des phases avec la ligne « Total MVP », registre `[H]`), **aucun chiffre** de stories ni de `[H]` dans la prose, risques et recommandations **actifs** seulement. Transfert, pas suppression. *Options écartées* : règle interne proposée par le `po` ; restriction de `I7`. | Story `3.16`, critères 10 à 13 ; note `I7` de `qa/audit-qualite-reference.md` |
| Q44 | Qui réalise `3.16`, et qui conduit l'itération 5 de `3.8` ? | **`3.16` réalisée par le `po`** de bout en bout. **L'itération 5 est conduite par l'agent principal**, qui n'a pas écrit `3.16`. | Story `3.16`, critère 14 ; Notes de `3.8` |

> **Historique** : les huit points d'ambiguïté du CDC (Q1 à Q8) ont été tranchés ou déclarés sans objet le 2026-08-29 ; Q9 et Q10 (implémentation) le 2026-08-30, Q11 à Q13 avant la story `1.5`, Q14 et Q15 après. **Q3 et Q8 ont été rouverts puis annulés le 2026-09-06 par Q17.** Q16 à Q19 ont été tranchés le 2026-09-06 (story `1.10`), Q20 à Q22 le même jour (story `1.11`). **Q23 à Q25** ont été tranchés le 2026-09-27 (story `2.11`, sur demande de l'utilisateur avant le commit de la phase 2), et **Q26** le même jour, à l'issue de la revue `po` du sprint 2. **Q27 à Q30** ont été ouverts par la revue `po` d'ouverture de la phase 3 et tranchés le même jour (story `3.10`), **avant le démarrage de `3.1`**. **Q31 à Q33** ont été soulevées par la story `3.4` et tranchées le même jour (story `3.11`), **avant l'ouverture de `3.5`**. **Q34 à Q37** ont été tranchées le même jour avant l'ouverture de `3.7` (story `3.12`). **Q38** a été soulevée par l'audit `3.8` et tranchée le même jour (story `3.13`). **Q39 à Q42** ont été tranchées après l'itération 3 de l'audit `3.8` (story `3.15`), **Q43 et Q44** après l'itération 4 (story `3.16`). **Les 44 questions sont closes ; aucune n'est ouverte.**
