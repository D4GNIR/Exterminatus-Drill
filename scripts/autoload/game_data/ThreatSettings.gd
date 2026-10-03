class_name ThreatSettings
extends RefCounted

## Chargeur et paramètres de la **courbe de risque** — bloc `menaces` de
## `data/generation.json` (story 6.6, amendement §4.2, arbitrages `Q17`, `Q19`,
## `Q30`, `Q67`).
##
## Une seule responsabilité : lire, valider et servir ce bloc. Instancié
## **uniquement** par l'autoload `GameData`, qui reste la façade publique.
##
## **Pourquoi un chargeur distinct de `GenerationSettings`** : le bloc vit dans
## `generation.json`, à côté du découpage `couches_profondeur` qu'il réutilise
## (`Q30`, procédé de `densites_minerai`), mais `GenerationSettings.gd` dépasse déjà
## 750 lignes (vigilance `B4` relevée par `6.1`) et la courbe de risque n'est pas
## un paramètre de génération du terrain. Le fichier est relu ici **seulement si**
## les paliers ont été acceptés : un fichier absent ou malformé n'est donc signalé
## qu'une fois, par `GenerationSettings`.
##
## Contraintes opposables à l'audit `6.9` :
## [br]— **`Q30` — aucun second découpage** : les paliers sont les `id` de
## `couches_profondeur`, lus sur `GenerationSettings` ; aucune profondeur ici.
## [br]— **`M2`, `D1`, `D2` — probabilités en données, validées au chargement** :
## chaque palier déclaré **une et une seule fois**, probabilité dans `[0, 1]`,
## **strictement croissante** d'un palier au suivant ; type de menace complet
## (`id` unique non vide, `nom_affiche` non vide, `degats` strictement positifs).
## **Un seul défaut rejette tout le bloc** : aucune rencontre n'est alors tirée,
## plutôt qu'une courbe partiellement inventée.
## [br]— **`M6` — graine dédiée** : `graine` ensemence le générateur de menace,
## distinct de celui du terrain et du loot.

const ROOT: String = "menaces"
const KEY_SEED: String = "graine"
const KEY_FEEDBACK_DURATION: String = "duree_retour_s"
const KEY_LAYERS: String = "paliers"
const KEY_PROBABILITY: String = "probabilite_rencontre"
const KEY_DAMAGE: String = "degats"

const BLOCK_SCHEMA: Dictionary = {
	KEY_SEED: DataValidator.FieldKind.INT,
	KEY_FEEDBACK_DURATION: DataValidator.FieldKind.FLOAT,
	KEY_LAYERS: DataValidator.FieldKind.DICT,
}

## Un palier de la courbe : probabilité de rencontre par tuile détruite, et le
## type de menace propre au palier (`Q67` (a) : un type par palier).
const LAYER_SCHEMA: Dictionary = {
	KEY_PROBABILITY: DataValidator.FieldKind.FLOAT,
	DataValidator.KEY_ID: DataValidator.FieldKind.STRING,
	DataValidator.KEY_NAME: DataValidator.FieldKind.STRING,
	KEY_DAMAGE: DataValidator.FieldKind.FLOAT,
}

var _validator: DataValidator
var _generation: GenerationSettings
## Vides tant que le bloc n'a pas été accepté **en entier**.
var _seed: int = 0
var _feedback_duration: float = 0.0
## `palier_id` → probabilité de rencontre par tuile détruite.
var _probabilities: Dictionary[String, float] = {}
## `palier_id` → `id` du type de menace du palier.
var _layer_threats: Dictionary[String, String] = {}
## `id` de menace → nom affiché, et → dégâts.
var _names: Dictionary[String, String] = {}
var _damages: Dictionary[String, float] = {}


func _init(validator: DataValidator, generation: GenerationSettings) -> void:
	_validator = validator
	_generation = generation


## Validé **après** `GenerationSettings` : les paliers en viennent.
func load_file() -> void:
	var context: String = "%s → %s" % [GenerationSettings.PATH, ROOT]
	var layer_ids: Array[String] = _generation.get_depth_layer_ids()
	if layer_ids.is_empty():
		_validator.report("%s : les paliers de profondeur n'ont pas été chargés, courbe de risque rejetée." % context)
		return
	var root: Dictionary = _validator.read_root(GenerationSettings.PATH)
	if root.is_empty():
		return
	var block: Dictionary = _validator.accept_block(root, ROOT, BLOCK_SCHEMA, context)
	if block.is_empty():
		return
	if block[KEY_FEEDBACK_DURATION] <= 0.0:
		_validator.report("%s : « %s » doit être strictement positif (lu : %s), courbe de risque rejetée." % [context, KEY_FEEDBACK_DURATION, block[KEY_FEEDBACK_DURATION]])
		return
	var layers: Dictionary = block[KEY_LAYERS]
	for layer_id: Variant in layers:
		if not layer_ids.has(layer_id):
			_validator.report("%s → %s : palier « %s » inconnu — il ne figure pas dans « %s », courbe de risque rejetée." % [context, KEY_LAYERS, layer_id, GenerationSettings.ROOT_DEPTH_LAYERS])
			return
	if not _accept_layers(layers, layer_ids, "%s → %s" % [context, KEY_LAYERS]):
		return
	_seed = block[KEY_SEED]
	_feedback_duration = block[KEY_FEEDBACK_DURATION]


## Paliers dans l'ordre de `couches_profondeur` : c'est cet ordre qui définit la
## croissance exigée. N'écrit rien si un seul palier est fautif.
func _accept_layers(layers: Dictionary, layer_ids: Array[String], context: String) -> bool:
	var probabilities: Dictionary[String, float] = {}
	var layer_threats: Dictionary[String, String] = {}
	var names: Dictionary[String, String] = {}
	var damages: Dictionary[String, float] = {}
	var previous: float = -1.0
	for layer_id: String in layer_ids:
		var layer_context: String = "%s → %s" % [context, layer_id]
		if not layers.has(layer_id):
			_validator.report("%s : palier sans probabilité de rencontre déclarée, courbe de risque rejetée." % layer_context)
			return false
		var entry: Dictionary = _validator.accept_entry(layers[layer_id], LAYER_SCHEMA, layer_context)
		if entry.is_empty():
			return false
		var probability: float = entry[KEY_PROBABILITY]
		if probability < 0.0 or probability > 1.0:
			_validator.report("%s : « %s » hors de [0, 1] (lue %s), courbe de risque rejetée." % [layer_context, KEY_PROBABILITY, probability])
			return false
		if probability <= previous:
			_validator.report("%s : « %s » (%s) doit être strictement supérieure à celle du palier précédent (%s), courbe de risque rejetée." % [layer_context, KEY_PROBABILITY, probability, previous])
			return false
		var threat_id: String = entry[DataValidator.KEY_ID]
		var known_ids: Array[String] = []
		known_ids.assign(names.keys())
		if not _validator.accept_id(threat_id, known_ids, layer_context):
			return false
		if String(entry[DataValidator.KEY_NAME]).strip_edges().is_empty():
			_validator.report("%s : « %s » vide — le nom de la menace est affiché au joueur, courbe de risque rejetée." % [layer_context, DataValidator.KEY_NAME])
			return false
		if entry[KEY_DAMAGE] <= 0.0:
			_validator.report("%s : « %s » doit être strictement positif (lu : %s) — une menace sans dégâts n'en est pas une, courbe de risque rejetée." % [layer_context, KEY_DAMAGE, entry[KEY_DAMAGE]])
			return false
		previous = probability
		probabilities[layer_id] = probability
		layer_threats[layer_id] = threat_id
		names[threat_id] = entry[DataValidator.KEY_NAME]
		damages[threat_id] = entry[KEY_DAMAGE]
	_probabilities = probabilities
	_layer_threats = layer_threats
	_names = names
	_damages = damages
	return true


func has_threat_settings() -> bool:
	return not _probabilities.is_empty()


func get_layer_count() -> int:
	return _probabilities.size()


func get_seed() -> int:
	return _seed


func get_feedback_duration() -> float:
	return _feedback_duration


## `0.0` et erreur pour un palier inconnu : aucune probabilité inventée.
func get_probability(layer_id: String) -> float:
	if not _probabilities.has(layer_id):
		push_error("GameData — courbe de risque : palier inconnu « %s » (voir %s)." % [layer_id, GenerationSettings.PATH])
		return 0.0
	return _probabilities[layer_id]


func get_layer_threat_id(layer_id: String) -> String:
	if not _layer_threats.has(layer_id):
		push_error("GameData — courbe de risque : palier inconnu « %s » (voir %s)." % [layer_id, GenerationSettings.PATH])
		return ""
	return _layer_threats[layer_id]


func get_threat_name(threat_id: String) -> String:
	if not _names.has(threat_id):
		push_error("GameData — menace inconnue : « %s » (voir %s)." % [threat_id, GenerationSettings.PATH])
		return ""
	return _names[threat_id]


func get_threat_damage(threat_id: String) -> float:
	if not _damages.has(threat_id):
		push_error("GameData — menace inconnue : « %s » (voir %s)." % [threat_id, GenerationSettings.PATH])
		return 0.0
	return _damages[threat_id]
