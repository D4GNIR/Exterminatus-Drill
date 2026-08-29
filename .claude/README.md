# Explications

Projet **Motherload 40K : Exterminatus Drill** — jeu 2D de forage sous **Godot 4.x / GDScript**, piloté selon une méthodologie **story par story**, avec deux agents Claude Code dédiés : un **Product Owner** et un **développeur Godot**.

Ce README explique l'organisation du dépôt, le cycle de travail, et **comment parler aux agents**.

---

## 1. Structure du projet

```
MotherloadW40k/
├── .claude/
│   ├── CLAUDE.md                              # Règles du projet (convention stories/) — chargé auto par Claude Code
│   ├── README.md                              # Ce fichier
│   └── agents/
│       ├── product-owner.md                   # Agent `po` : CDC, stories, avancement, QA
│       └── godot-dev.md                       # Agent `godot-dev` : implémentation Godot / GDScript
├── cahier_des_charges_motherload_40k_godot.md # CDC — référence fonctionnelle
├── stories/                                   # Une story = une action concrète documentée
│   ├── BACKLOG.md                             # Liste ordonnée des phases & stories + statuts
│   ├── AVANCEMENT.md                          # Rapport d'avancement fonctionnel (tenu par le PO)
│   └── <phase>.<tâche> - titre.md
├── qa/                                        # Gate qualité de fin de sprint
│   ├── README.md
│   ├── audit-qualite-reference.md
│   ├── plan-tests-manuels.md
│   ├── rapport-test-template.md
│   └── rapports/                              # Rapports de tests, un par sprint
└── (projet Godot)                             # project.godot, scenes/, scripts/, data/, assets/
```

> Le CDC est déjà rédigé. `stories/` se remplit au fil du projet ; `qa/` et le projet Godot restent à créer.

---

## 2. Comment le projet fonctionne

### Le principe : tout passe par une story

Toute action concrète **doit** être documentée par un fichier dans `stories/`. Pas de code sans story associée. (Règles complètes : `.claude/CLAUDE.md`.)

Chaque story contient au minimum : Phase · Statut · Objectif · Dépendances · Critères d'acceptation · Référence cahier des charges · Notes.

**Nomenclature** : `<phase>.<sous-tâche> - <titre>.md` → ex. `1.1 - Initialisation projet Godot.md`.

### Le cycle de vie d'une story

```
À faire ──▶ En cours ──▶ Terminée
                  └──▶ Bloquée
```

- **Avant** de commencer : statut → **En cours**.
- **Pendant** : décisions techniques notées dans la section *Notes*.
- **À la fin** : statut → **Terminée** + liste des artefacts, puis **pause** et point de validation avec toi.

### Règles d'or

- 🔂 **Une seule story En cours à la fois.** On termine N avant d'ouvrir N+1.
- 🪜 **Étapes séquentielles** à l'intérieur d'une story (pas de tout faire en parallèle).
- ⏸️ **Pause obligatoire** en fin de story (résumé + critères auto-vérifiés) avant la suivante.
- 📣 **Actions critiques annoncées** avant exécution : commit, push, suppression, plugin ou dépendance structurante, modification de `project.godot`.

### La gate de fin de sprint

À la fin de chaque sprint, deux stories s'enchaînent **dans l'ordre** :

1. **Audit qualité code** → checklist `qa/audit-qualite-reference.md` → verdict **Autorisé** ou **KO**.
2. **Tests manuels humains** (seulement si audit **Autorisé**) → plan `qa/plan-tests-manuels.md` → rapport depuis `qa/rapport-test-template.md`.

**Godot 4.7.2** est installé (`brew install --cask godot`) : les agents disposent du binaire `godot` en ligne de commande et vérifient leur travail en **headless** (`--check-only`, `--import`, `--headless --quit`). En revanche le rendu visuel, le ressenti de contrôle, l'équilibrage, l'audio et l'ergonomie ne sont **pas** vérifiables ainsi : ces critères restent validés **par toi**, dans l'éditeur, lors de la story de tests manuels.

### Commits Git

- Le projet n'est pas encore un dépôt Git : un `git init` est nécessaire avant le premier commit de phase.
- Un commit **uniquement à la fin de chaque phase complète** (toutes les stories Terminée, gate QA passée).
- Message : titre `Phase <N> — <nom>`, corps = stories incluses + artefacts.
- **Pas de push automatique** : le push reste à ton initiative.

---

## 3. Les deux agents

| | `po` | `godot-dev` |
|---|---|---|
| **Rôle** | Le « quoi » : besoin, périmètre, suivi | Le « comment » : implémentation Godot |
| **Écrit du code** | ❌ (docs/stories uniquement) | ✅ GDScript, scènes, ressources, données |
| **Cahier des charges** | ✅ maintient | lit seulement |
| **Stories & backlog** | ✅ crée & structure | met à jour le statut de la sienne |
| **Avancement fonctionnel** | ✅ vérifie & rapporte (`AVANCEMENT.md`) | — |
| **QA fin de sprint** | ✅ pilote audit + tests | corrige les points soulevés |
| **Git** | lecture seule | ✅ commit (avec annonce) |

Les deux agents lisent `.claude/CLAUDE.md` au démarrage et appliquent strictement la méthodologie.

---

## 4. Comment parler aux agents

Dans Claude Code, **adresse-toi explicitement à l'agent** en le nommant en début de demande.

### Avec le Product Owner

```
po : découpe le projet en phases et stories
po : crée le squelette qa/
po : où en est l'avancement fonctionnel du projet ?
po : lance l'audit qualité du sprint 1
```

À utiliser pour : affiner le besoin, créer ou réorganiser des stories, obtenir un état d'avancement, piloter la QA de fin de sprint.

### Avec le développeur Godot

```
godot-dev : implémente la story 1.1
godot-dev : passe la story 1.2 en cours et démarre
godot-dev : corrige les anomalies du rapport de tests du sprint 1
```

À utiliser pour : implémenter **une** story, écrire du GDScript et des scènes, corriger des bugs identifiés par une story.

### Bonnes pratiques

- **Une story à la fois** : ne demande pas au dev de « tout faire ». Donne-lui la story courante.
- **Commence par le PO** : pas de story sans découpage préalable.
- **Respecte la pause** : après une story terminée, valide avant de lancer la suivante.
- **Tu gardes la main** sur les commits et les push (l'agent annonce, tu décides).

---

## 5. Démarrer

1. `po : découpe le projet en phases et stories` (le CDC est déjà rédigé).
2. `po : crée le squelette qa/`.
3. `godot-dev : implémente la story 1.1` (init du projet Godot + `git init`).
4. En fin de sprint : `po : lance l'audit qualité` puis les tests manuels.
5. En fin de phase : le dev annonce le commit, tu valides.

> Godot 4.7.2 est installé : `godot` en ligne de commande pour les agents, `/Applications/Godot.app` pour ouvrir le projet toi-même.
