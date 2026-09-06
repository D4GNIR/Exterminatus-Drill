extends Node

## Autoload `GameData` — catalogue de données immuable.
##
## Charge **une seule fois au démarrage** les fichiers de `res://data/` et les
## expose en lecture au reste du jeu : minerais, améliorations, événements
## narratifs et état de départ d'une nouvelle partie. Aucune valeur de gameplay
## ne doit vivre ailleurs qu'ici (point d'audit D1).
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

# --- Fichiers de données ------------------------------------------------------

const RESOURCES_PATH: String = "res://data/resources.json"
const UPGRADES_PATH: String = "res://data/upgrades.json"
const EVENTS_PATH: String = "res://data/events.json"

# --- Clés des fichiers --------------------------------------------------------
# Déclarées en constantes plutôt qu'en littéraux dispersés : une clé JSON est
# lue par le chargeur, par les schémas de validation et par les accesseurs (D4).

const ROOT_RESOURCES: String = "ressources"
const ROOT_UPGRADES: String = "ameliorations"
const ROOT_EVENTS: String = "evenements"
const ROOT_NEW_GAME: String = "nouvelle_partie"

const KEY_ID: String = "id"
const KEY_NAME: String = "nom_affiche"
const KEY_ACTIVE_MVP: String = "actif_mvp"
const KEY_RARITY: String = "rarete"
const KEY_VALUE_CREDITS: String = "valeur_credits"
const KEY_HARDNESS_MIN: String = "hardness_min"
const KEY_MASS: String = "masse_soute"
const KEY_RISK: String = "risque"
const KEY_HAZARD_TYPE: String = "hazard_type"
const KEY_DESCRIPTION: String = "description"
const KEY_STATISTIC: String = "statistique"
const KEY_TIERS: String = "paliers"
const KEY_LEVEL: String = "niveau"
const KEY_COST: String = "cout_credits"
const KEY_VALUE: String = "valeur"
const KEY_TRIGGER: String = "condition_declenchement"
const KEY_TRIGGER_TYPE: String = "type"
const KEY_FLAG: String = "flag"
const KEY_SPEAKER: String = "locuteur"
const KEY_LINES: String = "lignes_de_dialogue"
const KEY_START_CREDITS: String = "credits_depart"

# --- Identifiants de statistiques ---------------------------------------------
# Chaque amélioration déclare la statistique qu'elle pilote. C'est par elle que
# `GameState` résout ses valeurs de départ (palier de plus petit niveau), sans
# qu'aucun chiffre ne soit dupliqué entre le code et les données.

const STAT_CARGO_CAPACITY: String = "capacite_soute"
const STAT_FUEL_MAX: String = "carburant_max"
const STAT_DRILL_POWER: String = "puissance_foret"
const STAT_ARMOR_MAX: String = "blindage_max"

# --- Schémas de validation ----------------------------------------------------
# Type attendu de chaque champ obligatoire. Un champ absent, d'un autre type, ou
# un `id` vide ou dupliqué fait rejeter l'entrée entière.

enum FieldKind { INT, FLOAT, STRING, BOOL, ARRAY, DICT }

const RESOURCE_SCHEMA: Dictionary = {
	KEY_ID: FieldKind.STRING,
	KEY_NAME: FieldKind.STRING,
	KEY_RARITY: FieldKind.STRING,
	KEY_VALUE_CREDITS: FieldKind.INT,
	KEY_HARDNESS_MIN: FieldKind.INT,
	KEY_MASS: FieldKind.INT,
	KEY_RISK: FieldKind.STRING,
	KEY_HAZARD_TYPE: FieldKind.STRING,
	KEY_ACTIVE_MVP: FieldKind.BOOL,
}

const UPGRADE_SCHEMA: Dictionary = {
	KEY_ID: FieldKind.STRING,
	KEY_NAME: FieldKind.STRING,
	KEY_DESCRIPTION: FieldKind.STRING,
	KEY_STATISTIC: FieldKind.STRING,
	KEY_ACTIVE_MVP: FieldKind.BOOL,
	KEY_TIERS: FieldKind.ARRAY,
}

const TIER_SCHEMA: Dictionary = {
	KEY_LEVEL: FieldKind.INT,
	KEY_COST: FieldKind.INT,
	KEY_VALUE: FieldKind.FLOAT,
}

const EVENT_SCHEMA: Dictionary = {
	KEY_ID: FieldKind.STRING,
	KEY_NAME: FieldKind.STRING,
	KEY_ACTIVE_MVP: FieldKind.BOOL,
	KEY_TRIGGER: FieldKind.DICT,
	KEY_FLAG: FieldKind.STRING,
	KEY_SPEAKER: FieldKind.STRING,
	KEY_LINES: FieldKind.ARRAY,
}

const TRIGGER_SCHEMA: Dictionary = {
	KEY_TRIGGER_TYPE: FieldKind.STRING,
	KEY_VALUE: FieldKind.FLOAT,
}

const NEW_GAME_SCHEMA: Dictionary = {
	KEY_START_CREDITS: FieldKind.INT,
}

# --- Catalogue ----------------------------------------------------------------
# Les listes d'`id` conservent l'ordre de déclaration des fichiers : la rareté
# croissante des minerais est une information de lecture qu'un dictionnaire
# perdrait.

var _resources: Dictionary[String, Dictionary] = {}
var _resource_ids: Array[String] = []
var _upgrades: Dictionary[String, Dictionary] = {}
var _upgrade_ids: Array[String] = []
var _events: Dictionary[String, Dictionary] = {}
var _event_ids: Array[String] = []
## Crédits impériaux au début d'une partie. `-1` tant que `nouvelle_partie` n'a
## pas été lu : sentinelle distincte de toute valeur légitime, pour que
## `get_start_credits()` signale l'échec au lieu d'offrir un solde inventé.
var _start_credits: int = -1
## Journal des anomalies rencontrées au chargement, dans l'ordre. Chaque entrée
## a déjà été poussée sur la console par `push_error()`.
var _errors: PackedStringArray = []


func _init() -> void:
	_load_all()


## Trace de chargement exigée par le cas de test `TM-1.8` (« les JSON de `data/`
## sont chargés sans erreur de parsing ; le nombre d'entrées est loggé »). Ce
## n'est pas un `print()` de debug oublié : c'est la seule sortie observable qui
## permette au testeur humain de constater le chargement au lancement du jeu.
func _ready() -> void:
	print(get_load_summary())


# --- Chargement ---------------------------------------------------------------

func _load_all() -> void:
	_load_resources()
	_load_upgrades()
	_load_events()


func _load_resources() -> void:
	var entries: Array = _read_entries(RESOURCES_PATH, ROOT_RESOURCES)
	for index: int in entries.size():
		var context: String = "%s → %s[%d]" % [RESOURCES_PATH, ROOT_RESOURCES, index]
		var entry: Dictionary = _accept_entry(entries[index], RESOURCE_SCHEMA, context)
		if entry.is_empty():
			continue
		var resource_id: String = entry[KEY_ID]
		if not _accept_id(resource_id, _resource_ids, context):
			continue
		_resources[resource_id] = entry
		_resource_ids.append(resource_id)


## La racine du fichier n'est lue qu'une fois : elle porte à la fois l'état de
## départ d'une nouvelle partie et le tableau des améliorations. Deux lectures
## dédoubleraient les messages d'erreur en cas de fichier absent ou malformé.
func _load_upgrades() -> void:
	var root: Dictionary = _read_root(UPGRADES_PATH)
	if root.is_empty():
		return
	_load_new_game_block(root)
	var entries: Array = _extract_array(root, UPGRADES_PATH, ROOT_UPGRADES)
	for index: int in entries.size():
		var context: String = "%s → %s[%d]" % [UPGRADES_PATH, ROOT_UPGRADES, index]
		var entry: Dictionary = _accept_entry(entries[index], UPGRADE_SCHEMA, context)
		if entry.is_empty():
			continue
		var upgrade_id: String = entry[KEY_ID]
		if not _accept_id(upgrade_id, _upgrade_ids, context):
			continue
		var tiers: Array[Dictionary] = _read_tiers(entry[KEY_TIERS], context)
		if tiers.is_empty():
			_report("%s : aucun palier valide, amélioration « %s » rejetée." % [context, upgrade_id])
			continue
		entry[KEY_TIERS] = tiers
		_upgrades[upgrade_id] = entry
		_upgrade_ids.append(upgrade_id)


## Paliers triés par niveau croissant : le premier est le palier de départ
## (colonne « Statut de départ » du CDC), le dernier le plafond d'achat.
func _read_tiers(raw_tiers: Array, context: String) -> Array[Dictionary]:
	var tiers: Array[Dictionary] = []
	var levels: Array[int] = []
	for index: int in raw_tiers.size():
		var tier_context: String = "%s → %s[%d]" % [context, KEY_TIERS, index]
		var tier: Dictionary = _accept_entry(raw_tiers[index], TIER_SCHEMA, tier_context)
		if tier.is_empty():
			continue
		var level: int = tier[KEY_LEVEL]
		if levels.has(level):
			_report("%s : niveau %d déclaré deux fois, palier ignoré." % [tier_context, level])
			continue
		levels.append(level)
		tiers.append(tier)
	tiers.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a[KEY_LEVEL] < b[KEY_LEVEL])
	return tiers


func _load_new_game_block(root: Dictionary) -> void:
	var context: String = "%s → %s" % [UPGRADES_PATH, ROOT_NEW_GAME]
	if not root.has(ROOT_NEW_GAME):
		_report("%s : bloc manquant." % context)
		return
	var block: Dictionary = _accept_entry(root[ROOT_NEW_GAME], NEW_GAME_SCHEMA, context)
	if block.is_empty():
		return
	_start_credits = block[KEY_START_CREDITS]


func _load_events() -> void:
	var entries: Array = _read_entries(EVENTS_PATH, ROOT_EVENTS)
	for index: int in entries.size():
		var context: String = "%s → %s[%d]" % [EVENTS_PATH, ROOT_EVENTS, index]
		var entry: Dictionary = _accept_entry(entries[index], EVENT_SCHEMA, context)
		if entry.is_empty():
			continue
		var event_id: String = entry[KEY_ID]
		if not _accept_id(event_id, _event_ids, context):
			continue
		var trigger: Dictionary = _accept_entry(entry[KEY_TRIGGER], TRIGGER_SCHEMA, "%s → %s" % [context, KEY_TRIGGER])
		if trigger.is_empty():
			continue
		var lines: PackedStringArray = _read_lines(entry[KEY_LINES], context)
		if lines.is_empty():
			_report("%s : aucune ligne de dialogue, événement « %s » rejeté." % [context, event_id])
			continue
		entry[KEY_TRIGGER] = trigger
		entry[KEY_LINES] = lines
		_events[event_id] = entry
		_event_ids.append(event_id)


func _read_lines(raw_lines: Array, context: String) -> PackedStringArray:
	var lines: PackedStringArray = []
	for index: int in raw_lines.size():
		if typeof(raw_lines[index]) != TYPE_STRING:
			_report("%s → %s[%d] : ligne de dialogue non textuelle, ignorée." % [context, KEY_LINES, index])
			continue
		lines.append(raw_lines[index])
	return lines


# --- Lecture et validation bas niveau -----------------------------------------

## Racine d'un fichier de données. Renvoie un dictionnaire vide en cas d'échec :
## fichier absent, illisible, JSON malformé ou racine qui n'est pas un objet.
func _read_root(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		_report("%s : fichier introuvable." % path)
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		_report("%s : ouverture impossible (erreur %d)." % [path, FileAccess.get_open_error()])
		return {}
	var text: String = file.get_as_text()
	file.close()
	var parser: JSON = JSON.new()
	var status: Error = parser.parse(text)
	if status != OK:
		_report("%s : JSON invalide, ligne %d — %s" % [path, parser.get_error_line(), parser.get_error_message()])
		return {}
	if typeof(parser.data) != TYPE_DICTIONARY:
		_report("%s : la racine du fichier doit être un objet JSON." % path)
		return {}
	return parser.data


## Tableau d'entrées d'un fichier. Renvoie un tableau vide en cas d'échec, ce qui
## laisse le catalogue correspondant vide plutôt que partiellement inventé.
func _read_entries(path: String, root_key: String) -> Array:
	var root: Dictionary = _read_root(path)
	if root.is_empty():
		return []
	return _extract_array(root, path, root_key)


func _extract_array(root: Dictionary, path: String, root_key: String) -> Array:
	if not root.has(root_key):
		_report("%s : clé « %s » manquante à la racine." % [path, root_key])
		return []
	if typeof(root[root_key]) != TYPE_ARRAY:
		_report("%s : la clé « %s » doit contenir un tableau." % [path, root_key])
		return []
	return root[root_key]


## Valide une entrée contre son schéma et renvoie une copie **normalisée**
## (types convertis, champs hors schéma écartés). Un dictionnaire vide signale
## le rejet : le catalogue ne contient donc que des entrées complètes et typées.
func _accept_entry(raw: Variant, schema: Dictionary, context: String) -> Dictionary:
	if typeof(raw) != TYPE_DICTIONARY:
		_report("%s : entrée ignorée, objet JSON attendu." % context)
		return {}
	var entry: Dictionary = raw
	var normalized: Dictionary = {}
	for field: String in schema:
		if not entry.has(field):
			_report("%s : champ « %s » manquant, entrée rejetée." % [context, field])
			return {}
		var kind: FieldKind = schema[field]
		if not _matches_kind(entry[field], kind):
			_report("%s : champ « %s » de type inattendu (%s), entrée rejetée." % [context, field, type_string(typeof(entry[field]))])
			return {}
		normalized[field] = _normalize(entry[field], kind)
	return normalized


## Un entier JSON peut être décodé en `int` ou en `float` selon l'écriture du
## littéral : les deux sont acceptés là où un entier est attendu, à condition que
## la valeur soit effectivement entière.
func _matches_kind(value: Variant, kind: FieldKind) -> bool:
	var value_type: int = typeof(value)
	match kind:
		FieldKind.INT:
			if value_type == TYPE_INT:
				return true
			if value_type != TYPE_FLOAT:
				return false
			var number: float = value
			return is_equal_approx(number, roundf(number))
		FieldKind.FLOAT:
			return value_type == TYPE_INT or value_type == TYPE_FLOAT
		FieldKind.STRING:
			return value_type == TYPE_STRING
		FieldKind.BOOL:
			return value_type == TYPE_BOOL
		FieldKind.ARRAY:
			return value_type == TYPE_ARRAY
		FieldKind.DICT:
			return value_type == TYPE_DICTIONARY
	return false


func _normalize(value: Variant, kind: FieldKind) -> Variant:
	match kind:
		FieldKind.INT:
			return int(value)
		FieldKind.FLOAT:
			return float(value)
	return value


## Un `id` vide ou dupliqué est refusé : il est la clé de tout le reste — TileSet
## (story 3.1), soute et sauvegardes (story 7.1).
func _accept_id(candidate_id: String, known_ids: Array[String], context: String) -> bool:
	if candidate_id.is_empty():
		_report("%s : « %s » vide, entrée rejetée." % [context, KEY_ID])
		return false
	if known_ids.has(candidate_id):
		_report("%s : « %s » déjà déclaré, entrée rejetée." % [context, candidate_id])
		return false
	return true


func _report(message: String) -> void:
	_errors.append(message)
	push_error("GameData — " + message)


# --- État du chargement -------------------------------------------------------

## Vrai si les trois fichiers ont été lus sans la moindre anomalie. Faux impose
## de considérer le catalogue comme incomplet : aucune valeur de repli n'a été
## substituée aux données rejetées.
func is_valid() -> bool:
	return _errors.is_empty()


func get_errors() -> PackedStringArray:
	return _errors.duplicate()


func get_load_summary() -> String:
	return "GameData — ressources : %d (%d actives MVP) · améliorations : %d (%d actives MVP) · événements : %d (%d actifs MVP) · erreurs : %d" % [
		_resource_ids.size(), get_mvp_resource_ids().size(),
		_upgrade_ids.size(), get_mvp_upgrade_ids().size(),
		_event_ids.size(), get_mvp_event_ids().size(),
		_errors.size(),
	]


# --- Ressources ---------------------------------------------------------------

func has_resource(resource_id: String) -> bool:
	return _resources.has(resource_id)


## Copie profonde : le catalogue est immuable pour ses lecteurs. Les accesseurs
## scalaires ci-dessous sont à préférer dans les chemins chauds (forage, HUD).
func get_resource(resource_id: String) -> Dictionary:
	if not has_resource(resource_id):
		push_error("GameData — ressource inconnue : « %s »." % resource_id)
		return {}
	return _resources[resource_id].duplicate(true)


func get_resource_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.assign(_resource_ids)
	return ids


## Ressources que le générateur de terrain (story 3.2) a le droit de placer au
## MVP. Les autres sont décrites mais ne doivent jamais apparaître (Q12).
func get_mvp_resource_ids() -> Array[String]:
	var ids: Array[String] = []
	for resource_id: String in _resource_ids:
		if _resources[resource_id][KEY_ACTIVE_MVP]:
			ids.append(resource_id)
	return ids


func is_resource_active_in_mvp(resource_id: String) -> bool:
	if not has_resource(resource_id):
		push_error("GameData — ressource inconnue : « %s »." % resource_id)
		return false
	return _resources[resource_id][KEY_ACTIVE_MVP]


func get_resource_name(resource_id: String) -> String:
	if not has_resource(resource_id):
		push_error("GameData — ressource inconnue : « %s »." % resource_id)
		return ""
	return _resources[resource_id][KEY_NAME]


## Prix de vente unitaire, en crédits impériaux — donnée de tuile `value`.
func get_resource_value(resource_id: String) -> int:
	if not has_resource(resource_id):
		push_error("GameData — ressource inconnue : « %s »." % resource_id)
		return 0
	return _resources[resource_id][KEY_VALUE_CREDITS]


## Dureté de la tuile portant ce minerai — donnée de tuile `hardness`.
func get_resource_hardness(resource_id: String) -> int:
	if not has_resource(resource_id):
		push_error("GameData — ressource inconnue : « %s »." % resource_id)
		return 0
	return _resources[resource_id][KEY_HARDNESS_MIN]


## Unités de soute consommées par une unité extraite.
func get_resource_mass(resource_id: String) -> int:
	if not has_resource(resource_id):
		push_error("GameData — ressource inconnue : « %s »." % resource_id)
		return 0
	return _resources[resource_id][KEY_MASS]


## Danger associé — donnée de tuile `hazard_type`, vide si aucun.
func get_resource_hazard_type(resource_id: String) -> String:
	if not has_resource(resource_id):
		push_error("GameData — ressource inconnue : « %s »." % resource_id)
		return ""
	return _resources[resource_id][KEY_HAZARD_TYPE]


# --- Améliorations ------------------------------------------------------------

func has_upgrade(upgrade_id: String) -> bool:
	return _upgrades.has(upgrade_id)


func get_upgrade(upgrade_id: String) -> Dictionary:
	if not has_upgrade(upgrade_id):
		push_error("GameData — amélioration inconnue : « %s »." % upgrade_id)
		return {}
	return _upgrades[upgrade_id].duplicate(true)


func get_upgrade_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.assign(_upgrade_ids)
	return ids


## Les améliorations proposées par la boutique du MVP — « MVP jouable » point 6.
func get_mvp_upgrade_ids() -> Array[String]:
	var ids: Array[String] = []
	for upgrade_id: String in _upgrade_ids:
		if _upgrades[upgrade_id][KEY_ACTIVE_MVP]:
			ids.append(upgrade_id)
	return ids


func is_upgrade_active_in_mvp(upgrade_id: String) -> bool:
	if not has_upgrade(upgrade_id):
		push_error("GameData — amélioration inconnue : « %s »." % upgrade_id)
		return false
	return _upgrades[upgrade_id][KEY_ACTIVE_MVP]


func get_upgrade_name(upgrade_id: String) -> String:
	if not has_upgrade(upgrade_id):
		push_error("GameData — amélioration inconnue : « %s »." % upgrade_id)
		return ""
	return _upgrades[upgrade_id][KEY_NAME]


func get_upgrade_description(upgrade_id: String) -> String:
	if not has_upgrade(upgrade_id):
		push_error("GameData — amélioration inconnue : « %s »." % upgrade_id)
		return ""
	return _upgrades[upgrade_id][KEY_DESCRIPTION]


## Statistique pilotée par l'amélioration (`STAT_*`).
func get_upgrade_statistic(upgrade_id: String) -> String:
	if not has_upgrade(upgrade_id):
		push_error("GameData — amélioration inconnue : « %s »." % upgrade_id)
		return ""
	return _upgrades[upgrade_id][KEY_STATISTIC]


## Niveau du premier palier déclaré : l'état de départ d'une nouvelle partie.
func get_upgrade_start_level(upgrade_id: String) -> int:
	var tiers: Array = _get_tiers(upgrade_id)
	if tiers.is_empty():
		return 0
	return tiers[0][KEY_LEVEL]


## Niveau du dernier palier déclaré : le plafond d'achat (story 5.4).
func get_upgrade_max_level(upgrade_id: String) -> int:
	var tiers: Array = _get_tiers(upgrade_id)
	if tiers.is_empty():
		return 0
	return tiers[tiers.size() - 1][KEY_LEVEL]


## Effet chiffré du palier. `0.0` signale un niveau inexistant : l'appelant doit
## s'être assuré du niveau via `get_upgrade_start_level()` / `_max_level()`.
func get_upgrade_value(upgrade_id: String, level: int) -> float:
	var tier: Dictionary = _find_tier(upgrade_id, level)
	if tier.is_empty():
		return 0.0
	return tier[KEY_VALUE]


## Coût d'achat du palier, en crédits impériaux. Le palier de départ vaut 0 :
## il n'est pas achetable, il est déjà acquis.
func get_upgrade_cost(upgrade_id: String, level: int) -> int:
	var tier: Dictionary = _find_tier(upgrade_id, level)
	if tier.is_empty():
		return 0
	return tier[KEY_COST]


## Valeur de départ d'une statistique : effet du palier de départ de
## l'amélioration qui la pilote. Source unique de vérité des valeurs initiales de
## `GameState` — aucun chiffre n'est recopié dans le code (Q13).
func get_start_stat(statistic_id: String) -> float:
	for upgrade_id: String in _upgrade_ids:
		if _upgrades[upgrade_id][KEY_STATISTIC] == statistic_id:
			return get_upgrade_value(upgrade_id, get_upgrade_start_level(upgrade_id))
	push_error("GameData — statistique inconnue : « %s »." % statistic_id)
	return 0.0


## Crédits impériaux au début d'une partie.
func get_start_credits() -> int:
	if _start_credits < 0:
		push_error("GameData — bloc « %s » non chargé : crédits de départ indéterminés." % ROOT_NEW_GAME)
		return 0
	return _start_credits


func _get_tiers(upgrade_id: String) -> Array:
	if not has_upgrade(upgrade_id):
		push_error("GameData — amélioration inconnue : « %s »." % upgrade_id)
		return []
	return _upgrades[upgrade_id][KEY_TIERS]


func _find_tier(upgrade_id: String, level: int) -> Dictionary:
	for tier: Dictionary in _get_tiers(upgrade_id):
		if tier[KEY_LEVEL] == level:
			return tier
	push_error("GameData — palier %d inexistant pour l'amélioration « %s »." % [level, upgrade_id])
	return {}


# --- Événements narratifs -----------------------------------------------------
# La façade reste volontairement générique : la structure d'un événement n'est
# figée qu'en phase 6 (stories 6.2 à 6.4). Y ajouter des accesseurs par champ dès
# maintenant produirait du code sans lecteur.

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
		if _events[event_id][KEY_ACTIVE_MVP]:
			ids.append(event_id)
	return ids
