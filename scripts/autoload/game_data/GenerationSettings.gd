class_name GenerationSettings
extends RefCounted

## Chargeur et paramètres de `data/generation.json` — dimensions de la carte,
## ancrages, graine, strates, paliers de profondeur, densités de minerai et table
## de loot (stories 3.2 à 3.7, découpé de `GameData` par la story 5.11).
##
## Une seule responsabilité : lire, valider et servir ce fichier. Instancié
## **uniquement** par l'autoload `GameData`, qui reste la façade publique.
##
## Ce fichier est la **source de vérité des dimensions de la carte** : le bloc
## `monde` y a été migré depuis `data/drill.json` (story 3.2, contrainte dérivée de
## Q24). Tout est exprimé **en tuiles** ; les pixels ne sont qu'une vue dérivée,
## calculée avec le facteur `pixels_par_metre` de `DrillSettings`.
##
## Dépendances **explicites**, injectées à la construction : le catalogue des
## ressources (densités et loot n'acceptent que des minerais connus et actifs au
## MVP, `K10`), et les paramètres de la foreuse (conversion tuiles → pixels). Il
## doit donc être chargé **après** eux.

const PATH: String = "res://data/generation.json"

const ROOT_WORLD: String = "monde"
const ROOT_GENERATION: String = "generation"
const ROOT_ANCHORS: String = "ancrages"
const ROOT_STRATA: String = "strates"
const ROOT_DEPTH_LAYERS: String = "couches_profondeur"
const ROOT_LAYER_TRANSITION: String = "transition_paliers"
const ROOT_ORE_DENSITY: String = "densites_minerai"
const ROOT_LOOT: String = "loot"

const KEY_LOOT_ENTRIES: String = "entrees"
const KEY_LOOT_WEIGHTS: String = "poids"
const KEY_LOOT_RESOURCE_ID: String = "resource_id"
const KEY_LOOT_HIGH_RARITY: String = "rarete_haute"

# Dimensions de la carte, **en tuiles** (story 3.2). Les quatre bords en pixels
# n'existent pas comme données : ils sont **dérivés** par `get_world_bounds()`.
# C'est ce qui interdit au générateur et au confinement de la foreuse de décrire
# deux cartes différentes — contrainte dérivée de Q24, refermée par construction.

const KEY_MAP_WIDTH: String = "largeur_tuiles"
const KEY_MAP_SURFACE: String = "hauteur_surface_tuiles"
const KEY_MAP_DEPTH: String = "profondeur_tuiles"
const KEY_MAP_BELT: String = "epaisseur_ceinture_tuiles"

const KEY_SEED: String = "graine"

# Ancrages indépendants de la graine (story 3.3, point d'audit K3), en tuiles.
# Colonne 0 = centre de la carte ; rangée 0 = première rangée sous la surface.
const KEY_SURFACE_COLUMN_MIN: String = "zone_surface_colonne_min"
const KEY_SURFACE_COLUMN_MAX: String = "zone_surface_colonne_max"
const KEY_SPAWN_COLUMN: String = "apparition_colonne"
const KEY_ANOMALY_COLUMN: String = "anomalie_colonne"
const KEY_ANOMALY_ROW: String = "anomalie_rangee"
const KEY_DEPTH_MAX_M: String = "profondeur_max_m"
const KEY_DEPTH_MIN_M: String = "profondeur_min_m"
const KEY_HARDNESS: String = "hardness"
## Marge d'hystérésis du palier courant, en mètres (story 6.1).
const KEY_HYSTERESIS_M: String = "marge_hysteresis_m"

## Sentinelle « jusqu'au fond de la carte » pour la dernière strate et le dernier
## palier de profondeur. Une borne négative ne peut pas être une profondeur réelle,
## ce qui la rend non ambiguë — contrairement à 0, qui est la surface.
const DEPTH_UNBOUNDED: float = -1.0

## Dimensions de la carte, en tuiles. Toutes strictement positives : une carte
## sans largeur, sans profondeur ou sans ceinture n'est pas une carte dégradée,
## c'est une carte absente.
const MAP_SCHEMA: Dictionary = {
	KEY_MAP_WIDTH: DataValidator.FieldKind.INT,
	KEY_MAP_SURFACE: DataValidator.FieldKind.INT,
	KEY_MAP_DEPTH: DataValidator.FieldKind.INT,
	KEY_MAP_BELT: DataValidator.FieldKind.INT,
}

## Graine de génération. Aucune borne : toute valeur entière est une graine
## légitime, y compris négative ou nulle — c'est justement ce qui la rend forçable.
const GENERATION_SCHEMA: Dictionary = {
	KEY_SEED: DataValidator.FieldKind.INT,
}

## Ancrages du monde. Les bornes se vérifient **contre les dimensions de la carte**
## (`_load_anchors`) : un ancrage dans la ceinture ou hors carte est rejeté.
const ANCHORS_SCHEMA: Dictionary = {
	KEY_SURFACE_COLUMN_MIN: DataValidator.FieldKind.INT,
	KEY_SURFACE_COLUMN_MAX: DataValidator.FieldKind.INT,
	KEY_SPAWN_COLUMN: DataValidator.FieldKind.INT,
	KEY_ANOMALY_COLUMN: DataValidator.FieldKind.INT,
	KEY_ANOMALY_ROW: DataValidator.FieldKind.INT,
}

## Une strate : jusqu'à quelle profondeur elle s'étend, et la dureté de sa tuile.
const STRATUM_SCHEMA: Dictionary = {
	KEY_DEPTH_MAX_M: DataValidator.FieldKind.FLOAT,
	KEY_HARDNESS: DataValidator.FieldKind.INT,
}

## Un palier de profondeur — clé commune à la table de loot (§2.2) et à la courbe
## de risque (§4.2), arbitrage Q30 : un seul découpage. `nom_affiche` est le nom
## de zone montré au joueur à la transition (story 6.1, `Q70` (a)).
const DEPTH_LAYER_SCHEMA: Dictionary = {
	DataValidator.KEY_ID: DataValidator.FieldKind.STRING,
	DataValidator.KEY_NAME: DataValidator.FieldKind.STRING,
	KEY_DEPTH_MIN_M: DataValidator.FieldKind.FLOAT,
	KEY_DEPTH_MAX_M: DataValidator.FieldKind.FLOAT,
}

## Transition entre paliers (story 6.1) : marge d'hystérésis en mètres.
const LAYER_TRANSITION_SCHEMA: Dictionary = {
	KEY_HYSTERESIS_M: DataValidator.FieldKind.FLOAT,
}

var _validator: DataValidator
var _resources: ResourceCatalog
var _drill: DrillSettings
## Dimensions, ancrages, graine, strates, paliers et densités. Vides si rejetés :
## le générateur refuse alors de produire un terrain, et la foreuse n'a aucun point
## d'apparition, plutôt que de s'appuyer sur des valeurs inventées.
var _map: Dictionary[String, int] = {}
var _generation: Dictionary[String, int] = {}
var _anchors: Dictionary[String, int] = {}
var _strata: Array[Dictionary] = []
var _depth_layers: Array[Dictionary] = []
var _depth_layer_ids: Array[String] = []
## Marge d'hystérésis du palier courant, en mètres. Négative tant qu'elle n'a pas
## été acceptée : aucune marge n'est inventée (`D2`).
var _layer_hysteresis_m: float = -1.0
## `palier_id` → (`resource_id` → probabilité par case creusée).
var _ore_density: Dictionary[String, Dictionary] = {}
## Table de loot (story 3.6) : entrées dans l'ordre déclaré — cet ordre fait partie
## du contrat de reproductibilité du tirage —, ressource de chaque entrée, et poids
## par palier alignés sur cet ordre. Vides si rejetés : aucun tirage n'a lieu.
var _loot_entry_ids: Array[String] = []
var _loot_resources: Dictionary[String, String] = {}
var _loot_weights: Dictionary[String, PackedFloat64Array] = {}
## Entrées marquées `rarete_haute` (story 3.7, `Q35`).
var _loot_high_rarity: Array[String] = []


func _init(validator: DataValidator, resources: ResourceCatalog, drill: DrillSettings) -> void:
	_validator = validator
	_resources = resources
	_drill = drill


## Lecture unique du fichier, puis validation bloc par bloc : plusieurs lectures
## dédoubleraient les messages d'erreur. L'ordre compte — les ancrages se bornent
## sur `monde`, densités et loot sur les paliers.
func load_file() -> void:
	var root: Dictionary = _validator.read_root(PATH)
	if root.is_empty():
		return
	_load_map_block(root)
	_load_anchors(root)
	_load_generation_block(root)
	_load_strata(root)
	_load_depth_layers(root)
	_load_layer_transition(root)
	_load_ore_density(root)
	_load_loot(root)


# --- Chargement : monde, ancrages, graine --------------------------------------

func _load_map_block(root: Dictionary) -> void:
	var context: String = "%s → %s" % [PATH, ROOT_WORLD]
	var block: Dictionary = _validator.accept_block(root, ROOT_WORLD, MAP_SCHEMA, context)
	if block.is_empty():
		return
	for field: String in block:
		if block[field] <= 0:
			_validator.report("%s : champ « %s » doit être strictement positif (lu : %d), bloc rejeté." % [context, field, block[field]])
			return
	# Il faut au moins une colonne intérieure entre les deux colonnes de ceinture,
	# sinon la carte est une paroi pleine et la descente est impossible.
	var minimum_width: int = 2 * block[KEY_MAP_BELT] + 1
	if block[KEY_MAP_WIDTH] < minimum_width:
		_validator.report("%s : « %s » (%d) doit valoir au moins %d pour laisser une colonne creusable entre les deux ceintures, bloc rejeté." % [context, KEY_MAP_WIDTH, block[KEY_MAP_WIDTH], minimum_width])
		return
	for field: String in block:
		_map[field] = block[field]


## Ancrages du monde, validés **après** le bloc `monde` : leurs bornes en dépendent.
## Colonnes intérieures seulement (hors ceinture), apparition dans la zone de
## surface, anomalie sur une rangée creusable.
func _load_anchors(root: Dictionary) -> void:
	var context: String = "%s → %s" % [PATH, ROOT_ANCHORS]
	var block: Dictionary = _validator.accept_block(root, ROOT_ANCHORS, ANCHORS_SCHEMA, context)
	if block.is_empty():
		return
	if not has_world_bounds():
		_validator.report("%s : bloc « %s » invalide, impossible de borner les ancrages — bloc rejeté." % [context, ROOT_WORLD])
		return
	var first_column: int = _get_first_interior_column()
	var last_column: int = _get_last_interior_column()
	for field: String in [KEY_SURFACE_COLUMN_MIN, KEY_SURFACE_COLUMN_MAX, KEY_SPAWN_COLUMN, KEY_ANOMALY_COLUMN]:
		if block[field] < first_column or block[field] > last_column:
			_validator.report("%s : « %s » (%d) hors des colonnes intérieures [%d, %d], bloc rejeté." % [context, field, block[field], first_column, last_column])
			return
	if block[KEY_SURFACE_COLUMN_MIN] > block[KEY_SURFACE_COLUMN_MAX]:
		_validator.report("%s : « %s » supérieur à « %s », bloc rejeté." % [context, KEY_SURFACE_COLUMN_MIN, KEY_SURFACE_COLUMN_MAX])
		return
	if block[KEY_SPAWN_COLUMN] < block[KEY_SURFACE_COLUMN_MIN] or block[KEY_SPAWN_COLUMN] > block[KEY_SURFACE_COLUMN_MAX]:
		_validator.report("%s : « %s » (%d) hors de la zone de surface, bloc rejeté." % [context, KEY_SPAWN_COLUMN, block[KEY_SPAWN_COLUMN]])
		return
	if block[KEY_ANOMALY_ROW] < 0 or block[KEY_ANOMALY_ROW] >= _map[KEY_MAP_DEPTH]:
		_validator.report("%s : « %s » (%d) hors des rangées creusables [0, %d], bloc rejeté." % [context, KEY_ANOMALY_ROW, block[KEY_ANOMALY_ROW], _map[KEY_MAP_DEPTH] - 1])
		return
	for field: String in block:
		_anchors[field] = block[field]


func _load_generation_block(root: Dictionary) -> void:
	var context: String = "%s → %s" % [PATH, ROOT_GENERATION]
	var block: Dictionary = _validator.accept_block(root, ROOT_GENERATION, GENERATION_SCHEMA, context)
	for field: String in block:
		_generation[field] = block[field]


# --- Chargement : strates et paliers de profondeur ------------------------------

## Strates de terrain, de la surface vers le fond. La **dernière** doit porter la
## sentinelle `DEPTH_UNBOUNDED` : sans elle, la partie basse de la carte n'aurait
## aucune strate déclarée et le générateur devrait inventer une tuile.
func _load_strata(root: Dictionary) -> void:
	var context: String = "%s → %s" % [PATH, ROOT_STRATA]
	var entries: Array = _validator.extract_array(root, PATH, ROOT_STRATA)
	if entries.is_empty():
		_validator.report("%s : aucune strate déclarée." % context)
		return
	var accepted: Array[Dictionary] = []
	var previous_depth: float = 0.0
	for index: int in entries.size():
		var entry_context: String = "%s[%d]" % [context, index]
		var entry: Dictionary = _validator.accept_entry(entries[index], STRATUM_SCHEMA, entry_context)
		if entry.is_empty():
			return
		if entry[KEY_HARDNESS] <= 0:
			_validator.report("%s : « %s » doit être strictement positif (lu : %d), strates rejetées." % [entry_context, KEY_HARDNESS, entry[KEY_HARDNESS]])
			return
		var depth: float = entry[KEY_DEPTH_MAX_M]
		var is_last: bool = index == entries.size() - 1
		if is_last:
			if not is_equal_approx(depth, DEPTH_UNBOUNDED):
				_validator.report("%s : la dernière strate doit porter « %s » = %s (jusqu'au fond), lu %s — strates rejetées." % [entry_context, KEY_DEPTH_MAX_M, DEPTH_UNBOUNDED, depth])
				return
		elif depth <= previous_depth:
			_validator.report("%s : « %s » (%s) doit être strictement croissant (précédent : %s), strates rejetées." % [entry_context, KEY_DEPTH_MAX_M, depth, previous_depth])
			return
		else:
			previous_depth = depth
		accepted.append(entry)
	_strata.assign(accepted)


## Paliers de profondeur — clé unique partagée par la table de loot (§2.2) et la
## courbe de risque (§4.2), arbitrage Q30. Ils doivent être **contigus** et partir
## de la surface : un trou entre deux paliers laisserait des cases sans table.
func _load_depth_layers(root: Dictionary) -> void:
	var context: String = "%s → %s" % [PATH, ROOT_DEPTH_LAYERS]
	var entries: Array = _validator.extract_array(root, PATH, ROOT_DEPTH_LAYERS)
	if entries.is_empty():
		_validator.report("%s : aucun palier de profondeur déclaré." % context)
		return
	var accepted: Array[Dictionary] = []
	var ids: Array[String] = []
	var expected_min: float = 0.0
	for index: int in entries.size():
		var entry_context: String = "%s[%d]" % [context, index]
		var entry: Dictionary = _validator.accept_entry(entries[index], DEPTH_LAYER_SCHEMA, entry_context)
		if entry.is_empty():
			return
		var layer_id: String = entry[DataValidator.KEY_ID]
		if not _validator.accept_id(layer_id, ids, entry_context):
			return
		# Le nom de zone est affiché au joueur à la transition (story 6.1) : une
		# couche sans nom n'est pas une couche anonyme, c'est une donnée fautive.
		if String(entry[DataValidator.KEY_NAME]).strip_edges().is_empty():
			_validator.report("%s : « %s » vide — le nom de zone est affiché au joueur, paliers rejetés." % [entry_context, DataValidator.KEY_NAME])
			return
		if not is_equal_approx(entry[KEY_DEPTH_MIN_M], expected_min):
			_validator.report("%s : « %s » doit valoir %s pour que les paliers soient contigus (lu %s), paliers rejetés." % [entry_context, KEY_DEPTH_MIN_M, expected_min, entry[KEY_DEPTH_MIN_M]])
			return
		var depth_max: float = entry[KEY_DEPTH_MAX_M]
		var is_last: bool = index == entries.size() - 1
		if is_last:
			if not is_equal_approx(depth_max, DEPTH_UNBOUNDED):
				_validator.report("%s : le dernier palier doit porter « %s » = %s (jusqu'au fond), lu %s — paliers rejetés." % [entry_context, KEY_DEPTH_MAX_M, DEPTH_UNBOUNDED, depth_max])
				return
		elif depth_max <= entry[KEY_DEPTH_MIN_M]:
			_validator.report("%s : « %s » (%s) doit dépasser « %s » (%s), paliers rejetés." % [entry_context, KEY_DEPTH_MAX_M, depth_max, KEY_DEPTH_MIN_M, entry[KEY_DEPTH_MIN_M]])
			return
		else:
			expected_min = depth_max
		ids.append(layer_id)
		accepted.append(entry)
	_depth_layers.assign(accepted)
	_depth_layer_ids.assign(ids)


## Marge d'hystérésis du palier courant (story 6.1, critère 3). Bornes : strictement
## positive — à zéro, une foreuse posée sur une frontière produirait une rafale de
## transitions — et strictement inférieure à l'épaisseur du plus mince palier
## borné — au-delà, remonter de la marge ferait sortir du palier voisin et la
## règle de retour perdrait son sens. Validée **après** les paliers.
func _load_layer_transition(root: Dictionary) -> void:
	var context: String = "%s → %s" % [PATH, ROOT_LAYER_TRANSITION]
	var block: Dictionary = _validator.accept_block(root, ROOT_LAYER_TRANSITION, LAYER_TRANSITION_SCHEMA, context)
	if block.is_empty():
		return
	if _depth_layers.is_empty():
		_validator.report("%s : les paliers de profondeur n'ont pas été chargés, marge rejetée." % context)
		return
	var margin: float = block[KEY_HYSTERESIS_M]
	var thinnest: float = INF
	for layer: Dictionary in _depth_layers:
		if not is_equal_approx(layer[KEY_DEPTH_MAX_M], DEPTH_UNBOUNDED):
			thinnest = minf(thinnest, float(layer[KEY_DEPTH_MAX_M]) - float(layer[KEY_DEPTH_MIN_M]))
	if margin <= 0.0 or margin >= thinnest:
		_validator.report("%s : « %s » (%s) doit être strictement positif et inférieur à l'épaisseur du plus mince palier (%s m), marge rejetée." % [context, KEY_HYSTERESIS_M, margin, thinnest])
		return
	_layer_hysteresis_m = margin


# --- Chargement : densités de minerai -------------------------------------------

## Densités de minerai par palier. Contrôles : un palier déclaré et un seul par
## entrée, des `resource_id` connus et **actifs au MVP** (K10), des probabilités
## dans `[0, 1]`, et une **somme strictement inférieure à 1** par palier — sans
## quoi il ne resterait aucune case stérile, donc aucune case pour le tirage de
## loot de la story 3.6 (arbitrage Q28 : la tuile décide, le reste est tiré).
func _load_ore_density(root: Dictionary) -> void:
	var context: String = "%s → %s" % [PATH, ROOT_ORE_DENSITY]
	if not root.has(ROOT_ORE_DENSITY):
		_validator.report("%s : bloc manquant." % context)
		return
	if typeof(root[ROOT_ORE_DENSITY]) != TYPE_DICTIONARY:
		_validator.report("%s : le bloc doit être un objet JSON." % context)
		return
	var block: Dictionary = root[ROOT_ORE_DENSITY]
	if _depth_layer_ids.is_empty():
		_validator.report("%s : les paliers de profondeur n'ont pas été chargés, densités rejetées." % context)
		return
	var accepted: Dictionary[String, Dictionary] = {}
	for layer_id: String in _depth_layer_ids:
		var layer_context: String = "%s → %s" % [context, layer_id]
		if not block.has(layer_id):
			_validator.report("%s : palier sans densités déclarées." % layer_context)
			return
		if typeof(block[layer_id]) != TYPE_DICTIONARY:
			_validator.report("%s : les densités d'un palier doivent être un objet JSON." % layer_context)
			return
		var densities: Dictionary[String, float] = {}
		if not _read_layer_densities(block[layer_id], layer_context, densities):
			return
		accepted[layer_id] = densities
	for layer_id: String in block:
		if not _depth_layer_ids.has(layer_id):
			_validator.report("%s : palier « %s » inconnu — il ne figure pas dans « %s »." % [context, layer_id, ROOT_DEPTH_LAYERS])
			return
	for layer_id: String in accepted:
		_ore_density[layer_id] = accepted[layer_id]


## Densités d'un palier, écrites dans `densities`. Faux si **une seule** est
## fautive — le palier, et avec lui tout le bloc, est alors rejeté par l'appelant.
func _read_layer_densities(layer: Dictionary, layer_context: String, densities: Dictionary[String, float]) -> bool:
	var total: float = 0.0
	for resource_id: String in layer:
		var value: Variant = layer[resource_id]
		if not _validator.matches_kind(value, DataValidator.FieldKind.FLOAT):
			_validator.report("%s : densité de « %s » non numérique." % [layer_context, resource_id])
			return false
		var probability: float = float(value)
		if probability < 0.0 or probability > 1.0:
			_validator.report("%s : densité de « %s » hors de [0, 1] (lue %s)." % [layer_context, resource_id, probability])
			return false
		if not _resources.has_resource(resource_id):
			_validator.report("%s : « %s » inconnu du catalogue %s." % [layer_context, resource_id, ResourceCatalog.PATH])
			return false
		if not _resources.is_resource_active_in_mvp(resource_id):
			_validator.report("%s : « %s » est `actif_mvp: false` et ne doit pas être généré au MVP." % [layer_context, resource_id])
			return false
		densities[resource_id] = probability
		total += probability
	if total >= 1.0:
		_validator.report("%s : la somme des densités vaut %s et doit rester strictement inférieure à 1, sinon aucune case stérile ne subsiste pour le tirage de loot." % [layer_context, total])
		return false
	return true


# --- Chargement : table de loot ---------------------------------------------------

## Table de loot des cases stériles (story 3.6). Validation opposable à l'audit :
## entrées uniques, **une et une seule** entrée « Rien » (ressource vide, critère 8),
## toute autre entrée liée à une ressource **active** (`K10` garanti par la
## structure), poids déclarés pour **chaque** palier et **seulement** eux (`Q30`),
## poids positifs, somme strictement positive et « Rien » strictement inférieur à
## la somme sur chaque palier (`K9`, règle §2.4). Tout écart rejette la table.
func _load_loot(root: Dictionary) -> void:
	var context: String = "%s → %s" % [PATH, ROOT_LOOT]
	if not root.has(ROOT_LOOT) or typeof(root[ROOT_LOOT]) != TYPE_DICTIONARY:
		_validator.report("%s : bloc manquant ou non objet." % context)
		return
	var block: Dictionary = root[ROOT_LOOT]
	if _depth_layer_ids.is_empty():
		_validator.report("%s : les paliers de profondeur n'ont pas été chargés, table rejetée." % context)
		return
	if not block.has(KEY_LOOT_ENTRIES) or typeof(block[KEY_LOOT_ENTRIES]) != TYPE_ARRAY or not block.has(KEY_LOOT_WEIGHTS) or typeof(block[KEY_LOOT_WEIGHTS]) != TYPE_DICTIONARY:
		_validator.report("%s : « %s » (tableau) et « %s » (objet) sont requis, table rejetée." % [context, KEY_LOOT_ENTRIES, KEY_LOOT_WEIGHTS])
		return
	var entries: Array[Dictionary] = _read_loot_entries(block[KEY_LOOT_ENTRIES], context)
	if entries.is_empty():
		return
	var entry_ids: Array[String] = []
	var resources: Dictionary[String, String] = {}
	var high_rarity: Array[String] = []
	var nothing_id: String = ""
	for entry: Dictionary in entries:
		entry_ids.append(entry[DataValidator.KEY_ID])
		resources[entry[DataValidator.KEY_ID]] = entry[KEY_LOOT_RESOURCE_ID]
		if entry[KEY_LOOT_HIGH_RARITY]:
			high_rarity.append(entry[DataValidator.KEY_ID])
		if String(entry[KEY_LOOT_RESOURCE_ID]).is_empty():
			nothing_id = entry[DataValidator.KEY_ID]
	var weights: Dictionary[String, PackedFloat64Array] = _read_loot_weights(block[KEY_LOOT_WEIGHTS], entry_ids, nothing_id, context)
	if weights.is_empty():
		return
	_loot_entry_ids = entry_ids
	_loot_resources = resources
	_loot_weights = weights
	_loot_high_rarity = high_rarity


## Entrées de la table, validées une à une. Vide si **une seule** est fautive, ou
## s'il n'existe pas **exactement une** entrée « Rien » : la table est rejetée.
func _read_loot_entries(raw_entries: Array, context: String) -> Array[Dictionary]:
	var accepted: Array[Dictionary] = []
	var seen: Dictionary[String, bool] = {}
	var nothing_id: String = ""
	for raw: Variant in raw_entries:
		if typeof(raw) != TYPE_DICTIONARY or typeof(raw.get(DataValidator.KEY_ID)) != TYPE_STRING or typeof(raw.get(KEY_LOOT_RESOURCE_ID)) != TYPE_STRING or typeof(raw.get(KEY_LOOT_HIGH_RARITY)) != TYPE_BOOL or raw.size() != 3:
			_validator.report("%s : entrée invalide (attendu : « %s » et « %s », chaînes, « %s », booléen) : %s — table rejetée." % [context, DataValidator.KEY_ID, KEY_LOOT_RESOURCE_ID, KEY_LOOT_HIGH_RARITY, raw])
			return []
		var entry_id: String = raw[DataValidator.KEY_ID]
		var resource_id: String = raw[KEY_LOOT_RESOURCE_ID]
		if entry_id.is_empty() or seen.has(entry_id):
			_validator.report("%s : identifiant d'entrée vide ou en double (« %s »), table rejetée." % [context, entry_id])
			return []
		if resource_id.is_empty():
			if not nothing_id.is_empty():
				_validator.report("%s : deux entrées « Rien » (« %s », « %s »), table rejetée." % [context, nothing_id, entry_id])
				return []
			if raw[KEY_LOOT_HIGH_RARITY]:
				_validator.report("%s : l'entrée « Rien » (« %s ») ne peut pas être une rareté haute, table rejetée." % [context, entry_id])
				return []
			nothing_id = entry_id
		elif not _resources.has_resource(resource_id) or not _resources.is_resource_active_in_mvp(resource_id):
			_validator.report("%s : entrée « %s » liée à « %s », inconnu ou `actif_mvp: false` (Q12) — table rejetée." % [context, entry_id, resource_id])
			return []
		seen[entry_id] = true
		accepted.append(raw)
	if nothing_id.is_empty():
		_validator.report("%s : aucune entrée « Rien » explicite (ressource vide), table rejetée." % context)
		return []
	return accepted


## Poids de chaque palier, alignés sur l'ordre des entrées. Vide si un palier est
## inconnu, manquant, incomplet, négatif, ou à 0 % de drop (`K9`).
func _read_loot_weights(weights_block: Dictionary, entry_ids: Array[String], nothing_id: String, context: String) -> Dictionary[String, PackedFloat64Array]:
	var weights: Dictionary[String, PackedFloat64Array] = {}
	for layer_id: String in weights_block:
		if not _depth_layer_ids.has(layer_id):
			_validator.report("%s : poids déclarés pour « %s », palier inconnu de « %s », table rejetée." % [context, layer_id, ROOT_DEPTH_LAYERS])
			return {}
	for layer_id: String in _depth_layer_ids:
		var layer_context: String = "%s → %s → %s" % [context, KEY_LOOT_WEIGHTS, layer_id]
		if not weights_block.has(layer_id) or typeof(weights_block[layer_id]) != TYPE_DICTIONARY:
			_validator.report("%s : poids manquants, table rejetée." % layer_context)
			return {}
		var row: PackedFloat64Array = _read_loot_row(weights_block[layer_id], entry_ids, nothing_id, layer_context)
		if row.is_empty():
			return {}
		weights[layer_id] = row
	return weights


## Poids d'un palier. Vide si un poids est absent, non numérique ou négatif, ou si
## le palier ne laisse **aucune** chance de drop (somme nulle, ou « Rien » ≥ somme).
func _read_loot_row(layer: Dictionary, entry_ids: Array[String], nothing_id: String, layer_context: String) -> PackedFloat64Array:
	if layer.size() != entry_ids.size():
		_validator.report("%s : %d poids pour %d entrées, table rejetée." % [layer_context, layer.size(), entry_ids.size()])
		return PackedFloat64Array()
	var row: PackedFloat64Array = PackedFloat64Array()
	var total: float = 0.0
	for entry_id: String in entry_ids:
		if not layer.has(entry_id) or not _validator.matches_kind(layer[entry_id], DataValidator.FieldKind.FLOAT) or float(layer[entry_id]) < 0.0:
			_validator.report("%s : poids de « %s » absent, non numérique ou négatif, table rejetée." % [layer_context, entry_id])
			return PackedFloat64Array()
		row.append(float(layer[entry_id]))
		total += float(layer[entry_id])
	if total <= 0.0 or float(layer[nothing_id]) >= total:
		_validator.report("%s : 0 %% de drop — somme %s, « %s » %s. La règle §2.4 exige une chance non nulle de drop sur chaque palier, table rejetée." % [layer_context, total, nothing_id, layer[nothing_id]])
		return PackedFloat64Array()
	return row


# --- Monde et ancrages ------------------------------------------------------------

func has_world_bounds() -> bool:
	return _map.size() == MAP_SCHEMA.size()


func get_map_field_count() -> int:
	return _map.size()


## Bords de carte sous forme de rectangle monde, coin haut-gauche en `position`,
## **dérivés** des dimensions en tuiles et de `pixels_par_metre`. `y = 0` est la
## ligne de surface ; la carte est centrée en `x`.
func get_world_bounds() -> Rect2:
	if not has_world_bounds():
		push_error("GameData — dimensions de carte indisponibles (voir %s)." % PATH)
		return Rect2()
	var tile: float = _get_tile_size()
	var left: float = -float(_map[KEY_MAP_WIDTH] / 2) * tile
	var top: float = -float(_map[KEY_MAP_SURFACE]) * tile
	var width: float = float(_map[KEY_MAP_WIDTH]) * tile
	var height: float = float(_map[KEY_MAP_SURFACE] + _map[KEY_MAP_DEPTH] + _map[KEY_MAP_BELT]) * tile
	return Rect2(left, top, width, height)


func get_map_value(field: String) -> int:
	if not _map.has(field):
		push_error("GameData — dimension de carte absente : « %s » (voir %s)." % [field, PATH])
		return 0
	return _map[field]


func has_anchors() -> bool:
	return _anchors.size() == ANCHORS_SCHEMA.size()


func get_anchor_field_count() -> int:
	return _anchors.size()


func get_spawn_ground_position() -> Vector2:
	if not has_anchors():
		push_error("GameData — point d'apparition indisponible (voir %s)." % PATH)
		return Vector2.ZERO
	var tile: float = _get_tile_size()
	return Vector2((float(_anchors[KEY_SPAWN_COLUMN]) + 0.5) * tile, 0.0)


## Zone de surface en pixels monde (story 5.1) : colonnes `zone_surface_colonne_min`
## à `zone_surface_colonne_max` **incluses**, du haut de la carte jusqu'à la ligne
## de surface (`y = 0`) **exclue**. Mêmes conventions que `get_world_bounds()`
## (colonne 0 = `[0, tuile[`) ; aucune dépendance à la graine (`K3`).
func get_surface_zone_rect() -> Rect2:
	if not has_anchors():
		push_error("GameData — zone de surface indisponible (voir %s)." % PATH)
		return Rect2()
	var tile: float = _get_tile_size()
	var left: float = float(_anchors[KEY_SURFACE_COLUMN_MIN]) * tile
	var columns: int = _anchors[KEY_SURFACE_COLUMN_MAX] - _anchors[KEY_SURFACE_COLUMN_MIN] + 1
	var top: float = -float(_map[KEY_MAP_SURFACE]) * tile
	return Rect2(left, top, float(columns) * tile, -top)


## Point de pose de la station (story 5.1) : milieu de la zone de surface, sur la
## ligne de surface. Dérivé des seuls ancrages : aucune coordonnée de station
## n'existe en données ni dans le code.
func get_station_ground_position() -> Vector2:
	if not has_anchors():
		push_error("GameData — point de pose de la station indisponible (voir %s)." % PATH)
		return Vector2.ZERO
	var zone: Rect2 = get_surface_zone_rect()
	return Vector2(zone.get_center().x, 0.0)


func get_anomaly_cell() -> Vector2i:
	if not has_anchors():
		push_error("GameData — ancrage de l'anomalie indisponible (voir %s)." % PATH)
		return Vector2i.ZERO
	return Vector2i(_anchors[KEY_ANOMALY_COLUMN], _anchors[KEY_ANOMALY_ROW])


## Taille d'une tuile en pixels : 1 tuile = 1 m (story 3.1), donc `pixels_par_metre`.
func _get_tile_size() -> float:
	return _drill.get_physics_value(DrillSettings.KEY_PIXELS_PER_METER)


## Première et dernière colonnes **intérieures** (hors ceinture). La carte est
## centrée : la colonne la plus à gauche vaut `-(largeur / 2)`. Même convention que
## `get_world_bounds()` et le générateur.
func _get_first_interior_column() -> int:
	return -(_map[KEY_MAP_WIDTH] / 2) + _map[KEY_MAP_BELT]


func _get_last_interior_column() -> int:
	return -(_map[KEY_MAP_WIDTH] / 2) + _map[KEY_MAP_WIDTH] - 1 - _map[KEY_MAP_BELT]


# --- Génération --------------------------------------------------------------------

func has_generation_settings() -> bool:
	return (has_world_bounds()
			and has_anchors()
			and _generation.size() == GENERATION_SCHEMA.size()
			and not _strata.is_empty()
			and not _depth_layers.is_empty()
			and _ore_density.size() == _depth_layers.size())


func get_generation_seed() -> int:
	if not _generation.has(KEY_SEED):
		push_error("GameData — graine de génération absente (voir %s)." % PATH)
		return 0
	return _generation[KEY_SEED]


func get_strata() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for stratum: Dictionary in _strata:
		out.append(stratum.duplicate())
	return out


func get_strata_count() -> int:
	return _strata.size()


## Dureté maximale **forable** du terrain (story 5.6, `Q59` (b)) : la plus grande
## dureté des tuiles destructibles que le générateur peut placer — strates de ce
## fichier et minerais actifs au MVP du catalogue des ressources. **Dérivée des
## données**, jamais écrite dans le code ; la ceinture indestructible n'est ni une
## strate ni un minerai, elle est donc exclue par construction. `0` et erreur si
## les strates ont été rejetées : aucune dureté inventée.
func get_max_drillable_hardness() -> int:
	if _strata.is_empty():
		push_error("GameData — strates non chargées (voir %s) : dureté maximale forable indéterminée." % PATH)
		return 0
	var max_hardness: int = 0
	for stratum: Dictionary in _strata:
		max_hardness = maxi(max_hardness, stratum[KEY_HARDNESS])
	for resource_id: String in _resources.get_mvp_resource_ids():
		max_hardness = maxi(max_hardness, _resources.get_resource_hardness(resource_id))
	return max_hardness


func get_depth_layer_count() -> int:
	return _depth_layers.size()


## `id` des paliers, de la surface vers le fond (copie). Lu par `ThreatSettings`
## (story 6.6) : la courbe de risque se cale sur ce découpage, sans le dupliquer.
func get_depth_layer_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.assign(_depth_layer_ids)
	return ids


func get_depth_layer_at(depth_m: float) -> String:
	for layer: Dictionary in _depth_layers:
		var maximum: float = layer[KEY_DEPTH_MAX_M]
		if depth_m < layer[KEY_DEPTH_MIN_M]:
			continue
		if is_equal_approx(maximum, DEPTH_UNBOUNDED) or depth_m < maximum:
			return layer[DataValidator.KEY_ID]
	return ""


## Nom de zone d'un palier, affiché au joueur (story 6.1). Chaîne vide et erreur
## pour un palier inconnu : aucun nom inventé.
func get_depth_layer_name(layer_id: String) -> String:
	var index: int = _depth_layer_ids.find(layer_id)
	if index < 0:
		push_error("GameData — palier de profondeur inconnu : « %s » (voir %s)." % [layer_id, PATH])
		return ""
	return _depth_layers[index][DataValidator.KEY_NAME]


func has_layer_transition() -> bool:
	return not _depth_layers.is_empty() and _layer_hysteresis_m > 0.0


func get_layer_hysteresis_m() -> float:
	return _layer_hysteresis_m


## Palier courant **avec hystérésis** (story 6.1, critère 3). Règle :
## [br]— vers le **bas**, le palier change dès la frontière franchie — c'est la
## frontière du loot (`Q30`) : descendre ne crée aucun écart entre les deux ;
## [br]— vers le **haut**, la foreuse ne revient au palier moins profond qu'une
## fois remontée de `marge_hysteresis_m` au-dessus de la frontière haute du palier
## courant. Une oscillation autour d'une limite ne produit qu'une transition.
## Un `current_id` inconnu ou vide (nouvelle partie) donne le palier brut. Fonction
## **pure** des données et de ses arguments : l'état reste à l'appelant.
## Marge rejetée au chargement (erreur déjà consignée) : palier brut, sans marge
## inventée — la seule conséquence est un éventuel bégaiement, visible au test.
func get_depth_layer_with_hysteresis(depth_m: float, current_id: String) -> String:
	var raw_id: String = get_depth_layer_at(depth_m)
	if not has_layer_transition():
		return raw_id
	var current_index: int = _depth_layer_ids.find(current_id)
	var raw_index: int = _depth_layer_ids.find(raw_id)
	if current_index < 0 or raw_index < 0 or raw_index >= current_index:
		return raw_id
	var current_min: float = _depth_layers[current_index][KEY_DEPTH_MIN_M]
	if depth_m < current_min - _layer_hysteresis_m:
		return raw_id
	return current_id


func get_ore_density(layer_id: String, resource_id: String) -> float:
	if not _ore_density.has(layer_id):
		push_error("GameData — palier de profondeur inconnu : « %s » (voir %s)." % [layer_id, PATH])
		return 0.0
	return _ore_density[layer_id].get(resource_id, 0.0)


## Densités d'un palier, dans l'ordre de déclaration du catalogue de ressources —
## c'est cet ordre qui rend le tirage du générateur **reproductible**.
func get_ore_densities(layer_id: String) -> Dictionary[String, float]:
	var out: Dictionary[String, float] = {}
	if not _ore_density.has(layer_id):
		push_error("GameData — palier de profondeur inconnu : « %s » (voir %s)." % [layer_id, PATH])
		return out
	for resource_id: String in _resources.get_resource_ids():
		if _ore_density[layer_id].has(resource_id):
			out[resource_id] = _ore_density[layer_id][resource_id]
	return out


# --- Table de loot -------------------------------------------------------------------

func has_loot_table() -> bool:
	return not _loot_entry_ids.is_empty() and _loot_weights.size() == _depth_layer_ids.size()


func get_loot_entry_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.assign(_loot_entry_ids)
	return ids


func get_loot_entry_resource(entry_id: String) -> String:
	if not _loot_resources.has(entry_id):
		push_error("GameData — entrée de loot inconnue : « %s » (voir %s)." % [entry_id, PATH])
		return ""
	return _loot_resources[entry_id]


func is_loot_entry_high_rarity(entry_id: String) -> bool:
	return _loot_high_rarity.has(entry_id)


func get_loot_weights(layer_id: String) -> PackedFloat64Array:
	if not _loot_weights.has(layer_id):
		push_error("GameData — palier de loot inconnu : « %s » (voir %s)." % [layer_id, PATH])
		return PackedFloat64Array()
	return _loot_weights[layer_id].duplicate()
