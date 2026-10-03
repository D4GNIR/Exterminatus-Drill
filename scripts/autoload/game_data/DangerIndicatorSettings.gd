class_name DangerIndicatorSettings
extends RefCounted

## Chargeur et paramètres de l'**indicateur de danger non chiffré** — bloc
## `indicateur_danger` de `data/generation.json` (story 6.8, amendement §4.3,
## arbitrages `Q17`, `Q30`, `Q69` (a)).
##
## Une seule responsabilité : lire, valider et servir ce bloc. Instancié
## **uniquement** par l'autoload `GameData`, qui reste la façade publique.
##
## **Pourquoi ici, et pourquoi un chargeur distinct** : le bloc vit dans
## `generation.json`, à côté du découpage `couches_profondeur` qu'il réutilise
## (`Q30`, même procédé que `menaces` de la story 6.6) — aucune frontière n'est
## répétée. `GenerationSettings.gd` dépasse déjà 750 lignes (`B4`) et la teinte ou
## l'ambiance ne sont pas des paramètres de génération. Le fichier n'est relu que
## si les paliers ont été acceptés : un fichier fautif n'est signalé qu'une fois.
##
## Contraintes opposables à l'audit `6.9` :
## [br]— **`M5` — aucun chiffre** : ce bloc ne porte que des couleurs, des opacités,
## des flux et des volumes ; rien de ce qui est servi ici n'est un texte.
## [br]— **`D1`, `D2` — tout en données, validé au chargement** : chaque palier
## déclaré **une et une seule fois** ; `teinte` couleur `#rrggbb` ; opacités dans
## `[0, 1]` et **non décroissantes** d'un palier au suivant (le danger ne baisse
## pas en descendant) ; `ambiance` chemin d'un flux existant sous
## `res://assets/audio/`, ou vide pour un palier sans ambiance (le premier) ; `volume_db` dans `[-80, 0[`, sous le niveau nominal des
## alertes ; `duree_transition_s` strictement positive (jamais de basculement
## brutal). **Un seul défaut rejette tout le bloc** : l'indicateur reste alors
## neutre et muet, plutôt qu'un palier partiellement inventé.
## [br]— **`Q69` (a)** : les teintes sont des **données** ; les ambiances sont des
## assets générés, substituables sans toucher au code.

const ROOT: String = "indicateur_danger"
const KEY_TRANSITION: String = "duree_transition_s"
const KEY_LAYERS: String = "paliers"
const KEY_TINT: String = "teinte"
const KEY_VEIL: String = "opacite_voile"
const KEY_EDGES: String = "opacite_bords"
const KEY_AMBIENCE: String = "ambiance"
const KEY_VOLUME: String = "volume_db"

## Seul dossier admis pour les flux d'ambiance (`A1`, `assets/README.md`).
const AMBIENCE_DIR: String = "res://assets/audio/"
## Bornes du volume : -80 dB est le silence de Godot ; 0 dB, niveau nominal des
## alertes (`4.2`), est exclu pour que l'ambiance ne les couvre jamais.
const VOLUME_MIN_DB: float = -80.0
const VOLUME_MAX_DB: float = 0.0

const BLOCK_SCHEMA: Dictionary = {
	KEY_TRANSITION: DataValidator.FieldKind.FLOAT,
	KEY_LAYERS: DataValidator.FieldKind.DICT,
}

const LAYER_SCHEMA: Dictionary = {
	KEY_TINT: DataValidator.FieldKind.STRING,
	KEY_VEIL: DataValidator.FieldKind.FLOAT,
	KEY_EDGES: DataValidator.FieldKind.FLOAT,
	KEY_AMBIENCE: DataValidator.FieldKind.STRING,
	KEY_VOLUME: DataValidator.FieldKind.FLOAT,
}

var _validator: DataValidator
var _generation: GenerationSettings
## Vides tant que le bloc n'a pas été accepté **en entier**.
var _transition_duration: float = 0.0
## `palier_id` → entrée normalisée (`teinte` convertie en `Color`).
var _layers: Dictionary[String, Dictionary] = {}


func _init(validator: DataValidator, generation: GenerationSettings) -> void:
	_validator = validator
	_generation = generation


## Validé **après** `GenerationSettings` : les paliers en viennent.
func load_file() -> void:
	var context: String = "%s → %s" % [GenerationSettings.PATH, ROOT]
	var layer_ids: Array[String] = _generation.get_depth_layer_ids()
	if layer_ids.is_empty():
		_validator.report("%s : les paliers de profondeur n'ont pas été chargés, indicateur de danger rejeté." % context)
		return
	var root: Dictionary = _validator.read_root(GenerationSettings.PATH)
	if root.is_empty():
		return
	if not root.has(ROOT):
		_validator.report("%s : bloc manquant." % context)
		return
	_accept_block(root[ROOT], layer_ids, context)


## Bloc complet : schéma, durée du fondu, paliers connus, puis chaque palier.
## N'écrit rien si un seul défaut est trouvé. Séparé de `load_file()` pour être
## éprouvé sur des données modifiées sans toucher au fichier.
func _accept_block(raw: Variant, layer_ids: Array[String], context: String) -> bool:
	var block: Dictionary = _validator.accept_entry(raw, BLOCK_SCHEMA, context)
	if block.is_empty():
		return false
	if block[KEY_TRANSITION] <= 0.0:
		_validator.report("%s : « %s » doit être strictement positif (lu : %s) — un changement de palier ne bascule jamais d'un coup, indicateur de danger rejeté." % [context, KEY_TRANSITION, block[KEY_TRANSITION]])
		return false
	var layers: Dictionary = block[KEY_LAYERS]
	for layer_id: Variant in layers:
		if not layer_ids.has(layer_id):
			_validator.report("%s → %s : palier « %s » inconnu — il ne figure pas dans « %s », indicateur de danger rejeté." % [context, KEY_LAYERS, layer_id, GenerationSettings.ROOT_DEPTH_LAYERS])
			return false
	if not _accept_layers(layers, layer_ids, "%s → %s" % [context, KEY_LAYERS]):
		return false
	_transition_duration = block[KEY_TRANSITION]
	return true


## Paliers dans l'ordre de `couches_profondeur` : c'est cet ordre qui définit la
## progression exigée des opacités. N'écrit rien si un seul palier est fautif.
func _accept_layers(layers: Dictionary, layer_ids: Array[String], context: String) -> bool:
	var accepted: Dictionary[String, Dictionary] = {}
	var previous_veil: float = 0.0
	var previous_edges: float = 0.0
	for layer_id: String in layer_ids:
		var layer_context: String = "%s → %s" % [context, layer_id]
		if not layers.has(layer_id):
			_validator.report("%s : palier sans indicateur de danger déclaré, indicateur de danger rejeté." % layer_context)
			return false
		var entry: Dictionary = _validator.accept_entry(layers[layer_id], LAYER_SCHEMA, layer_context)
		if entry.is_empty():
			return false
		var tint: String = entry[KEY_TINT]
		if not (tint.length() == 7 and tint.begins_with("#") and Color.html_is_valid(tint)):
			_validator.report("%s : « %s » doit être une couleur « #rrggbb » (lu : « %s »), indicateur de danger rejeté." % [layer_context, KEY_TINT, tint])
			return false
		for key: String in [KEY_VEIL, KEY_EDGES]:
			var opacity: float = entry[key]
			if opacity < 0.0 or opacity > 1.0:
				_validator.report("%s : « %s » hors de [0, 1] (lu : %s), indicateur de danger rejeté." % [layer_context, key, opacity])
				return false
		if entry[KEY_VEIL] < previous_veil or entry[KEY_EDGES] < previous_edges:
			_validator.report("%s : « %s » et « %s » ne peuvent pas décroître d'un palier au suivant (lus : %s et %s, palier précédent : %s et %s), indicateur de danger rejeté." % [layer_context, KEY_VEIL, KEY_EDGES, entry[KEY_VEIL], entry[KEY_EDGES], previous_veil, previous_edges])
			return false
		var path: String = entry[KEY_AMBIENCE]
		if not path.is_empty() and (not path.begins_with(AMBIENCE_DIR) or not ResourceLoader.exists(path)):
			_validator.report("%s : « %s » doit être vide (aucune ambiance) ou désigner un flux existant sous %s (lu : « %s »), indicateur de danger rejeté." % [layer_context, KEY_AMBIENCE, AMBIENCE_DIR, path])
			return false
		var volume: float = entry[KEY_VOLUME]
		if volume < VOLUME_MIN_DB or volume >= VOLUME_MAX_DB:
			_validator.report("%s : « %s » hors de [%s, %s[ (lu : %s) — l'ambiance reste sous le niveau des alertes, indicateur de danger rejeté." % [layer_context, KEY_VOLUME, VOLUME_MIN_DB, VOLUME_MAX_DB, volume])
			return false
		previous_veil = entry[KEY_VEIL]
		previous_edges = entry[KEY_EDGES]
		entry[KEY_TINT] = Color.html(tint)
		accepted[layer_id] = entry
	_layers = accepted
	return true


func has_settings() -> bool:
	return not _layers.is_empty()


func get_layer_count() -> int:
	return _layers.size()


func get_transition_duration() -> float:
	return _transition_duration


## Couleur du voile uniforme du palier : teinte, alpha = `opacite_voile`.
func get_veil_color(layer_id: String) -> Color:
	var entry: Dictionary = _entry(layer_id)
	if entry.is_empty():
		return Color(0.0, 0.0, 0.0, 0.0)
	var color: Color = entry[KEY_TINT]
	color.a = entry[KEY_VEIL]
	return color


## Couleur de l'assombrissement des bords du palier : teinte, alpha = `opacite_bords`.
func get_edge_color(layer_id: String) -> Color:
	var entry: Dictionary = _entry(layer_id)
	if entry.is_empty():
		return Color(0.0, 0.0, 0.0, 0.0)
	var color: Color = entry[KEY_TINT]
	color.a = entry[KEY_EDGES]
	return color


## Vide : palier sans ambiance de danger (silence).
func get_ambience_path(layer_id: String) -> String:
	var entry: Dictionary = _entry(layer_id)
	return "" if entry.is_empty() else String(entry[KEY_AMBIENCE])


func get_ambience_volume_db(layer_id: String) -> float:
	var entry: Dictionary = _entry(layer_id)
	return VOLUME_MIN_DB if entry.is_empty() else float(entry[KEY_VOLUME])


## Entrée vide et erreur pour un palier inconnu : aucune teinte inventée.
func _entry(layer_id: String) -> Dictionary:
	if not _layers.has(layer_id):
		push_error("GameData — indicateur de danger : palier inconnu « %s » (voir %s)." % [layer_id, GenerationSettings.PATH])
		return {}
	return _layers[layer_id]
