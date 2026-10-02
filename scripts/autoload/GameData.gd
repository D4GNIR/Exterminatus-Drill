extends Node

## Autoload `GameData` — catalogue de données immuable.
##
## Charge **une seule fois au démarrage** les fichiers de `res://data/` et les
## expose en lecture au reste du jeu : minerais, améliorations, événements
## narratifs et état de départ d'une nouvelle partie. Aucune valeur de gameplay
## ne doit vivre ailleurs qu'ici (point d'audit D1).
##
## **Façade unique** (story 5.11, `Q53` (a)) : la lecture et la validation de
## chaque fichier vivent dans un chargeur dédié de `scripts/autoload/game_data/`
## — `ResourceCatalog`, `UpgradeCatalog`, `EventCatalog`, `DrillSettings`,
## `GenerationSettings` —, appuyé sur les outils partagés de `DataValidator`. Ce
## script ne fait que les construire, les charger dans l'ordre et leur déléguer.
## Les appelants ne connaissent que `GameData` : aucun ne construit ni ne lit un
## chargeur directement.
##
## Contraintes de conception, opposables aux phases suivantes :
## [br]— **Catalogue immuable** : `GameData` ne contient aucun état de partie.
## L'état mutable appartient à `GameState`. Corollaire imposé par l'arbitrage
## Q4 : la sauvegarde (phase 7) ne persiste **jamais** une donnée issue d'ici,
## uniquement des `id` qui y font référence.
## [br]— **Chargé avant `GameState`** : l'ordre de la section `[autoload]` de
## `project.godot` est l'ordre de chargement. Le catalogue est lu dans `_init()`
## et non dans `_ready()`, pour être disponible quel que soit le moment où un
## autre singleton l'interroge — l'accès fichier ne demande pas l'arbre de scène.
## [br]— Aucun accès à l'arbre de scène, aucun `_input()` / `_unhandled_input()`
## (Q10) : un autoload de données ne lit jamais les entrées.
## [br]— **Aucun repli silencieux** : une entrée invalide est **rejetée** et
## signalée par `push_error()`, jamais remplacée par une valeur par défaut. Une
## valeur d'équilibrage inventée dans le code contredirait D1 et masquerait le
## défaut ; un catalogue amputé, lui, se voit immédiatement.

# --- Constantes publiques -----------------------------------------------------
# Reprises des chargeurs, sans nouvelle valeur : ce sont celles que lisent les
# appelants (chemins cités dans leurs messages d'erreur, statistiques, sentinelle
# de profondeur, clés du zoom et de la carte — story 5.14). Les autres clés JSON
# appartiennent désormais à leur chargeur — aucun script hors de `GameData` ne
# les lisait (story 5.11, Notes). Les chemins de `upgrades.json` et `events.json`
# n'ont pas d'alias ici : aucun appelant ne les cite, ils restent
# `UpgradeCatalog.PATH` et `EventCatalog.PATH` (story 5.15, `B7`).

const RESOURCES_PATH: String = ResourceCatalog.PATH
const DRILL_PATH: String = DrillSettings.PATH
const GENERATION_PATH: String = GenerationSettings.PATH

const STAT_CARGO_CAPACITY: String = UpgradeCatalog.STAT_CARGO_CAPACITY
const STAT_FUEL_MAX: String = UpgradeCatalog.STAT_FUEL_MAX
const STAT_DRILL_POWER: String = UpgradeCatalog.STAT_DRILL_POWER
const STAT_ARMOR_MAX: String = UpgradeCatalog.STAT_ARMOR_MAX

## Sentinelle « jusqu'au fond de la carte » de la dernière strate et du dernier
## palier de profondeur.
const DEPTH_UNBOUNDED: float = GenerationSettings.DEPTH_UNBOUNDED
const KEY_CAMERA_ZOOM: String = DrillSettings.KEY_CAMERA_ZOOM

## Blocs et champs cités par les messages d'erreur de `CameraSystem` (story
## 5.14) : zoom dans le bloc `camera` de `drill.json`, dimensions de carte, en
## tuiles, dans le bloc `monde` de `generation.json`.
const ROOT_CAMERA: String = DrillSettings.ROOT_CAMERA
const ROOT_WORLD: String = GenerationSettings.ROOT_WORLD
const KEY_MAP_WIDTH: String = GenerationSettings.KEY_MAP_WIDTH
const KEY_MAP_SURFACE: String = GenerationSettings.KEY_MAP_SURFACE
const KEY_MAP_DEPTH: String = GenerationSettings.KEY_MAP_DEPTH

# --- Chargeurs ----------------------------------------------------------------

## Journal unique des anomalies, partagé par tous les chargeurs : son ordre est
## celui du chargement.
var _validator: DataValidator = DataValidator.new()
var _resources: ResourceCatalog = ResourceCatalog.new(_validator)
var _upgrades: UpgradeCatalog = UpgradeCatalog.new(_validator)
var _events: EventCatalog = EventCatalog.new(_validator)
var _drill: DrillSettings = DrillSettings.new(_validator)
var _generation: GenerationSettings = GenerationSettings.new(_validator, _resources, _drill)


func _init() -> void:
	_load_all()


## Trace de chargement exigée par le cas de test `TM-1.8` (« les JSON de `data/`
## sont chargés sans erreur de parsing ; le nombre d'entrées est loggé »). Ce
## n'est pas un `print()` de debug oublié : c'est la seule sortie observable qui
## permette au testeur humain de constater le chargement au lancement du jeu.
func _ready() -> void:
	print(get_load_summary())


## Ordre imposé : `generation.json` se valide contre le catalogue des ressources
## (minerais connus et actifs) et convertit ses tuiles avec `drill.json`.
func _load_all() -> void:
	_resources.load_file()
	_upgrades.load_file()
	_events.load_file()
	_drill.load_file()
	_generation.load_file()


# --- État du chargement -------------------------------------------------------

## Vrai si les fichiers ont été lus sans la moindre anomalie. Faux impose de
## considérer le catalogue comme incomplet : aucune valeur de repli n'a été
## substituée aux données rejetées.
func is_valid() -> bool:
	return not _validator.has_errors()


func get_errors() -> PackedStringArray:
	return _validator.get_errors()


func get_load_summary() -> String:
	return "GameData — ressources : %d (%d actives MVP) · améliorations : %d (%d actives MVP) · événements : %d (%d actifs MVP) · physique foreuse : %d champs · carburant : %d champs · blindage : %d · caméra : %d · forage : %d · retour : %d · messages : %d · monde : %d tuiles · ancrages : %d · strates : %d · paliers : %d · loot : %d entrées · erreurs : %d" % [
		_resources.get_resource_ids().size(), _resources.get_mvp_resource_ids().size(),
		_upgrades.get_upgrade_ids().size(), _upgrades.get_mvp_upgrade_ids().size(),
		_events.get_event_ids().size(), _events.get_mvp_event_ids().size(),
		_drill.get_block_field_count(DrillSettings.ROOT_PHYSICS),
		_drill.get_block_field_count(DrillSettings.ROOT_FUEL),
		_drill.get_block_field_count(DrillSettings.ROOT_ARMOR),
		_drill.get_block_field_count(DrillSettings.ROOT_CAMERA),
		_drill.get_block_field_count(DrillSettings.ROOT_DRILLING),
		_drill.get_block_field_count(DrillSettings.ROOT_FEEDBACK),
		_drill.get_block_field_count(DrillSettings.ROOT_MESSAGES),
		_generation.get_map_field_count(),
		_generation.get_anchor_field_count(),
		_generation.get_strata_count(),
		_generation.get_depth_layer_count(),
		_generation.get_loot_entry_ids().size(),
		_validator.get_error_count(),
	]


# --- Ressources ---------------------------------------------------------------

func has_resource(resource_id: String) -> bool:
	return _resources.has_resource(resource_id)


## Copie profonde : le catalogue est immuable pour ses lecteurs. Les accesseurs
## scalaires ci-dessous sont à préférer dans les chemins chauds (forage, HUD).
func get_resource(resource_id: String) -> Dictionary:
	return _resources.get_resource(resource_id)


func get_resource_ids() -> Array[String]:
	return _resources.get_resource_ids()


## Ressources que le générateur de terrain (story 3.2) a le droit de placer au
## MVP. Les autres sont décrites mais ne doivent jamais apparaître (Q12).
func get_mvp_resource_ids() -> Array[String]:
	return _resources.get_mvp_resource_ids()


func is_resource_active_in_mvp(resource_id: String) -> bool:
	return _resources.is_resource_active_in_mvp(resource_id)


func get_resource_name(resource_id: String) -> String:
	return _resources.get_resource_name(resource_id)


## Prix de vente unitaire, en crédits impériaux — donnée de tuile `value`.
func get_resource_value(resource_id: String) -> int:
	return _resources.get_resource_value(resource_id)


## Dureté de la tuile portant ce minerai — donnée de tuile `hardness`.
func get_resource_hardness(resource_id: String) -> int:
	return _resources.get_resource_hardness(resource_id)


## Unités de soute consommées par une unité extraite.
func get_resource_mass(resource_id: String) -> int:
	return _resources.get_resource_mass(resource_id)


## Danger associé — donnée de tuile `hazard_type`, vide si aucun.
func get_resource_hazard_type(resource_id: String) -> String:
	return _resources.get_resource_hazard_type(resource_id)


# --- Améliorations ------------------------------------------------------------

func has_upgrade(upgrade_id: String) -> bool:
	return _upgrades.has_upgrade(upgrade_id)


func get_upgrade(upgrade_id: String) -> Dictionary:
	return _upgrades.get_upgrade(upgrade_id)


func get_upgrade_ids() -> Array[String]:
	return _upgrades.get_upgrade_ids()


## Les améliorations proposées par la boutique du MVP — « MVP jouable » point 6.
func get_mvp_upgrade_ids() -> Array[String]:
	return _upgrades.get_mvp_upgrade_ids()


func is_upgrade_active_in_mvp(upgrade_id: String) -> bool:
	return _upgrades.is_upgrade_active_in_mvp(upgrade_id)


func get_upgrade_name(upgrade_id: String) -> String:
	return _upgrades.get_upgrade_name(upgrade_id)


func get_upgrade_description(upgrade_id: String) -> String:
	return _upgrades.get_upgrade_description(upgrade_id)


## Statistique pilotée par l'amélioration (`STAT_*`).
func get_upgrade_statistic(upgrade_id: String) -> String:
	return _upgrades.get_upgrade_statistic(upgrade_id)


## Niveau de départ d'une nouvelle partie (statut de départ du CDC, coût nul) :
## le niveau 1 pour toute amélioration (story 5.6, `Q57`).
func get_upgrade_start_level(upgrade_id: String) -> int:
	return _upgrades.get_upgrade_start_level(upgrade_id)


## Effet chiffré du niveau `level`, pour **tout** niveau ≥ 1 : aucune borne
## supérieure (story 5.6, `Q18`, `Q58` (a) — `valeur_depart + increment ×
## (level − 1)`). `0.0` et erreur pour un `id` inconnu ou un niveau < 1.
func get_upgrade_value(upgrade_id: String, level: int) -> float:
	return _upgrades.get_upgrade_value(upgrade_id, level)


## Coût, en crédits impériaux, de l'achat du niveau **suivant** depuis le niveau
## courant `current_level` (≥ 1, sans borne supérieure) : `base ×
## facteur^current_level`, arrondi à l'entier, saturé à 2^53 (story 5.6, `Q18`,
## `Q57` (b) ; règle détaillée dans `UpgradeCatalog.gd`). Le niveau 1 lui-même
## n'a pas de coût : c'est le statut de départ, non achetable. C'est **ce**
## montant que la boutique affiche et débite (`L3`). Erreur et coût saturé —
## jamais 0 — pour un `id` inconnu ou un niveau < 1.
func get_upgrade_next_cost(upgrade_id: String, current_level: int) -> int:
	return _upgrades.get_upgrade_next_cost(upgrade_id, current_level)


## Valeur de départ d'une statistique : effet du niveau de départ de
## l'amélioration qui la pilote. Source unique de vérité des valeurs initiales de
## `GameState` — aucun chiffre n'est recopié dans le code (Q13).
func get_start_stat(statistic_id: String) -> float:
	return _upgrades.get_start_stat(statistic_id)


## Amélioration qui pilote une statistique (`STAT_*`). Permet à un système de
## lire la valeur **courante** d'une statistique — effet du niveau atteint dans
## `GameState` — sans connaître l'`id` de l'amélioration (story 3.4 : puissance du
## foret). Chaîne vide et erreur si aucune amélioration ne la pilote.
func get_upgrade_id_for_statistic(statistic_id: String) -> String:
	return _upgrades.get_upgrade_id_for_statistic(statistic_id)


## Crédits impériaux au début d'une partie.
func get_start_credits() -> int:
	return _upgrades.get_start_credits()


# --- Services de la station ---------------------------------------------------
# Story 5.3 (`Q56`, `Q63`) : bloc `station` de `data/upgrades.json`. Faux si le
# bloc a été rejeté : `EconomySystem` refuse alors plein et réparation.

func has_station_services() -> bool:
	return _upgrades.has_station_services()


## Crédits par unité de carburant (entier ≥ 1).
func get_fuel_unit_price() -> int:
	return _upgrades.get_fuel_unit_price()


## Crédits par point de blindage (entier ≥ 1).
func get_armor_point_price() -> int:
	return _upgrades.get_armor_point_price()


## Seuil du ravitaillement de secours gratuit, en fraction du réservoir courant.
func get_rescue_fuel_ratio() -> float:
	return _upgrades.get_rescue_fuel_ratio()


# --- Physique de la foreuse ---------------------------------------------------
# Story 2.2. Un accesseur nommé par paramètre : le script de la foreuse ne connaît
# aucune clé JSON, et un champ manquant se signale au chargement, pas au premier
# appel dans `_physics_process()`.

## Vrai si le bloc de physique a été chargé en entier. Faux impose de considérer
## la foreuse comme non paramétrée : aucun chiffre n'a été inventé à la place.
func has_drill_physics() -> bool:
	return _drill.has_physics()


## Accélération de la pesanteur, en px/s².
func get_drill_gravity() -> float:
	return _drill.get_physics_value(DrillSettings.KEY_GRAVITY)


## Accélération horizontale sous poussée, en px/s².
func get_drill_horizontal_acceleration() -> float:
	return _drill.get_physics_value(DrillSettings.KEY_H_ACCELERATION)


## Décélération horizontale touches relâchées, en px/s² — c'est elle qui donne
## l'inertie : plus elle est faible, plus la foreuse glisse.
func get_drill_horizontal_friction() -> float:
	return _drill.get_physics_value(DrillSettings.KEY_H_FRICTION)


## Vitesse horizontale maximale, en px/s.
func get_drill_horizontal_max_speed() -> float:
	return _drill.get_physics_value(DrillSettings.KEY_H_MAX_SPEED)


## Poussée des propulseurs, en px/s². Doit excéder la gravité pour que la
## foreuse monte réellement — le cas contraire se constate à l'écran, il n'est
## pas contrôlable au chargement sans réimplanter la physique.
func get_drill_thrust() -> float:
	return _drill.get_physics_value(DrillSettings.KEY_THRUST)


## Accélération ajoutée vers le bas sur `move_down`, en px/s².
func get_drill_descent_acceleration() -> float:
	return _drill.get_physics_value(DrillSettings.KEY_DESCENT_ACCELERATION)


## Vitesse de montée maximale, en px/s.
func get_drill_max_rise_speed() -> float:
	return _drill.get_physics_value(DrillSettings.KEY_MAX_RISE_SPEED)


## Vitesse de chute maximale, en px/s.
func get_drill_max_fall_speed() -> float:
	return _drill.get_physics_value(DrillSettings.KEY_MAX_FALL_SPEED)


## Facteur de freinage, dans `]0, 1]` : il multiplie les vitesses maximales et
## divise la friction, de sorte qu'une seule valeur règle « moins vite » et
## « s'arrête plus court » (CDC : « réduit la vitesse et l'inertie »).
func get_drill_brake_factor() -> float:
	return _drill.get_physics_value(DrillSettings.KEY_BRAKE_FACTOR)


## Pixels par mètre : convertit une position monde en profondeur affichable.
## **Verrouillé à 32 par la story 3.1** (décision utilisateur du 2026-09-27) :
## 1 tuile = 1 m = 32 px, égale à `TileSet.tile_size.x`, égalité vérifiée par
## assertion. ⚠️ La changer exigerait de recalculer **ensemble** cette valeur, les
## bords de carte, la conversion profondeur → mètres et les repères de la courbe
## de risque du §4.2 de l'amendement.
func get_pixels_per_meter() -> float:
	return _drill.get_physics_value(DrillSettings.KEY_PIXELS_PER_METER)


# --- Carburant de la foreuse --------------------------------------------------
# Story 2.3. La capacité du réservoir n'est **pas** ici : c'est la statistique
# `carburant_max` de l'amélioration `reacteur` (`get_start_stat()`).

## Vrai si le bloc `carburant` a été chargé en entier.
func has_drill_fuel() -> bool:
	return _drill.has_fuel()


## Carburant consommé par seconde de poussée, en plus de la consommation au repos.
func get_fuel_thrust_consumption() -> float:
	return _drill.get_fuel_value(DrillSettings.KEY_FUEL_THRUST_PER_S)


## Carburant consommé par seconde, moteur en marche, sans poussée. Peut valoir 0.
func get_fuel_idle_consumption() -> float:
	return _drill.get_fuel_value(DrillSettings.KEY_FUEL_IDLE_PER_S)


## Fraction du réservoir sous laquelle l'alerte « carburant bas » est émise.
func get_fuel_low_ratio() -> float:
	return _drill.get_fuel_value(DrillSettings.KEY_FUEL_LOW_RATIO)


## Carburant prélevé à chaque tuile détruite par le foret (story 3.4).
func get_fuel_per_drilled_tile() -> float:
	return _drill.get_fuel_value(DrillSettings.KEY_FUEL_PER_DRILLED_TILE)


# --- Forage, retour audiovisuel, messages de bord -----------------------------
# Story 3.4 : durée seulement, la puissance est une statistique d'amélioration.

func has_drilling_settings() -> bool:
	return _drill.has_drilling()


func has_feedback_settings() -> bool:
	return _drill.has_feedback()


## Durée, en secondes, de visibilité du retour d'une rareté haute (story 3.7).
func get_jackpot_duration() -> float:
	return _drill.get_jackpot_duration()


func has_message_settings() -> bool:
	return _drill.has_messages()


## Durée, en secondes, d'affichage d'un message transitoire de bord (story 4.2).
func get_message_duration() -> float:
	return _drill.get_message_duration()


## Nombre de messages transitoires affichés ensemble (story 4.2).
func get_message_max() -> int:
	return _drill.get_message_max()


## Durée, en secondes, du forage d'une tuile de cette dureté par un foret de cette
## puissance (story 5.6, `Q59` (b)) : durée de la story 3.4 tant que la puissance
## ne dépasse pas `get_max_drillable_hardness()`, raccourcie par l'excédent
## au-delà — strictement décroissante, strictement positive, sans plancher. Forme
## et paramètre : `DrillSettings.get_drilling_duration_for_power()` et bloc
## `forage` de `data/drill.json`. N'autorise aucun forage : la comparaison
## puissance / dureté reste celle de `MiningSystem` (`Q31`). Consommée par
## `MiningSystem` à partir de la story 5.5. **Seule durée de forage exposée par
## la façade** : celle de la story 3.4, qui ignore la puissance, reste interne à
## `DrillSettings` (story 5.15, `B6`) — aucun appelant ne peut contourner `Q59` (b).
func get_drilling_duration_for_power(hardness: int, drill_power: float) -> float:
	return _drill.get_drilling_duration_for_power(hardness, drill_power, _generation.get_max_drillable_hardness())


## Dureté maximale forable du terrain, **dérivée des données** (strates de
## `data/generation.json` et minerais actifs au MVP de `data/resources.json`,
## ceinture indestructible exclue) — story 5.6.
func get_max_drillable_hardness() -> int:
	return _generation.get_max_drillable_hardness()


# --- Dégâts d'impact ----------------------------------------------------------
# Story 2.5. Le franchissement du seuil et le coût par px/s sont les deux seuls
# réglages de sévérité.

func has_armor_settings() -> bool:
	return _drill.has_armor()


## Vitesse de choc, en px/s, en deçà de laquelle aucun dégât n'est infligé.
func get_armor_impact_threshold() -> float:
	return _drill.get_armor_value(DrillSettings.KEY_ARMOR_IMPACT_THRESHOLD)


## Points de blindage perdus par px/s de vitesse **au-delà** du seuil.
func get_armor_damage_per_speed() -> float:
	return _drill.get_armor_value(DrillSettings.KEY_ARMOR_DAMAGE_PER_SPEED)


## Fraction de blindage sous laquelle l'alerte « blindage faible » est émise.
func get_armor_low_ratio() -> float:
	return _drill.get_armor_value(DrillSettings.KEY_ARMOR_LOW_RATIO)


## Durée, en secondes, de la transition d'état à blindage nul.
func get_armor_destruction_duration() -> float:
	return _drill.get_armor_value(DrillSettings.KEY_ARMOR_DESTRUCTION_DURATION)


# --- Caméra et bords de carte -------------------------------------------------

func has_camera_settings() -> bool:
	return _drill.has_camera()


## Vitesse d'amortissement du suivi (`position_smoothing_speed`).
func get_camera_smoothing() -> float:
	return _drill.get_camera_value(DrillSettings.KEY_CAMERA_SMOOTHING)


## Facteur de zoom appliqué aux deux axes : au-delà de 1, la vue se rapproche.
func get_camera_zoom() -> float:
	return _drill.get_camera_value(DrillSettings.KEY_CAMERA_ZOOM)


func has_world_bounds() -> bool:
	return _generation.has_world_bounds()


## Bords de carte sous forme de rectangle monde, coin haut-gauche en `position`.
## Rendre les quatre bords d'un bloc évite qu'un appelant n'en oublie un.
##
## **Signature inchangée depuis la story 2.4** : les quatre bords ne sont plus lus
## en pixels, ils sont **dérivés** des dimensions en tuiles de
## `data/generation.json` (story 3.2). Le générateur et le confinement ne peuvent
## donc plus décrire deux cartes différentes : contrainte dérivée de Q24, refermée
## **par construction**. `y = 0` est la ligne de surface ; la carte est centrée
## en `x`.
func get_world_bounds() -> Rect2:
	return _generation.get_world_bounds()


# --- Dimensions et paramètres de génération ------------------------------------
# Story 3.2. Tout est exprimé **en tuiles** : le générateur travaille en cellules,
# et les pixels ne sont qu'une vue dérivée pour la caméra et la physique.

func has_generation_settings() -> bool:
	return _generation.has_generation_settings()


## Graine de génération. **Forçable** : changer la valeur dans les données suffit,
## et c'est ce que le prérequis `P4` du plan de tests exige d'une campagne.
func get_generation_seed() -> int:
	return _generation.get_generation_seed()


## Largeur de la carte en tuiles, ceintures **comprises**.
func get_map_width_tiles() -> int:
	return _generation.get_map_value(GenerationSettings.KEY_MAP_WIDTH)


## Hauteur de la bande libre au-dessus de la surface, en tuiles.
func get_map_surface_tiles() -> int:
	return _generation.get_map_value(GenerationSettings.KEY_MAP_SURFACE)


## Nombre de rangées **creusables**, de la surface (`y = 0`) au-dessus de la ceinture.
func get_map_depth_tiles() -> int:
	return _generation.get_map_value(GenerationSettings.KEY_MAP_DEPTH)


## Épaisseur de la ceinture indestructible, en tuiles.
func get_map_belt_tiles() -> int:
	return _generation.get_map_value(GenerationSettings.KEY_MAP_BELT)


## Profondeur en mètres du centre d'une rangée de tuiles : 1 tuile = 1 m
## (verrouillé par la story 3.1), rangée 0 sous la surface. Source unique de cette
## conversion pour le générateur (strates, minerai) et le tirage de loot.
func get_row_depth_m(row: int) -> float:
	return float(row) + 0.5


# --- Table de loot (story 3.6) ---------------------------------------------------

func has_loot_table() -> bool:
	return _generation.has_loot_table()


## Entrées de la table, dans l'ordre déclaré (ordre de cumul du tirage).
func get_loot_entry_ids() -> Array[String]:
	return _generation.get_loot_entry_ids()


## Ressource d'une entrée ; chaîne vide pour « Rien ».
func get_loot_entry_resource(entry_id: String) -> String:
	return _generation.get_loot_entry_resource(entry_id)


## L'entrée est-elle une rareté haute, qui déclenche le retour « jackpot » du
## §2.4 (`Q35`) ? Lu en données, jamais en dur.
func is_loot_entry_high_rarity(entry_id: String) -> bool:
	return _generation.is_loot_entry_high_rarity(entry_id)


## Poids du palier, alignés sur `get_loot_entry_ids()`. Copie.
func get_loot_weights(layer_id: String) -> PackedFloat64Array:
	return _generation.get_loot_weights(layer_id)


# --- Ancrages, strates, paliers, densités ----------------------------------------

func has_anchors() -> bool:
	return _generation.has_anchors()


## Point de contact au sol du point d'apparition, en pixels monde : centre de la
## colonne `apparition_colonne`, sur la ligne de surface (`y = 0`). **Indépendant
## de la graine** (critère 5 de la story 3.3) : la rangée 0 est toujours pleine,
## le générateur ne laissant aucun vide sous la surface. La foreuse se pose en
## retranchant sa propre demi-hauteur, qu'elle seule connaît.
func get_spawn_ground_position() -> Vector2:
	return _generation.get_spawn_ground_position()


## Zone de surface en pixels monde (story 5.1) : colonnes
## `zone_surface_colonne_min` à `zone_surface_colonne_max` incluses, du haut de la
## carte jusqu'à la ligne de surface exclue. **Indépendante de la graine** (`K3`) :
## la foreuse y est « en surface » — et la station accessible — quand son centre
## s'y trouve.
func get_surface_zone_rect() -> Rect2:
	return _generation.get_surface_zone_rect()


## Point de pose de la station, en pixels monde : milieu de la zone de surface,
## sur la ligne de surface. Dérivé des ancrages, sans coordonnée propre.
func get_station_ground_position() -> Vector2:
	return _generation.get_station_ground_position()


## Cellule de l'anomalie scénarisée, en coordonnées de tuile. **Marqueur seul** au
## sprint 3 : le générateur n'y pose jamais de minerai (`Q28` : la tuile décide).
## L'anomalie réelle est l'objet de la story 6.4.
func get_anomaly_cell() -> Vector2i:
	return _generation.get_anomaly_cell()


## Strates de terrain, de la surface vers le fond. Copie défensive : le catalogue
## reste immuable pour ses lecteurs.
func get_strata() -> Array[Dictionary]:
	return _generation.get_strata()


## Identifiant du palier contenant cette profondeur. Chaîne vide si aucun — ce qui
## ne peut arriver que sur une profondeur négative, les paliers étant contigus et
## le dernier non borné.
func get_depth_layer_at(depth_m: float) -> String:
	return _generation.get_depth_layer_at(depth_m)


## Probabilité qu'une case de ce palier porte ce minerai. `0.0` pour un minerai non
## déclaré sur ce palier : c'est une absence légitime, pas une erreur — un minerai
## profond n'a pas à figurer en surface.
func get_ore_density(layer_id: String, resource_id: String) -> float:
	return _generation.get_ore_density(layer_id, resource_id)


## Densités d'un palier, dans l'ordre de déclaration du catalogue de ressources —
## c'est cet ordre qui rend le tirage du générateur **reproductible**.
func get_ore_densities(layer_id: String) -> Dictionary[String, float]:
	return _generation.get_ore_densities(layer_id)


# --- Événements narratifs -----------------------------------------------------
# La façade reste volontairement générique : la structure d'un événement n'est
# figée qu'en phase 6 (stories 6.2 à 6.4).

func has_event(event_id: String) -> bool:
	return _events.has_event(event_id)


func get_event(event_id: String) -> Dictionary:
	return _events.get_event(event_id)


func get_event_ids() -> Array[String]:
	return _events.get_event_ids()


func get_mvp_event_ids() -> Array[String]:
	return _events.get_mvp_event_ids()
