extends Node
class_name NarrativeSystem

## Moteur narratif minimal du MVP — story 6.3 (CDC « Architecture Godot »).
##
## Évalue, à chaque image physique, la **condition de déclenchement** de chaque
## événement **actif au MVP** de `data/events.json` et déclenche chacun **une
## seule fois** : il pose le flag de l'événement dans `GameState`, puis publie le
## déclenchement par `event_triggered`.
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Le flag porte seul l'unicité** (contrat de `data/events.json`, story
## 1.5) : un événement dont le flag est posé n'est plus évalué, donc ne se rejoue
## jamais — ni dans la même session, ni après une restitution de flags (`7.1`).
## [br]— **Aucun état narratif ici** : les flags sont écrits par
## `GameState.set_narrative_flag()` et lus par `has_narrative_flag()`, rien
## d'autre. Ce script ne retient que des données **immuables** du catalogue,
## relevées une fois à `_ready()`, comme la physique de `DrillRig`.
## [br]— **Lecture par la façade `GameData`** (`C3`) : aucun fichier lu, aucune
## clé JSON connue ; les types de condition sont les constantes `EVENT_TRIGGER_*`.
## Un type inconnu n'arrive jamais jusqu'ici : il est rejeté au chargement (`D2`).
## [br]— **Aucune coordonnée ni seuil dans le code** (`D1`, `K3`) : le rayon est
## la `valeur` de chaque événement, la position de l'anomalie dérive de
## l'ancrage de `data/generation.json`. Depuis la story 6.4 (`Q71` (a)),
## `anomalie_necropole` se déclenche par proximité ; le type `profondeur_min_m`,
## sans plus aucun événement, a été retiré des données et du code (`B6`).
## [br]— **Aucun aléa** (`K2`, `M6`) : l'évaluation ne tire sur aucun générateur.
## [br]— **Aucune sauvegarde** (`H7 [B]`) : la persistance sur disque est l'objet
## de `7.1`, qui lit `GameState.get_narrative_flags()`.
## [br]— **Pausable** (`process_mode` hérité) : rien ne bouge pendant une modale,
## aucune condition n'y change donc. La mise en attente d'un déclenchement
## survenu pendant une modale ou la transition de destruction relève de
## l'affichage (`6.2`, `Q72` (a)) ; le flag, lui, est posé une seule fois.
## [br]— **Lecture de l'état publié** : la foreuse publie position et profondeur
## dans son `_physics_process()` ; ce nœud est placé **après** `DrillRig` dans
## `Main.tscn`, il évalue donc la position de l'image courante.
## [br]— **Validation headless** : ce fichier référence les autoloads `GameData`
## et `GameState` — exception bornée de `--check-only` (story `1.9`).

## Émis au déclenchement d'un événement, **après** la pose de son flag : une seule
## fois par événement et par partie. Seul consommateur : l'affichage des messages
## radio (`Dialogue.gd`, `6.2`). Le journal (`6.5`) ne s'y abonne pas : il relit
## les flags de `GameState` à chaque ouverture.
signal event_triggered(event_id: String)

## Données d'un événement évalué, relevées une fois dans le catalogue immuable.
class EventCondition:
	var event_id: String
	var flag: String
	var trigger_type: String
	var value: float

	func _init(id: String, flag_id: String, kind: String, threshold: float) -> void:
		event_id = id
		flag = flag_id
		trigger_type = kind
		value = threshold


## Événements actifs au MVP, dans l'ordre du catalogue : deux conditions remplies
## à la même image se déclenchent dans cet ordre.
var _conditions: Array[EventCondition] = []
## Centre de la cellule d'ancrage de l'anomalie, en pixels monde.
var _anomaly_position: Vector2 = Vector2.ZERO
var _pixels_per_meter: float = 0.0


func _ready() -> void:
	_pixels_per_meter = GameData.get_pixels_per_meter()
	if _pixels_per_meter <= 0.0:
		push_error("NarrativeSystem — conversion pixels/mètre indisponible (voir %s) : moteur narratif inactif." % GameData.DRILL_PATH)
		set_physics_process(false)
		return
	for event_id: String in GameData.get_mvp_event_ids():
		var trigger_type: String = GameData.get_event_trigger_type(event_id)
		_conditions.append(EventCondition.new(event_id, GameData.get_event_flag(event_id), trigger_type, GameData.get_event_trigger_value(event_id)))
		if trigger_type == GameData.EVENT_TRIGGER_ANOMALY_PROXIMITY and not GameData.has_anchors():
			push_error("NarrativeSystem — « %s » se déclenche près de l'anomalie, mais les ancrages de %s n'ont pas été chargés." % [event_id, GameData.GENERATION_PATH])
	if GameData.has_anchors():
		_anomaly_position = GameData.get_anomaly_center_position()


func _physics_process(_delta: float) -> void:
	_evaluate()


## Déclenche, dans l'ordre du catalogue, chaque événement non encore joué dont la
## condition est remplie. Appelée à chaque image physique.
func _evaluate() -> void:
	for condition: EventCondition in _conditions:
		if GameState.has_narrative_flag(condition.flag):
			continue
		if not _is_met(condition):
			continue
		GameState.set_narrative_flag(condition.flag, true)
		event_triggered.emit(condition.event_id)


## Constantes de la façade comparées par `if` et non par `match` : un motif de
## `match` doit être une constante de compilation, ce qu'un membre d'autoload
## n'est pas.
func _is_met(condition: EventCondition) -> bool:
	if condition.trigger_type == GameData.EVENT_TRIGGER_GAME_START:
		return true
	if condition.trigger_type == GameData.EVENT_TRIGGER_ANOMALY_PROXIMITY:
		if not GameData.has_anchors():
			return false
		var distance_m: float = GameState.get_drill_position().distance_to(_anomaly_position) / _pixels_per_meter
		return distance_m < condition.value
	return false
