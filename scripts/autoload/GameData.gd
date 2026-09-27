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
const DRILL_PATH: String = "res://data/drill.json"

# --- Clés des fichiers --------------------------------------------------------
# Déclarées en constantes plutôt qu'en littéraux dispersés : une clé JSON est
# lue par le chargeur, par les schémas de validation et par les accesseurs (D4).

const ROOT_RESOURCES: String = "ressources"
const ROOT_UPGRADES: String = "ameliorations"
const ROOT_EVENTS: String = "evenements"
const ROOT_NEW_GAME: String = "nouvelle_partie"
const ROOT_DRILL_PHYSICS: String = "physique"
const ROOT_DRILL_FUEL: String = "carburant"
const ROOT_ARMOR: String = "blindage"
const ROOT_CAMERA: String = "camera"
const ROOT_WORLD: String = "monde"

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

# Physique de la foreuse (story 2.2, arbitrage Q15). Toutes ces grandeurs sont en
# pixels et en secondes, sauf le coefficient de freinage (sans unité) et le
# facteur de conversion en mètres.

const KEY_GRAVITY: String = "gravite_px_s2"
const KEY_H_ACCELERATION: String = "acceleration_horizontale_px_s2"
const KEY_H_FRICTION: String = "friction_horizontale_px_s2"
const KEY_H_MAX_SPEED: String = "vitesse_horizontale_max_px_s"
const KEY_THRUST: String = "poussee_verticale_px_s2"
const KEY_DESCENT_ACCELERATION: String = "acceleration_descente_px_s2"
const KEY_MAX_RISE_SPEED: String = "vitesse_montee_max_px_s"
const KEY_MAX_FALL_SPEED: String = "vitesse_chute_max_px_s"
const KEY_BRAKE_FACTOR: String = "coefficient_freinage"
const KEY_PIXELS_PER_METER: String = "pixels_par_metre"

# Consommation de carburant (story 2.3). La **capacité** du réservoir n'est pas
# ici : elle appartient à l'amélioration `reacteur` de data/upgrades.json, et
# la redéclarer créerait deux sources de vérité pour une même grandeur.

const KEY_FUEL_THRUST_PER_S: String = "consommation_poussee_par_s"
const KEY_FUEL_IDLE_PER_S: String = "consommation_repos_par_s"
const KEY_FUEL_LOW_RATIO: String = "seuil_alerte_ratio"

# Vue et bords de carte (story 2.4). Le bloc `monde` est **hébergé** ici en
# attendant `data/generation.json` (story 3.2) : la caméra a besoin des bords un
# sprint avant que le générateur existe, et les poser en dur violerait D1.

# Dégâts d'impact (story 2.5, arbitrage Q20). La **capacité** de blindage n'est
# pas ici : c'est la statistique `blindage_max` de l'amélioration `blindage` de
# data/upgrades.json, qui deviendra achetable en phase 5 (Q21).

const KEY_ARMOR_IMPACT_THRESHOLD: String = "seuil_impact_px_s"
const KEY_ARMOR_DAMAGE_PER_SPEED: String = "degats_par_px_s"
const KEY_ARMOR_LOW_RATIO: String = "seuil_alerte_ratio"
const KEY_ARMOR_DESTRUCTION_DURATION: String = "duree_destruction_s"

const KEY_CAMERA_SMOOTHING: String = "amortissement_position"
const KEY_CAMERA_ZOOM: String = "zoom"
const KEY_WORLD_LEFT: String = "bord_gauche_px"
const KEY_WORLD_RIGHT: String = "bord_droit_px"
const KEY_WORLD_TOP: String = "bord_haut_px"
const KEY_WORLD_BOTTOM: String = "bord_bas_px"

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

## Tous les champs de physique sont des réels **strictement positifs** : une
## gravité, une friction ou une vitesse maximale nulle ne dégrade pas le
## comportement, elle le supprime. Le coefficient de freinage est en outre borné
## à `]0, 1]` — au-delà de 1, « freiner » accélérerait.
const DRILL_PHYSICS_SCHEMA: Dictionary = {
	KEY_GRAVITY: FieldKind.FLOAT,
	KEY_H_ACCELERATION: FieldKind.FLOAT,
	KEY_H_FRICTION: FieldKind.FLOAT,
	KEY_H_MAX_SPEED: FieldKind.FLOAT,
	KEY_THRUST: FieldKind.FLOAT,
	KEY_DESCENT_ACCELERATION: FieldKind.FLOAT,
	KEY_MAX_RISE_SPEED: FieldKind.FLOAT,
	KEY_MAX_FALL_SPEED: FieldKind.FLOAT,
	KEY_BRAKE_FACTOR: FieldKind.FLOAT,
	KEY_PIXELS_PER_METER: FieldKind.FLOAT,
}

## Consommation de carburant. `consommation_repos_par_s` est le seul champ que
## zéro laisse valide : un moteur qui ne consomme rien à l'arrêt est un réglage
## légitime. Le seuil d'alerte est une **fraction** du réservoir, donc dans
## `]0, 1[` : à 0 l'alerte ne se déclencherait jamais, à 1 elle serait permanente.
const DRILL_FUEL_SCHEMA: Dictionary = {
	KEY_FUEL_THRUST_PER_S: FieldKind.FLOAT,
	KEY_FUEL_IDLE_PER_S: FieldKind.FLOAT,
	KEY_FUEL_LOW_RATIO: FieldKind.FLOAT,
}

## Dégâts d'impact. Les quatre champs sont strictement positifs, et le **seuil
## d'impact non nul** est une exigence d'audit (`M8`) autant qu'une règle de
## design : à seuil nul, le moindre déplacement grignoterait le blindage. Le
## seuil d'alerte est une fraction, donc dans `]0, 1[`.
const ARMOR_SCHEMA: Dictionary = {
	KEY_ARMOR_IMPACT_THRESHOLD: FieldKind.FLOAT,
	KEY_ARMOR_DAMAGE_PER_SPEED: FieldKind.FLOAT,
	KEY_ARMOR_LOW_RATIO: FieldKind.FLOAT,
	KEY_ARMOR_DESTRUCTION_DURATION: FieldKind.FLOAT,
}

## Paramètres de suivi de la caméra. Amortissement et zoom strictement positifs :
## un zoom nul annulerait la projection, un amortissement nul figerait la caméra.
const CAMERA_SCHEMA: Dictionary = {
	KEY_CAMERA_SMOOTHING: FieldKind.FLOAT,
	KEY_CAMERA_ZOOM: FieldKind.FLOAT,
}

## Bords de carte, en pixels monde. `y = 0` est la ligne de surface et croît vers
## le bas : le bord « haut » est donc le plus petit `y`. Seule contrainte de sens
## vérifiable ici : un rectangle non dégénéré.
const WORLD_SCHEMA: Dictionary = {
	KEY_WORLD_LEFT: FieldKind.FLOAT,
	KEY_WORLD_RIGHT: FieldKind.FLOAT,
	KEY_WORLD_TOP: FieldKind.FLOAT,
	KEY_WORLD_BOTTOM: FieldKind.FLOAT,
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
## Paramètres de physique de la foreuse, `champ` → valeur. Vide si le bloc a été
## rejeté : aucune valeur de repli n'est substituée, la foreuse reste alors
## immobile — une panne visible, conforme à la règle « aucun repli silencieux ».
var _drill_physics: Dictionary[String, float] = {}
## Paramètres de consommation de carburant, `champ` → valeur. Vide si le bloc a
## été rejeté : `FuelSystem` se désactive alors plutôt que de consommer un
## carburant au rythme d'un chiffre inventé.
var _drill_fuel: Dictionary[String, float] = {}
## Paramètres de la caméra et bords de carte. Vides si rejetés : la caméra reste
## alors immobile et le signale, au lieu de cadrer sur des valeurs inventées.
## Paramètres de dégâts d'impact. Vide si rejeté : `ArmorSystem` refuse alors
## d'infliger le moindre dégât — un blindage intact est l'échec le moins nuisible
## possible, et l'erreur de chargement reste bruyante.
var _armor: Dictionary[String, float] = {}
var _camera: Dictionary[String, float] = {}
var _world: Dictionary[String, float] = {}
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
	_load_drill()


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


## Fichier de la foreuse. Comme pour les améliorations, la racine n'est lue
## **qu'une fois** pour ses deux blocs : deux lectures dédoubleraient les
## messages en cas de fichier absent ou malformé.
##
## Contrairement aux trois autres fichiers, ces blocs ne portent pas un tableau
## d'entrées mais **un seul objet** : il n'y a qu'une foreuse. Chacun est donc
## validé d'un coup, et rejeté d'un coup — un jeu de paramètres à moitié valide
## produirait un comportement incohérent, plus difficile à diagnostiquer qu'une
## foreuse inerte.
func _load_drill() -> void:
	var root: Dictionary = _read_root(DRILL_PATH)
	if root.is_empty():
		return
	_load_drill_block(root, ROOT_DRILL_PHYSICS, DRILL_PHYSICS_SCHEMA, _drill_physics)
	_load_drill_block(root, ROOT_DRILL_FUEL, DRILL_FUEL_SCHEMA, _drill_fuel)
	_load_drill_block(root, ROOT_ARMOR, ARMOR_SCHEMA, _armor)
	_load_drill_block(root, ROOT_CAMERA, CAMERA_SCHEMA, _camera)
	_load_drill_block(root, ROOT_WORLD, WORLD_SCHEMA, _world)


## Le dictionnaire de destination est passé par référence : c'est ce qui permet
## aux deux blocs de partager la même séquence lecture → schéma → bornes, sans
## dupliquer le contrôle ni l'oublier d'un côté.
func _load_drill_block(root: Dictionary, root_key: String, schema: Dictionary, target: Dictionary[String, float]) -> void:
	var context: String = "%s → %s" % [DRILL_PATH, root_key]
	if not root.has(root_key):
		_report("%s : bloc manquant." % context)
		return
	var block: Dictionary = _accept_entry(root[root_key], schema, context)
	if block.is_empty():
		return
	if not _accept_drill_bounds(block, root_key, context):
		return
	for field: String in block:
		target[field] = block[field]


## Bornes propres à chaque bloc. Le schéma garantit le type, jamais le sens :
## une gravité nulle est un `float` parfaitement valide et un jeu cassé.
func _accept_drill_bounds(block: Dictionary, root_key: String, context: String) -> bool:
	match root_key:
		ROOT_DRILL_PHYSICS:
			return _accept_physics_bounds(block, context)
		ROOT_DRILL_FUEL:
			return _accept_fuel_bounds(block, context)
		ROOT_ARMOR:
			return _accept_armor_bounds(block, context)
		ROOT_CAMERA:
			return _accept_camera_bounds(block, context)
		ROOT_WORLD:
			return _accept_world_bounds(block, context)
	# Aucun contrôle de bornes déclaré pour ce bloc. Le rejeter en silence
	# rendrait le défaut indiagnosticable : un bloc ajouté sans sa validation
	# disparaîtrait sans un mot, alors que tout le chargeur repose sur l'échec
	# bruyant. Relevé comme KO `D2` par l'audit `2.6`, corrigé en story `2.10`.
	_report("%s : bloc « %s » sans contrôle de bornes déclaré dans _accept_drill_bounds(), bloc rejeté." % [context, root_key])
	return false


func _accept_armor_bounds(block: Dictionary, context: String) -> bool:
	for field: String in block:
		if block[field] <= 0.0:
			_report("%s : champ « %s » doit être strictement positif (lu : %s), bloc rejeté." % [context, field, block[field]])
			return false
	var ratio: float = block[KEY_ARMOR_LOW_RATIO]
	if ratio >= 1.0:
		_report("%s : champ « %s » doit être dans ]0, 1[ (lu : %s), bloc rejeté." % [context, KEY_ARMOR_LOW_RATIO, ratio])
		return false
	return true


func _accept_camera_bounds(block: Dictionary, context: String) -> bool:
	for field: String in block:
		if block[field] <= 0.0:
			_report("%s : champ « %s » doit être strictement positif (lu : %s), bloc rejeté." % [context, field, block[field]])
			return false
	return true


## Un rectangle inversé ou plat ne borne rien : la caméra dévoilerait le hors
## carte, exactement ce que les bords servent à empêcher.
func _accept_world_bounds(block: Dictionary, context: String) -> bool:
	if block[KEY_WORLD_RIGHT] <= block[KEY_WORLD_LEFT]:
		_report("%s : « %s » doit être supérieur à « %s » (lus : %s et %s), bloc rejeté." % [context, KEY_WORLD_RIGHT, KEY_WORLD_LEFT, block[KEY_WORLD_RIGHT], block[KEY_WORLD_LEFT]])
		return false
	if block[KEY_WORLD_BOTTOM] <= block[KEY_WORLD_TOP]:
		_report("%s : « %s » doit être supérieur à « %s » (lus : %s et %s), bloc rejeté." % [context, KEY_WORLD_BOTTOM, KEY_WORLD_TOP, block[KEY_WORLD_BOTTOM], block[KEY_WORLD_TOP]])
		return false
	return true


func _accept_fuel_bounds(block: Dictionary, context: String) -> bool:
	if block[KEY_FUEL_THRUST_PER_S] <= 0.0:
		_report("%s : champ « %s » doit être strictement positif (lu : %s), bloc rejeté." % [context, KEY_FUEL_THRUST_PER_S, block[KEY_FUEL_THRUST_PER_S]])
		return false
	if block[KEY_FUEL_IDLE_PER_S] < 0.0:
		_report("%s : champ « %s » ne peut pas être négatif (lu : %s), bloc rejeté." % [context, KEY_FUEL_IDLE_PER_S, block[KEY_FUEL_IDLE_PER_S]])
		return false
	var ratio: float = block[KEY_FUEL_LOW_RATIO]
	if ratio <= 0.0 or ratio >= 1.0:
		_report("%s : champ « %s » doit être dans ]0, 1[ (lu : %s), bloc rejeté." % [context, KEY_FUEL_LOW_RATIO, ratio])
		return false
	return true


## Bornes des paramètres de physique. Le bloc entier est rejeté dès le premier
## champ fautif : un jeu de paramètres partiellement valide produirait un
## comportement incohérent plus difficile à diagnostiquer qu'une foreuse inerte.
func _accept_physics_bounds(block: Dictionary, context: String) -> bool:
	for field: String in block:
		var value: float = block[field]
		if value <= 0.0:
			_report("%s : champ « %s » doit être strictement positif (lu : %s), bloc rejeté." % [context, field, value])
			return false
	if block[KEY_BRAKE_FACTOR] > 1.0:
		_report("%s : champ « %s » doit être dans ]0, 1] (lu : %s), bloc rejeté." % [context, KEY_BRAKE_FACTOR, block[KEY_BRAKE_FACTOR]])
		return false
	return true


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
	return "GameData — ressources : %d (%d actives MVP) · améliorations : %d (%d actives MVP) · événements : %d (%d actifs MVP) · physique foreuse : %d champs · carburant : %d champs · blindage : %d · caméra : %d · monde : %d · erreurs : %d" % [
		_resource_ids.size(), get_mvp_resource_ids().size(),
		_upgrade_ids.size(), get_mvp_upgrade_ids().size(),
		_event_ids.size(), get_mvp_event_ids().size(),
		_drill_physics.size(),
		_drill_fuel.size(),
		_armor.size(),
		_camera.size(),
		_world.size(),
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


# --- Physique de la foreuse ---------------------------------------------------
# Story 2.2. Un accesseur nommé par paramètre, comme pour les autres catalogues :
# le script de la foreuse ne connaît aucune clé JSON, et un champ manquant se
# signale au chargement, pas au premier appel dans `_physics_process()`.

## Vrai si le bloc de physique a été chargé en entier. Faux impose de considérer
## la foreuse comme non paramétrée : aucun chiffre n'a été inventé à la place.
func has_drill_physics() -> bool:
	return _drill_physics.size() == DRILL_PHYSICS_SCHEMA.size()


## Accélération de la pesanteur, en px/s².
func get_drill_gravity() -> float:
	return _get_physics_value(KEY_GRAVITY)


## Accélération horizontale sous poussée, en px/s².
func get_drill_horizontal_acceleration() -> float:
	return _get_physics_value(KEY_H_ACCELERATION)


## Décélération horizontale touches relâchées, en px/s² — c'est elle qui donne
## l'inertie : plus elle est faible, plus la foreuse glisse.
func get_drill_horizontal_friction() -> float:
	return _get_physics_value(KEY_H_FRICTION)


## Vitesse horizontale maximale, en px/s.
func get_drill_horizontal_max_speed() -> float:
	return _get_physics_value(KEY_H_MAX_SPEED)


## Poussée des propulseurs, en px/s². Doit excéder la gravité pour que la
## foreuse monte réellement — le cas contraire se constate à l'écran, il n'est
## pas contrôlable au chargement sans réimplanter la physique.
func get_drill_thrust() -> float:
	return _get_physics_value(KEY_THRUST)


## Accélération ajoutée vers le bas sur `move_down`, en px/s².
func get_drill_descent_acceleration() -> float:
	return _get_physics_value(KEY_DESCENT_ACCELERATION)


## Vitesse de montée maximale, en px/s.
func get_drill_max_rise_speed() -> float:
	return _get_physics_value(KEY_MAX_RISE_SPEED)


## Vitesse de chute maximale, en px/s.
func get_drill_max_fall_speed() -> float:
	return _get_physics_value(KEY_MAX_FALL_SPEED)


## Facteur de freinage, dans `]0, 1]` : il multiplie les vitesses maximales et
## divise la friction, de sorte qu'une seule valeur règle « moins vite » et
## « s'arrête plus court » (CDC : « réduit la vitesse et l'inertie »).
func get_drill_brake_factor() -> float:
	return _get_physics_value(KEY_BRAKE_FACTOR)


## Pixels par mètre : convertit une position monde en profondeur affichable.
## Provisoirement calé sur l'empreinte de la foreuse (story 2.1) ; à réconcilier
## avec la taille de tuile réelle du TileSet en story 3.1.
func get_pixels_per_meter() -> float:
	return _get_physics_value(KEY_PIXELS_PER_METER)


# --- Carburant de la foreuse --------------------------------------------------
# Story 2.3. La capacité du réservoir n'est **pas** ici : c'est la statistique
# `carburant_max` de l'amélioration `reacteur` (`get_start_stat()`), pour que
# l'achat d'un réacteur en phase 5 n'ait aucun effet de bord à écrire.

## Vrai si le bloc `carburant` a été chargé en entier.
func has_drill_fuel() -> bool:
	return _drill_fuel.size() == DRILL_FUEL_SCHEMA.size()


## Carburant consommé par seconde de poussée, en plus de la consommation au repos.
func get_fuel_thrust_consumption() -> float:
	return _get_fuel_value(KEY_FUEL_THRUST_PER_S)


## Carburant consommé par seconde, moteur en marche, sans poussée. Peut valoir 0.
func get_fuel_idle_consumption() -> float:
	return _get_fuel_value(KEY_FUEL_IDLE_PER_S)


## Fraction du réservoir sous laquelle l'alerte « carburant bas » est émise.
func get_fuel_low_ratio() -> float:
	return _get_fuel_value(KEY_FUEL_LOW_RATIO)


# --- Dégâts d'impact ----------------------------------------------------------
# Story 2.5. Le franchissement du seuil et le coût par px/s sont les deux seuls
# réglages de sévérité : les menaces de la phase 6 passeront par le même
# `ArmorSystem`, avec leurs propres sources de dégâts.

func has_armor_settings() -> bool:
	return _armor.size() == ARMOR_SCHEMA.size()


## Vitesse de choc, en px/s, en deçà de laquelle aucun dégât n'est infligé.
func get_armor_impact_threshold() -> float:
	return _get_armor_value(KEY_ARMOR_IMPACT_THRESHOLD)


## Points de blindage perdus par px/s de vitesse **au-delà** du seuil.
func get_armor_damage_per_speed() -> float:
	return _get_armor_value(KEY_ARMOR_DAMAGE_PER_SPEED)


## Fraction de blindage sous laquelle l'alerte « blindage faible » est émise.
func get_armor_low_ratio() -> float:
	return _get_armor_value(KEY_ARMOR_LOW_RATIO)


## Durée, en secondes, de la transition d'état à blindage nul.
func get_armor_destruction_duration() -> float:
	return _get_armor_value(KEY_ARMOR_DESTRUCTION_DURATION)


func _get_armor_value(field: String) -> float:
	if not _armor.has(field):
		push_error("GameData — paramètre de blindage absent : « %s » (voir %s)." % [field, DRILL_PATH])
		return 0.0
	return _armor[field]


# --- Caméra et bords de carte -------------------------------------------------
# Story 2.4. Les bords sont **hébergés** dans `data/drill.json` faute de
# `data/generation.json` avant la story 3.2 : cette façade ne changera pas à la
# migration, seul le fichier lu changera.

func has_camera_settings() -> bool:
	return _camera.size() == CAMERA_SCHEMA.size()


## Vitesse d'amortissement du suivi (`position_smoothing_speed`).
func get_camera_smoothing() -> float:
	if not _camera.has(KEY_CAMERA_SMOOTHING):
		push_error("GameData — paramètre de caméra absent : « %s » (voir %s)." % [KEY_CAMERA_SMOOTHING, DRILL_PATH])
		return 0.0
	return _camera[KEY_CAMERA_SMOOTHING]


## Facteur de zoom appliqué aux deux axes : au-delà de 1, la vue se rapproche.
func get_camera_zoom() -> float:
	if not _camera.has(KEY_CAMERA_ZOOM):
		push_error("GameData — paramètre de caméra absent : « %s » (voir %s)." % [KEY_CAMERA_ZOOM, DRILL_PATH])
		return 0.0
	return _camera[KEY_CAMERA_ZOOM]


func has_world_bounds() -> bool:
	return _world.size() == WORLD_SCHEMA.size()


## Bords de carte sous forme de rectangle monde, coin haut-gauche en `position`.
## Rendre les quatre bords d'un bloc évite qu'un appelant n'en oublie un.
func get_world_bounds() -> Rect2:
	if not has_world_bounds():
		push_error("GameData — bords de carte indisponibles (voir %s)." % DRILL_PATH)
		return Rect2()
	var left: float = _world[KEY_WORLD_LEFT]
	var top: float = _world[KEY_WORLD_TOP]
	return Rect2(left, top, _world[KEY_WORLD_RIGHT] - left, _world[KEY_WORLD_BOTTOM] - top)


func _get_fuel_value(field: String) -> float:
	if not _drill_fuel.has(field):
		push_error("GameData — paramètre de carburant absent : « %s » (voir %s)." % [field, DRILL_PATH])
		return 0.0
	return _drill_fuel[field]


func _get_physics_value(field: String) -> float:
	if not _drill_physics.has(field):
		push_error("GameData — paramètre de physique absent : « %s » (voir %s)." % [field, DRILL_PATH])
		return 0.0
	return _drill_physics[field]


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
