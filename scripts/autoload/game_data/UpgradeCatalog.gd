class_name UpgradeCatalog
extends RefCounted

## Chargeur et catalogue de `data/upgrades.json` — améliorations, état de
## départ d'une nouvelle partie (stories 1.5 et 2.x, découpé de `GameData` par la
## story 5.11), tarifs des services de la station (story 5.3) et **progression
## infinie** des améliorations (story 5.6, `schema_version: 2`).
##
## Une seule responsabilité : lire, valider et servir ce fichier. Instancié
## **uniquement** par l'autoload `GameData`, qui reste la façade publique.
##
## [br]**Progression infinie** (story 5.6 — arbitrages `Q18`, `Q57` (b), `Q58` (a)) :
## aucun tableau de paliers, aucun niveau maximal (`L2`). Coût et valeur d'un
## niveau sont **calculés**, chacun par **une seule** fonction pure et
## déterministe de ce script (`_compute_next_cost()`, `_compute_value()`), à
## partir de quatre paramètres **en données** par amélioration (`L1`, `D1`).
## [br]**Convention de niveau** (`Q57`) : le niveau 1 est le statut de départ —
## coût nul, non achetable, **hors formule**. `niveau` désigne le **niveau
## courant** : passer du niveau `n` au niveau `n + 1` coûte
## `base × facteur^n`, `n ≥ 1`. La valeur d'un niveau `n ≥ 1` vaut
## `valeur_depart + increment × (n − 1)`.
## [br]**Arrondi du coût** (`L3`) : à l'entier le plus proche, moitié vers le haut
## (`roundf`, la quantité étant positive). **Saturation** : un coût qui
## atteindrait `COST_SATURATION` (2^53, ≈ 9,0 × 10^15 crédits — dès le niveau
## courant 39 à 42 avec les paramètres de départ) vaut exactement
## `COST_SATURATION`. C'est une limite de **représentation** des crédits (au-delà,
## un flottant double ne représente plus chaque entier, et la conversion en
## entier 64 bits deviendrait indéfinie vers 9,2 × 10^18), **pas une borne sur le
## niveau** : le niveau reste achetable sans limite, à ce prix.

const PATH: String = "res://data/upgrades.json"
const ROOT: String = "ameliorations"
const ROOT_NEW_GAME: String = "nouvelle_partie"
## Services de la station de surface (story 5.3) : ravitaillement, réparation et
## secours carburant (`Q56`, `Q63`). Dans ce fichier parce que c'est celui des
## **prix** du jeu (coûts d'amélioration, crédits de départ) : l'équilibrage
## économique se règle en un seul endroit (`7.6`).
const ROOT_STATION: String = "station"

## Version du schéma lue à la racine. Seule la version 2 est acceptée : le
## schéma 1 (paliers fixes) n'est plus lu, et une version inconnue fait rejeter
## le fichier entier (`D2`). Les **sauvegardes** écrites sous le schéma 1 restent
## lisibles (`H5`, story 7.1) : elles ne portent que des `id` (inchangés, `Q12`)
## et des niveaux 1 à 4, tous valides ici.
const KEY_SCHEMA_VERSION: String = "schema_version"
const SCHEMA_VERSION: int = 2

const KEY_DESCRIPTION: String = "description"
const KEY_STATISTIC: String = "statistique"
## Valeur au niveau 1 (statut de départ, `Q13`) — entier > 0.
const KEY_START_VALUE: String = "valeur_depart"
## Gain de valeur par niveau (`Q58` (a)) — entier > 0.
const KEY_INCREMENT: String = "increment"
## `base` de `cout = base × facteur^niveau` (`Q18`) — réel > 0.
const KEY_COST_BASE: String = "base"
## `facteur` de `cout = base × facteur^niveau` (`Q18`) — réel > 1.
const KEY_COST_FACTOR: String = "facteur"
## Clés du schéma 1, **interdites** au schéma 2 : un tableau de paliers ou un
## niveau maximal oublié dans les données réintroduirait un plafond (`L2`). Leur
## présence fait rejeter l'entrée, plutôt que d'être ignorée en silence.
const FORBIDDEN_KEYS: Array[String] = ["paliers", "niveau_max"]
const KEY_START_CREDITS: String = "credits_depart"
## Crédits par unité de carburant (entier ≥ 1).
const KEY_FUEL_UNIT_PRICE: String = "prix_unite_carburant"
## Crédits par point de blindage (entier ≥ 1).
const KEY_ARMOR_POINT_PRICE: String = "prix_point_blindage"
## Seuil du secours gratuit, en **fraction du réservoir courant**, dans `]0, 1]`.
const KEY_RESCUE_FUEL_RATIO: String = "seuil_secours_carburant_ratio"

## Niveau de départ de toute amélioration : statut de départ du CDC, coût nul.
## Convention du schéma 2 (`Q57`), et non une donnée d'équilibrage.
const START_LEVEL: int = 1
## Saturation du coût (2^53) : plus grand entier exactement représentable par un
## flottant double. Limite de représentation, pas de gameplay (voir en tête).
const COST_SATURATION: int = 9007199254740992

# --- Identifiants de statistiques ---------------------------------------------
# Chaque amélioration déclare la statistique qu'elle pilote. C'est par elle que
# `GameState` résout ses valeurs de départ (valeur du niveau 1), sans qu'aucun
# chiffre ne soit dupliqué entre le code et les données.

const STAT_CARGO_CAPACITY: String = "capacite_soute"
const STAT_FUEL_MAX: String = "carburant_max"
const STAT_DRILL_POWER: String = "puissance_foret"
const STAT_ARMOR_MAX: String = "blindage_max"

## Valeur de départ et incrément **entiers** pour toutes les améliorations : la
## puissance du foret est comparée à `hardness` (entier), la capacité de la soute
## est un nombre d'unités ; une valeur entière par niveau ne prive les autres
## statistiques de rien. Le schéma garantit l'entier ; le signe, et les bornes
## de `base` et `facteur`, sont vérifiés par `_accept_progression()`.
const SCHEMA: Dictionary = {
	DataValidator.KEY_ID: DataValidator.FieldKind.STRING,
	DataValidator.KEY_NAME: DataValidator.FieldKind.STRING,
	KEY_DESCRIPTION: DataValidator.FieldKind.STRING,
	KEY_STATISTIC: DataValidator.FieldKind.STRING,
	DataValidator.KEY_ACTIVE_MVP: DataValidator.FieldKind.BOOL,
	KEY_START_VALUE: DataValidator.FieldKind.INT,
	KEY_INCREMENT: DataValidator.FieldKind.INT,
	KEY_COST_BASE: DataValidator.FieldKind.FLOAT,
	KEY_COST_FACTOR: DataValidator.FieldKind.FLOAT,
}

const NEW_GAME_SCHEMA: Dictionary = {
	KEY_START_CREDITS: DataValidator.FieldKind.INT,
}

## Prix **entiers strictement positifs** : un prix nul rendrait le service gratuit
## (le carburant cesserait d'être une dépense, `Q56`) et le calcul des unités
## achetables diviserait par zéro. Le seuil de secours est une fraction du
## réservoir dans `]0, 1]` : à 0 le secours n'existerait plus et la partie
## pourrait se bloquer (`L6`) ; au-delà de 1 il dépasserait le plein.
const STATION_SCHEMA: Dictionary = {
	KEY_FUEL_UNIT_PRICE: DataValidator.FieldKind.INT,
	KEY_ARMOR_POINT_PRICE: DataValidator.FieldKind.INT,
	KEY_RESCUE_FUEL_RATIO: DataValidator.FieldKind.FLOAT,
}

var _validator: DataValidator
var _upgrades: Dictionary[String, Dictionary] = {}
var _upgrade_ids: Array[String] = []
## Crédits impériaux au début d'une partie. `-1` tant que `nouvelle_partie` n'a
## pas été lu : sentinelle distincte de toute valeur légitime, pour que
## `get_start_credits()` signale l'échec au lieu d'offrir un solde inventé.
var _start_credits: int = -1
## Tarifs de la station, vides si le bloc a été rejeté : les services sont alors
## refusés, jamais rendus à un prix inventé (`D2`).
var _station: Dictionary = {}


func _init(validator: DataValidator) -> void:
	_validator = validator


## La racine du fichier n'est lue qu'une fois : elle porte à la fois l'état de
## départ d'une nouvelle partie et le tableau des améliorations. Deux lectures
## dédoubleraient les messages d'erreur en cas de fichier absent ou malformé. Une
## version de schéma autre que `SCHEMA_VERSION` fait rejeter le fichier **entier**.
func load_file() -> void:
	var root: Dictionary = _validator.read_root(PATH)
	if root.is_empty():
		return
	if not _accept_schema_version(root):
		return
	_load_new_game_block(root)
	_load_station_block(root)
	var entries: Array = _validator.extract_array(root, PATH, ROOT)
	for index: int in entries.size():
		var context: String = "%s → %s[%d]" % [PATH, ROOT, index]
		if not _accept_no_forbidden_key(entries[index], context):
			continue
		var entry: Dictionary = _validator.accept_entry(entries[index], SCHEMA, context)
		if entry.is_empty():
			continue
		var upgrade_id: String = entry[DataValidator.KEY_ID]
		if not _validator.accept_id(upgrade_id, _upgrade_ids, context):
			continue
		if not _accept_progression(entry, context):
			continue
		_upgrades[upgrade_id] = entry
		_upgrade_ids.append(upgrade_id)


func _accept_schema_version(root: Dictionary) -> bool:
	var version: Variant = root.get(KEY_SCHEMA_VERSION)
	if not _validator.matches_kind(version, DataValidator.FieldKind.INT) or int(version) != SCHEMA_VERSION:
		_validator.report("%s : « %s » doit valoir %d (lu : %s), fichier rejeté." % [PATH, KEY_SCHEMA_VERSION, SCHEMA_VERSION, version])
		return false
	return true


## Le schéma n'énumère que les champs attendus : sans ce contrôle, un tableau de
## paliers ou un niveau maximal resté dans les données serait ignoré en silence.
func _accept_no_forbidden_key(raw: Variant, context: String) -> bool:
	if typeof(raw) != TYPE_DICTIONARY:
		return true
	var entry: Dictionary = raw
	for key: String in FORBIDDEN_KEYS:
		if entry.has(key):
			_validator.report("%s : champ « %s » interdit par le schéma %d (progression sans plafond, Q18), entrée rejetée." % [context, key, SCHEMA_VERSION])
			return false
	return true


## Bornes des paramètres de progression (`D2`) : valeur de départ et incrément
## strictement positifs (un incrément nul ferait d'un achat une dépense sans
## effet, contraire au §3.3 et à `L5`), `base` strictement positive, `facteur`
## strictement supérieur à 1 (sinon le coût ne croîtrait pas). Aucun repli : un
## seul paramètre hors bornes fait rejeter l'amélioration.
func _accept_progression(entry: Dictionary, context: String) -> bool:
	for key: String in [KEY_START_VALUE, KEY_INCREMENT]:
		if entry[key] <= 0:
			_validator.report("%s : champ « %s » doit être un entier > 0 (lu : %s), entrée rejetée." % [context, key, entry[key]])
			return false
	var base: float = entry[KEY_COST_BASE]
	if not is_finite(base) or base <= 0.0:
		_validator.report("%s : champ « %s » doit être > 0 (lu : %s), entrée rejetée." % [context, KEY_COST_BASE, base])
		return false
	var factor: float = entry[KEY_COST_FACTOR]
	if not is_finite(factor) or factor <= 1.0:
		_validator.report("%s : champ « %s » doit être > 1 (lu : %s), entrée rejetée." % [context, KEY_COST_FACTOR, factor])
		return false
	return true


func _load_new_game_block(root: Dictionary) -> void:
	var context: String = "%s → %s" % [PATH, ROOT_NEW_GAME]
	var block: Dictionary = _validator.accept_block(root, ROOT_NEW_GAME, NEW_GAME_SCHEMA, context)
	if block.is_empty():
		return
	_start_credits = block[KEY_START_CREDITS]


func _load_station_block(root: Dictionary) -> void:
	var context: String = "%s → %s" % [PATH, ROOT_STATION]
	var block: Dictionary = _validator.accept_block(root, ROOT_STATION, STATION_SCHEMA, context)
	if block.is_empty():
		return
	for key: String in [KEY_FUEL_UNIT_PRICE, KEY_ARMOR_POINT_PRICE]:
		if block[key] < 1:
			_validator.report("%s : champ « %s » doit être un entier ≥ 1 (lu : %s), bloc rejeté." % [context, key, block[key]])
			return
	var ratio: float = block[KEY_RESCUE_FUEL_RATIO]
	if ratio <= 0.0 or ratio > 1.0:
		_validator.report("%s : champ « %s » doit être dans ]0, 1] (lu : %s), bloc rejeté." % [context, KEY_RESCUE_FUEL_RATIO, ratio])
		return
	_station = block


func has_upgrade(upgrade_id: String) -> bool:
	return _upgrades.has(upgrade_id)


func get_upgrade(upgrade_id: String) -> Dictionary:
	if not _is_known(upgrade_id):
		return {}
	return _upgrades[upgrade_id].duplicate(true)


func get_upgrade_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.assign(_upgrade_ids)
	return ids


func get_mvp_upgrade_ids() -> Array[String]:
	var ids: Array[String] = []
	for upgrade_id: String in _upgrade_ids:
		if _upgrades[upgrade_id][DataValidator.KEY_ACTIVE_MVP]:
			ids.append(upgrade_id)
	return ids


func is_upgrade_active_in_mvp(upgrade_id: String) -> bool:
	if not _is_known(upgrade_id):
		return false
	return _upgrades[upgrade_id][DataValidator.KEY_ACTIVE_MVP]


func get_upgrade_name(upgrade_id: String) -> String:
	if not _is_known(upgrade_id):
		return ""
	return _upgrades[upgrade_id][DataValidator.KEY_NAME]


func get_upgrade_description(upgrade_id: String) -> String:
	if not _is_known(upgrade_id):
		return ""
	return _upgrades[upgrade_id][KEY_DESCRIPTION]


func get_upgrade_statistic(upgrade_id: String) -> String:
	if not _is_known(upgrade_id):
		return ""
	return _upgrades[upgrade_id][KEY_STATISTIC]


## `START_LEVEL` pour toute amélioration connue ; `0` et erreur sinon.
func get_upgrade_start_level(upgrade_id: String) -> int:
	if not _is_known(upgrade_id):
		return 0
	return START_LEVEL


## Effet chiffré du niveau `level` (`level ≥ 1`, sans borne supérieure). `0.0` et
## erreur pour un `id` inconnu ou un niveau inférieur à 1.
func get_upgrade_value(upgrade_id: String, level: int) -> float:
	if not _is_known(upgrade_id) or not _is_level_valid(upgrade_id, level):
		return 0.0
	var upgrade: Dictionary = _upgrades[upgrade_id]
	return _compute_value(upgrade[KEY_START_VALUE], upgrade[KEY_INCREMENT], level)


## Coût, en crédits, du passage du niveau courant `current_level` au niveau
## `current_level + 1` (`current_level ≥ 1`, sans borne supérieure). Pour un `id`
## inconnu ou un niveau inférieur à 1 : erreur, et `COST_SATURATION` — jamais 0,
## pour qu'un appel fautif ne puisse pas devenir un achat gratuit.
func get_upgrade_next_cost(upgrade_id: String, current_level: int) -> int:
	if not _is_known(upgrade_id) or not _is_level_valid(upgrade_id, current_level):
		return COST_SATURATION
	var upgrade: Dictionary = _upgrades[upgrade_id]
	return _compute_next_cost(upgrade[KEY_COST_BASE], upgrade[KEY_COST_FACTOR], current_level)


## **Seul point de calcul de la valeur** (`Q58` (a)) — fonction pure :
## `valeur_depart + increment × (level − 1)`. Calculée en flottant : aucun
## débordement d'entier, quel que soit le niveau ; exacte tant que le résultat
## reste sous 2^53, soit bien au-delà de tout niveau atteignable.
static func _compute_value(start_value: int, increment: int, level: int) -> float:
	return float(start_value) + float(increment) * float(level - START_LEVEL)


## **Seul point de calcul du coût** (`Q18`, `Q57` (b)) — fonction pure :
## `base × facteur^current_level`, arrondi à l'entier le plus proche, saturé à
## `COST_SATURATION` (voir en tête). `pow()` peut rendre l'infini pour un niveau
## très grand : la comparaison le sature aussi, sans erreur.
static func _compute_next_cost(base: float, factor: float, current_level: int) -> int:
	var raw: float = roundf(base * pow(factor, float(current_level)))
	if raw >= float(COST_SATURATION):
		return COST_SATURATION
	return int(raw)


func get_start_stat(statistic_id: String) -> float:
	var upgrade_id: String = get_upgrade_id_for_statistic(statistic_id)
	if upgrade_id.is_empty():
		return 0.0
	return get_upgrade_value(upgrade_id, get_upgrade_start_level(upgrade_id))


func get_upgrade_id_for_statistic(statistic_id: String) -> String:
	for upgrade_id: String in _upgrade_ids:
		if _upgrades[upgrade_id][KEY_STATISTIC] == statistic_id:
			return upgrade_id
	push_error("GameData — statistique inconnue : « %s »." % statistic_id)
	return ""


func get_start_credits() -> int:
	if _start_credits < 0:
		push_error("GameData — bloc « %s » non chargé : crédits de départ indéterminés." % ROOT_NEW_GAME)
		return 0
	return _start_credits


func has_station_services() -> bool:
	return not _station.is_empty()


func get_fuel_unit_price() -> int:
	if not _is_station_loaded(KEY_FUEL_UNIT_PRICE):
		return 0
	return _station[KEY_FUEL_UNIT_PRICE]


func get_armor_point_price() -> int:
	if not _is_station_loaded(KEY_ARMOR_POINT_PRICE):
		return 0
	return _station[KEY_ARMOR_POINT_PRICE]


func get_rescue_fuel_ratio() -> float:
	if not _is_station_loaded(KEY_RESCUE_FUEL_RATIO):
		return 0.0
	return _station[KEY_RESCUE_FUEL_RATIO]


## Faux, avec erreur, si le bloc a été rejeté : l'appelant doit avoir consulté
## `has_station_services()` et refusé le service plutôt que de lire un tarif nul.
func _is_station_loaded(key: String) -> bool:
	if not _station.is_empty():
		return true
	push_error("GameData — bloc « %s » non chargé : « %s » indéterminé." % [ROOT_STATION, key])
	return false


## Vrai si `level` est un niveau existant : tout entier ≥ `START_LEVEL`. Aucune
## borne supérieure (`L2`).
func _is_level_valid(upgrade_id: String, level: int) -> bool:
	if level >= START_LEVEL:
		return true
	push_error("GameData — niveau %d invalide pour l'amélioration « %s » : le niveau de départ est %d." % [level, upgrade_id, START_LEVEL])
	return false


## Vrai si l'amélioration existe ; sinon, signale l'`id` inconnu à l'appelant.
func _is_known(upgrade_id: String) -> bool:
	if has_upgrade(upgrade_id):
		return true
	push_error("GameData — amélioration inconnue : « %s »." % upgrade_id)
	return false
