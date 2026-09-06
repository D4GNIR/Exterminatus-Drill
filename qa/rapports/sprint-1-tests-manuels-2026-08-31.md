# Rapport de tests manuels — Sprint 1 (Phase 1 — Fondations techniques du projet Godot)

> Créé depuis `qa/rapport-test-template.md` pour la story `1.8 - Tests manuels humains — Sprint 1`.
> **Pré-rempli par un agent** : procédures, valeurs attendues et cases à cocher. Les colonnes *Obtenu*, *Verdict* et les sections 5 et 6 sont à remplir **par le testeur humain**, dans l'éditeur. Un agent ne coche jamais un résultat.

---

## ⚠️ Clôture du 2026-09-06 — campagne NON EXÉCUTÉE

**Verdict global : « Validé sur décision utilisateur du 2026-09-06 — campagne non exécutée ».**

La gate `1.8` a été **close sur décision de l'utilisateur**, sans exécution complète de la campagne. Motif donné : *« c'est pas des points essentiels »*.

**Ce que cette validation ne signifie pas.** Elle ne repose sur **aucun constat à l'écran**. Aucun des 7 cas n'a de résultat observé et rapporté :

| Cas | État réel |
|---|---|
| `TM-1.1` | **Non exécuté** — procédure lue par le testeur, **aucun constat rapporté** |
| `TM-1.2` | **Non exécuté** |
| `TM-1.3` | **Non exécuté** |
| `TM-1.4` | **Non exécuté** |
| `TM-1.6` | **Non exécuté — interrompu.** La procédure était **fausse** (vocabulaire Godot 3, lecture de variables privées non affichables). C'est ce blocage qui a déclenché la story `1.12` |
| `TM-1.7` | **Non exécuté** |
| `TM-1.8` | **Non exécuté** |
| `TM-1.5` | **Non exécuté** — déjà reporté au sprint 2 par l'arbitrage **Q9**, décision antérieure et indépendante |

**Les cases à cocher restent vides et aucun cas n'est coté OK** : cocher rétroactivement serait inventer un résultat.

> 🛠 **Rectification faite à la clôture — quatre verdicts `OK` non étayés.** À la clôture, les cas `TM-1.1`, `TM-1.2`, `TM-1.3` et `TM-1.4` portaient un `**Verdict** : OK`, alors que leur champ *Obtenu* était **vide** et qu'**aucune** de leurs **31** cases n'était cochée. Ces `OK` ne s'appuyaient donc sur **aucune observation consignée**, et contredisaient le relevé de la campagne, selon lequel aucun cas n'a de résultat rapporté. Ils ont été **ramenés à « Non exécuté »**, chacun accompagné sur place d'une note de rectification datée. Rien n'a été effacé en silence. Trois de ces quatre cas sont **bloquants** : les laisser à `OK` aurait fait croire que la gate avait été franchie sur constat. **Les critères `[H]` des stories `1.1` à `1.6` n'ont donc PAS été vérifiés humainement** — ils sont *non vérifiés*, ni confirmés ni infirmés.

**Ce qui reste acquis, et qui n'est pas rien** : la conformité vérifiée **en headless** par les agents — import, chargement de projet, chargement de chaque scène, `godot --headless --quit` en sortie 0, et plusieurs centaines d'assertions relues depuis le moteur (34 en `1.6`, 33 en `1.4`, 63 en `1.5`, 42 + 26 à l'audit `1.7`). L'audit `1.7` a rendu **Autorisé** avec **0 KO**. Ce qui manque est le **constat visuel** : personne n'a vu la fenêtre de jeu s'ouvrir, ni l'Input Map, ni l'arbre de `Main.tscn` dans l'éditeur.

**Précédent invoqué** : la gate `0.5` du sprint 0 a elle aussi été **annulée sur décision de l'utilisateur**, tracée par la story `0.10`. Même nature, même exigence d'honnêteté de trace : la décision est consignée telle quelle, sans être maquillée en succès.

**Ce rapport n'est pas vidé.** Les procédures corrigées par la story `1.12` — `TM-1.6` réécrit, `TM-1.7` scindé en deux écrans, table bilingue des docks, précisions `TM-1.2` et `TM-1.3` — sont **conservées en l'état** : elles serviront si la campagne est rejouée, en itération 2 ou au sprint 2.

**Risque tracé** : `stories/AVANCEMENT.md` §5, entrée « Les fondations de la phase 1 n'ont jamais été constatées à l'écran ».

---

## 1. Contexte

| Champ | Valeur |
|---|---|
| Sprint / phase | Sprint 1 — Phase 1, Fondations techniques du projet Godot |
| Date d'exécution | _(à compléter)_ |
| Testeur | _(à compléter — humain devant l'éditeur)_ |
| Version de Godot | `4.7.2.stable.official.ed1daf0bf` (`/Applications/Godot.app`, binaire `godot` dans le `PATH`) |
| OS / machine | macOS 26.5.2 (build 25F84), Apple Silicon `arm64` |
| Commit / état du dépôt | branche `main`, dernier commit `0e21bff` (clôture phase 0). **Le travail de la phase 1 n'est pas commité** : 37 entrées dans `git status --porcelain -uall` au moment du test. C'est l'état attendu — le commit de phase est justement ce que cette story autorise ou refuse. |
| Itération | 1 |
| Verdict de l'audit préalable | **Autorisé** — story `1.7`, 2026-08-31, itération 1 (71 points : 42 OK, **0 KO**, 29 N/A) |
| Graine de génération | _sans objet au sprint 1_ — le prérequis `P4` ne s'applique qu'à partir du sprint 3 (aucun terrain généré ici) |

## 2. Périmètre testé

Stories couvertes par cette passe :

- `1.1 - Initialisation du projet Godot 4`
- `1.2 - Arborescence contractuelle du projet`
- `1.3 - Input Map complet`
- `1.4 - Autoload GameState`
- `1.5 - Socle de données JSON`
- `1.6 - Scènes squelettes Main et World`

Cas de test exécutés (référence `qa/plan-tests-manuels.md`) : `TM-1.1`, `TM-1.2`, `TM-1.3`, `TM-1.4`, `TM-1.6`, `TM-1.7`, `TM-1.8` — **7 cas**, dont **4 bloquants** (`TM-1.1`, `TM-1.2`, `TM-1.4`, `TM-1.6`).

Cas **non exécutés** et pourquoi :

- **`TM-1.5` — Test des touches** : reporté au **sprint 2** par l'arbitrage **Q9**. Aucun code ne consomme les entrées avant la phase 2, et la « scène de test d'input » n'a volontairement pas été créée (elle serait un artefact de debug au sens du point d'audit A5). L'identifiant est conservé : un cas de test ne se renumérote pas. Voir le rappel en tête du sprint 2 dans `qa/plan-tests-manuels.md`.

### Noms des docks — correspondance bilingue

L'éditeur peut être en français ou en anglais selon le poste de test. Les procédures ci-dessous emploient la forme « *Français* (*Anglais*) » aux endroits révisés ; ailleurs, se reporter à cette table.

| Français | Anglais | Emplacement par défaut |
|---|---|---|
| **Scène** | *Scene* | dock en haut à gauche — porte aussi le sélecteur **Distant / Local** pendant l'exécution |
| **Système de fichiers** | *FileSystem* | dock en bas à gauche |
| **Inspecteur** | *Inspector* | dock à droite |
| **Sortie** | *Output* | panneau du bas |
| **Débogueur** | *Debugger* | panneau du bas — onglets *Pile d'appels*, *Erreurs*, *Profileur*, *Moniteurs* |
| **Chargements automatiques** | *AutoLoad* | *Projet > Paramètres du projet…*, onglet situé entre *Carte des entrées* et *Globales de shader* |
| **Carte des entrées** | *Input Map* | *Projet > Paramètres du projet…* |

> ⚠️ **Vocabulaire à ne pas chercher** : les noms *Globals* et *Arbre de scène distant (dans le Débogueur)* appartiennent à **Godot 3** et n'existent plus en 4.7. Ils figuraient dans la version initiale de ce rapport et ont été corrigés par la story `1.12`.

### Avertissement attendu — ne pas le consigner comme anomalie

Les trois `TileMapLayer` (`TerrainLayer`, `OreLayer`, `DecorationsLayer`) **n'ont aucun TileSet** avant la story `3.1`. L'éditeur affiche donc sur chacun l'icône d'avertissement de configuration « **TileSet manquant** ». C'est **attendu et conforme** : ce n'est pas une erreur, cela ne doit faire échouer aucun cas, et cela ne se consigne pas en anomalie.

> 📍 **Où ces trois icônes s'affichent réellement** *(corrigé par la story `1.12`)* : **uniquement à l'ouverture de `scenes/world/World.tscn`**, dans le dock *Scène* (*Scene*). Elles **n'apparaissent pas** à l'ouverture de `Main.tscn`, où `World` est une **instance de scène** dont l'éditeur n'affiche pas les enfants. Voir `TM-1.7`, dont l'attendu est scindé en deux écrans pour cette raison.

---

## 3. Résultats

> Cocher au fur et à mesure. Une sous-case non satisfaite ⇒ le cas est **KO**, et une anomalie est ouverte en section 4.

### TM-1.1 `[REG]` — Ouverture du projet · **Bloquant**

**Procédure** — Lancer `/Applications/Godot.app`. Dans le gestionnaire de projets : *Importer* → sélectionner `project.godot` à la racine du dépôt → *Importer et éditer*. Laisser l'import se terminer, puis ouvrir les docks *Output* et *Debugger*.

| # | Attendu | ✓ |
|---|---|---|
| a | L'import se termine sans boîte de dialogue d'erreur | ☐ |
| b | Le dock *Debugger* n'affiche **aucune** erreur (onglet *Erreurs* vide) | ☐ |
| c | Le dock *Output* ne contient aucune ligne `ERROR:` ni `SCRIPT ERROR:` | ☐ |
| d | Le titre de la fenêtre porte bien **Exterminatus Drill** | ☐ |
| e | Aucune boîte « projet créé avec une version antérieure de Godot » | ☐ |

**Obtenu** : ⚠️ **NON EXÉCUTÉ** — aucun constat rapporté (clôture sur décision du 2026-09-06)

**Verdict** : **Non exécuté** — *ni OK, ni KO* — **Sévérité si KO** : Bloquant

> ⚠️ **Verdict rectifié le 2026-09-06 (clôture de `1.8`).** Ce cas portait un `Verdict : OK` **non étayé** : le champ *Obtenu* était **vide** et **aucune** de ses cases n'était cochée. Selon le relevé de la campagne, ce cas **n'a pas été exécuté**. Un `OK` sans observation ni case cochée n'est pas un résultat : il est ramené à **Non exécuté**. La mention d'origine est conservée ici, elle n'est pas effacée.

---

### TM-1.2 `[REG]` — Lancement · **Bloquant**

**Procédure** — Presser `F5` (*Exécuter le projet*). Laisser tourner quelques secondes, puis fermer la fenêtre de jeu et relire l'*Output*.

| # | Attendu | ✓ |
|---|---|---|
| a | Une fenêtre de jeu s'ouvre — c'est `Main.tscn` qui démarre (`run/main_scene`) | ☐ |
| b | La fenêtre fait **1280 × 720** | ☐ |
| c | L'écran est **vide** (aucun terrain, aucune foreuse) — c'est l'attendu du sprint 1 | ☐ |
| d | Aucune **erreur** dans la *Sortie* (*Output*) ni dans le *Débogueur* (*Debugger*) pendant l'exécution — voir la précision ci-dessous | ☐ |
| e | La fermeture de la fenêtre rend la main à l'éditeur sans erreur | ☐ |

> ⚠️ **Précision sur le point d** *(story `1.12`)* — la *Sortie* n'est **jamais vide** au démarrage : `GameData._ready()` exécute un `print()` de résumé, et cette ligne est **attendue**. C'est précisément l'objet du cas `TM-1.8`. **Seule** une ligne commençant par `ERROR:` ou `SCRIPT ERROR:` fait échouer le point **d**. Une *Sortie* contenant la ligne `GameData — ressources : …` et rien d'autre est un **succès**.

> Redimensionner la fenêtre pour observer le mode d'étirement `canvas_items` / `expand` : le contenu doit s'adapter sans déformation. Il n'y a encore rien à l'écran — l'observation est purement documentaire ici, à confirmer au sprint 4 avec le HUD.

**Obtenu** : ⚠️ **NON EXÉCUTÉ** — aucun constat rapporté (clôture sur décision du 2026-09-06)

**Verdict** : **Non exécuté** — *ni OK, ni KO* — **Sévérité si KO** : Bloquant

> ⚠️ **Verdict rectifié le 2026-09-06 (clôture de `1.8`).** Ce cas portait un `Verdict : OK` **non étayé** : le champ *Obtenu* était **vide** et **aucune** de ses cases n'était cochée. Selon le relevé de la campagne, ce cas **n'a pas été exécuté**. Un `OK` sans observation ni case cochée n'est pas un résultat : il est ramené à **Non exécuté**. La mention d'origine est conservée ici, elle n'est pas effacée.

---

### TM-1.3 — Arborescence · **Majeur**

**Procédure** — Dans le dock *FileSystem*, déplier `res://` entièrement.

| # | Attendu | ✓ |
|---|---|---|
| a | `assets/` contient `audio/`, `fonts/`, `sprites/` **et** `README.md` | ☐ |
| b | `data/` contient `events.json`, `resources.json`, `upgrades.json` | ☐ |
| c | `scenes/` contient `main/`, `player/`, `ui/`, `world/` | ☐ |
| d | `scripts/` contient `autoload/`, `components/`, `player/`, `systems/` | ☐ |
| e | `scenes/main/Main.tscn` et `scenes/world/World.tscn` sont visibles | ☐ |
| f | `scripts/autoload/GameData.gd` et `GameState.gd` sont visibles | ☐ |
| g | **Aucun artefact Godot superflu** à la racine de `res://` : pas de scène de test, pas de `.bak`, pas de script jetable (point d'audit `A5`) | ☐ |

> Les 12 dossiers contractuels du CDC sont attendus, ni plus ni moins. Les `.gitkeep` peuvent ne pas apparaître dans le dock (fichiers non reconnus par le moteur) : leur absence à l'écran n'est **pas** une anomalie.

> ⚠️ **Précision sur le point g** *(story `1.12`)* — le dock *Système de fichiers* (*FileSystem*) montre **tout le dépôt**, pas seulement l'arborescence Godot. Le testeur verra donc aussi, à la racine, `README.md`, `cahier_des_charges_motherload_40k_godot.md`, `cahier_des_charges_gameplay_addictif.md`, `qa/` et `stories/`. Ce sont les **fichiers de pilotage du projet** : ils sont **légitimes et attendus**, et ne constituent **pas** un « fichier superflu ». Ce que le point g proscrit, c'est un **artefact Godot** orphelin. Le dossier `.claude/`, commençant par un point, n'apparaît pas.

**Obtenu** : ⚠️ **NON EXÉCUTÉ** — aucun constat rapporté (clôture sur décision du 2026-09-06)

**Verdict** : **Non exécuté** — *ni OK, ni KO* — **Sévérité si KO** : Bloquant

> ⚠️ **Verdict rectifié le 2026-09-06 (clôture de `1.8`).** Ce cas portait un `Verdict : OK` **non étayé** : le champ *Obtenu* était **vide** et **aucune** de ses cases n'était cochée. Selon le relevé de la campagne, ce cas **n'a pas été exécuté**. Un `OK` sans observation ni case cochée n'est pas un résultat : il est ramené à **Non exécuté**. La mention d'origine est conservée ici, elle n'est pas effacée.

---

### TM-1.4 — Input Map · **Bloquant**

**Procédure** — *Projet > Paramètres du projet… > Input Map*. **Décocher « Afficher les actions intégrées »** pour masquer les actions `ui_*` et n'afficher que celles du projet.

| # | Action | Touches attendues | ✓ |
|---|---|---|---|
| a | `move_up` | position physique **W** (affichée `Z` sur AZERTY) + **Flèche haut** | ☐ |
| b | `move_down` | position physique **S** + **Flèche bas** | ☐ |
| c | `move_left` | position physique **A** (affichée `Q` sur AZERTY) + **Flèche gauche** | ☐ |
| d | `move_right` | position physique **D** + **Flèche droite** | ☐ |
| e | `drill` | **Espace** | ☐ |
| f | `brake` | **Maj (Shift)** | ☐ |
| g | `use_item_1` | **1** | ☐ |
| h | `use_item_2` | **2** | ☐ |
| i | `use_item_3` | **3** | ☐ |
| j | `toggle_inventory` | **I** + **Tab** | ☐ |
| k | `toggle_journal` | **J** | ☐ |
| l | `pause` | **Échap** | ☐ |
| m | **12 actions exactement**, aucune de plus, aucune de moins | ☐ |
| n | Chaque événement est marqué **« (Physique) »** / **« (Physical) »** — arbitrage **Q2** | ☐ |

> **Pourquoi « position physique »** : toutes les touches sont déclarées en `physical_keycode`, ce qui rend le jeu jouable en ZQSD sur AZERTY et en WASD sur QWERTY sans code conditionnel. L'éditeur affiche le libellé de la touche **pour la disposition courante** : sur un clavier AZERTY, `move_up` s'affiche donc `Z` et `move_left` s'affiche `Q`. Le point vérifié est double : la bonne **position** et la mention **« Physique »**. Une touche affichée sans cette mention serait un KO (`keycode` au lieu de `physical_keycode`).

**Obtenu** : ⚠️ **NON EXÉCUTÉ** — aucun constat rapporté (clôture sur décision du 2026-09-06)

**Verdict** : **Non exécuté** — *ni OK, ni KO* — **Sévérité si KO** : Bloquant

> ⚠️ **Verdict rectifié le 2026-09-06 (clôture de `1.8`).** Ce cas portait un `Verdict : OK` **non étayé** : le champ *Obtenu* était **vide** et **aucune** de ses cases n'était cochée. Selon le relevé de la campagne, ce cas **n'a pas été exécuté**. Un `OK` sans observation ni case cochée n'est pas un résultat : il est ramené à **Non exécuté**. La mention d'origine est conservée ici, elle n'est pas effacée.

---

### TM-1.6 — Autoload `GameState` · **Bloquant**

> ⚠️ **Procédure corrigée par la story `1.12`.** La version initiale employait du vocabulaire **Godot 3** (*Globals*, *Arbre de scène distant* dans le *Débogueur*) et demandait de lire des variables que l'éditeur n'affiche pas nécessairement. Le testeur bloqué sur ce cas peut le reprendre depuis le début.

**Procédure, partie 1 — les autoloads sont-ils déclarés ?**
*Projet > Paramètres du projet…* → onglet **AutoLoad** (« **Chargements automatiques** » si l'éditeur est en français), situé **entre** *Carte des entrées* et *Globales de shader*.

| # | Attendu | ✓ |
|---|---|---|
| a | **`GameData`** est présent, chemin `res://scripts/autoload/GameData.gd`, colonne *Activer* (*Enable*) cochée | ☐ |
| b | **`GameState`** est présent, chemin `res://scripts/autoload/GameState.gd`, colonne *Activer* cochée | ☐ |
| c | `GameData` est listé **AVANT** `GameState` — l'ordre de la liste est l'ordre de chargement (arbitrage **Q4**) | ☐ |
| d | Aucun autre autoload déclaré | ☐ |

> **Ces quatre points sont bloquants et suffisent à prononcer le cas.** Ils correspondent exactement à ce que contient `project.godot` : deux entrées, `GameData` puis `GameState`, toutes deux préfixées `*` (donc activées), et aucune autre.

**Procédure, partie 2 — les valeurs de départ sont-elles lisibles ?** *(complément non bloquant)*
Presser `F5`. **Pendant que le jeu tourne**, revenir à l'éditeur : dans le dock **Scène** (*Scene*, en haut à gauche), un sélecteur **Distant / Local** (*Remote / Local*) apparaît — il n'existe **que** pendant l'exécution. Choisir **Distant**, déplier `root`, sélectionner `GameState`, et lire ses propriétés dans l'**Inspecteur** (*Inspector*).

> Le dock *Débogueur* du bas ne contient **pas** l'arbre distant : il n'a que *Pile d'appels*, *Erreurs*, *Profileur*, *Moniteurs* et apparentés. Chercher l'arbre distant à cet endroit est sans issue.

> 🟡 **Points e à l — conditionnels et NON bloquants.** `_fuel`, `_fuel_max`, `_armor`, `_armor_max`, `_credits`, `_cargo_used`, `_cargo_capacity`, `_depth_m`, `_upgrade_levels`, `_narrative_flags` et `_cargo` sont des variables **privées non exportées** (`var _fuel: float`, **aucun `@export`** dans `GameState.gd`). L'Inspecteur **local** ne montre jamais ce type de variable, et rien ne garantit que l'Inspecteur **distant** de 4.7 les liste.
>
> - **S'ils apparaissent** : les vérifier et les cocher — c'est un bonus de confiance.
> - **S'ils n'apparaissent pas** : cocher **« non observable »** ci-dessous et **passer**. Ce n'est **pas un KO** de la story `1.4` : `GameState` est conforme, vérifié par 33 assertions en `1.4` et 63 en `1.5`, dont la relecture des valeurs de départ **depuis le moteur en exécution réelle**. C'est la **procédure** qui ne sait pas les observer, pas le produit qui est fautif.
>
> **Dans ce cas, `TM-1.6` est prononcé sur ses seuls points a-d**, qui restent bloquants — le cas ne reste jamais en suspens — et la vérification des valeurs de départ est **transférée à `TM-4.1`** (sprint 4), où le HUD affiche précisément carburant, blindage, crédits, charge de soute et profondeur. **Transfert tracé, pas abandonné** : voir la table de traçabilité en fin de section 3, `TM-1.6`/`TM-4.1` dans `qa/plan-tests-manuels.md`, et la story `1.12`.
>
> ⛔ **Ne créer ni scène de debug, ni script jetable** pour rendre ces valeurs visibles : le point d'audit **`A5`** l'interdit, et c'est le motif même du report de `TM-1.5` par **Q9**.

| ☐ | **Les champs `_*` ne sont pas observables dans l'Inspecteur distant** → cocher ici, ignorer e-l, prononcer le cas sur a-d |
|---|---|

| # | Champ | Valeur attendue | ✓ *(si observable)* |
|---|---|---|---|
| e | `_fuel` / `_fuel_max` | `100` / `100` | ☐ |
| f | `_armor` / `_armor_max` | `100` / `100` | ☐ |
| g | `_credits` | `0` | ☐ |
| h | `_cargo_used` / `_cargo_capacity` | `0` / `50` | ☐ |
| i | `_depth_m` | `0` | ☐ |
| j | `_upgrade_levels` | `{ "soute": 1, "reacteur": 1, "foret": 1 }` | ☐ |
| k | `_narrative_flags` | vide `{ }` | ☐ |
| l | `_cargo` | vide `{ }` | ☐ |
| m | **Bloquant** — aucune erreur dans la *Sortie* (*Output*) pendant l'exécution *(la ligne de résumé `GameData — …` est attendue, cf. `TM-1.8`)* | ☐ |

> Ces valeurs ne sont **pas** écrites dans le code : elles sont lues dans `data/upgrades.json` au démarrage (arbitrage **Q13**). Une valeur différente — **si elle est observable** — signale soit un JSON modifié, soit un défaut de résolution des valeurs de départ.

**Prononcé du cas** : **OK** si **a, b, c, d** et **m** sont satisfaits. Les points **e** à **l** ne peuvent, à eux seuls, ni faire échouer le cas ni le laisser en suspens.

**Obtenu** : ⚠️ **NON EXÉCUTÉ** — aucun constat rapporté (clôture sur décision du 2026-09-06)

**Verdict** : **Non exécuté** — *ni OK, ni KO* — **Sévérité si KO** : Bloquant

---

### TM-1.7 — Arbre de `Main.tscn` · **Majeur**

> ⚠️ **Procédure corrigée par la story `1.12`.** La version initiale décrivait le **contenu du fichier** `Main.tscn` et non ce que l'éditeur affiche : `World` y est une **instance de scène**, et l'éditeur **n'affiche pas les enfants d'une instance**. L'attendu se vérifie donc en **deux écrans**, pas en un seul.

**Procédure, écran 1** — Double-cliquer `scenes/main/Main.tscn` dans le *Système de fichiers* (*FileSystem*). Déplier l'arbre dans le dock **Scène** (*Scene*).

Hiérarchie réellement affichée — **8 nœuds** :

```
Main                 (Node2D)
├── World            (instance de res://scenes/world/World.tscn — icône « clap » d'instance,
│                     PAS de flèche de dépliage : ses enfants ne sont pas affichés, c'est normal)
├── Camera2D         (Camera2D)
└── UI               (CanvasLayer, process_mode = 3 → Always)
    ├── HUD          (Control)
    ├── Inventory    (Control, visible = false → icône « œil barré »)
    ├── Shop         (Control, visible = false)
    └── Dialogue     (Control, visible = false)
```

| # | Attendu | ✓ |
|---|---|---|
| a1 | L'arbre de `Main.tscn` affiche **exactement 8 nœuds**, mêmes noms, mêmes types que ci-dessus | ☐ |
| b | `World` porte l'icône d'**instance de scène** (et non un nœud recréé à la main) | ☐ |
| c | Aucun nœud ne porte de **script** (aucune icône de script dans l'arbre) | ☐ |
| d | Aucun nœud `DrillRig` n'a été anticipé | ☐ |
| e | **Aucun avertissement** n'est affiché sur cet écran — les trois « TileSet manquant » se constatent en écran 2, pas ici | ☐ |
| f | La scène s'ouvre **sans** boîte d'erreur (`load_steps`, UID, `ExtResource` corrects) | ☐ |
| g | Dans la vue 2D, le cadre de la `Camera2D` est visible et **cohérent avec l'origine (0,0)** | ☐ |

> ⛔ **Ne pas activer « Modifiable enfants »** (*Editable Children*) sur `World` pour forcer l'affichage de ses enfants. Cela écrit `editable_instance` dans `Main.tscn` et **salit un artefact déjà audité en `1.7`**, dont le md5 a été constaté inchangé. Si l'option a été activée par curiosité, **fermer la scène sans enregistrer** (*Scène > Fermer*, puis répondre **Ne pas enregistrer**).

**Procédure, écran 2** — Ouvrir `scenes/world/World.tscn` **séparément** (double-clic dans le *Système de fichiers*).

Hiérarchie réellement affichée — **5 nœuds** :

```
World                    (Node2D)
├── TerrainLayer         (TileMapLayer)   ⚠ « TileSet manquant » — attendu
├── OreLayer             (TileMapLayer)   ⚠ « TileSet manquant » — attendu
├── DecorationsLayer     (TileMapLayer)   ⚠ « TileSet manquant » — attendu
└── Hazards              (Node2D)
```

| # | Attendu | ✓ |
|---|---|---|
| h | `World.tscn` s'ouvre **sans erreur** et affiche **exactement 5 nœuds**, mêmes noms, mêmes types | ☐ |
| i | Les `TileMapLayer` sont bien de type **`TileMapLayer`** — jamais `TileMap`, déprécié en Godot 4 | ☐ |
| j | Les **seuls** avertissements sont les **3 « TileSet manquant »**, un par `TileMapLayer` — attendus jusqu'à la story `3.1` | ☐ |
| k | Aucun nœud de `World.tscn` ne porte de script | ☐ |
| a2 | **Total du projet : 12 nœuds** — 8 (écran 1) + 5 (écran 2) − 1 (`World`, commun aux deux vues) | ☐ |

> Le point **g** est le seul critère de **cadrage** de ce sprint. La `Camera2D` n'a ni cible ni limites : elle reste à l'origine. Il s'agit de constater qu'elle est bien placée et non décalée, pas d'en juger l'ergonomie — la caméra n'est réglée qu'à la story `2.4`.

**Obtenu** : ⚠️ **NON EXÉCUTÉ** — aucun constat rapporté (clôture sur décision du 2026-09-06)

**Verdict** : **Non exécuté** — *ni OK, ni KO* — **Sévérité si KO** : Majeur

---

### TM-1.8 — Chargement des données · **Majeur**

**Procédure** — Presser `F5` et lire le dock *Output* dès le démarrage.

| # | Attendu | ✓ |
|---|---|---|
| a | La ligne de résumé de `GameData` apparaît, **exactement** : | ☐ |

```
GameData — ressources : 6 (2 actives MVP) · améliorations : 4 (3 actives MVP) · événements : 1 (1 actifs MVP) · erreurs : 0
```

| # | Attendu | ✓ |
|---|---|---|
| b | Le compteur **`erreurs : 0`** — toute autre valeur signale un rejet d'entrée | ☐ |
| c | Aucune ligne `GameData — …` d'erreur ne précède ou ne suit ce résumé | ☐ |
| d | Aucune erreur de parsing JSON dans le *Debugger* | ☐ |
| e | Les accents s'affichent correctement (`améliorations`, `événements`) — encodage UTF-8 | ☐ |

> Ce `print()` est **volontaire** : c'est la seule sortie observable qui prouve le chargement au lancement, et il est exigé par ce cas de test. Il est tracé comme tel dans `GameData.gd` et a été validé au point d'audit B6.

> ⚠️ **Point de vigilance signalé par la story `1.12`, non corrigé — sans objet pour cette campagne.** La chaîne attendue ci-dessus a été recollationnée avec `get_load_summary()` (`GameData.gd` l. 399) : elle est **exacte au 2026-09-06**. Elle deviendra en revanche **fausse** dès que les arbitrages **Q17** et **Q21** auront activé l'amélioration `blindage` — le compteur passera alors à `améliorations : 4 (4 actives MVP)`. À reprendre avant tout re-test de ce cas après la phase 5.

**Obtenu** : ⚠️ **NON EXÉCUTÉ** — aucun constat rapporté (clôture sur décision du 2026-09-06)

**Verdict** : **Non exécuté** — *ni OK, ni KO* — **Sévérité si KO** : Majeur

---

### Traçabilité des vérifications transférées

> Ajoutée par la story `1.12`. Une vérification qu'une procédure ne sait pas observer est **transférée et tracée**, jamais abandonnée en silence (point d'audit `I5`).

| Vérification | Cas d'origine | Pourquoi elle n'est pas observable ici | Transférée à | Statut |
|---|---|---|---|---|
| Valeurs de départ de `GameState` — carburant `100/100`, blindage `100/100`, crédits `0`, soute `0/50`, profondeur `0`, `{soute:1, reacteur:1, foret:1}`, flags et cargo vides | `TM-1.6` **e** à **l** | Variables **privées non exportées** (`var _x`, aucun `@export`) : l'Inspecteur local ne les montre jamais, et l'Inspecteur distant de 4.7 ne les liste pas de façon garantie. Aucun contournement possible sans artefact de debug, interdit par `A5` | **`TM-4.1`** (sprint 4) — le HUD affiche carburant, blindage, crédits, charge de soute et profondeur, ce qui est le critère d'acceptation MVP correspondant | 🔁 **Transféré** — conditionnel et non bloquant ici ; **bloquant** en `TM-4.1` |
| Déclenchement d'une action par appui, une seule fois | `TM-1.5` | Aucun code ne consomme les entrées avant la phase 2 ; la scène de test d'input a été refusée (`A5`) | **Sprint 2** — arbitrage **Q9**, identifiant conservé | ⏭ **Reporté** *(décision antérieure, rappelée ici)* |

> **Ce que ces transferts ne changent pas** : la conformité de `GameState` est déjà **établie** — 33 assertions en story `1.4`, 63 en `1.5`, dont la relecture des valeurs de départ depuis le moteur en exécution réelle. Le transfert porte sur la **confirmation humaine à l'écran**, pas sur la validité du produit.

---

### Synthèse

| | |
|---|---|
| Cas exécutés | **0** / 7 |
| OK | **0** |
| KO | **0** |
| Non exécutés | **7** — `TM-1.1`, `TM-1.2`, `TM-1.3`, `TM-1.4`, `TM-1.6` *(interrompu sur procédure fausse)*, `TM-1.7`, `TM-1.8` |
| Non exécutés par report antérieur | **1** — `TM-1.5`, reporté au sprint 2 (**Q9**) |

**Synthèse** : **0 cas exécuté · 0 OK · 0 KO · 7 non exécutés** (+ 1 reporté par Q9). La gate est close **sur décision**, pas sur résultat.

---

## 4. Anomalies détectées

> Une fiche par anomalie. Supprimer la fiche vide s'il n'y a rien à signaler.
> **Rappel de gate** : toute anomalie **bloquante ou majeure** impose une story de correction dans la phase 1 puis un re-test des cas impactés (critère 6 de la story `1.8`). Les **mineures** acceptées se tracent ici **et** dans `stories/BACKLOG.md` (critère 7).

> **Aucune anomalie consignée** — et ce n'est pas un signe de bonne santé : **aucun cas n'ayant été exécuté**, aucune anomalie ne *pouvait* être détectée. L'absence d'anomalie ici est une conséquence de la non-exécution, non un constat de qualité. La fiche vide ci-dessous est conservée comme gabarit pour une éventuelle itération 2.

### ANO-1-1 — _(titre court, fiche vierge conservée comme gabarit)_

| Champ | Valeur |
|---|---|
| Sévérité | Bloquant / Majeur / Mineur |
| Cas de test | `TM-1.x` |
| Reproductible | Oui / Non / Aléatoire |

**Étapes de reproduction**
1.
2.

**Comportement attendu** :

**Comportement observé** :

**Trace / message d'erreur** :

```
```

**Suite donnée** : story de correction `1.__` créée / anomalie mineure acceptée et reportée au backlog.

---

## 5. Ressenti de jeu

> Le sprint 1 ne produit **aucun gameplay** : l'écran est vide, rien n'est jouable. Cette section n'a donc pas de matière à ce stade et reprendra son rôle au sprint 2. À renseigner uniquement si quelque chose surprend au lancement.

- Confort de l'éditeur, lisibilité de l'arborescence, temps d'import : **non renseigné — l'éditeur n'a pas été parcouru**
- Temps de démarrage du jeu (`F5`) : **non mesuré — le jeu n'a pas été lancé**
- Remarque libre : *(vide)*

---

## 6. Confirmation des critères `[H]` des stories `1.1` à `1.6`

> Critère 8 de la story `1.8` : chaque critère `[H]` est explicitement **confirmé** ou **infirmé**, et le statut de la story concernée est mis à jour en conséquence.

> ⚠️ **Critère 8 NON SATISFAIT — clôture du 2026-09-06.** Aucun cas n'ayant été exécuté, **aucun critère `[H]` du sprint 1 n'a été vérifié humainement**. Les 9 lignes ci-dessous restent **décochées** : elles ne sont **ni confirmées, ni infirmées**, elles sont **non vérifiées**. Cocher « Confirmé » sans constat serait une falsification.
>
> Les stories `1.1` à `1.6` conservent leur statut `Terminée`, acquis sur leurs **critères automatisables** vérifiés en headless. Leurs critères `[H]` — 9 au total — restent en suspens et devront être repris, soit en itération 2 de cette campagne, soit à la gate du **sprint 2**, qui héritera de fait de cette dette.

| Story | Critère `[H]` | Cas | Confirmé ? |
|---|---|---|---|
| `1.1` | Critère 8 — le projet s'importe sans erreur et se lance avec `F5` sans erreur console | `TM-1.1`, `TM-1.2` | ☐ Confirmé ☐ Infirmé |
| `1.1` | Rendu effectif de la résolution 1280×720 et du mode d'étirement | `TM-1.2` b | ☐ Confirmé ☐ Infirmé |
| `1.2` | Critère 7 — le dock *FileSystem* affiche l'arborescence attendue | `TM-1.3` | ☐ Confirmé ☐ Infirmé |
| `1.3` | Critère 7 — *Input Map* affiche les 12 actions avec les bonnes touches | `TM-1.4` | ☐ Confirmé ☐ Infirmé |
| `1.3` | Critère 8 — chaque touche déclenche son action, une fois par appui | `TM-1.5` | ⏭ **Reporté au sprint 2** (Q9) |
| `1.4` | Critère 9 — `GameState` chargé et déclaré correctement *(voir la note ci-dessous)* | `TM-1.6` a-d | ☐ Confirmé ☐ Infirmé |
| `1.5` | Critère 10 — données chargées sans erreur de parsing, nombre d'entrées vérifiable | `TM-1.8` | ☐ Confirmé ☐ Infirmé |
| `1.6` | Critère 10 — `Main.tscn` s'ouvre avec la hiérarchie attendue et le jeu se lance dessus | `TM-1.7`, `TM-1.2` | ☐ Confirmé ☐ Infirmé |
| `1.6` | Cadrage et position de la `Camera2D` à l'écran | `TM-1.7` g | ☐ Confirmé ☐ Infirmé |

> **Note sur le critère 9 de la story `1.4`** *(story `1.12`)* — ce critère se confirme désormais sur les **points a-d** de `TM-1.6` : les deux autoloads sont déclarés, dans le bon ordre, et le jeu démarre sans erreur. La lecture **à l'écran** des valeurs initiales (`TM-1.6` e-l) est **conditionnelle** : si l'Inspecteur distant ne liste pas les variables privées de `GameState`, le critère reste **Confirmé** sur a-d, et la confirmation visuelle des valeurs est **transférée à `TM-4.1`** — voir la table « Traçabilité des vérifications transférées » en section 3. Ce n'est ni un échec de la story `1.4`, ni une confirmation par défaut : c'est un transfert tracé.

---

## 7. Verdict de fin de sprint

**Verdict** : ✅ **Validé sur décision utilisateur du 2026-09-06 — campagne non exécutée.**

**Commit de phase autorisé** : **Oui**, par la même décision.

État réel des quatre conditions normales de la gate — aucune n'est remplie par constat :

| Condition | État |
|---|---|
| Les **4 cas bloquants** (`TM-1.1`, `TM-1.2`, `TM-1.4`, `TM-1.6`) sont **OK** | ❌ **Non** — les 4 sont **non exécutés**. Aucun n'est OK, aucun n'est KO |
| Les anomalies restantes sont tracées | ➖ **Sans objet** — aucune anomalie n'a pu être détectée, faute d'exécution |
| Les critères `[H]` des stories `1.1` à `1.6` sont confirmés ou infirmés | ❌ **Non** — les 9 critères `[H]` sont **non vérifiés** (section 6) |
| Les statuts des stories concernées ont été mis à jour | ✅ **Oui** — `1.8` passe à `Terminée` **sur décision**, les stories `1.1`–`1.6` conservent leur statut acquis en headless |

> **La validation est administrative, pas technique.** Elle est prononcée par l'utilisateur, qui en assume le motif — *« c'est pas des points essentiels »* — et elle est tracée ici sans être maquillée. Elle satisfait formellement la règle de `.claude/CLAUDE.md` (« ne pas commiter tant que les deux stories de gate ne sont pas `Terminée` ») et autorise le commit `Phase 1 — Fondations techniques du projet Godot`.
>
> **Ce qu'elle laisse ouvert** : les fondations de la phase 1 n'ont **jamais été constatées à l'écran**. Risque inscrit à `stories/AVANCEMENT.md` §5. Le premier constat visuel réel arrivera à la gate du **sprint 2**, qui héritera de cette vérification en plus de la sienne — `TM-1.5` (reporté par **Q9**) s'y ajoutant déjà.

**Commentaire du testeur** : *(aucun — la campagne n'a pas été déroulée)*

---

### Reprise éventuelle — itération 2

Ce rapport reste **exploitable en l'état** : les procédures corrigées par la story `1.12` sont intactes. Une reprise consisterait à dérouler les 7 cas et à consigner les résultats dans une **section « Itération 2 » datée**, sans écraser la présente clôture (convention `qa/README.md` §5 : un rapport n'est jamais écrasé).
