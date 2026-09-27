# Checklist d'audit qualité — Godot 4.x / GDScript

Document de **référence** de la story « Audit qualité code » de fin de sprint.

- Audit **statique + vérifications headless** : tout point portant sur la syntaxe, le chargement d'une scène ou la validité de `project.godot` doit être étayé par une commande `godot --headless` et sa sortie (voir `qa/README.md` §4).
- Chaque point se répond par **OK / KO / N/A**, avec **preuve** (fichier + ligne) en cas de KO.
- **Un seul KO bloquant suffit à rendre le verdict `KO`.**
- Référence fonctionnelle : `cahier_des_charges_motherload_40k_godot.md`, **amendé par `cahier_des_charges_gameplay_addictif.md`** (arbitrage **Q16** du 2026-09-06, story `1.10`). Les sections `L` et `M`, ainsi que les points `K7` à `K9`, en découlent directement.

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

  > **Contrôle opposable** *(complété le 2026-09-27, revue `po` du sprint 2)* :
  >
  > ```
  > grep -rnE 'get_node(_or_null)?\(|get_parent\(\)|\$"?\.\./' scripts/
  > ```
  >
  > ⚠️ La forme `grep -rn "get_node("` employée jusqu'ici **ne matche pas `get_node_or_null(`** et laisserait donc passer un `get_node_or_null("../../X")`. Même classe de défaut que celui corrigé sur `F1` par la story `2.9` : un contrôle trop littéral donne une fausse assurance.
  >
  > Une occurrence remontée n'est **pas** automatiquement un KO : un `get_node_or_null(chemin)` dont le chemin vient d'un `@export NodePath` renseigné dans la scène est conforme à `C2`. L'auditeur lit l'origine du chemin — **littéral dans le code** (KO) ou **donnée de scène** (conforme).
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

- [ ] F1 **[B]** **Aucun scancode / touche en dur** dans le code (`Key.KEY_Z`, `event.keycode == ...`) : tout passe par l'Input Map. Les noms d'action (`&"move_left"`) sont, eux, attendus dans le code : ce sont des identifiants d'Input Map, pas des touches.

  > **Contrôle opposable** *(reformulé par la story `2.9`)* :
  >
  > ```
  > grep -rnE "Key\.KEY_|\.keycode|physical_keycode|scancode" scripts/
  > ```
  >
  > Il doit ne **rien** remonter. ⚠️ **Ne pas utiliser `grep -rn "KEY_\|keycode\|scancode" scripts/`**, forme employée jusqu'au 2026-09-26 : elle remonte **72 faux positifs** — les constantes de **clés JSON** de `GameData` (`KEY_ID`, `KEY_TIERS`, `KEY_GRAVITY`, …), convention posée par la story `1.5`. Un `KEY_*` du projet nomme un champ de données ; une touche en dur se reconnaît à l'énumération `Key` du moteur ou à un champ d'événement clavier.
- [ ] F2 **[B]** Les 12 actions du CDC existent dans `project.godot` : `move_up`, `move_down`, `move_left`, `move_right`, `drill`, `brake`, `use_item_1`, `use_item_2`, `use_item_3`, `toggle_inventory`, `toggle_journal`, `pause`.
- [ ] F3 Les touches par défaut correspondent au CDC (ZQSD + flèches, Espace, Shift, 1/2/3, I/Tab, J, Échap).
- [ ] **F4 [B]** La lecture d'input est faite au bon endroit (`_unhandled_input` pour les actions UI/ponctuelles, `Input.is_action_pressed` dans `_physics_process` pour le mouvement continu) ; les entrées consommées par l'UI ne fuient pas vers le gameplay.
- [ ] **F5 [B]** *(arbitrage Q10)* **Aucun nœud de gameplay n'implémente `_input()`** — la lecture ponctuelle passe exclusivement par `_unhandled_input()`. Motif : `drill`/Espace, `pause`/Échap, `toggle_inventory`/Tab et les flèches partagent leurs touches avec les actions intégrées `ui_accept`, `ui_cancel`, `ui_focus_next` et `ui_up/down/left/right`. Un `_input()` dans le gameplay recevrait l'événement **avant** l'UI : Espace déclencherait le forage tout en validant un bouton. Contrôle : `grep -rn "func _input(" scripts/ scenes/` ne doit remonter aucun nœud de gameplay.
- [ ] **F6** Toute UI modale (inventaire, boutique, pause, dialogue) appelle `set_input_as_handled()` ou consomme l'événement, de sorte qu'aucune action de jeu ne se déclenche derrière elle.
- [ ] **F7** Aucune action inutilisée n'est ajoutée hors CDC sans story. *(Renuméroté de `F5` en `F7` par la story `2.9` : deux points portaient le même code. Le code `F5` reste attaché à l'interdiction de `_input()`, que les stories `2.2` et `2.3` citent déjà sous ce nom.)*

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
- [ ] **I7 [B]** *(ajouté le 2026-09-27, revue `po` du sprint 2 — story `2.12`)* **Les compteurs de `stories/BACKLOG.md` et de `stories/AVANCEMENT.md` concordent**, et le total MVP est **recalculé, jamais recopié**. L'auditeur refait l'addition à la main et compare les deux documents.

  > **Pourquoi ce point est devenu opposable, et bloquant.** La cohérence des compteurs reposait jusqu'ici sur une **discipline de rédaction** (« reprendre §1 et §2/§3 ensemble »), qui a échoué **quatre fois** : 55 → 57 → 58 (corrigé à 59), puis le 2026-09-27 un total de 73 affiché pour une addition qui donnait 70, et deux documents divergents (73 contre 74). Un compteur faux n'est pas cosmétique : c'est l'indicateur d'avancement du projet, et il sert à juger si une phase est complète.
  >
  > **Règle de dénombrement**, à appliquer telle quelle : une story **`Annulée`** est **exclue** du total (elle ne sera jamais faite) ; une story **`Reportée`** y est **incluse** (elle sera faite, plus tard et ailleurs). Le contrôle par `ls` ne vaut que sur les **phases ouvertes** — celles dont les fichiers existent : leur nombre de fichiers **moins** le nombre de stories `Annulée` doit égaler le sous-total de ces phases. Les phases non ouvertes n'ont aucun fichier et leurs volumes restent **prévisionnels**. Au 2026-09-27 : 34 fichiers pour les phases 0 à 2, moins 1 `Annulée` (`0.5`) = **33**, plus **42** prévisionnelles pour les phases 3 à 7 = **75**. L'auditeur refait ce calcul.

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

*Points ajoutés le 2026-09-06 — amendement §2, arbitrage **Q19** (story `1.10`) :*

- [ ] K7 **[B]** **Table de loot entièrement en données** : les poids de rareté par couche vivent dans `data/generation.json`, jamais dans le code. Aucune probabilité littérale, aucun seuil de rareté, aucune liste de raretés codée en dur dans le générateur ou dans `MiningSystem` — extension de `D1` et `K5`. Contrôle : la modification d'un poids dans le JSON change le comportement du jeu **sans recompilation ni édition de `.gd`**.
- [ ] K8 **[B]** **Graine du tirage de loot journalisée** : le tirage de loot passe par le `RandomNumberGenerator` ensemencé de la génération, ou par une instance dédiée **elle aussi ensemencée depuis une donnée**. Aucun `randf()`/`randi()` global, aucun `randomize()` implicite. La graine effectivement employée est **journalisée au démarrage** et restituée au testeur (prolonge `K1` et `K6`, prérequis `P5` du plan de tests). Sans elle, `TM-3.17` est injouable et toute anomalie de drop devient indiagnosticable.
- [ ] K9 **Aucune couche ne peut produire 0 % de drop** (règle de design §2.4) : la table de loot est **validée au chargement** — somme des poids strictement positive sur chaque couche, et poids de l'entrée « Rien » strictement inférieur au total. Une table qui violerait la règle provoque un **échec bruyant** au chargement, jamais un repli silencieux.
- [ ] K10 Le tirage de loot ne peut **jamais** retourner une ressource marquée `actif_mvp: false` dans `data/resources.json` (contrainte **Q12**) : le filtrage est explicite dans le code ou garanti par la structure de la table.

## L. Économie et progression infinie **[B]**

Référence : amendement §3 (progression infinie) · arbitrage **Q18** du 2026-09-06 (`data/upgrades.json` en `schema_version: 2`). Section applicable à partir de la **phase 5**.

- [ ] L1 **[B]** **Formule de coût paramétrable en données** : `base` et `facteur` sont déclarés par amélioration dans `data/upgrades.json`, et le coût est calculé par `cout = base × facteur^niveau`. Aucun tableau de paliers de coût codé en dur, aucune constante numérique de prix dans `EconomySystem` ni dans `Shop.tscn` — extension de `D1`.
- [ ] L2 **[B]** **Aucun plafond dur** (règle de design §3.3) : pas de champ `niveau_max`, pas de `clamp`/`min` bornant le niveau d'amélioration par le haut, pas de branche « niveau maximal atteint ». Le coût doit être calculable pour un niveau arbitrairement grand. Un plafond, même lointain, est un KO bloquant : il contredit la mécanique de rétention centrale de l'amendement.
- [ ] L3 Le calcul de coût est une **fonction pure et déterministe** — un seul point de calcul, sans effet de bord, appelable pour un niveau quelconque — et la règle d'arrondi est explicite et documentée (pas d'arrondi implicite divergeant entre l'affichage et le débit).
- [ ] L4 **[B]** La migration `schema_version 1 → 2` **ne renomme aucun `id`** d'amélioration (contrainte **Q12** : `soute`, `reacteur`, `foret`, `blindage` sont définitifs, utilisés par le TileSet et les sauvegardes). La lecture reste tolérante à une sauvegarde écrite en `schema_version: 1` (prolonge `H5`).
- [ ] L5 Les **4 stats upgradables minimum** du §3.2 existent, sont **actives au MVP** — *(arbitrage **Q21** : exactement `soute`, `reacteur`, `foret`, `blindage` ; aucun `id` nouveau, `blindage` basculé en `actif_mvp: true` avec des paliers supérieurs ; « profondeur max sûre » **reportée post-MVP**)* —, et chacune pilote une statistique **réellement consommée** par le gameplay — une amélioration dont l'effet n'est lu par aucun système est du code mort au sens de `B6`. Le niveau doit produire une **valeur** croissante, pas seulement un coût croissant (sinon la règle §3.3 « effet ressenti immédiatement » est inatteignable).
- [ ] L6 La progression ne peut pas **bloquer** la partie : quel que soit l'état, le joueur conserve un moyen de regagner des crédits (prolonge le critère MVP « boucle non bloquante », `TM-5.8`).

## M. Risque, dégâts et menaces **[B]**

Référence : amendement §4 (risque croissant) · arbitrages **Q17** (qui **annule Q3 et Q8**) et **Q20** (première source de dégâts : chute et impact) du 2026-09-06.

**Applicabilité — précisée par Q20** : la section est **pleinement applicable dès la phase 2**, et non plus à partir de la seule phase 6. Depuis Q20, le sprint 2 livre une source de dégâts réelle (chute et impact) **et** son consommateur : `M1`, `M4`, `M7` et `M8` sont donc auditables à l'audit `2.6`. `M2`, `M3`, `M5` et `M6`, qui portent sur les menaces par profondeur et sur la perte de cargo, restent `N/A` jusqu'à la phase 6.

- [ ] M1 **[B]** **`ArmorSystem` est le seul point d'entrée de dégâts** : aucune écriture directe de `GameState.armor` depuis un autre nœud. Contrôle : tous les appelants de la mutation du blindage sont dans `ArmorSystem`. **Vaut pour les deux familles de dégâts** — impact (phase 2, `Q20`) et menaces par profondeur (phase 6, §4.2) : la seconde s'**ajoute** à la première et passe par le même point d'entrée, elle ne le contourne pas.
- [ ] M2 **[B]** La **probabilité de rencontre hostile par profondeur** est une donnée externalisée (`data/*.json`), croissante d'un palier au suivant, conforme à l'ordre de grandeur du §4.2. Aucune probabilité en dur dans le code — extension de `D1`.
- [ ] M3 **[B]** **La perte n'est jamais totale** (règle de design §4.3) : à blindage nul, le code ne supprime ni le fichier de sauvegarde, ni les crédits, ni les niveaux d'amélioration, ni les flags narratifs. Seule une **fraction du cargo** est perdue, et cette fraction est une **donnée**, pas une constante. Toute suppression de sauvegarde, toute remise à zéro de la progression et tout « game over » définitif sont des **KO bloquants**.
- [ ] M4 L'état « foreuse détruite » est une **transition d'état explicite**, sans état intermédiaire jouable incohérent (le joueur ne peut ni forer ni se déplacer pendant la transition) — prolonge `H3`.
- [ ] M5 **L'indicateur de danger est non chiffré** (règle de design §4.3) : aucune probabilité de rencontre, aucun pourcentage de risque n'est affiché au joueur. Le retour passe par la teinte d'écran et l'ambiance sonore, par palier de profondeur.
- [ ] M6 **[B]** Le tirage de menace utilise un `RandomNumberGenerator` **distinct** de celui de la génération de terrain, lui aussi ensemencé depuis une donnée et journalisé. Partager l'instance décalerait la séquence du terrain dès la première rencontre et **casserait la reproductibilité `K2`** — donc toute la campagne de tests à graine fixe.
- [ ] M7 Le blindage reste borné : jamais négatif, jamais supérieur au maximum (prolonge `H2`), et le maximum ne peut être nul (prolonge `H1`).
- [ ] M8 **[B]** *(arbitrage **Q20**)* **Paramètres de dégâts d'impact externalisés** : le **seuil de vitesse** en deçà duquel aucun dégât n'est infligé et le **coefficient** de conversion vitesse → dégâts sont des données (`data/drill.json`, fichier créé par la story `2.2` au titre de **Q15**). Aucune constante d'impact en dur dans `ArmorSystem` ni dans `DrillRig` — extension de `D1`. Le seuil doit exister et être non nul : sans lui, le déplacement ordinaire grignoterait le blindage et rendrait le jeu punitif.
- [ ] M9 *(arbitrage **Q20**)* **Source et consommateur livrés ensemble** : au sprint qui introduit l'`ArmorSystem`, une source de dégâts réelle l'appelle. Un `ArmorSystem` sans appelant est du **code mort** au sens de `B6` — c'est précisément ce que Q20 ferme, et le point ne peut pas être répondu `N/A` par commodité.

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
