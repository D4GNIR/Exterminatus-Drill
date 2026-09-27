# QA — Gate de fin de sprint

Ce dossier définit **comment un sprint est déclaré terminé** sur *Motherload 40K : Exterminatus Drill*.

Aucune phase n'est commitée tant que sa gate n'est pas franchie.

> ⛔ **Changement de régime — décision utilisateur du 2026-09-26 (story `2.8`).** Les campagnes de **tests manuels humains par sprint sont supprimées**. La gate de fin de sprint est désormais **unique : l'audit qualité**. Toute la vérification humaine est **regroupée en une seule recette de fin de projet**, la story `7.8`, sur le plan `qa/plan-tests-manuels.md` inchangé. Les gates `2.7`, `3.9`, `4.6`, `5.9` et `6.10` sont **Reportée** vers `7.8`.

> **Référence fonctionnelle opposable en audit** : `cahier_des_charges_motherload_40k_godot.md`, **amendé par `cahier_des_charges_gameplay_addictif.md`** (arbitrage **Q16** du 2026-09-06, story `1.10`). L'amendement fait foi pour le loot, l'économie, la courbe de risque et la durée de boucle ; le CDC principal fait foi partout ailleurs. Un écart à l'amendement est un écart au cahier des charges (point d'audit `I5`).

---

## 1. Principe

Un sprint = une phase du `stories/BACKLOG.md`. Chaque phase se termine par **une story de gate** :

| Ordre | Story | Support | Sortie attendue |
|---|---|---|---|
| 1 | **Audit qualité code** | `qa/audit-qualite-reference.md` | Verdict **Autorisé** ou **KO**, consigné dans les *Notes* de la story |

```
Stories dev de la phase  ──▶  Audit qualité  ──▶  Commit de phase
       (toutes Terminée)         (Autorisé)
                                     │
                                     └── KO ──▶ story de correction ──▶ nouvel audit
```

Et **une seule fois, à la fin du projet** :

```
Phases 1 à 7 commitées  ──▶  Recette humaine unique (story 7.8)  ──▶  corrections  ──▶  MVP validé
                              plan qa/plan-tests-manuels.md
                              rapport qa/rapports/
```

La recette `7.8` exécute **l'intégralité du plan**, `TM-1.x` à `TM-7.x` : c'est la première et unique fois que le jeu est jugé à l'écran.

---

## 2. Règles de gate (non négociables)

1. **Pas de commit de phase** tant que toutes les stories dev **et** la story d'audit ne sont pas **Terminée**. Un audit **Autorisé** suffit désormais à autoriser le commit.
2. Un audit **KO** ⇒ création d'une **story de correction** dédiée (numérotée dans la phase courante), puis **nouvel audit** consigné dans la même story d'audit (section Notes, avec date et itération).
3. Un critère **[H]** n'est **jamais coché par un agent** et n'est **jamais réputé satisfait** par défaut : il reste **en attente** jusqu'à `7.8`. Le cumul des `[H]` en attente est tenu à jour dans `stories/AVANCEMENT.md`.
4. À la recette `7.8` : une anomalie **bloquante ou majeure** ⇒ story de correction + re-test des cas impactés. Une anomalie **mineure** peut être acceptée : elle est tracée dans le rapport **et** reportée en story dans le backlog. Elle n'est jamais simplement oubliée.
5. Le plan de tests, ses identifiants `TM-*` et ses sévérités restent **intacts** : le report change **quand** ils sont joués, pas **ce qui** est joué.

> ⚠️ **Le risque assumé de ce régime** : aucun rendu, aucun ressenti de contrôle et aucun équilibrage ne sera constaté avant la phase 7. Un défaut de fondation se découvrira sur cinq sprints de code bâti dessus. Deux contreparties le limitent : l'audit reste bloquant à chaque sprint, et les grandeurs d'équilibrage restent **externalisées en données** (`data/*.json`), donc rattrapables sans réécriture de code. Registre du risque : `stories/AVANCEMENT.md` §5.

---

## 3. Qui fait quoi

| Acteur | Audit qualité (chaque sprint) | Recette humaine `7.8` (fin de projet) |
|---|---|---|
| `po` | Pilote, rend le verdict, ouvre les stories de correction | Prépare la campagne complète, dépouille le rapport |
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

  > **Exception unique et bornée — faux positif sur les autoloads, hors exécution du projet** *(story `1.9`, **élargie par la story `2.9`**)*. Un nom d'autoload ne devient un identifiant global **qu'au démarrage du projet**. Tout script compilé avant ce moment et référençant un autoload produit donc un faux `Identifier not found`, suivi de `Failed to load script … "Compilation failed"`, avec un code de retour 0.
  >
  > **Deux situations produisent ce faux positif**, et non une seule :
  > - `--check-only`, qui compile un script isolément — cas d'origine de la story `1.9` ;
  > - **tout script chargé avant le démarrage du projet qui en compile un autre par anticipation** — typiquement un script lancé par `--script`, ou l'usage d'une classe `class_name` : mentionner la classe suffit à compiler son fichier. **Constat de la story `2.3`** sur `scripts/components/FuelSystem.gd` (`class_name FuelSystem` + référence à `GameData`), reproduit sur `CameraSystem.gd` en `2.4`.
  >
  > L'exception ne s'applique que si les **trois** conditions sont réunies :
  > 1. la commande n'exécute pas le projet (`--check-only`, ou `--script` hors démarrage) ;
  > 2. le message est exactement `Identifier not found: X` (et l'échec de chargement qui en découle) ;
  > 3. `X` figure réellement dans la section `[autoload]` de `project.godot`.
  >
  > **Dans ce cas seulement**, l'auditeur ne conclut pas à un échec et rejoue la vérification par `godot --headless --import` **et** `godot --headless --editor --quit`, qui chargent le projet complet — c'est cette seconde sortie qui fait foi. Y ajouter `godot --headless --quit` ou `--quit-after N scenes/main/Main.tscn` quand le script vit dans une scène : c'est le seul contexte où les autoloads sont réellement enregistrés. Toute autre occurrence de `ERROR:`, y compris un `Identifier not found` portant sur autre chose qu'un autoload déclaré, reste un **échec**.
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

Un critère `[H]` n'est jamais coché par un agent : il est validé par l'humain à la **recette unique `7.8`**, en fin de projet (story `2.8`). D'ici là il reste **en attente**, et son cumul est suivi dans `stories/AVANCEMENT.md`.

> **Note historique** : jusqu'à l'installation de Godot (story `0.6`), `[H]` désignait tout critère exigeant une exécution réelle, faute d'exécutable sur la machine. Le périmètre de `[H]` s'est donc **restreint** : ce qui relève de la syntaxe et du chargement est désormais à la charge des agents. Les stories antérieures peuvent porter des `[H]` désormais trop larges — les requalifier à l'ouverture de leur sprint.

---

## 5. Convention de nommage des rapports

```
qa/rapports/sprint-<N>-tests-manuels-<AAAA-MM-JJ>.md
```

Exemple : `qa/rapports/sprint-1-tests-manuels-2026-09-05.md`

Un rapport n'est jamais écrasé : une re-passe après correction produit un **nouveau** fichier daté (ou une section « Itération 2 » clairement datée).
