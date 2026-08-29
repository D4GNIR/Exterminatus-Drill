# Avancement fonctionnel — Motherload 40K : Exterminatus Drill

> Document tenu par l'agent `po`. **Mis à jour, jamais dupliqué.**
> Dernière mise à jour : **2026-08-29** · Contexte : fin de la story `0.3`.

---

## 1. Synthèse

| Indicateur | Valeur |
|---|---|
| Phase courante | **Phase 0 — Amorçage du projet** (sprint 0) |
| Story `En cours` | aucune (la `0.3` vient d'être terminée) |
| Prochaine story | `0.4 - Audit qualité — Sprint 0` (gate 1/2) |
| Stories créées | **14** (phase 0 : 6 · phase 1 : 8) |
| Stories terminées | **4** (`0.1`, `0.2`, `0.6`, `0.3`) |
| Avancement MVP (estimé) | **~8 %** (4 stories terminées sur ~52 prévues jusqu'à la fin de la phase 7) |
| Code de production existant | **aucun** — vérifié : ni `project.godot`, ni `.gd`, ni `.tscn`, ni `.tres` |
| Dépôt Git | **initialisé** — branche `main`, `.gitignore` Godot 4 en place, **0 commit**, **aucun remote** (story `0.3`) |
| Jeu jouable | non (aucune fonctionnalité du MVP n'est encore implémentée) |

---

## 2. Avancement par phase

| Phase | Sprint | Stories | Terminées | % | Gate QA | État |
|---|---|---|---|---|---|---|
| 0 — Amorçage du projet | 0 | 6 | 4 | **67 %** | `0.4` audit → `0.5` revue humaine | 🟡 En cours |
| 1 — Fondations techniques Godot | 1 | 8 | 0 | 0 % | `1.7` audit → `1.8` tests | ⬜ Non démarrée (stories rédigées) |
| 2 — Foreuse et déplacement | 2 | ~6 | 0 | 0 % | `2.5` → `2.6` | ⬜ Non découpée en fichiers |
| 3 — Terrain destructible et forage | 3 | ~7 | 0 | 0 % | `3.6` → `3.7` | ⬜ Non découpée en fichiers |
| 4 — HUD et interfaces de bord | 4 | ~6 | 0 | 0 % | `4.5` → `4.6` | ⬜ Non découpée en fichiers |
| 5 — Surface, économie, améliorations | 5 | ~7 | 0 | 0 % | `5.6` → `5.7` | ⬜ Non découpée en fichiers |
| 6 — Zone profonde et anomalie | 6 | ~7 | 0 | 0 % | `6.6` → `6.7` | ⬜ Non découpée en fichiers |
| 7 — Sauvegarde et recette MVP | 7 | ~6 | 0 | 0 % | `7.5` → `7.6` | ⬜ Non découpée en fichiers |
| 8+ — Post-MVP | — | — | — | — | — | ⬜ Hors périmètre MVP |

---

## 3. Détail de la phase 0 (sprint courant)

| Story | Statut | Vérification factuelle |
|---|---|---|
| `0.1 - Nettoyage du squelette .claude` | ✅ Terminée | Vérifié : `.claude/README.md` décrit bien le stack Godot, `.claude/agents/godot-dev.md` existe, `product-owner.md` référence `.claude/CLAUDE.md` et le CDC réel. Les 6 critères sont satisfaits. |
| `0.2 - Backlog, squelette QA et suivi d'avancement` | ✅ Terminée | Vérifié : `stories/BACKLOG.md`, `stories/AVANCEMENT.md`, `qa/{README,audit-qualite-reference,plan-tests-manuels,rapport-test-template}.md`, `qa/rapports/` et les 12 stories des phases 0-1 existent. Aucun fichier de code créé. |
| `0.3 - Initialisation du dépôt Git` | ✅ Terminée | Vérifié par commandes : `git init -b main` exécuté (Git 2.50.1), `git symbolic-ref --short HEAD` → `main`, `git status` sort en 0. `.gitignore` couvre les 8 motifs exigés ; test réel avec fichiers factices dans `.godot/`, `.import/`, `build/`, `export*.cfg`, `.DS_Store`, `*.translation`, `*.tmp` → `git status --porcelain` inchangé, `git check-ignore -v` concluant. `README.md` complet (pitch, stack, prérequis Godot 4.x / 4.7.2, arborescences, renvois CDC + backlog + QA). `git rev-list --all --count` → 0, `git remote -v` vide, aucun `.gd`/`.tscn`/`project.godot`. Les 8 critères sont satisfaits. |
| `0.4 - Audit qualité — Sprint 0` | ⬜ À faire | Gate 1/2. **Débloquée** : `0.3` est Terminée. Prochaine story à lancer. |
| `0.5 - Revue humaine de fin de sprint 0` | ⬜ À faire | Gate 2/2. Ne démarre que si `0.4` rend **Autorisé**. |
| `0.6 - Installation de Godot 4 et requalification des critères [H]` | ✅ Terminée | Vérifié : `godot --version` → `4.7.2.stable`, `godot --headless --quit` sort en 0 sans `ERROR:`, binaire dans le `PATH`. Les 16 mentions « Godot non installé » de `stories/` et `qa/` ont été requalifiées. Exécutée chronologiquement avant `0.3`. |

**Reste à faire pour clôturer le sprint 0** : la gate `0.4` → `0.5`, puis le commit `Phase 0 — Amorçage du projet` (sur annonce et décision de l'utilisateur). Prérequis au commit non encore traité : l'identité Git (`user.name` / `user.email`) n'est pas configurée localement — à trancher par l'utilisateur.

---

## 4. Couverture du cahier des charges

### Fonctionnalités MVP

Les 8 points de « MVP jouable » et les 7 « Critères d'acceptation MVP » sont **tous rattachés à une phase** (tables de traçabilité dans `stories/BACKLOG.md`). **Aucun périmètre MVP orphelin identifié à ce jour.**

### Écarts et zones de vigilance relevés dans le CDC

| # | Constat | Traitement |
|---|---|---|
| E1 | Le critère MVP « le HUD affiche le **blindage** » suppose une jauge de blindage, alors qu'**aucun système de dégâts** n'apparaît dans les 8 points du « MVP jouable ». Périmètre ambigu. | Arbitrage Q3 du backlog, avant la phase 2. |
| E2 | Le comportement en **soute pleine** n'est spécifié nulle part (refus de collecte ? perte du minerai ?). | Arbitrage Q5, avant la phase 3. |
| E3 | La **mort de la foreuse** (blindage à zéro) n'est décrite ni dans la boucle de jeu, ni dans le MVP. | Arbitrage Q8. |
| ~~E4~~ | ~~La section « Architecture Godot » ne prévoit **aucun chargeur de données**~~ | ✅ **Résolu** — Q4 tranchée : autoload `scripts/autoload/GameData.gd`, déviation assumée et validée. Tracé en story 1.5. |
| E5 | Le mode de **génération du terrain** MVP n'est pas précisé ; la génération procédurale est explicitement post-MVP. | Arbitrage Q6, avant la phase 3. |
| E6 | Le **déclenchement de la sauvegarde** (auto / manuel) n'est pas spécifié. | Arbitrage Q7, avant la phase 7. |
| E7 | Les notions de **quota** et de **faveur du Mechanicus** sont décrites dans « Économie » mais absentes du MVP. | Hors MVP : reportées en phase 12. Champs éventuellement anticipés dans `GameState` (story 1.4). |
| E8 | La **note de propriété intellectuelle** du CDC (univers Warhammer 40,000) reste un risque pour toute diffusion commerciale. | Décision produit de l'utilisateur, hors périmètre technique. À trancher avant toute publication. |

---

## 5. Risques et blocages

| Risque | Sévérité | Impact | Mitigation |
|---|---|---|---|
| ~~**Godot n'est pas installé** sur la machine~~ | ✅ **Levé** | — | Godot **4.7.2 stable** installé en story `0.6` ; binaire `godot` dans le `PATH`. Les agents valident désormais syntaxe, import et chargement de scènes en headless. Prérequis P1 du plan de tests satisfait. |
| Écriture manuelle de `project.godot` et des `.tscn` | 🟠 Moyenne | Risque d'un projet inouvrable au premier lancement (UID, `load_steps`, `ExtResource`). | Rester minimaliste en phase 1 ; prévoir une story de correction après `TM-1.1`. |
| Ambiguïtés CDC non tranchées | 🟡 Faible *(était 🟠 Moyenne)* | Risque de développement à refaire si un arbitrage arrive après l'implémentation. | **Q1 à Q4 tranchées le 2026-08-29** (renderer, clavier, blindage, chargeur de données) : la phase 1 est débloquée. Q8 devient sans objet au MVP. Restent Q5, Q6 (avant phase 3) et Q7 (avant phase 7). |
| ~~Dépôt Git non initialisé~~ | ✅ **Levé** | — | Story `0.3` : dépôt initialisé sur `main` avec un `.gitignore` Godot 4 posé **avant** toute génération de cache. Reste ouvert, sans gravité : 0 commit et aucun remote (par périmètre de story), identité Git et hébergement distant à l'initiative de l'utilisateur. |
| Volume du MVP (~52 stories, 8 phases) | 🟡 Faible | Risque d'essoufflement / dérive de périmètre. | Gate stricte par sprint, aucune fonctionnalité post-MVP avant la fin de la phase 7. |

---

## 6. Recommandations immédiates

1. **Trancher les questions Q1 à Q4** (`stories/BACKLOG.md` §Points en attente) : elles conditionnent la phase 1.
2. ~~Installer Godot 4.x~~ — ✅ fait (story `0.6`, Godot 4.7.2 stable).
3. ~~Lancer `0.3 - Initialisation du dépôt Git`~~ — ✅ fait (dépôt sur `main`, `.gitignore`, `README.md`, sans commit).
4. Lancer la gate du sprint 0 : `0.4 - Audit qualité` puis `0.5 - Revue humaine`.
5. Configurer l'identité Git (`user.name` / `user.email`) et décider d'un éventuel remote **avant** le commit de fin de phase 0.
6. Ne pas ouvrir la phase 1 avant la clôture du sprint 0 (une seule story `En cours` à la fois).
