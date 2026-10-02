class_name DataValidator
extends RefCounted

## Outils de lecture et de validation partagés par les chargeurs de `GameData`
## (story 5.11, découpage par fichier de données — `Q53` (a)).
##
## Une seule responsabilité : **lire un fichier JSON de `data/`, contrôler le type
## d'une entrée contre un schéma, et consigner toute anomalie**. Aucune règle
## propre à un fichier n'est ici : chaque chargeur (`ResourceCatalog`,
## `UpgradeCatalog`, `EventCatalog`, `DrillSettings`, `GenerationSettings`) porte
## ses schémas et ses bornes, et partage cette instance pour que le journal
## d'anomalies reste **unique et ordonné** — l'ordre est celui du chargement.
##
## [br]— **Aucun repli silencieux** (`D2`) : un échec est signalé par
## `push_error()` **et** consigné, jamais remplacé par une valeur par défaut. Le
## préfixe « GameData — » des messages est conservé : l'autoload reste, pour le
## joueur comme pour le testeur, la seule source de ces erreurs.
## [br]— Ni accès à l'arbre de scène, ni lecture d'entrée (`Q10`).

## Préfixe des messages d'anomalie, inchangé depuis la story 1.5.
const ERROR_PREFIX: String = "GameData — "

# --- Clés communes à plusieurs fichiers ----------------------------------------
# Déclarées une fois ici plutôt que dans chaque chargeur (D4).

const KEY_ID: String = "id"
const KEY_NAME: String = "nom_affiche"
const KEY_ACTIVE_MVP: String = "actif_mvp"
## Effet d'un palier d'amélioration et seuil d'une condition d'événement.
const KEY_VALUE: String = "valeur"

## Type attendu de chaque champ obligatoire. Un champ absent, d'un autre type, ou
## un `id` vide ou dupliqué fait rejeter l'entrée entière.
enum FieldKind { INT, FLOAT, STRING, BOOL, ARRAY, DICT }

## Journal des anomalies rencontrées au chargement, dans l'ordre. Chaque entrée
## a déjà été poussée sur la console par `push_error()`.
var _errors: PackedStringArray = []


func report(message: String) -> void:
	_errors.append(message)
	push_error(ERROR_PREFIX + message)


func get_errors() -> PackedStringArray:
	return _errors.duplicate()


func has_errors() -> bool:
	return not _errors.is_empty()


func get_error_count() -> int:
	return _errors.size()


## Racine d'un fichier de données. Renvoie un dictionnaire vide en cas d'échec :
## fichier absent, illisible, JSON malformé ou racine qui n'est pas un objet.
func read_root(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		report("%s : fichier introuvable." % path)
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		report("%s : ouverture impossible (erreur %d)." % [path, FileAccess.get_open_error()])
		return {}
	var text: String = file.get_as_text()
	file.close()
	var parser: JSON = JSON.new()
	var status: Error = parser.parse(text)
	if status != OK:
		report("%s : JSON invalide, ligne %d — %s" % [path, parser.get_error_line(), parser.get_error_message()])
		return {}
	if typeof(parser.data) != TYPE_DICTIONARY:
		report("%s : la racine du fichier doit être un objet JSON." % path)
		return {}
	return parser.data


## Tableau d'entrées d'un fichier. Renvoie un tableau vide en cas d'échec, ce qui
## laisse le catalogue correspondant vide plutôt que partiellement inventé.
func read_entries(path: String, root_key: String) -> Array:
	var root: Dictionary = read_root(path)
	if root.is_empty():
		return []
	return extract_array(root, path, root_key)


func extract_array(root: Dictionary, path: String, root_key: String) -> Array:
	if not root.has(root_key):
		report("%s : clé « %s » manquante à la racine." % [path, root_key])
		return []
	if typeof(root[root_key]) != TYPE_ARRAY:
		report("%s : la clé « %s » doit contenir un tableau." % [path, root_key])
		return []
	return root[root_key]


## Valide une entrée contre son schéma et renvoie une copie **normalisée**
## (types convertis, champs hors schéma écartés). Un dictionnaire vide signale
## le rejet : le catalogue ne contient donc que des entrées complètes et typées.
func accept_entry(raw: Variant, schema: Dictionary, context: String) -> Dictionary:
	if typeof(raw) != TYPE_DICTIONARY:
		report("%s : entrée ignorée, objet JSON attendu." % context)
		return {}
	var entry: Dictionary = raw
	var normalized: Dictionary = {}
	for field: String in schema:
		if not entry.has(field):
			report("%s : champ « %s » manquant, entrée rejetée." % [context, field])
			return {}
		var kind: FieldKind = schema[field]
		if not matches_kind(entry[field], kind):
			report("%s : champ « %s » de type inattendu (%s), entrée rejetée." % [context, field, type_string(typeof(entry[field]))])
			return {}
		normalized[field] = _normalize(entry[field], kind)
	return normalized


## Bloc unique d'un fichier (et non tableau d'entrées) : présence, puis schéma.
## Vide si le bloc manque ou si son contenu est rejeté — le message est déjà
## consigné.
func accept_block(root: Dictionary, root_key: String, schema: Dictionary, context: String) -> Dictionary:
	if not root.has(root_key):
		report("%s : bloc manquant." % context)
		return {}
	return accept_entry(root[root_key], schema, context)


## Un entier JSON peut être décodé en `int` ou en `float` selon l'écriture du
## littéral : les deux sont acceptés là où un entier est attendu, à condition que
## la valeur soit effectivement entière.
func matches_kind(value: Variant, kind: FieldKind) -> bool:
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


## Un `id` vide ou dupliqué est refusé : il est la clé de tout le reste — TileSet
## (story 3.1), soute et sauvegardes (story 7.1).
func accept_id(candidate_id: String, known_ids: Array[String], context: String) -> bool:
	if candidate_id.is_empty():
		report("%s : « %s » vide, entrée rejetée." % [context, KEY_ID])
		return false
	if known_ids.has(candidate_id):
		report("%s : « %s » déjà déclaré, entrée rejetée." % [context, candidate_id])
		return false
	return true


func _normalize(value: Variant, kind: FieldKind) -> Variant:
	match kind:
		FieldKind.INT:
			return int(value)
		FieldKind.FLOAT:
			return float(value)
	return value
