extends CharacterBody2D

## Foreuse pilotable — story 2.2.
##
## Porte **la physique de déplacement** et rien d'autre : gravité, inertie,
## propulsion, descente, freinage, et annulation des directions opposées. Le
## forage appartient à `DrillSystem` (`MiningSystem`, story 3.4), la consommation
## de carburant à `FuelSystem` (story 2.3), les dégâts à `ArmorSystem` (story 2.5).
## La foreuse **branche** ces composants et réagit à leurs signaux : pendant un
## forage vers le bas, elle s'aligne sur la colonne forée pour pouvoir y
## descendre — c'est un déplacement, donc c'est ici.
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Aucune valeur de gameplay ici** (points d'audit `D1`/`D4`, arbitrage
## Q15) : tous les paramètres viennent de `data/drill.json`, via `GameData`. Les
## seules constantes de ce fichier sont des **noms d'action** de l'Input Map.
## [br]— **Aucune touche en dur** (`F1`) : aucun `KEY_*`, aucun `keycode`. Les
## actions sont celles déclarées dans `project.godot` (story 1.3).
## [br]— **Aucun `_input()`** (`F5 [B]`, arbitrage Q10). Le déplacement est une
## lecture **continue** : `Input.is_action_pressed()` / `Input.get_axis()` dans
## `_physics_process()`. Aucune **action ponctuelle** n'existe encore : le forage
## est lui aussi un appui maintenu (story 3.4). Il n'y a donc pas de
## `_unhandled_input()` à écrire — il serait vide, donc du code mort (`B6`).
## [br]— **Aucun chemin de nœud fragile** (`C1`/`C2`) : ce script ne connaît ni
## ses frères ni ses parents. Il ne référence que **ses propres enfants**, par
## chemin descendant `$Enfant` (`C2`), et publie son état par l'autoload
## `GameState` (`C3`). Le terrain, que le forage doit connaître, lui est donné
## par un **export de scène** renseigné dans `Main.tscn` — même procédé que la
## cible de `CameraSystem`.
## [br]— **Validation headless** : ce fichier référence les autoloads `GameData`
## et `GameState`. `--check-only` ne résout pas un identifiant d'autoload et
## signale un faux « Identifier not found » — exception bornée de la story `1.9`.

# --- Actions de l'Input Map ---------------------------------------------------
# Les noms des 12 actions du CDC (story 1.3). Ce sont des identifiants d'Input
# Map, jamais des touches : la disposition clavier reste réglable par le joueur
# sans toucher au code (point d'audit F1).

const ACTION_MOVE_LEFT: StringName = &"move_left"
const ACTION_MOVE_RIGHT: StringName = &"move_right"
const ACTION_MOVE_UP: StringName = &"move_up"
const ACTION_MOVE_DOWN: StringName = &"move_down"
const ACTION_BRAKE: StringName = &"brake"

## Scène d'effet du forage (story 3.7), préchargée (`H6`) et instanciée sous le
## monde au démarrage : elle ne fait partie d'aucun arbre contractuel.
const DRILL_FEEDBACK_SCENE: PackedScene = preload("res://scenes/world/DrillFeedback.tscn")

## Chemin du monde (`TerrainSystem`), renseigné dans `Main.tscn`. `NodePath` plutôt
## que nœud typé, pour la raison documentée dans `CameraSystem` : un `.tscn`
## rédigé à la main ne porte pas la table `node_paths`. Vide, le forage reste
## désactivé et le signale.
@export var terrain_path: NodePath

# --- Paramètres de physique ---------------------------------------------------
# Relevés une seule fois depuis `GameData` : `_physics_process()` est un chemin
# chaud et le catalogue est immuable pour ses lecteurs. Aucune de ces variables
# n'a de valeur par défaut porteuse de sens : sans données valides, le script
# désactive son traitement physique au lieu de faire rouler la foreuse sur des
# chiffres inventés.

var _gravity: float = 0.0
var _horizontal_acceleration: float = 0.0
var _horizontal_friction: float = 0.0
var _horizontal_max_speed: float = 0.0
var _thrust: float = 0.0
var _descent_acceleration: float = 0.0
var _max_rise_speed: float = 0.0
var _max_fall_speed: float = 0.0
var _brake_factor: float = 0.0
var _pixels_per_meter: float = 0.0

# --- Sous-systèmes de la foreuse ----------------------------------------------
# Chemins **descendants** vers ses propres enfants, la seule forme de référence
# de nœud autorisée par le point d'audit `C2`. La foreuse commande ses
# composants ; ce sont eux qui portent les règles de leur domaine (`B4`).

@onready var _fuel_system: FuelSystem = $FuelSystem
@onready var _armor_system: ArmorSystem = $ArmorSystem
@onready var _drill_system: MiningSystem = $DrillSystem

## Règle de soute (story 3.5). Objet et non nœud : l'arbre de `DrillRig.tscn` est
## figé à 11 nœuds (story 2.1). **Public en lecture** : ses signaux `cargo_full`,
## `ore_lost` et son compteur de perte sont destinés au HUD de la story 4.2 (`G10`).
var cargo_system: CargoSystem = CargoSystem.new()
@onready var _alert_audio: AudioStreamPlayer2D = $Audio/AlertAudio
@onready var _drill_audio: AudioStreamPlayer2D = $Audio/DrillAudio
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

# --- Bords de carte et détection de choc --------------------------------------
# Story 2.5. Relevés une fois : ni les bords ni l'empreinte de la foreuse ne
# changent en cours de partie.

var _world_bounds: Rect2 = Rect2()
var _half_extents: Vector2 = Vector2.ZERO
## Appui au sol à la frame précédente : c'est **le passage** de faux à vrai qui
## constitue un choc, pas le fait d'être posé.
var _was_grounded: bool = false
## Alignement horizontal pendant un forage vers le bas : la foreuse fait la
## largeur d'une tuile, elle ne descend dans le puits que centrée sur sa colonne.
var _aligning: bool = false
var _align_x: float = 0.0


## Si le bloc `physique` de `data/drill.json` a été rejeté au chargement,
## `GameData` a déjà signalé le champ fautif. La foreuse reste alors **inerte**,
## et le dit une fois : une panne franche est diagnosticable, un repli silencieux
## sur des valeurs par défaut ne l'est pas.
func _ready() -> void:
	if not GameData.has_drill_physics():
		push_error("DrillRig — physique non chargée depuis %s : foreuse inerte." % GameData.DRILL_PATH)
		set_physics_process(false)
		return
	_gravity = GameData.get_drill_gravity()
	_horizontal_acceleration = GameData.get_drill_horizontal_acceleration()
	_horizontal_friction = GameData.get_drill_horizontal_friction()
	_horizontal_max_speed = GameData.get_drill_horizontal_max_speed()
	_thrust = GameData.get_drill_thrust()
	_descent_acceleration = GameData.get_drill_descent_acceleration()
	_max_rise_speed = GameData.get_drill_max_rise_speed()
	_max_fall_speed = GameData.get_drill_max_fall_speed()
	_brake_factor = GameData.get_drill_brake_factor()
	_pixels_per_meter = GameData.get_pixels_per_meter()
	# Connexions par `Callable` (`C4`) : la foreuse est le seul consommateur des
	# signaux de ses composants, et le seul à posséder `AlertAudio`.
	_fuel_system.fuel_low.connect(_on_fuel_low)
	_fuel_system.fuel_depleted.connect(_on_fuel_depleted)
	_fuel_system.fuel_restored.connect(_on_fuel_restored)
	_armor_system.armor_low.connect(_on_armor_low)
	_armor_system.destruction_started.connect(_on_destruction_started)
	_armor_system.destruction_finished.connect(_on_destruction_finished)
	_setup_drilling()
	_world_bounds = GameData.get_world_bounds()
	_half_extents = _read_half_extents()
	_place_at_spawn()
	_publish_state()


## Pose la foreuse **sur le sol** du point d'apparition (story 3.3, critère 4) :
## contact au sol donné par `GameData`, moins la demi-hauteur de la foreuse. Aucune
## coordonnée en dur dans la scène ni ici (critère 6). Sans ancrage chargé, la
## foreuse reste où la scène l'a mise et l'erreur est signalée — jamais de
## position de repli inventée.
func _place_at_spawn() -> void:
	if not GameData.has_anchors():
		push_error("DrillRig — aucun point d'apparition chargé depuis %s : foreuse laissée à sa position de scène." % GameData.GENERATION_PATH)
		return
	global_position = GameData.get_spawn_ground_position() - Vector2(0.0, _half_extents.y)
	velocity = Vector2.ZERO


## Demi-empreinte de la foreuse, lue depuis **sa propre forme de collision** et
## non écrite en dur : c'est une donnée de structure de la scène (story 2.1), et
## la lire ici évite un nombre magique que `D4` relèverait.
func _read_half_extents() -> Vector2:
	var shape: Shape2D = _collision_shape.shape
	if shape is RectangleShape2D:
		return (shape as RectangleShape2D).size * 0.5
	push_error("DrillRig — forme de collision inattendue (%s) : confinement aux bords de carte désactivé." % shape)
	return Vector2.ZERO


func _physics_process(delta: float) -> void:
	# Pendant la transition de destruction, les commandes sont ignorées (`M4`) :
	# la foreuse n'est plus pilotable, mais la physique continue — elle finit sa
	# chute et se pose, au lieu de se figer en l'air.
	var controllable: bool = _armor_system.can_act()
	var braking: bool = controllable and Input.is_action_pressed(ACTION_BRAKE)
	_update_horizontal_velocity(delta, braking, controllable)
	_update_vertical_velocity(delta, braking, controllable)
	# Vitesse d'avant déplacement : c'est elle qui fait le choc. Après
	# `move_and_slide()` et le confinement, la composante verticale est déjà
	# retombée à zéro.
	var impact_speed: float = velocity.y
	move_and_slide()
	var grounded: bool = _contain_within_world() or is_on_floor()
	if grounded and not _was_grounded:
		_armor_system.apply_impact(impact_speed)
	_was_grounded = grounded
	_publish_state()


## Déplacement horizontal. `Input.get_axis()` soustrait les deux forces d'action :
## gauche et droite pressées ensemble donnent donc **exactement** zéro, et la
## foreuse retombe sur la branche « aucune direction commandée », qui décélère
## vers l'arrêt. L'annulation est arithmétique, pas arbitrée par une suite de
## `if` : c'est ce qui exclut toute oscillation (point d'audit `G3`, cas `TM-2.2`).
func _update_horizontal_velocity(delta: float, braking: bool, controllable: bool) -> void:
	if _aligning:
		# Vitesse qui rejoint la colonne en une frame, plafonnée à la vitesse
		# horizontale maximale : l'alignement n'est jamais plus rapide qu'un
		# déplacement ordinaire.
		velocity.x = clampf((_align_x - global_position.x) / delta, -_horizontal_max_speed, _horizontal_max_speed)
		return
	var direction: float = Input.get_axis(ACTION_MOVE_LEFT, ACTION_MOVE_RIGHT) if controllable else 0.0
	var max_speed: float = _horizontal_max_speed * _speed_scale(braking)
	if is_zero_approx(direction):
		# Décélération progressive : c'est elle qui rend l'inertie perceptible.
		velocity.x = move_toward(velocity.x, 0.0, _horizontal_friction * _friction_scale(braking) * delta)
		return
	velocity.x = move_toward(velocity.x, direction * max_speed, _horizontal_acceleration * delta)


## Déplacement vertical. La gravité s'applique **toujours** : elle n'est pas une
## direction commandée, et ne s'annule donc pas avec les touches. Haut et bas
## pressés ensemble ne produisent ni poussée ni descente forcée — au sol, la
## foreuse ne bouge pas ; en vol, elle continue de tomber, ce qui est le
## comportement attendu et non une oscillation.
func _update_vertical_velocity(delta: float, braking: bool, controllable: bool) -> void:
	var direction: float = Input.get_axis(ACTION_MOVE_UP, ACTION_MOVE_DOWN) if controllable else 0.0
	velocity.y += _gravity * delta
	if direction < 0.0 and _fuel_system.has_fuel():
		# Propulseurs : la poussée excède la gravité, d'où une montée réelle.
		# Sans carburant, la branche est simplement ignorée — la gravité, elle,
		# continue de s'appliquer : la foreuse en panne **chute encore** (`G4`).
		velocity.y -= _thrust * delta
		_fuel_system.consume_thrust(delta)
	elif direction > 0.0:
		velocity.y += _descent_acceleration * delta
	var scale: float = _speed_scale(braking)
	velocity.y = clampf(velocity.y, -_max_rise_speed * scale, _max_fall_speed * scale)


## Freiner réduit les vitesses maximales — y compris en chute, le CDC nommant
## l'action « Freiner/stabiliser ».
func _speed_scale(braking: bool) -> float:
	return _brake_factor if braking else 1.0


## ... et renforce la décélération dans la même proportion : le facteur étant
## dans `]0, 1]`, le diviser revient à freiner plus court. Une seule valeur de
## données règle donc « moins vite » et « s'arrête plus net ».
func _friction_scale(braking: bool) -> float:
	return 1.0 / _brake_factor if braking else 1.0


## Confinement aux bords de carte — CDC « Règles interdites ou limitées » :
## « aucune traversée d'un bord de carte ». Renvoie **vrai** si la foreuse repose
## sur le bord **bas**, qui tient lieu de sol tant qu'aucun terrain n'existe : la
## story 3.2 livrera des bordures indestructibles réelles et ce confinement
## deviendra une seconde barrière, pas la seule.
func _contain_within_world() -> bool:
	if _half_extents == Vector2.ZERO:
		return false
	var lower: Vector2 = _world_bounds.position + _half_extents
	var upper: Vector2 = _world_bounds.end - _half_extents
	var clamped: Vector2 = Vector2(
		clampf(global_position.x, lower.x, upper.x),
		clampf(global_position.y, lower.y, upper.y),
	)
	# Toucher un bord annule la vitesse sur cet axe seulement : glisser le long
	# d'une paroi reste possible, comme contre une tuile.
	if not is_equal_approx(clamped.x, global_position.x):
		velocity.x = 0.0
	if not is_equal_approx(clamped.y, global_position.y):
		velocity.y = 0.0
	global_position = clamped
	return is_equal_approx(clamped.y, upper.y)


## Branche le forage sur le terrain désigné par la scène. Sans terrain, la
## foreuse reste pilotable mais ne fore pas — panne visible, jamais silencieuse.
func _setup_drilling() -> void:
	var terrain: TerrainSystem = get_node_or_null(terrain_path) as TerrainSystem
	if terrain == null:
		push_error("DrillRig — terrain introuvable ou non TerrainSystem (« %s ») : forage désactivé." % terrain_path)
		return
	_drill_system.drilling_started.connect(_on_drilling_started)
	_drill_system.drilling_stopped.connect(_on_drilling_stopped)
	_drill_system.drill_refused.connect(_on_drill_refused)
	_drill_system.setup(self, _fuel_system, _armor_system, terrain)
	# Le retour visuel vit dans le monde, pas sur la foreuse : ajouté en différé,
	# `World` et `Main` finissant leur propre mise en place.
	var feedback: DrillFeedback = DRILL_FEEDBACK_SCENE.instantiate()
	feedback.bind(_drill_system)
	terrain.add_child.call_deferred(feedback)
	if cargo_system.setup():
		_drill_system.tile_drilled.connect(_on_tile_drilled)
		cargo_system.cargo_full.connect(_on_cargo_full)


## Le forage commence : la soute est consultée **avant** la destruction, pour que
## son alerte précède toute perte (`G9`).
func _on_drilling_started(_cell: Vector2i, direction: Vector2i, cell_center: Vector2, _duration: float, resource_id: String) -> void:
	cargo_system.on_drilling_started(resource_id)
	# Son de forage (story 3.7) : flux réel en boucle, `sfx_drill_loop.wav`.
	if not _drill_audio.playing:
		_drill_audio.play()
	if direction != MiningSystem.DIRECTION_DOWN:
		return
	_aligning = true
	_align_x = cell_center.x


func _on_drilling_stopped() -> void:
	_aligning = false
	_drill_audio.stop()


func _on_tile_drilled(_cell: Vector2i, resource_id: String) -> void:
	cargo_system.on_tile_drilled(resource_id)


## Alerte « soute pleine » (CDC « Direction sonore », `Q5`) : flux réel de
## `AlertAudio`. Son affichage est livré par la story 4.2.
func _on_cargo_full() -> void:
	_alert_audio.play()


## Retour explicite d'un forage refusé (critère 5 de la story 3.4, `TM-3.5`) :
## émis une fois par tuile visée, jamais à chaque frame. Le retour visuel et un
## son dédié sont l'objet de la story 3.7.
func _on_drill_refused(_cell: Vector2i, _reason: MiningSystem.RefusalReason) -> void:
	_alert_audio.play()


## Retours d'alerte. `AlertAudio` appartient à la foreuse, pas au composant :
## `FuelSystem` signale, `DrillRig` sonne. C'est ce qui permettra au HUD de la
## phase 4 de s'abonner aux mêmes signaux sans rien dupliquer.
func _on_fuel_low(_ratio: float) -> void:
	_alert_audio.play()


func _on_fuel_depleted() -> void:
	_alert_audio.play()


## Le ravitaillement (phase 5) coupe une alerte encore en cours : le joueur ne
## doit pas entendre une panne qu'il vient de résoudre.
func _on_fuel_restored() -> void:
	_alert_audio.stop()


func _on_armor_low(_ratio: float) -> void:
	_alert_audio.play()


## Entrée en destruction : les commandes cessent d'être lues et l'alerte sonne.
## Couper l'élan horizontal rend l'état lisible — la foreuse ne continue pas sa
## course comme si rien n'était arrivé.
func _on_destruction_started() -> void:
	velocity.x = 0.0
	_alert_audio.play()


## Sortie de destruction : l'alerte se tait, le pilotage reprend du seul fait que
## `can_act()` redevient vrai. Rien d'autre à défaire — l'état de destruction n'a
## touché aucune donnée persistante.
func _on_destruction_finished() -> void:
	_alert_audio.stop()


## Publication de l'état vers `GameState` (`C3`) : aucun nœud n'est appelé
## directement. La profondeur est une grandeur d'affichage en mètres, nulle en
## surface et croissante vers le bas (`y` positif) ; la position en pixels, elle,
## sert à restituer la partie en phase 7.
func _publish_state() -> void:
	GameState.set_drill_position(global_position)
	GameState.set_depth_m(maxf(global_position.y, 0.0) / _pixels_per_meter)
