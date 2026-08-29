# Checklist d'audit qualité — Godot 4.x / GDScript

Document de **référence** de la story « Audit qualité code » de fin de sprint.

- Audit **statique + vérifications headless** : tout point portant sur la syntaxe, le chargement d'une scène ou la validité de `project.godot` doit être étayé par une commande `godot --headless` et sa sortie (voir `qa/README.md` §4).
- Chaque point se répond par **OK / KO / N/A**, avec **preuve** (fichier + ligne) en cas de KO.
- **Un seul KO bloquant suffit à rendre le verdict `KO`.**

---

## Verdict

| Verdict | Condition |
|---|---|
| **Autorisé** | Aucun KO sur un point marqué **[B]** (bloquant), et les KO mineurs sont tracés en story |
| **KO** | Au moins un point **[B]** en KO |

Le verdict est consigné dans les *Notes / décisions* de la story d'audit, avec la liste des points KO.

---

## A. Conformité à l'arborescence contractuelle **[B]**

Référence CDC : section « Architecture Godot ».

- [ ] A1 **[B]** L'arborescence `res://` respecte le contrat : `scenes/{main,player,world,ui}`, `scripts/{autoload,player,systems,components}`, `data/`, `assets/{sprites,audio,fonts}`.
- [ ] A2 **[B]** Aucun script/scène placé hors de son dossier de responsabilité (ex. un système dans `scripts/player/`).
- [ ] A3 Toute **déviation** de l'arborescence est justifiée dans les *Notes* d'une story (sinon KO).
- [ ] A4 Les noms de fichiers respectent la convention : scripts `PascalCase.gd`, scènes `PascalCase.tscn`, données `snake_case.json`.
- [ ] A5 Aucun fichier orphelin / résidu de test non référencé (`test.gd`, `truc2.tscn`, `.bak`).

## B. Qualité GDScript

- [ ] B1 **[B]** **Typage statique systématique** : toute variable déclarée est typée (`var fuel: float = 100.0`), toute fonction a un type de retour (`-> void`, `-> bool`, ...) et des paramètres typés.
- [ ] B2 **[B]** **Godot 4 uniquement** : `TileMapLayer` (jamais `TileMap` déprécié), `CharacterBody2D` + `move_and_slide()`, `@onready`, `@export`, `Callable`. Aucune API Godot 3 (`yield`, `KinematicBody2D`, `export var`, `onready var`).
- [ ] B3 Nommage : `snake_case` (variables/fonctions), `PascalCase` (classes/nœuds), `SCREAMING_SNAKE_CASE` (constantes).
- [ ] B4 **Un script = une responsabilité** ; pas de « god script ». Les sous-systèmes de la foreuse sont des nœuds enfants distincts (`DrillSystem`, `FuelSystem`, `ArmorSystem`, `ScannerSystem`).
- [ ] B5 Fonctions courtes et lisibles (repère indicatif : > 50 lignes ou > 3 niveaux d'imbrication ⇒ à justifier).
- [ ] B6 Aucun code mort, aucun `print()` de debug oublié (utiliser un flag de debug si nécessaire).
- [ ] B7 Les commentaires expliquent le **pourquoi**, pas le **quoi** ; aucun commentaire mensonger ou obsolète.
- [ ] B8 Pas de `TODO`/`FIXME` non tracés : chaque TODO restant correspond à une story identifiée.

## C. Couplage et accès aux nœuds **[B]**

- [ ] C1 **[B]** **Aucun chemin de nœud fragile en dur** : pas de `get_node("../../..")`, pas de `$"../../Machin"`, pas de `get_parent().get_parent()`.
- [ ] C2 Les références internes à une scène passent par `@onready var x: Type = $Enfant` (chemin descendant, stable) ou `@export var x: NodePath/Node` renseigné dans la scène.
- [ ] C3 **[B]** La communication inter-systèmes passe par **signaux** ou par l'autoload `GameState` — jamais par appel direct à un nœud d'une autre branche.
- [ ] C4 Les signaux sont **typés** et déclarés explicitement ; les connexions sont faites via `Callable` (pas de chaînes de caractères).
- [ ] C5 Les connexions créées dynamiquement sont déconnectées ou nettoyées si le nœud peut disparaître (pas de fuite de signal).
- [ ] C6 L'autoload `GameState` porte l'**état**, pas la logique de gameplay des systèmes.

## D. Données externalisées **[B]**

Référence CDC : sections « Ressources », « Améliorations », « Architecture Godot ».

- [ ] D1 **[B]** Les valeurs de gameplay (minerais, valeurs de vente, coûts et effets d'améliorations, événements) sont dans `data/*.json` — **pas en dur dans le code**.
- [ ] D2 Le JSON est chargé et **parsé avec gestion d'erreur** (`JSON.parse_string` vérifié, fichier manquant géré, message d'erreur explicite).
- [ ] D3 Les identifiants (`resource_id`, `upgrade_id`) sont cohérents entre `data/*.json`, les Custom Data Layers du TileSet et le code.
- [ ] D4 Aucun « nombre magique » de gameplay disséminé dans les scripts : constante nommée ou entrée JSON.
- [ ] D5 Les JSON sont valides syntaxiquement (vérifiable sans Godot).

## E. Tuiles et TileSet **[B]**

Référence CDC : section « Données de tuile ».

- [ ] E1 **[B]** Les Custom Data Layers du TileSet définissent bien : `mineable` (bool), `hardness` (int), `resource_id` (String), `value` (int), `hazard_type` (String), `destructible` (bool).
- [ ] E2 Le code lit ces propriétés via `get_cell_tile_data()` + `get_custom_data()` — jamais par déduction sur l'`atlas_coords` ou l'ID de tuile en dur.
- [ ] E3 Les cas limites sont gérés : cellule vide (`-1` / `TileData` nul), tuile hors carte, tuile indestructible.
- [ ] E4 Les couches (`TerrainLayer`, `OreLayer`, `DecorationsLayer`) ont des rôles distincts et respectés.

## F. Input **[B]**

Référence CDC : section « Contrôles ».

- [ ] F1 **[B]** **Aucun scancode / touche en dur** dans le code (`Key.KEY_Z`, `event.keycode == ...`) : tout passe par l'Input Map.
- [ ] F2 **[B]** Les 12 actions du CDC existent dans `project.godot` : `move_up`, `move_down`, `move_left`, `move_right`, `drill`, `brake`, `use_item_1`, `use_item_2`, `use_item_3`, `toggle_inventory`, `toggle_journal`, `pause`.
- [ ] F3 Les touches par défaut correspondent au CDC (ZQSD + flèches, Espace, Shift, 1/2/3, I/Tab, J, Échap).
- [ ] F4 La lecture d'input est faite au bon endroit (`_unhandled_input` pour les actions UI/ponctuelles, `Input.is_action_pressed` dans `_physics_process` pour le mouvement continu) ; les entrées consommées par l'UI ne fuient pas vers le gameplay.
- [ ] F5 Aucune action inutilisée n'est ajoutée hors CDC sans story.

## G. Règles de gameplay non négociables **[B]**

Référence CDC : sections « Règles autorisées » et « Règles interdites ou limitées ».

- [ ] G1 **[B]** **Aucun forage vers le haut** : la direction `up` ne peut jamais déclencher une destruction de tuile — vérifiable explicitement dans le code.
- [ ] G2 **[B]** **Aucun forage latéral dans le vide** : le forage latéral exige un contrôle de sol solide sous la foreuse (`is_on_floor()` ou test de tuile) avant destruction.
- [ ] G3 **[B]** **Directions opposées** (haut+bas, gauche+droite) ⇒ mouvement **annulé**, sans état instable ni oscillation.
- [ ] G4 **[B]** **Sans carburant** : ni forage, ni propulsion vers le haut. La chute/le déplacement passif reste possible.
- [ ] G5 Aucune traversée de tuile indestructible, de bord de carte ou de plafond de zone.
- [ ] G6 Aucun usage de consommable pendant : animation de destruction, interface ouverte, cinématique, état de mort.
- [ ] G7 Les consommables respectent stock **et** cooldown.
- [ ] G8 La soute ne dépasse jamais sa capacité ; le dépassement est géré explicitement — **Q5 : tuile détruite, minerai perdu** (le forage n'est pas empêché), jamais un débordement silencieux.
- [ ] G9 **[B]** **Alerte de soute pleine antérieure à la perte** (Q5) : l'émission de l'alerte (signal `cargo_full` ou équivalent) précède, dans le code, toute destruction de minerai non collecté. Un ordre inverse — perte puis alerte — ou une alerte conditionnée à la perte est un KO bloquant.
- [ ] G10 La perte de minerai en soute pleine est **observable** : signal/compteur exposé au HUD (message ou total perdu). Une perte silencieuse, même correcte fonctionnellement, est un KO.

## H. Robustesse et état

- [ ] H1 Aucune division par zéro possible sur les jauges (carburant max, capacité soute, hardness).
- [ ] H2 Les jauges sont bornées (`clamp`) : jamais de carburant négatif, de blindage > max, de crédits négatifs.
- [ ] H3 Les transitions d'état (mort, panne sèche, retour surface, pause) sont explicites et sans état intermédiaire incohérent.
- [ ] H4 La pause (`get_tree().paused`) est cohérente avec les `process_mode` des nœuds UI.
- [ ] H5 Sauvegarde : écriture dans `user://`, lecture tolérante à un fichier absent, corrompu ou d'une version antérieure.
- [ ] H6 Aucune ressource lourde chargée dans `_process` / `_physics_process` (`load()` en boucle).
- [ ] H7 **[B]** **Aucune sauvegarde automatique** (Q7) : l'écriture dans `user://` n'est appelée que depuis une action explicite du joueur. Aucun appel déclenché par un `Timer`, par l'entrée en zone de surface, par une vente, par un changement de scène ou par `NOTIFICATION_WM_CLOSE_REQUEST` / `_exit_tree()`. Vérifiable en listant tous les appelants de la fonction de sauvegarde.
- [ ] H8 Garde-fous Q7 présents : rappel **non bloquant** au retour en surface quand la progression n'est pas sauvegardée, et confirmation avant de quitter dans le même cas. Le rappel ne met pas le jeu en pause et n'exige aucun clic.
- [ ] H9 Un indicateur d'état « progression non sauvegardée » existe dans `GameState` (drapeau positionné à chaque mutation persistante, remis à zéro à la sauvegarde) — sinon H8 n'est pas fiabilisable.

## I. Cohérence documentaire **[B]**

- [ ] I1 **[B]** Chaque fichier produit sur ce sprint est rattaché à une **story existante** (aucun artefact orphelin).
- [ ] I2 **[B]** Les stories du sprint sont au statut **Terminée** et listent leurs **artefacts produits**.
- [ ] I3 Les critères d'acceptation non vérifiables sans Godot sont **explicitement marqués `[H]`** et reportés à la story de tests manuels — aucun critère `[H]` n'a été coché par un agent.
- [ ] I4 `stories/BACKLOG.md` reflète les statuts réels.
- [ ] I5 Les écarts au CDC sont justifiés en *Notes* de story (pas d'écart silencieux).
- [ ] I6 Aucune story renommée / renumérotée / supprimée (interdits `.claude/CLAUDE.md`).

## J. Dépôt et configuration

- [ ] J1 `.gitignore` couvre `.godot/`, `.import/`, exports, `*.translation`, fichiers OS (`.DS_Store`).
- [ ] J2 Aucun fichier généré (`.godot/`) ni binaire lourd versionné par erreur.
- [ ] J3 `project.godot` est syntaxiquement cohérent (`config_version=5`, autoloads valides, `run/main_scene` pointant vers une scène existante).
- [ ] J4 Aucun plugin/addon ajouté sans story ni annonce préalable.
- [ ] J5 Les chemins référencés dans les `.tscn` (`ExtResource`) pointent vers des fichiers réellement présents.

## K. Génération de terrain et déterminisme **[B]**

Référence : arbitrage **Q6** du 2026-08-29 (terrain semi-procédural dès le MVP) · CDC « Backlog après MVP » (périmètre remonté en phase 3, écart assumé).

- [ ] K1 **[B]** **Graine de génération explicite et forçable** : la graine est une donnée nommée, lisible et surchargeable (constante de configuration ou `data/*.json`), **journalisée au démarrage** de la partie. Aucun `randomize()` implicite, aucun `randi()`/`randf()` global : tout l'aléa de génération passe par une instance `RandomNumberGenerator` dédiée et ensemencée.
- [ ] K2 **[B]** **Déterminisme** : à graine identique, la génération produit un terrain identique. Aucune dépendance à l'ordre d'exécution, au temps, au nombre d'images ou à l'état du joueur dans le flux de génération.
- [ ] K3 **[B]** **Ancrages déterministes indépendants de la graine** : la zone de surface et l'emplacement de l'anomalie scénarisée sont posés hors du flux aléatoire (coordonnées fixes ou dérivées de constantes), donc identiques quelle que soit la graine. Un ancrage tiré au sort est un KO bloquant : il rend la progression narrative aléatoire.
- [ ] K4 **[B]** La génération garantit une **ceinture de tuiles `destructible=false` sur tout le pourtour** de la carte (bords latéraux et fond), sans discontinuité, quelle que soit la graine — complète G5.
- [ ] K5 Les paramètres de génération (seuils de strates, densités de minerai par profondeur, dimensions de carte) sont externalisés en `data/*.json` conformément à D1 — pas de nombre magique dans le générateur.
- [ ] K6 La graine effectivement utilisée est **restituée au testeur** (log ou écran de debug) : sans elle, aucun rapport de test manuel n'est exploitable (cf. prérequis `P4` de `qa/plan-tests-manuels.md`).

---

## Format du verdict (à recopier dans la story d'audit)

```
Verdict : Autorisé | KO
Date : AAAA-MM-JJ · Itération : 1
Points contrôlés : XX · OK : XX · KO : XX · N/A : XX

KO relevés :
- <Code> — <description> — <fichier:ligne> — bloquant / mineur

Suite donnée :
- story de correction <n.m> créée / aucune
```
