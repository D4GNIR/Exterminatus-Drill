# Avancement fonctionnel — Motherload 40K : Exterminatus Drill

> Document tenu par l'agent `po`. **Mis à jour, jamais dupliqué.**
> Dernière mise à jour : **2026-08-29** · Contexte : intégration au plan des arbitrages **Q5, Q6 et Q7** rendus par l'utilisateur lors de la revue `0.5`.
>
> **Méthode de comptage** — les statuts ci-dessous sont relevés en lisant le champ `## Statut` des **16** fichiers de `stories/` (hors `BACKLOG.md` et `AVANCEMENT.md`), jamais recopiés d'une version antérieure de ce document. Relevé du 2026-08-29 : **7 Terminée · 9 À faire · 0 En cours · 0 Bloquée**.

---

## 1. Synthèse

| Indicateur | Valeur |
|---|---|
| Phase courante | **Phase 0 — Amorçage du projet** (sprint 0) |
| Story `En cours` | **aucune** (0 fichier au statut `En cours`, conforme à la règle « une seule à la fois ») |
| Prochaine story | `1.1 - Initialisation du projet Godot 4` (ouverture de la phase 1) |
| Stories créées | **18** fichiers (phase 0 : 10 · phase 1 : 8) — phases 2 à 7 encore prévisionnelles, sans fichier |
| Stories terminées | **9** (`0.1`, `0.2`, `0.3`, `0.4`, `0.6`, `0.7`, `0.8`, `0.9`, `0.10`) · **1 `Annulée`** (`0.5`) · **8 `À faire`** (phase 1) |
| Avancement MVP (estimé) | **~15 %** (9 stories terminées sur **58** prévues jusqu'à la fin de la phase 7 : 9+8+6+8+6+7+7+7, la `0.5` annulée n'étant plus comptée en phase 0) |
| Code de production existant | **aucun** — vérifié : ni `project.godot`, ni `.gd`, ni `.tscn`, ni `.tres` |
| Dépôt Git | **initialisé et publié** — branche `main`, commit `7a86b1d` (29 fichiers), poussé sur `origin/main` → `https://github.com/D4GNIR/Exterminatus-Drill.git` |
| Gate du sprint 0 | audit `0.4` **Autorisé** (écarts levés par `0.8` et `0.9`). Gate 2/2 `0.5` **annulée** sur décision utilisateur (story `0.10`) : la phase 0 est close avec une seule gate. |
| Arbitrages | **Q1 à Q7 tranchés**, Q8 sans objet. Q5/Q6/Q7 rendus le 2026-08-29 et propagés au backlog, au plan de tests et à la checklist d'audit. |
| Jeu jouable | non (aucune fonctionnalité du MVP n'est encore implémentée) |

---

## 2. Avancement par phase

| Phase | Sprint | Stories | Terminées | % | Gate QA | État |
|---|---|---|---|---|---|---|
| 0 — Amorçage du projet | 0 | 9 *(+1 annulée)* | 9 | **100 %** | `0.4` audit ✅ · `0.5` revue ⛔ annulée | ✅ **Close** |
| 1 — Fondations techniques Godot | 1 | 8 | 0 | 0 % | `1.7` audit → `1.8` tests | ⬜ Non démarrée (stories rédigées) |
| 2 — Foreuse et déplacement | 2 | ~6 | 0 | 0 % | `2.5` → `2.6` | ⬜ Non découpée en fichiers |
| 3 — Terrain destructible et forage | 3 | **8** | 0 | 0 % | `3.7` → `3.8` | ⬜ Non découpée en fichiers · périmètre élargi par **Q6** |
| 4 — HUD et interfaces de bord | 4 | ~6 | 0 | 0 % | `4.5` → `4.6` | ⬜ Non découpée en fichiers |
| 5 — Surface, économie, améliorations | 5 | ~7 | 0 | 0 % | `5.6` → `5.7` | ⬜ Non découpée en fichiers |
| 6 — Zone profonde et anomalie | 6 | ~7 | 0 | 0 % | `6.6` → `6.7` | ⬜ Non découpée en fichiers |
| 7 — Sauvegarde et recette MVP | 7 | **7** | 0 | 0 % | `7.6` → `7.7` | ⬜ Non découpée en fichiers · garde-fous ajoutés par **Q7** |
| 8+ — Post-MVP | — | — | — | — | — | ⬜ Hors périmètre MVP · phase 8 requalifiée en *enrichissement* de la génération (**Q6**) |
| **Total MVP (phases 0 à 7)** | — | **57** | **7** | **12 %** | — | 🟡 Sprint 0 en cours |

> Les volumes des phases 2 à 7 sont **prévisionnels** (aucun fichier de story créé) : ils reflètent les tableaux de `stories/BACKLOG.md` au 2026-08-29, après résorption des entrées `3.2b` et `7.3b` en numérotation séquentielle.

---

## 3. Détail de la phase 0 (sprint courant)

| Story | Statut | Vérification factuelle |
|---|---|---|
| `0.1 - Nettoyage du squelette .claude` | ✅ Terminée | Vérifié : `.claude/README.md` décrit bien le stack Godot, `.claude/agents/godot-dev.md` existe, `product-owner.md` référence `.claude/CLAUDE.md` et le CDC réel. Les 6 critères sont satisfaits. |
| `0.2 - Backlog, squelette QA et suivi d'avancement` | ✅ Terminée | Vérifié : `stories/BACKLOG.md`, `stories/AVANCEMENT.md`, `qa/{README,audit-qualite-reference,plan-tests-manuels,rapport-test-template}.md`, `qa/rapports/` et les 12 stories des phases 0-1 existent. Aucun fichier de code créé. |
| `0.3 - Initialisation du dépôt Git` | ✅ Terminée | Vérifié par commandes : `git init -b main` exécuté (Git 2.50.1), `git symbolic-ref --short HEAD` → `main`, `git status` sort en 0. `.gitignore` couvre les 8 motifs exigés ; test réel avec fichiers factices dans `.godot/`, `.import/`, `build/`, `export*.cfg`, `.DS_Store`, `*.translation`, `*.tmp` → `git status --porcelain` inchangé, `git check-ignore -v` concluant. `README.md` complet (pitch, stack, prérequis Godot 4.x / 4.7.2, arborescences, renvois CDC + backlog + QA). `git rev-list --all --count` → 0, `git remote -v` vide, aucun `.gd`/`.tscn`/`project.godot`. Les 8 critères sont satisfaits. |
| `0.4 - Audit qualité — Sprint 0` | ✅ Terminée | Gate 1/2. Verdict **Autorisé** : 58 points contrôlés, 7 OK, 2 KO mineurs, 49 N/A (sections GDScript sans objet, aucun code produit ce sprint). Aucun KO bloquant. Les 2 écarts mineurs sont traités par `0.8`. |
| `0.5 - Revue humaine de fin de sprint 0` | ⛔ **Annulée** | Gate 2/2 **annulée le 2026-08-29** sur décision de l'utilisateur (story `0.10`). Fichier conservé (34 renvois dans 9 fichiers). Non exécutée : les cas `TM-0.1` à `TM-0.3` ne seront pas joués, dont `TM-0.2` (bloquant), seul contrôle humain de la couverture du CDC par le découpage. Ses critères 3 et 4 étaient de toute façon purgés de leur objet, Q1 à Q7 ayant été tranchées le même jour et propagées au backlog, au plan de tests et à la checklist d'audit. |
| `0.7 - Commit et publication anticipés du dépôt` | ✅ Terminée | Dérogation demandée par l'utilisateur. Vérifié : commit `7a86b1d` (29 fichiers, 2477 insertions), `git diff origin/main..main` vide, branche `main` suivie de `origin/main`. Les 5 critères sont satisfaits. |
| `0.10 - Annulation de la revue humaine du sprint 0` | ✅ Terminée | Story `0.5` passée à `Annulée`, fichier conservé, décision et coût tracés. Portée limitée au sprint 0 : les gates de tests manuels des sprints 1 à 7 restent en vigueur. |
| `0.9 - Correction du prérequis P1 et des références de gate` | ✅ Terminée | Vérifié : `qa/plan-tests-manuels.md:17` → `P1 ✅ satisfait (Godot 4.7.2)`, règle de blocage reformulée ; `TM-6.6` et `TM-5.9` créés sans renumérotation ; `.claude/CLAUDE.md:49` cite désormais des gates réelles. Les 5 critères sont satisfaits. |
| `0.8 - Remise à niveau du suivi et portabilité du .gitignore` | ✅ Terminée | Correction des 2 écarts mineurs de l'audit `0.4` : remise à niveau de ce document, et exclusion de `.claude/settings.local.json` par le `.gitignore` du dépôt (vérifié : `git check-ignore -v` désigne désormais `.gitignore:65`). |
| `0.6 - Installation de Godot 4 et requalification des critères [H]` | ✅ Terminée | Vérifié : `godot --version` → `4.7.2.stable`, `godot --headless --quit` sort en 0 sans `ERROR:`, binaire dans le `PATH`. Les 16 mentions « Godot non installé » de `stories/` et `qa/` ont été requalifiées. Exécutée chronologiquement avant `0.3`. |

**Sprint 0 clos.** Toutes les stories exécutables sont `Terminée` ; `0.5` est `Annulée`. Reste le **commit de clôture de la phase 0**, portant `0.4`, `0.8`, `0.9`, `0.10` et la fin de `0.7` — à annoncer avant exécution, le push restant à l'initiative de l'utilisateur.

> ⛔ **Dérogation à la règle de gate** : `.claude/CLAUDE.md` interdit de commiter la phase tant que les **deux** stories de fin de sprint ne sont pas `Terminée`. La phase 0 est close avec la seule gate d'audit `0.4`, sur décision de l'utilisateur (story `0.10`).

> **Dérogation tracée (story `0.7`)** : à la demande explicite de l'utilisateur, un premier commit `7a86b1d` a été poussé sur `origin/main` **avant** la clôture de la phase. La phase 0 sera donc couverte par deux commits au lieu d'un.
>
> L'identité Git est disponible en configuration **globale** (`Dagnir` / `jeremiecette@gmail.com`) et a bien signé le commit : le point signalé en story `0.3` portait sur la configuration locale au dépôt et n'était pas bloquant.

---

## 4. Couverture du cahier des charges

### Fonctionnalités MVP

Les 8 points de « MVP jouable » et les 7 « Critères d'acceptation MVP » sont **tous rattachés à une phase** (tables de traçabilité dans `stories/BACKLOG.md`). **Aucun périmètre MVP orphelin identifié à ce jour.**

### Écarts et zones de vigilance relevés dans le CDC

| # | Constat | Traitement |
|---|---|---|
| ~~E1~~ | ~~Le critère MVP « le HUD affiche le **blindage** » suppose une jauge de blindage, alors qu'**aucun système de dégâts** n'apparaît dans les 8 points du « MVP jouable »~~ | ✅ **Résolu** — Q3 tranchée : jauge affichée mais **statique** au MVP. Tracé en story 1.4. |
| ~~E2~~ | ~~Le comportement en **soute pleine** n'est spécifié nulle part (refus de collecte ? perte du minerai ?)~~ | ✅ **Résolu** — **Q5 tranchée le 2026-08-29** : tuile détruite, minerai perdu, forage non empêché. Le CDC ne tranchait pas : la décision **comble** un vide, ce n'est pas un écart. Contraintes opposables : alerte antérieure à la perte et perte visible (audit `G9`/`G10`, tests `TM-3.11` à `TM-3.13`). À porter en story 3.5. |
| ~~E3~~ | ~~La **mort de la foreuse** (blindage à zéro) n'est décrite ni dans la boucle de jeu, ni dans le MVP~~ | ✅ **Sans objet au MVP** — Q8 : conséquence de Q3, sans système de dégâts le blindage ne peut atteindre zéro. Repoussé avec les dangers, en post-MVP. |
| ~~E4~~ | ~~La section « Architecture Godot » ne prévoit **aucun chargeur de données**~~ | ✅ **Résolu** — Q4 tranchée : autoload `scripts/autoload/GameData.gd`, déviation assumée et validée. Tracé en story 1.5. |
| E5 | Le mode de **génération du terrain** MVP n'est pas précisé ; la génération procédurale est explicitement placée en post-MVP par le CDC. | ⚠️ **Tranché mais devenu un écart** — **Q6 : semi-procédural dès le MVP**. Voir **E9**. |
| ~~E6~~ | ~~Le **déclenchement de la sauvegarde** (auto / manuel) n'est pas spécifié~~ | ✅ **Résolu** — **Q7 tranchée le 2026-08-29** : sauvegarde **manuelle uniquement**, aucune sauvegarde automatique. Le CDC ne tranchait pas : ce n'est pas un écart. Contraintes opposables : rappel non bloquant au retour en surface et confirmation avant de quitter (audit `H7`–`H9`, tests `TM-7.7` à `TM-7.10`), portées en story 7.4. |
| E7 | Les notions de **quota** et de **faveur du Mechanicus** sont décrites dans « Économie » mais absentes du MVP. | Hors MVP : reportées en phase 12. Champs éventuellement anticipés dans `GameState` (story 1.4). |
| E8 | La **note de propriété intellectuelle** du CDC (univers Warhammer 40,000) reste un risque pour toute diffusion commerciale. | Décision produit de l'utilisateur, hors périmètre technique. À trancher avant toute publication. |
| **E9** | 🔴 **Écart au CDC assumé — remontée de périmètre du post-MVP vers le MVP.** Le CDC place la génération procédurale du terrain dans « Backlog après MVP » (phase 8). L'arbitrage **Q6 du 2026-08-29** la fait **remonter en phase 3**, à l'intérieur du MVP. C'est le premier écart où le réalisé s'écarte volontairement du CDC — les autres arbitrages ne faisaient que combler des silences. | **Écart assumé et validé par l'utilisateur**, non silencieux (audit `I5`). Conséquences tracées : phase 3 portée à 8 stories (`3.2` générateur, `3.3` ancrages), phase 8 du CDC **requalifiée en *enrichissement*** de la génération et non en création, section `K` ajoutée à `qa/audit-qualite-reference.md`, cas `TM-3.14`/`TM-3.15`/`TM-3.16` et prérequis de graine figée `P4` ajoutés au plan de tests. **Le CDC lui-même n'est pas réécrit** : la remontée vit dans le backlog et ici. |

---

## 5. Risques et blocages

| Risque | Sévérité | Impact | Mitigation |
|---|---|---|---|
| ~~**Godot n'est pas installé** sur la machine~~ | ✅ **Levé** | — | Godot **4.7.2 stable** installé en story `0.6` ; binaire `godot` dans le `PATH`. Les agents valident désormais syntaxe, import et chargement de scènes en headless. Prérequis P1 du plan de tests satisfait. |
| Écriture manuelle de `project.godot` et des `.tscn` | 🟠 Moyenne | Risque d'un projet inouvrable au premier lancement (UID, `load_steps`, `ExtResource`). | Rester minimaliste en phase 1 ; prévoir une story de correction après `TM-1.1`. |
| ~~Ambiguïtés CDC non tranchées~~ | ✅ **Levé** | — | **Q1 à Q7 tranchées le 2026-08-29**, Q8 sans objet. Les 8 points d'ambiguïté du CDC sont clos ; les contraintes d'implémentation dérivées sont tracées dans `BACKLOG.md`. |
| Périmètre du MVP élargi par Q6 (écart **E9**) | 🟠 Moyenne | La génération procédurale, placée en post-MVP par le CDC, remonte en phase 3 : sprint 3 porté à 8 stories et tests manuels non reproductibles sans graine fixe. | Graine explicite et forçable en story 3.2, ancrages déterministes en story 3.3 ; graine figée pour toute la campagne de tests d'un sprint (prérequis `P4`). Audit : section `K` (`K1`–`K6`). Phase 8 requalifiée en enrichissement. |
| Cumul Q5 × Q7 (perte de minerai + sauvegarde manuelle) | 🟠 Moyenne | Une longue descente peut être perdue deux fois : à la collecte en soute pleine, puis à la fermeture sans sauvegarde. Risque de frustration rapporté comme un défaut aux tests. | Alerte préalable et perte visible (story 3.5, audit `G9`/`G10`, tests `TM-3.11`–`TM-3.13`) ; rappel au retour en surface et confirmation avant de quitter (story 7.4, audit `H7`–`H9`, tests `TM-7.7`–`TM-7.10`). **Réévaluer à l'équilibrage du sprint 5**, quand la boucle économique sera jouable. |
| ~~Dépôt Git non initialisé~~ | ✅ **Levé** | — | Story `0.3` : dépôt initialisé sur `main` avec un `.gitignore` Godot 4 posé **avant** toute génération de cache. Story `0.7` : commit `7a86b1d` publié sur `origin/main`. Identité Git présente en configuration globale et ayant signé le commit. |
| Dérive des compteurs de `AVANCEMENT.md` | 🟡 Faible | Ce document agrège des compteurs (§1) et un détail (§2, §3) : une mise à jour partielle du détail sans reprise des agrégats recrée l'incohérence relevée par l'audit `0.4`. | Reprendre §1 **et** §2/§3 à chaque fin de story, jamais l'un sans l'autre. Point à recontrôler à chaque audit de sprint. |
| Volume du MVP (**57 stories**, 8 phases) | 🟡 Faible | Risque d'essoufflement / dérive de périmètre. Le volume a crû de 54 à 57 du fait de Q6 et Q7. | Gate stricte par sprint, aucune fonctionnalité post-MVP avant la fin de la phase 7. |
| Prérequis `P1` du plan de tests périmé | 🟡 Faible | `qa/plan-tests-manuels.md` affiche encore `P1 — Godot 4.x installé : ⚠️ à faire`, alors que la story `0.6` (Terminée) a installé Godot 4.7.2. Lu littéralement, ce prérequis fait passer **toute** story de tests manuels à `Bloquée`, y compris `1.8`. | Écart documentaire à corriger **avant l'ouverture de la phase 1**. Aucune correction faite ici : elle exige une story dédiée (règle « pas de travail sans story »). À traiter en `0.9` ou en amont de `1.8`. |
| Exemples de gate désynchronisés dans `.claude/CLAUDE.md` | 🟡 Faible | Le fichier cite « `1.6` audit → `1.7` tests · `3.8` audit → `3.9` tests » ; la numérotation réelle est `1.7`/`1.8` et, depuis la renumérotation du 2026-08-29, `3.7`/`3.8`. | Ce sont des **exemples illustratifs**, pas des références opposables : `stories/BACKLOG.md` fait foi. Correction à l'initiative de l'utilisateur (fichier de configuration, hors périmètre agent). |

---

## 6. Recommandations immédiates

1. ~~Trancher les questions Q1 à Q7~~ — ✅ **fait le 2026-08-29**. Q1–Q4 (`GL Compatibility`, `physical_keycode`, blindage statique, autoload `GameData.gd`), puis Q5 (soute pleine : minerai perdu), Q6 (terrain semi-procédural dès le MVP) et Q7 (sauvegarde manuelle uniquement). Q8 sans objet. **Aucune question ouverte** ; les contraintes dérivées sont propagées au backlog, au plan de tests et à la checklist d'audit.
2. ~~Installer Godot 4.x~~ — ✅ fait (story `0.6`, Godot 4.7.2 stable).
3. ~~Lancer `0.3 - Initialisation du dépôt Git`~~ — ✅ fait, puis publié sur `origin/main` (story `0.7`).
4. ~~Lancer l'audit `0.4`~~ — ✅ fait, verdict **Autorisé**. Terminer `0.8`, puis lancer la revue humaine `0.5`.
5. ~~Configurer l'identité Git et décider d'un remote~~ — ✅ sans objet : identité globale présente et ayant signé `7a86b1d`, remote `origin` configuré sur GitHub.
6. Ne pas ouvrir la phase 1 avant la clôture du sprint 0 (une seule story `En cours` à la fois).
7. Au commit de clôture, ne pas reproduire l'erreur de dénombrement du corps de `7a86b1d` (« 13 stories » pour 15 fichiers réels) : compter les fichiers avant de rédiger.
8. **Avant d'ouvrir la phase 1** : corriger le prérequis `P1` de `qa/plan-tests-manuels.md` (Godot est installé depuis `0.6`), sous peine de bloquer mécaniquement la story de tests `1.8`. Nécessite une story dédiée.
9. **À l'ouverture de la phase 3** : reprendre textuellement les contraintes dérivées de Q5 et Q6 dans les critères d'acceptation des stories `3.2`, `3.3` et `3.5` — elles sont opposables à l'audit du sprint (`G9`, `G10`, `K1` à `K6`).
10. **À l'ouverture de la phase 7** : idem pour Q7 dans les stories `7.1` et `7.4` (`H7` à `H9`).
