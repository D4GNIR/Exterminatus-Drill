class_name EventCatalog
extends RefCounted

## Chargeur et catalogue de `data/events.json` — événements narratifs (story 1.5,
## découpé de `GameData` par la story 5.11, conditions typées par la story 6.3).
##
## Une seule responsabilité : lire, valider et servir ce fichier. Instancié
## **uniquement** par l'autoload `GameData`, qui reste la façade publique.
##
## **Conditions de déclenchement typées** (story 6.3, `Q71` (a)) : la liste
## racine `types_condition` déclare les types en usage ; chacun doit être un type
## **évalué par `NarrativeSystem`** (`SUPPORTED_TRIGGER_TYPES`), et chaque
## événement doit en employer un. Un type inconnu — non déclaré, ou déclaré mais
## non évalué par le code — est **rejeté au chargement**, bruyamment (`D2`) :
## jamais un événement qui ne se déclencherait pas sans rien dire.
##
## **Locuteurs et lignes** (story 6.2, `Q72` (a)) : la liste racine `locuteurs`
## déclare les émetteurs radio (`id`, `nom_affiche`) ; le `locuteur` de chaque
## événement doit y figurer, sinon l'événement est **rejeté au chargement** — le
## dialogue n'affiche jamais un identifiant brut. Une ligne de dialogue vide est
## signalée et ignorée ; un événement sans ligne est rejeté. Aucun texte narratif
## n'est écrit dans le code (`D1`) : noms et lignes viennent de ce fichier.
##
## **Alerte « anomalie proche »** (story 6.4, `Q71` (a), CDC « Direction
## sonore ») : le bloc racine `alerte_anomalie_proche` désigne l'événement de
## proximité dont l'alerte annonce l'approche, et porte le **rayon d'alerte** et
## la **marge de sortie**, en mètres. Validé au chargement (`D2`) : événement
## connu, actif au MVP, de type `proximite_anomalie_m` ; rayon d'alerte
## **strictement supérieur** à son rayon de déclenchement ; marge strictement
## positive. Un bloc rejeté désactive l'alerte, bruyamment — l'événement, lui,
## reste valide et se déclenche.

const PATH: String = "res://data/events.json"
const ROOT: String = "evenements"
## Types de condition déclarés par les données (story 6.3).
const ROOT_TRIGGER_TYPES: String = "types_condition"
## Émetteurs radio déclarés par les données (story 6.2).
const ROOT_SPEAKERS: String = "locuteurs"
## Alerte « anomalie proche » (story 6.4).
const ROOT_ANOMALY_ALERT: String = "alerte_anomalie_proche"
const KEY_ALERT_EVENT: String = "evenement"
const KEY_ALERT_RADIUS: String = "rayon_m"
const KEY_ALERT_EXIT_MARGIN: String = "marge_sortie_m"

const KEY_TRIGGER: String = "condition_declenchement"
const KEY_TRIGGER_TYPE: String = "type"
const KEY_FLAG: String = "flag"
const KEY_SPEAKER: String = "locuteur"
const KEY_LINES: String = "lignes_de_dialogue"

# --- Types de condition évalués par `NarrativeSystem` (story 6.3) --------------
# Ce sont des identifiants de données, pas des valeurs : le seuil de chaque
# condition est le champ `valeur` de l'événement (`D1`).

## Proximité de l'ancrage de l'anomalie (`Q71` (a)) : `valeur` = rayon de
## déclenchement, en mètres (> 0), mesuré du centre de la foreuse au centre de la
## cellule d'ancrage (`GameData.get_anomaly_cell()`).
const TRIGGER_ANOMALY_PROXIMITY: String = "proximite_anomalie_m"
## Début de partie (prologue, story 6.2) : aucune `valeur` — la condition est
## remplie dès la première évaluation ; seul le flag en porte l'unicité.
const TRIGGER_GAME_START: String = "debut_partie"

## Type évalué → prend-il un seuil `valeur` ? Un type absent de ce tableau n'est
## évalué par aucun code : déclaré dans les données, il est rejeté au chargement.
## `profondeur_min_m` (story 6.3) n'y figure plus : son seul consommateur,
## `anomalie_necropole`, se déclenche par proximité depuis la story 6.4 (`Q71`
## (a)), et un type sans événement n'est pas conservé (`B6`).
const SUPPORTED_TRIGGER_TYPES: Dictionary[String, bool] = {
	TRIGGER_ANOMALY_PROXIMITY: true,
	TRIGGER_GAME_START: false,
}

const SCHEMA: Dictionary = {
	DataValidator.KEY_ID: DataValidator.FieldKind.STRING,
	DataValidator.KEY_NAME: DataValidator.FieldKind.STRING,
	DataValidator.KEY_ACTIVE_MVP: DataValidator.FieldKind.BOOL,
	KEY_TRIGGER: DataValidator.FieldKind.DICT,
	KEY_FLAG: DataValidator.FieldKind.STRING,
	KEY_SPEAKER: DataValidator.FieldKind.STRING,
	KEY_LINES: DataValidator.FieldKind.ARRAY,
}

## Schéma d'un locuteur : identifiant référencé par les événements, nom affiché.
const SPEAKER_SCHEMA: Dictionary = {
	DataValidator.KEY_ID: DataValidator.FieldKind.STRING,
	DataValidator.KEY_NAME: DataValidator.FieldKind.STRING,
}

## Champ commun à toutes les conditions ; `valeur` dépend du type.
const TRIGGER_SCHEMA: Dictionary = {
	KEY_TRIGGER_TYPE: DataValidator.FieldKind.STRING,
}

## Schéma du bloc d'alerte « anomalie proche » (story 6.4).
const ANOMALY_ALERT_SCHEMA: Dictionary = {
	KEY_ALERT_EVENT: DataValidator.FieldKind.STRING,
	KEY_ALERT_RADIUS: DataValidator.FieldKind.FLOAT,
	KEY_ALERT_EXIT_MARGIN: DataValidator.FieldKind.FLOAT,
}

var _validator: DataValidator
var _events: Dictionary[String, Dictionary] = {}
var _event_ids: Array[String] = []
## `id` de locuteur → nom affiché (story 6.2).
var _speaker_names: Dictionary[String, String] = {}
## Bloc d'alerte « anomalie proche » validé ; vide s'il a été rejeté (story 6.4).
var _anomaly_alert: Dictionary = {}


func _init(validator: DataValidator) -> void:
	_validator = validator


func load_file() -> void:
	var root: Dictionary = _validator.read_root(PATH)
	if root.is_empty():
		return
	_accept_root(root)


## Validation du contenu, séparée de la lecture du fichier : les types déclarés
## et les locuteurs d'abord, puis les événements, chacun contre eux.
func _accept_root(root: Dictionary) -> void:
	var trigger_types: Array[String] = _accept_trigger_types(root)
	_accept_speakers(root)
	var entries: Array = _validator.extract_array(root, PATH, ROOT)
	var flags: Array[String] = []
	for index: int in entries.size():
		var context: String = "%s → %s[%d]" % [PATH, ROOT, index]
		var entry: Dictionary = _validator.accept_entry(entries[index], SCHEMA, context)
		if entry.is_empty():
			continue
		var event_id: String = entry[DataValidator.KEY_ID]
		if not _validator.accept_id(event_id, _event_ids, context):
			continue
		var trigger: Dictionary = _accept_trigger(entry[KEY_TRIGGER], trigger_types, "%s → %s" % [context, KEY_TRIGGER])
		if trigger.is_empty():
			continue
		if not _accept_flag(entry[KEY_FLAG], flags, context):
			continue
		if not _speaker_names.has(entry[KEY_SPEAKER]):
			_validator.report("%s : locuteur « %s » absent de « %s », événement « %s » rejeté." % [context, entry[KEY_SPEAKER], ROOT_SPEAKERS, event_id])
			continue
		var lines: PackedStringArray = _read_lines(entry[KEY_LINES], context)
		if lines.is_empty():
			_validator.report("%s : aucune ligne de dialogue, événement « %s » rejeté." % [context, event_id])
			continue
		entry[KEY_TRIGGER] = trigger
		entry[KEY_LINES] = lines
		flags.append(entry[KEY_FLAG])
		_events[event_id] = entry
		_event_ids.append(event_id)
	_accept_anomaly_alert(root)


## Types déclarés par `types_condition`. Un type non évalué par le code, vide ou
## répété est signalé et écarté : les événements qui l'emploient seront rejetés à
## leur tour, avec leur propre message.
func _accept_trigger_types(root: Dictionary) -> Array[String]:
	var accepted: Array[String] = []
	var raw_types: Array = _validator.extract_array(root, PATH, ROOT_TRIGGER_TYPES)
	for index: int in raw_types.size():
		var context: String = "%s → %s[%d]" % [PATH, ROOT_TRIGGER_TYPES, index]
		if typeof(raw_types[index]) != TYPE_STRING:
			_validator.report("%s : type de condition non textuel, ignoré." % context)
			continue
		var trigger_type: String = raw_types[index]
		if not SUPPORTED_TRIGGER_TYPES.has(trigger_type):
			_validator.report("%s : type de condition « %s » inconnu — aucun code ne l'évalue (types évalués : %s), ignoré." % [context, trigger_type, ", ".join(SUPPORTED_TRIGGER_TYPES.keys())])
			continue
		if accepted.has(trigger_type):
			_validator.report("%s : type de condition « %s » déjà déclaré, ignoré." % [context, trigger_type])
			continue
		accepted.append(trigger_type)
	return accepted


## Locuteurs déclarés par `locuteurs`. Un locuteur incomplet, à `id` vide ou
## répété, ou à nom affiché vide, est signalé et écarté : les événements qui le
## citent seront rejetés à leur tour, avec leur propre message.
func _accept_speakers(root: Dictionary) -> void:
	var known_ids: Array[String] = []
	var raw_speakers: Array = _validator.extract_array(root, PATH, ROOT_SPEAKERS)
	for index: int in raw_speakers.size():
		var context: String = "%s → %s[%d]" % [PATH, ROOT_SPEAKERS, index]
		var speaker: Dictionary = _validator.accept_entry(raw_speakers[index], SPEAKER_SCHEMA, context)
		if speaker.is_empty():
			continue
		var speaker_id: String = speaker[DataValidator.KEY_ID]
		if not _validator.accept_id(speaker_id, known_ids, context):
			continue
		var speaker_name: String = speaker[DataValidator.KEY_NAME]
		if speaker_name.strip_edges().is_empty():
			_validator.report("%s : « %s » vide, locuteur « %s » ignoré." % [context, DataValidator.KEY_NAME, speaker_id])
			continue
		known_ids.append(speaker_id)
		_speaker_names[speaker_id] = speaker_name


## Condition normalisée — `type`, plus `valeur` pour les types à seuil. Vide si
## rejetée : type non déclaré, seuil manquant, hors bornes ou superflu.
func _accept_trigger(raw: Variant, trigger_types: Array[String], context: String) -> Dictionary:
	var trigger: Dictionary = _validator.accept_entry(raw, TRIGGER_SCHEMA, context)
	if trigger.is_empty():
		return {}
	var trigger_type: String = trigger[KEY_TRIGGER_TYPE]
	if not trigger_types.has(trigger_type):
		_validator.report("%s : type de condition « %s » inconnu — absent de « %s », événement rejeté." % [context, trigger_type, ROOT_TRIGGER_TYPES])
		return {}
	var raw_trigger: Dictionary = raw
	var has_value: bool = raw_trigger.has(DataValidator.KEY_VALUE)
	if not SUPPORTED_TRIGGER_TYPES[trigger_type]:
		if has_value:
			_validator.report("%s : le type « %s » ne prend pas de « %s », événement rejeté." % [context, trigger_type, DataValidator.KEY_VALUE])
			return {}
		return trigger
	if not has_value or not _validator.matches_kind(raw_trigger[DataValidator.KEY_VALUE], DataValidator.FieldKind.FLOAT):
		_validator.report("%s : le type « %s » exige un seuil numérique « %s », événement rejeté." % [context, trigger_type, DataValidator.KEY_VALUE])
		return {}
	var value: float = float(raw_trigger[DataValidator.KEY_VALUE])
	if trigger_type == TRIGGER_ANOMALY_PROXIMITY and value <= 0.0:
		_validator.report("%s : rayon de déclenchement non strictement positif (%s m), événement rejeté." % [context, value])
		return {}
	trigger[DataValidator.KEY_VALUE] = value
	return trigger


## Bloc d'alerte « anomalie proche », validé **après** les événements, contre
## celui qu'il désigne : le rayon d'alerte doit dépasser **strictement** le rayon
## de déclenchement (`Q71` (a)) — sinon l'événement se déclencherait avant toute
## alerte, ou à l'instant même. Rejeté, le bloc laisse l'alerte désactivée.
func _accept_anomaly_alert(root: Dictionary) -> void:
	var context: String = "%s → %s" % [PATH, ROOT_ANOMALY_ALERT]
	var block: Dictionary = _validator.accept_block(root, ROOT_ANOMALY_ALERT, ANOMALY_ALERT_SCHEMA, context)
	if block.is_empty():
		return
	var event_id: String = block[KEY_ALERT_EVENT]
	if not has_event(event_id):
		_validator.report("%s : événement « %s » inconnu ou rejeté, alerte « anomalie proche » désactivée." % [context, event_id])
		return
	if not _events[event_id][DataValidator.KEY_ACTIVE_MVP]:
		_validator.report("%s : événement « %s » inactif au MVP, alerte « anomalie proche » désactivée." % [context, event_id])
		return
	if get_event_trigger_type(event_id) != TRIGGER_ANOMALY_PROXIMITY:
		_validator.report("%s : événement « %s » non déclenché par « %s », alerte « anomalie proche » désactivée." % [context, event_id, TRIGGER_ANOMALY_PROXIMITY])
		return
	var trigger_radius: float = get_event_trigger_value(event_id)
	var alert_radius: float = block[KEY_ALERT_RADIUS]
	if alert_radius <= trigger_radius:
		_validator.report("%s : rayon d'alerte (%s m) non strictement supérieur au rayon de déclenchement de « %s » (%s m), alerte « anomalie proche » désactivée." % [context, alert_radius, event_id, trigger_radius])
		return
	var exit_margin: float = block[KEY_ALERT_EXIT_MARGIN]
	if exit_margin <= 0.0:
		_validator.report("%s : marge de sortie non strictement positive (%s m), alerte « anomalie proche » désactivée." % [context, exit_margin])
		return
	_anomaly_alert = block


## Le flag porte **seul** l'unicité du déclenchement : vide, il ne pourrait pas
## être posé ; partagé, il empêcherait le second événement de jamais se jouer.
func _accept_flag(flag: String, known_flags: Array[String], context: String) -> bool:
	if flag.strip_edges().is_empty():
		_validator.report("%s : « %s » vide, événement rejeté." % [context, KEY_FLAG])
		return false
	if known_flags.has(flag):
		_validator.report("%s : « %s » « %s » déjà porté par un autre événement, événement rejeté." % [context, KEY_FLAG, flag])
		return false
	return true


func _read_lines(raw_lines: Array, context: String) -> PackedStringArray:
	var lines: PackedStringArray = []
	for index: int in raw_lines.size():
		if typeof(raw_lines[index]) != TYPE_STRING:
			_validator.report("%s → %s[%d] : ligne de dialogue non textuelle, ignorée." % [context, KEY_LINES, index])
			continue
		if (raw_lines[index] as String).strip_edges().is_empty():
			_validator.report("%s → %s[%d] : ligne de dialogue vide, ignorée." % [context, KEY_LINES, index])
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


## Champs d'un événement **connu** (story 6.3) : `NarrativeSystem` les lit sans
## connaître les clés JSON. Un `id` inconnu est signalé, jamais remplacé.
func get_event_flag(event_id: String) -> String:
	if not has_event(event_id):
		push_error("GameData — événement inconnu : « %s »." % event_id)
		return ""
	return _events[event_id][KEY_FLAG]


func get_event_trigger_type(event_id: String) -> String:
	if not has_event(event_id):
		push_error("GameData — événement inconnu : « %s »." % event_id)
		return ""
	return _events[event_id][KEY_TRIGGER][KEY_TRIGGER_TYPE]


## Seuil de la condition ; 0.0 pour un type sans seuil (`debut_partie`), qui ne le
## lit pas.
func get_event_trigger_value(event_id: String) -> float:
	if not has_event(event_id):
		push_error("GameData — événement inconnu : « %s »." % event_id)
		return 0.0
	return _events[event_id][KEY_TRIGGER].get(DataValidator.KEY_VALUE, 0.0)


## Nom affiché d'un événement **connu** (`nom_affiche`), relu par le journal
## (story 6.5). Un `id` inconnu est signalé, jamais remplacé.
func get_event_name(event_id: String) -> String:
	if not has_event(event_id):
		push_error("GameData — événement inconnu : « %s »." % event_id)
		return ""
	return _events[event_id][DataValidator.KEY_NAME]


## Nom affiché du locuteur d'un événement **connu** (story 6.2) : toujours
## déclaré, l'événement étant rejeté au chargement sinon.
func get_event_speaker_name(event_id: String) -> String:
	if not has_event(event_id):
		push_error("GameData — événement inconnu : « %s »." % event_id)
		return ""
	return _speaker_names[_events[event_id][KEY_SPEAKER]]


## Lignes de dialogue d'un événement **connu**, dans l'ordre des données (story
## 6.2) : jamais vides, l'événement étant rejeté au chargement sinon. Copie.
func get_event_lines(event_id: String) -> PackedStringArray:
	if not has_event(event_id):
		push_error("GameData — événement inconnu : « %s »." % event_id)
		return PackedStringArray()
	var lines: PackedStringArray = _events[event_id][KEY_LINES]
	return lines.duplicate()


# --- Alerte « anomalie proche » (story 6.4) -------------------------------------

## Vrai si le bloc d'alerte a été accepté au chargement.
func has_anomaly_alert() -> bool:
	return not _anomaly_alert.is_empty()


## Événement de proximité dont l'alerte annonce l'approche ; vide sans alerte.
func get_anomaly_alert_event_id() -> String:
	return _anomaly_alert.get(KEY_ALERT_EVENT, "")


## Rayon d'alerte, en mètres (centre de la foreuse → centre de la cellule
## d'ancrage) ; 0.0 sans alerte.
func get_anomaly_alert_radius_m() -> float:
	return _anomaly_alert.get(KEY_ALERT_RADIUS, 0.0)


## Marge, en mètres, au-delà du rayon d'alerte, avant que l'alerte ne s'éteigne ;
## 0.0 sans alerte.
func get_anomaly_alert_exit_margin_m() -> float:
	return _anomaly_alert.get(KEY_ALERT_EXIT_MARGIN, 0.0)
