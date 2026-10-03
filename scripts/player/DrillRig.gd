extends CharacterBody2D
class_name DrillRig

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
## [br]— **Type nommé** (`class_name`, story 4.2) : le HUD reçoit la foreuse par
## injection de scène (`Q38`) et s'abonne aux signaux de ses composants, qu'il
## obtient par les accesseurs `get_*_system()` ci-dessous.

## Émis après un rapatriement au point d'apparition (story 6.7) : la position a
## sauté sans déplacement physique. `CameraSystem` s'y recale sans travelling.
signal relocated()

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

# --- Sons d'alerte (story 4.2, arbitrage Q45) ---------------------------------
# Un flux par alerte, joué par le **seul** lecteur `Audio/AlertAudio` dont on
# change le flux : l'arbre de `DrillRig.tscn` reste figé à 11 nœuds (story 2.1,
# `TM-2.11`). Les flux sont **renseignés dans la scène** et chargés avec elle
# (`H6`) : aucun chemin de son dans ce script. Remplacer un son = remplacer le
# fichier `assets/audio/sfx_*.wav` du même nom, sans toucher au code.

@export var fuel_low_sound: AudioStream
@export var fuel_depleted_sound: AudioStream
@export var armor_low_sound: AudioStream
@export var cargo_full_sound: AudioStream
@export var drill_refused_sound: AudioStream
@export var destruction_sound: AudioStream

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
## Courbe de risque (story 6.6). Objet et non nœud, pour la même raison ; la
## logique de menace vit dans `ThreatSystem`, la foreuse ne fait que le brancher.
## **Public en lecture** : son signal `threat_encountered` est destiné au HUD.
var threat_system: ThreatSystem = ThreatSystem.new()
## Conséquence des échecs (story 6.7). Objet et non nœud, pour la même raison ;
## la règle (déclencheurs, perte, retour) vit dans `RecoverySystem`, la foreuse
## ne fait que le brancher, avancer son délai et se replacer sur `recovered`.
## **Public en lecture** : son signal `recovered` est destiné au HUD.
var recovery_system: RecoverySystem = RecoverySystem.new()
@onready var _alert_audio: AudioStreamPlayer2D = $Audio/AlertAudio
@onready var _drill_audio: AudioStreamPlayer2D = $Audio/DrillAudio
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

# --- Bords de carte et détection de choc --------------------------------------
# Story 2.5. Relevés une fois : ni les bords ni l'empreinte de la foreuse ne
# changent en cours de partie.

var _world_bounds: Rect2 = Rect2()
var _half_extents: Vector2 = Vector2.ZERO
## Zone de surface des ancrages (story 5.1), en pixels monde. Vide sans ancrage
## chargé : la foreuse n'est alors jamais « en surface » — `_place_at_spawn()` a
## déjà signalé l'absence d'ancrages.
var _surface_zone: Rect2 = Rect2()
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
	_fuel_system.fuel_low_cleared.connect(_on_fuel_low_cleared)
	_armor_system.armor_low.connect(_on_armor_low)
	_armor_system.destruction_started.connect(_on_destruction_started)
	_armor_system.destruction_finished.connect(_on_destruction_finished)
	_check_alert_sounds()
	_setup_drilling()
	if recovery_system.setup(_fuel_system, _armor_system, cargo_system):
		recovery_system.recovered.connect(_on_recovered)
	_world_bounds = GameData.get_world_bounds()
	_half_extents = _read_half_extents()
	_place_at_spawn()
	_surface_zone = GameData.get_surface_zone_rect() if GameData.has_anchors() else Rect2()
	_publish_state()


## Composants exposés au HUD (story 4.2) pour qu'il s'abonne à leurs signaux :
## requête synchrone sur un type nommé, référence injectée par la scène — les
## trois conditions de la précision `Q38` de `C3`. Aucune notification ne passe
## par ces accesseurs.
func get_fuel_system() -> FuelSystem:
	return _fuel_system


func get_armor_system() -> ArmorSystem:
	return _armor_system


func get_drill_system() -> MiningSystem:
	return _drill_system


## Un flux absent rendrait l'alerte **muette** sans erreur — `play()` sans flux
## est un no-op silencieux (mesuré en story 2.3). On le dit donc au démarrage.
func _check_alert_sounds() -> void:
	var sounds: Dictionary[String, AudioStream] = {
		"fuel_low_sound": fuel_low_sound,
		"fuel_depleted_sound": fuel_depleted_sound,
		"armor_low_sound": armor_low_sound,
		"cargo_full_sound": cargo_full_sound,
		"drill_refused_sound": drill_refused_sound,
		"destruction_sound": destruction_sound,
	}
	for property: String in sounds:
		if sounds[property] == null:
			push_error("DrillRig — son d'alerte « %s » non renseigné dans la scène : alerte muette." % property)


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
	# Après la publication : le délai de panne sèche juge la zone de surface de
	# cette image (story 6.7).
	recovery_system.tick(delta)


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
	# Branché **après** la soute : la tuile est collectée avant que la menace ne
	# frappe, ce que la perte de cargo de la story 6.7 suppose.
	if threat_system.setup(_armor_system):
		_drill_system.tile_drilled.connect(threat_system.on_tile_drilled)
		feedback.bind_threats(threat_system)


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


## Alerte « soute pleine » (CDC « Direction sonore », `Q5`) : son propre. Son
## affichage est porté par le HUD (story 4.2), abonné au même signal.
func _on_cargo_full() -> void:
	_play_alert(cargo_full_sound)


## Retour explicite d'un forage refusé (critère 5 de la story 3.4, `TM-3.5`) :
## émis une fois par tuile visée, jamais à chaque frame. Son court et sourd,
## distinct des alertes ; le motif est affiché par le HUD (story 4.2, `E20`).
func _on_drill_refused(_cell: Vector2i, _reason: MiningSystem.RefusalReason) -> void:
	_play_alert(drill_refused_sound)


## Retours d'alerte. `AlertAudio` appartient à la foreuse, pas au composant :
## `FuelSystem` signale, `DrillRig` sonne, le HUD affiche (story 4.2) — trois
## abonnés distincts au même signal, rien de dupliqué. Chaque alerte a **son**
## flux (`E21`, `Q45`) ; un seul lecteur, donc la plus récente l'emporte.
func _on_fuel_low(_ratio: float) -> void:
	_play_alert(fuel_low_sound)


func _on_fuel_depleted() -> void:
	_play_alert(fuel_depleted_sound)


## Le ravitaillement (story 5.3) coupe une alerte **carburant** encore en
## cours : le joueur ne doit pas entendre une panne qu'il vient de résoudre.
## Une autre alerte (soute pleine, blindage faible…) partage le même lecteur et
## **n'est pas interrompue** — point hérité de l'audit `4.5`, qui relevait un
## `stop()` inconditionnel. Vaut à la sortie de panne sèche comme au retour
## au-dessus du seuil de carburant bas.
func _on_fuel_restored() -> void:
	_stop_fuel_alert()


func _on_fuel_low_cleared() -> void:
	_stop_fuel_alert()


## Le flux courant du lecteur dit quelle alerte joue : seule une alerte de
## carburant est coupée.
func _stop_fuel_alert() -> void:
	if _alert_audio.stream == fuel_low_sound or _alert_audio.stream == fuel_depleted_sound:
		_alert_audio.stop()


func _on_armor_low(_ratio: float) -> void:
	_play_alert(armor_low_sound)


## Entrée en destruction : les commandes cessent d'être lues et l'alerte sonne.
## Couper l'élan horizontal rend l'état lisible — la foreuse ne continue pas sa
## course comme si rien n'était arrivé.
func _on_destruction_started() -> void:
	velocity.x = 0.0
	_play_alert(destruction_sound)


## Sortie de destruction : l'alerte se tait, le pilotage reprend du seul fait que
## `can_act()` redevient vrai. La conséquence (perte, retour) suit dans le même
## appel, par `RecoverySystem.recovered` (story 6.7).
func _on_destruction_finished() -> void:
	_alert_audio.stop()


## Rapatriement (story 6.7, critère 4) : la foreuse est replacée au point
## d'apparition dérivé des ancrages (`K3`), vitesse nulle, posée au sol, forage
## et alignement abandonnés ; l'état est republié à la même image et la caméra
## se recale (`relocated`). La perte, le blindage et le carburant sont déjà
## traités par `RecoverySystem` : ici, seulement la position.
func _on_recovered(_cause: RecoverySystem.Cause, _lost: Dictionary[String, int]) -> void:
	_aligning = false
	_drill_audio.stop()
	_place_at_spawn()
	# Posée : l'image suivante ne doit pas compter un « atterrissage ».
	_was_grounded = true
	_publish_state()
	relocated.emit()


## Change le flux du lecteur d'alerte puis le joue : un son interrompt le
## précédent au lieu de s'y superposer.
func _play_alert(sound: AudioStream) -> void:
	_alert_audio.stream = sound
	_alert_audio.play()


## Publication de l'état vers `GameState` (`C3`) : aucun nœud n'est appelé
## directement. La profondeur est une grandeur d'affichage en mètres, nulle en
## surface et croissante vers le bas (`y` positif) ; la position en pixels, elle,
## sert à restituer la partie en phase 7. La présence en zone de surface (story
## 5.1) est jugée sur le **centre** de la foreuse : posée sur la rangée 0, il est
## au-dessus de la ligne de surface ; dès qu'elle s'enfonce de plus d'une
## demi-hauteur, elle est sous terre et la station n'est plus accessible.
func _publish_state() -> void:
	GameState.set_drill_position(global_position)
	GameState.set_depth_m(maxf(global_position.y, 0.0) / _pixels_per_meter)
	GameState.set_in_surface_zone(_surface_zone.has_point(global_position))
	GameState.set_drill_operational(_armor_system.can_act())
