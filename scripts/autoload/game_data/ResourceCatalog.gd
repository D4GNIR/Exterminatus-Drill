class_name ResourceCatalog
extends RefCounted

## Chargeur et catalogue de `data/resources.json` — les minerais (story 1.5,
## découpé de `GameData` par la story 5.11).
##
## Une seule responsabilité : lire, valider et servir le catalogue des
## ressources. Instancié **uniquement** par l'autoload `GameData`, qui reste la
## façade publique : aucun autre script ne doit le construire ni le lire.
## L'ordre de déclaration du fichier est conservé — la rareté croissante est une
## information de lecture qu'un dictionnaire perdrait, et l'ordre rend le tirage
## du générateur reproductible.

const PATH: String = "res://data/resources.json"
const ROOT: String = "ressources"

const KEY_RARITY: String = "rarete"
const KEY_VALUE_CREDITS: String = "valeur_credits"
const KEY_HARDNESS_MIN: String = "hardness_min"
const KEY_MASS: String = "masse_soute"
const KEY_RISK: String = "risque"
const KEY_HAZARD_TYPE: String = "hazard_type"

const SCHEMA: Dictionary = {
	DataValidator.KEY_ID: DataValidator.FieldKind.STRING,
	DataValidator.KEY_NAME: DataValidator.FieldKind.STRING,
	KEY_RARITY: DataValidator.FieldKind.STRING,
	KEY_VALUE_CREDITS: DataValidator.FieldKind.INT,
	KEY_HARDNESS_MIN: DataValidator.FieldKind.INT,
	KEY_MASS: DataValidator.FieldKind.INT,
	KEY_RISK: DataValidator.FieldKind.STRING,
	KEY_HAZARD_TYPE: DataValidator.FieldKind.STRING,
	DataValidator.KEY_ACTIVE_MVP: DataValidator.FieldKind.BOOL,
}

var _validator: DataValidator
var _resources: Dictionary[String, Dictionary] = {}
var _resource_ids: Array[String] = []


func _init(validator: DataValidator) -> void:
	_validator = validator


func load_file() -> void:
	var entries: Array = _validator.read_entries(PATH, ROOT)
	for index: int in entries.size():
		var context: String = "%s → %s[%d]" % [PATH, ROOT, index]
		var entry: Dictionary = _validator.accept_entry(entries[index], SCHEMA, context)
		if entry.is_empty():
			continue
		var resource_id: String = entry[DataValidator.KEY_ID]
		if not _validator.accept_id(resource_id, _resource_ids, context):
			continue
		_resources[resource_id] = entry
		_resource_ids.append(resource_id)


func has_resource(resource_id: String) -> bool:
	return _resources.has(resource_id)


## Copie profonde : le catalogue est immuable pour ses lecteurs.
func get_resource(resource_id: String) -> Dictionary:
	if not _is_known(resource_id):
		return {}
	return _resources[resource_id].duplicate(true)


func get_resource_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.assign(_resource_ids)
	return ids


func get_mvp_resource_ids() -> Array[String]:
	var ids: Array[String] = []
	for resource_id: String in _resource_ids:
		if _resources[resource_id][DataValidator.KEY_ACTIVE_MVP]:
			ids.append(resource_id)
	return ids


func is_resource_active_in_mvp(resource_id: String) -> bool:
	if not _is_known(resource_id):
		return false
	return _resources[resource_id][DataValidator.KEY_ACTIVE_MVP]


func get_resource_name(resource_id: String) -> String:
	if not _is_known(resource_id):
		return ""
	return _resources[resource_id][DataValidator.KEY_NAME]


func get_resource_value(resource_id: String) -> int:
	if not _is_known(resource_id):
		return 0
	return _resources[resource_id][KEY_VALUE_CREDITS]


func get_resource_hardness(resource_id: String) -> int:
	if not _is_known(resource_id):
		return 0
	return _resources[resource_id][KEY_HARDNESS_MIN]


func get_resource_mass(resource_id: String) -> int:
	if not _is_known(resource_id):
		return 0
	return _resources[resource_id][KEY_MASS]


func get_resource_hazard_type(resource_id: String) -> String:
	if not _is_known(resource_id):
		return ""
	return _resources[resource_id][KEY_HAZARD_TYPE]


## Vrai si la ressource existe ; sinon, signale l'`id` inconnu à l'appelant.
func _is_known(resource_id: String) -> bool:
	if has_resource(resource_id):
		return true
	push_error("GameData — ressource inconnue : « %s »." % resource_id)
	return false
