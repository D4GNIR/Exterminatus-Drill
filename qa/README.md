# QA — Gate de fin de sprint

Ce dossier définit **comment un sprint est déclaré terminé** sur *Motherload 40K : Exterminatus Drill*.

Aucune phase n'est commitée tant que sa gate n'est pas franchie.

> **Référence fonctionnelle opposable en audit** : `cahier_des_charges_motherload_40k_godot.md`, **amendé par `cahier_des_charges_gameplay_addictif.md`** (arbitrage **Q16** du 2026-09-06, story `1.10`). L'amendement fait foi pour le loot, l'économie, la courbe de risque et la durée de boucle ; le CDC principal fait foi partout ailleurs. Un écart à l'amendement est un écart au cahier des charges (point d'audit `I5`).

---

## 1. Principe

Un sprint = une phase du `stories/BACKLOG.md`. Chaque phase se termine par **deux stories dédiées, dans cet ordre** :

| Ordre | Story | Support | Sortie attendue |
|---|---|---|---|
| 1 | **Audit qualité code** | `qa/audit-qualite-reference.md` | Verdict **Autorisé** ou **KO**, consigné dans les *Notes* de la story |
| 2 | **Tests manuels humains** | `qa/plan-tests-manuels.md` | Rapport dans `qa/rapports/`, créé depuis `qa/rapport-test-template.md` |

```
Stories dev de la phase  ──▶  Audit qualité  ──▶  Tests manuels humains  ──▶  Commit de phase
       (toutes Terminée)         (Autorisé)          (rapport rédigé)
                                     │
                                     └── KO ──▶ story de correction ──▶ nouvel audit
```

---

## 2. Règles de gate (non négociables)

1. **Aucune story de tests manuels ne démarre si l'audit n'est pas `Autorisé`.**
2. Un audit **KO** ⇒ création d'une **story de correction** dédiée (numérotée dans la phase courante), puis **nouvel audit** consigné dans la même story d'audit (section Notes, avec date et itération).
3. **Pas de commit de phase** tant que : toutes les stories dev **et** les deux stories de gate ne sont pas au statut **Terminée**.
4. Une anomalie **bloquante** détectée en tests manuels ⇒ story de correction + re-test des cas impactés, avant commit.
5. Une anomalie **mineure** peut être acceptée : elle est alors tracée dans le rapport **et** reportée en story dans le backlog. Elle n'est jamais simplement oubliée.

---

## 3. Qui fait quoi

| Acteur | Audit qualité | Tests manuels |
|---|---|---|
| `po` | Pilote, rend le verdict, ouvre les stories de correction | Prépare le plan de test du sprint, dépouille le rapport |
| `godot-dev` | Fournit la liste des artefacts, corrige les points KO | Corrige les anomalies remontées |
| **Humain (toi)** | — | **Exécute réellement les tests dans Godot** et remplit le rapport |

---

## 4. Environnement de vérification : Godot en headless

> **Godot 4.7.2 stable est installé** : binaire `godot` dans le `PATH` (`/opt/homebrew/bin/godot`), éditeur dans `/Applications/Godot.app`.

### Ce que les agents vérifient eux-mêmes (en ligne de commande, depuis la racine du projet)

| Vérification | Commande |
|---|---|
| Version du moteur | `godot --version` |
| Syntaxe d'un script | `godot --headless --check-only --script scripts/…/Foo.gd` |
| Import des assets / génération de `.godot/` | `godot --headless --import` |
| Le projet et ses scènes se chargent sans erreur | `godot --headless --quit` |
| Une scène précise démarre | `godot --headless --quit-after 120 scenes/main/Main.tscn` |

Règles d'interprétation, opposables en audit :

- Une sortie contenant `ERROR:` ou `SCRIPT ERROR:` est un **échec**, même avec un code de retour 0. L'auditeur lit la sortie, pas seulement l'exit code.

  > **Exception unique et bornée — faux positif `--check-only` sur les autoloads** *(story `1.9`)*. En mode `--check-only`, Godot compile un script isolément, sans démarrer le projet ; or les noms d'autoload ne deviennent des identifiants globaux qu'au démarrage. Tout script référençant un autoload y produit donc un faux `Identifier not found`, suivi de `Failed to load script … "Compilation failed"`, avec un code de retour 0.
  >
  > L'exception ne s'applique que si les **trois** conditions sont réunies :
  > 1. la commande est `--check-only` ;
  > 2. le message est exactement `Identifier not found: X` (et l'échec de chargement qui en découle) ;
  > 3. `X` figure réellement dans la section `[autoload]` de `project.godot`.
  >
  > **Dans ce cas seulement**, l'auditeur ne conclut pas à un échec et rejoue la vérification par `godot --headless --import` **et** `godot --headless --editor --quit`, qui chargent le projet complet — c'est cette seconde sortie qui fait foi. Toute autre occurrence de `ERROR:`, y compris un `Identifier not found` portant sur autre chose qu'un autoload déclaré, reste un **échec**.
  >
  > Pourquoi conserver `--check-only` malgré ce défaut : c'est le seul mode qui localise une erreur de syntaxe **fichier par fichier**. `--import` et `--editor --quit` signalent qu'un projet a une erreur, pas lequel de ses scripts la porte.
- Le premier `--import` est **obligatoire** après ajout d'assets : sans lui, un `.tscn` référençant une ressource non importée échouera à tort.
- L'audit qualité n'est donc plus purement statique : un point de checklist portant sur la syntaxe, le chargement d'une scène ou la validité de `project.godot` **doit** être étayé par une commande headless et sa sortie.

### Ce que le headless ne prouve pas — critères `[H]`

Un critère est marqué **[H]** quand il exige un **jugement humain à l'écran**, que la ligne de commande ne peut pas rendre :

- rendu visuel, lisibilité, cadrage de la caméra ;
- ressenti de contrôle : inertie, réactivité, vitesse de forage ;
- équilibrage : économie, consommation de carburant, durée d'une descente ;
- audio : mixage, déclenchement des alertes ;
- ergonomie et clarté de l'UI.

Un critère `[H]` n'est jamais coché par un agent : il est validé par l'humain à la story de **tests manuels humains** du sprint.

> **Note historique** : jusqu'à l'installation de Godot (story `0.6`), `[H]` désignait tout critère exigeant une exécution réelle, faute d'exécutable sur la machine. Le périmètre de `[H]` s'est donc **restreint** : ce qui relève de la syntaxe et du chargement est désormais à la charge des agents. Les stories antérieures peuvent porter des `[H]` désormais trop larges — les requalifier à l'ouverture de leur sprint.

---

## 5. Convention de nommage des rapports

```
qa/rapports/sprint-<N>-tests-manuels-<AAAA-MM-JJ>.md
```

Exemple : `qa/rapports/sprint-1-tests-manuels-2026-09-05.md`

Un rapport n'est jamais écrasé : une re-passe après correction produit un **nouveau** fichier daté (ou une section « Itération 2 » clairement datée).
