class_name EventCatalog
extends RefCounted

## Chargeur et catalogue de `data/events.json` — événements narratifs (story 1.5,
## découpé de `GameData` par la story 5.11).
##
## Une seule responsabilité : lire, valider et servir ce fichier. Instancié
## **uniquement** par l'autoload `GameData`, qui reste la façade publique. La
## façade est volontairement générique : la structure d'un événement n'est figée
## qu'en phase 6 (stories 6.2 à 6.4).

const PATH: String = "res://data/events.json"
const ROOT: String = "evenements"

const KEY_TRIGGER: String = "condition_declenchement"
const KEY_TRIGGER_TYPE: String = "type"
const KEY_FLAG: String = "flag"
const KEY_SPEAKER: String = "locuteur"
const KEY_LINES: String = "lignes_de_dialogue"

const SCHEMA: Dictionary = {
	DataValidator.KEY_ID: DataValidator.FieldKind.STRING,
	DataValidator.KEY_NAME: DataValidator.FieldKind.STRING,
	DataValidator.KEY_ACTIVE_MVP: DataValidator.FieldKind.BOOL,
	KEY_TRIGGER: DataValidator.FieldKind.DICT,
	KEY_FLAG: DataValidator.FieldKind.STRING,
	KEY_SPEAKER: DataValidator.FieldKind.STRING,
	KEY_LINES: DataValidator.FieldKind.ARRAY,
}

const TRIGGER_SCHEMA: Dictionary = {
	KEY_TRIGGER_TYPE: DataValidator.FieldKind.STRING,
	DataValidator.KEY_VALUE: DataValidator.FieldKind.FLOAT,
}

var _validator: DataValidator
var _events: Dictionary[String, Dictionary] = {}
var _event_ids: Array[String] = []


func _init(validator: DataValidator) -> void:
	_validator = validator


func load_file() -> void:
	var entries: Array = _validator.read_entries(PATH, ROOT)
	for index: int in entries.size():
		var context: String = "%s → %s[%d]" % [PATH, ROOT, index]
		var entry: Dictionary = _validator.accept_entry(entries[index], SCHEMA, context)
		if entry.is_empty():
			continue
		var event_id: String = entry[DataValidator.KEY_ID]
		if not _validator.accept_id(event_id, _event_ids, context):
			continue
		var trigger: Dictionary = _validator.accept_entry(entry[KEY_TRIGGER], TRIGGER_SCHEMA, "%s → %s" % [context, KEY_TRIGGER])
		if trigger.is_empty():
			continue
		var lines: PackedStringArray = _read_lines(entry[KEY_LINES], context)
		if lines.is_empty():
			_validator.report("%s : aucune ligne de dialogue, événement « %s » rejeté." % [context, event_id])
			continue
		entry[KEY_TRIGGER] = trigger
		entry[KEY_LINES] = lines
		_events[event_id] = entry
		_event_ids.append(event_id)


func _read_lines(raw_lines: Array, context: String) -> PackedStringArray:
	var lines: PackedStringArray = []
	for index: int in raw_lines.size():
		if typeof(raw_lines[index]) != TYPE_STRING:
			_validator.report("%s → %s[%d] : ligne de dialogue non textuelle, ignorée." % [context, KEY_LINES, index])
			continue
		lines.append(raw_lines[index])
	return lines


func has_event(event_id: String) -> bool:
	return _events.has(event_id)


func get_event(event_id: String) -> Dictionary:
	if not has_event(event_id):
		push_error("GameData — événement inconnu : « %s »." % event_id)
		return {}
	return _events[event_id].duplicate(true)


func get_event_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.assign(_event_ids)
	return ids


func get_mvp_event_ids() -> Array[String]:
	var ids: Array[String] = []
	for event_id: String in _event_ids:
		if _events[event_id][DataValidator.KEY_ACTIVE_MVP]:
			ids.append(event_id)
	return ids
