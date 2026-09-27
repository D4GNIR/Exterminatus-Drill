extends Node
class_name MiningSystem

## Système de forage — stories 3.4 et 3.6.
##
## Porte **les règles de forage** du CDC (« Règles autorisées » / « Règles
## interdites ou limitées ») et rien d'autre (`B4`) : il décide **si** et **quand**
## une tuile est détruite, et le **signale**. Il ne déplace pas la foreuse (c'est
## `DrillRig`), ne connaît pas la jauge de carburant (c'est `FuelSystem`), ne sait
## pas lire une tuile (c'est `TerrainSystem`), et ne crédite rien : la collecte
## est l'objet de la story 3.5.
##
## **`Q28` — la tuile décide, et la source est déterminée AVANT la destruction**
## (story 3.6) : au **début** d'un forage, une tuile porteuse d'un `resource_id`
## donne ce minerai, **sans tirage** ; une tuile stérile donne le résultat du
## tirage de `LootSystem`. Les deux ne sont **jamais** appliqués à la même case.
## Le gain ainsi déterminé est porté par `drilling_started` puis `tile_drilled` :
## la soute le reçoit par son chemin unique, et peut alerter avant une perte.
##
## Ordre de contrôle, **opposable à l'audit** — interdits d'abord, faisabilité
## ensuite, destruction en dernier :
## [br]1. `G1` — **aucun forage vers le haut** : `move_up` maintenu annule toute
## demande (`_read_request()`), et aucune direction « haut » n'existe ici.
## [br]2. `G2` — **aucun forage dans le vide** : tout forage exige un sol solide
## sous la foreuse ; le forage latéral exige **en plus** le contact avec la paroi
## visée (`_is_supported_for()`).
## [br]3. `G4` — **aucun forage sans carburant** : l'information vient de
## `FuelSystem.has_fuel()`, jamais d'une notion de panne sèche réimplémentée ici.
## [br]4. `E3`/`G5` — cellule vide, hors carte ou indestructible : aucune destruction.
## [br]5. Puissance du foret contre `hardness` (critère 5).
## [br]6. Durée de forage liée à `hardness` (critère 9), puis destruction et coût
## en carburant (critère 4).
##
## Entrées **continues** (`Q10`, critère 8) : `Input.is_action_pressed()` lu en
## `_physics_process()`, comme le déplacement de la story 2.2. Aucun `_input()`,
## aucune touche en dur. Le forage est un appui **maintenu** (`TM-3.1`), pas une
## action ponctuelle.
##
## **Validation headless** : ce fichier référence les autoloads `GameData` et
## `GameState` — faux « Identifier not found » en `--check-only`, exception `1.9`.

## Pourquoi une demande de forage n'a pas abouti. Émis **une fois** par cellule
## visée tant que la demande persiste : c'est le « retour explicite » exigé par le
## critère 5 (`TM-3.5`), sans répétition à chaque frame.
enum RefusalReason { NO_FUEL, INDESTRUCTIBLE, TOO_HARD }

## Un forage commence : `cell` est visée, `cell_center` est son centre monde (la
## foreuse s'y aligne pour un forage vers le bas), `duration` sa durée en secondes,
## `resource_id` le **gain** de la case — minerai de la tuile ou drop tiré, vide
## pour « Rien » (`Q28`). Émis **avant** toute destruction : c'est ce qui permet à
## la soute d'alerter avant une perte (`G9`).
signal drilling_started(cell: Vector2i, direction: Vector2i, cell_center: Vector2, duration: float, resource_id: String)
## Le forage en cours s'arrête — achevé ou abandonné.
signal drilling_stopped()
## Une tuile vient d'être détruite par le foret. `resource_id` est le gain de la
## case, le même que celui annoncé par `drilling_started`. Consommé par la
## collecte (story 3.5).
signal tile_drilled(cell: Vector2i, resource_id: String)
## La case détruite était stérile et le tirage de loot a donné `entry_id` (y
## compris « Rien »), soit `resource_id`. Émis **après** `tile_drilled`, et
## **uniquement** pour un gain tiré — jamais pour une tuile de minerai (`Q36`) :
## c'est ce qui permet au retour « jackpot » de la story 3.7 de ne réagir qu'aux
## drops, sans relire la tuile.
signal loot_dropped(cell: Vector2i, cell_center: Vector2, entry_id: String, resource_id: String)
## Une demande de forage est refusée, avec son motif.
signal drill_refused(cell: Vector2i, reason: RefusalReason)

const ACTION_MOVE_LEFT: StringName = &"move_left"
const ACTION_MOVE_RIGHT: StringName = &"move_right"
const ACTION_MOVE_UP: StringName = &"move_up"
const ACTION_MOVE_DOWN: StringName = &"move_down"
const ACTION_DRILL: StringName = &"drill"

## Directions de forage **autorisées**. Il n'en existe aucune vers le haut (`G1`).
const DIRECTION_DOWN: Vector2i = Vector2i(0, 1)
const DIRECTION_NONE: Vector2i = Vector2i.ZERO

var _rig: CharacterBody2D = null
var _fuel_system: FuelSystem = null
var _armor_system: ArmorSystem = null
var _terrain: TerrainSystem = null
## Amélioration qui porte la puissance du foret, résolue une fois.
var _power_upgrade_id: String = ""
var _loot: LootSystem = LootSystem.new()

var _drilling: bool = false
var _target_cell: Vector2i = Vector2i.ZERO
var _elapsed: float = 0.0
var _duration: float = 0.0
## Gain de la case en cours de forage, déterminé au début du forage (`Q28`) :
## ressource obtenue, et entrée de loot tirée — vide pour une tuile de minerai.
var _target_resource: String = ""
var _target_loot_entry: String = ""
var _refusal_sent: bool = false
var _refused_cell: Vector2i = Vector2i.ZERO


## Inactif tant que `setup()` n'a pas fourni ses collaborateurs : un forage sans
## terrain ni carburant connus serait un forage sur des hypothèses.
func _ready() -> void:
	set_physics_process(false)


## Branché par `DrillRig`, qui possède les composants et reçoit le terrain par un
## export de scène (`C1`, `C2`). Refuse de s'activer si une donnée manque.
func setup(rig: CharacterBody2D, fuel_system: FuelSystem, armor_system: ArmorSystem, terrain: TerrainSystem) -> void:
	if not GameData.has_drilling_settings():
		push_error("MiningSystem — durée de forage non chargée depuis %s : forage désactivé." % GameData.DRILL_PATH)
		return
	_power_upgrade_id = GameData.get_upgrade_id_for_statistic(GameData.STAT_DRILL_POWER)
	if _power_upgrade_id.is_empty():
		push_error("MiningSystem — aucune amélioration ne porte « %s » : forage désactivé." % GameData.STAT_DRILL_POWER)
		return
	if not _loot.setup():
		push_error("MiningSystem — table de loot indisponible : forage désactivé.")
		return
	_rig = rig
	_fuel_system = fuel_system
	_armor_system = armor_system
	_terrain = terrain
	set_physics_process(true)


## Exécuté **après** `DrillRig._physics_process()` (un enfant est traité après son
## parent) : `is_on_floor()` et `is_on_wall()` reflètent donc le déplacement de
## cette frame.
func _physics_process(delta: float) -> void:
	var direction: Vector2i = _read_request()
	if direction == DIRECTION_NONE:
		_stop()
		return
	if not _is_supported_for(direction):
		_stop()
		return
	var cell: Vector2i = _terrain.world_to_cell(_rig.global_position) + direction
	var info: TerrainSystem.CellInfo = _terrain.get_cell_info(cell)
	if info.state != TerrainSystem.CellState.SOLID:
		# Vide : la foreuse se déplace, il n'y a rien à forer. Hors carte : rien
		# n'existe à détruire, et le confinement de `2.11` retient la foreuse.
		_stop()
		return
	if not _fuel_system.has_fuel():
		_refuse(cell, RefusalReason.NO_FUEL)
		return
	if not info.mineable or not info.destructible:
		_refuse(cell, RefusalReason.INDESTRUCTIBLE)
		return
	if float(info.hardness) > _drill_power():
		_refuse(cell, RefusalReason.TOO_HARD)
		return
	if not _drilling or cell != _target_cell:
		_start(cell, direction, info)
	_elapsed += delta
	if _elapsed >= _duration:
		_complete(cell, _target_resource)


## Direction demandée par le joueur, ou `DIRECTION_NONE`.
func _read_request() -> Vector2i:
	if not _armor_system.can_act():
		return DIRECTION_NONE
	# G1 — condition explicite, non un effet de bord : tant que `move_up` est
	# maintenu, **aucune** tuile n'est forée, quelle que soit l'autre touche.
	if Input.is_action_pressed(ACTION_MOVE_UP):
		return DIRECTION_NONE
	if Input.is_action_pressed(ACTION_MOVE_DOWN):
		return DIRECTION_DOWN
	var horizontal: float = Input.get_axis(ACTION_MOVE_LEFT, ACTION_MOVE_RIGHT)
	if not is_zero_approx(horizontal):
		return Vector2i(int(signf(horizontal)), 0)
	# `drill` seul active le foret « dans la direction de mouvement » (CDC,
	# « Contrôles ») ; sans direction, la seule direction de forage restante est
	# le bas.
	if Input.is_action_pressed(ACTION_DRILL):
		return DIRECTION_DOWN
	return DIRECTION_NONE


## G2 — la foreuse doit être **soutenue par un sol solide** pour forer, et, pour
## un forage latéral, **au contact** de la paroi visée : sa normale doit faire
## face à la direction demandée. Aucune tolérance chiffrée : ce sont les états
## de contact du moteur physique, établis par `move_and_slide()`.
func _is_supported_for(direction: Vector2i) -> bool:
	if not _rig.is_on_floor():
		return false
	if direction == DIRECTION_DOWN:
		return true
	return _rig.is_on_wall() and signf(_rig.get_wall_normal().x) == -float(direction.x)


## Puissance **courante** du foret : effet du niveau atteint de l'amélioration,
## relu à chaque demande pour qu'un achat en phase 5 prenne effet immédiatement.
func _drill_power() -> float:
	return GameData.get_upgrade_value(_power_upgrade_id, GameState.get_upgrade_level(_power_upgrade_id))


## `Q28` — une seule source de gain par case, déterminée **ici, avant** toute
## destruction : le minerai de la tuile s'il existe, sinon le tirage de loot.
## Jamais les deux.
func _start(cell: Vector2i, direction: Vector2i, info: TerrainSystem.CellInfo) -> void:
	_stop()
	_drilling = true
	_target_cell = cell
	if info.resource_id.is_empty():
		_target_loot_entry = _loot.roll_entry(cell)
		_target_resource = GameData.get_loot_entry_resource(_target_loot_entry)
	else:
		_target_loot_entry = ""
		_target_resource = info.resource_id
	_elapsed = 0.0
	_duration = GameData.get_drilling_duration(info.hardness)
	drilling_started.emit(cell, direction, _terrain.cell_to_world(cell), _duration, _target_resource)


## Dernière vérification de carburant **au moment** de détruire : la réserve a pu
## s'épuiser pendant le forage (consommation au repos). Puis destruction, coût,
## signal — dans cet ordre, pour que la collecte ne voie qu'une tuile réellement
## détruite et payée.
func _complete(cell: Vector2i, resource_id: String) -> void:
	if not _fuel_system.has_fuel():
		_refuse(cell, RefusalReason.NO_FUEL)
		return
	var destroyed: bool = _terrain.destroy_cell(cell)
	_stop()
	if not destroyed:
		return
	_fuel_system.consume_drilled_tile()
	tile_drilled.emit(cell, resource_id)
	if not _target_loot_entry.is_empty():
		loot_dropped.emit(cell, _terrain.cell_to_world(cell), _target_loot_entry, resource_id)


func _refuse(cell: Vector2i, reason: RefusalReason) -> void:
	if _drilling:
		_drilling = false
		drilling_stopped.emit()
	if _refusal_sent and _refused_cell == cell:
		return
	_refusal_sent = true
	_refused_cell = cell
	drill_refused.emit(cell, reason)


func _stop() -> void:
	_refusal_sent = false
	if not _drilling:
		return
	_drilling = false
	drilling_stopped.emit()
