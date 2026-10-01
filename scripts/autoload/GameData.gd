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
const GENERATION_PATH: String = "res://data/generation.json"

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
const ROOT_DRILLING: String = "forage"
const ROOT_FEEDBACK: String = "retour"
const ROOT_MESSAGES: String = "messages"
## `monde` vit désormais dans `data/generation.json` : la story 3.2 l'a migré
## depuis `data/drill.json`, où la story 2.4 l'hébergeait à titre temporaire.
const ROOT_WORLD: String = "monde"
const ROOT_GENERATION: String = "generation"
const ROOT_ANCHORS: String = "ancrages"
const ROOT_STRATA: String = "strates"
const ROOT_DEPTH_LAYERS: String = "couches_profondeur"
const ROOT_ORE_DENSITY: String = "densites_minerai"
const ROOT_LOOT: String = "loot"
const KEY_LOOT_ENTRIES: String = "entrees"
const KEY_LOOT_WEIGHTS: String = "poids"
const KEY_LOOT_RESOURCE_ID: String = "resource_id"
const KEY_LOOT_HIGH_RARITY: String = "rarete_haute"

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
## Carburant prélevé à chaque tuile détruite (story 3.4, `TM-3.9`).
const KEY_FUEL_PER_DRILLED_TILE: String = "consommation_forage_par_tuile"

# Durée de forage d'une tuile (story 3.4) : `duree_base_s + duree_par_hardness_s ×
# hardness`. La **puissance** du foret n'est pas ici : c'est la statistique
# `puissance_foret` de l'amélioration `foret`. Q21 : la durée ne dépend jamais du
# niveau de foret (vitesse de forage non couverte au MVP, écart E12).
const KEY_DRILL_BASE_DURATION: String = "duree_base_s"
const KEY_DRILL_DURATION_PER_HARDNESS: String = "duree_par_hardness_s"
## Durée de visibilité du retour d'une rareté haute (story 3.7, §2.4).
const KEY_JACKPOT_DURATION: String = "duree_jackpot_s"
# Bloc `messages` (story 4.2) : messages transitoires du HUD.
const KEY_MESSAGE_DURATION: String = "duree_message_s"
const KEY_MESSAGE_MAX: String = "messages_max"

# Dégâts d'impact (story 2.5, arbitrage Q20). La **capacité** de blindage n'est
# pas ici : c'est la statistique `blindage_max` de l'amélioration `blindage` de
# data/upgrades.json, qui deviendra achetable en phase 5 (Q21).

const KEY_ARMOR_IMPACT_THRESHOLD: String = "seuil_impact_px_s"
const KEY_ARMOR_DAMAGE_PER_SPEED: String = "degats_par_px_s"
const KEY_ARMOR_LOW_RATIO: String = "seuil_alerte_ratio"
const KEY_ARMOR_DESTRUCTION_DURATION: String = "duree_destruction_s"

const KEY_CAMERA_SMOOTHING: String = "amortissement_position"
const KEY_CAMERA_ZOOM: String = "zoom"
# Dimensions de la carte, **en tuiles** (story 3.2). Les quatre bords en pixels
# n'existent plus comme données : ils sont **dérivés** par `get_world_bounds()`.
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

## Sentinelle « jusqu'au fond de la carte » pour la dernière strate et le dernier
## palier de profondeur. Une borne négative ne peut pas être une profondeur réelle,
## ce qui la rend non ambiguë — contrairement à 0, qui est la surface.
const DEPTH_UNBOUNDED: float = -1.0

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
	KEY_FUEL_PER_DRILLED_TILE: FieldKind.FLOAT,
}

## Durée de forage. La base peut valoir 0 (seule la dureté compte alors) ; le
## coût par point de dureté est strictement positif, sinon toutes les tuiles se
## foreraient à la même vitesse et `hardness` perdrait son sens (critère 9).
const DRILLING_SCHEMA: Dictionary = {
	KEY_DRILL_BASE_DURATION: FieldKind.FLOAT,
	KEY_DRILL_DURATION_PER_HARDNESS: FieldKind.FLOAT,
}

## Retour audiovisuel du forage. Durée strictement positive : un retour de durée
## nulle ne serait pas « visible assez longtemps pour être perçu » (§2.4).
const FEEDBACK_SCHEMA: Dictionary = {
	KEY_JACKPOT_DURATION: FieldKind.FLOAT,
}

## Messages transitoires de bord (story 4.2). Durée strictement positive — un
## message de durée nulle serait une perte silencieuse (`G10`) — et nombre de
## messages simultanés **entier** d'au moins 1. Lu en `FLOAT` comme tout nombre
## JSON, l'entier est vérifié par les bornes.
const MESSAGES_SCHEMA: Dictionary = {
	KEY_MESSAGE_DURATION: FieldKind.FLOAT,
	KEY_MESSAGE_MAX: FieldKind.FLOAT,
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

## Dimensions de la carte, en tuiles. Toutes strictement positives : une carte
## sans largeur, sans profondeur ou sans ceinture n'est pas une carte dégradée,
## c'est une carte absente.
const MAP_SCHEMA: Dictionary = {
	KEY_MAP_WIDTH: FieldKind.INT,
	KEY_MAP_SURFACE: FieldKind.INT,
	KEY_MAP_DEPTH: FieldKind.INT,
	KEY_MAP_BELT: FieldKind.INT,
}

## Graine de génération. Aucune borne : toute valeur entière est une graine
## légitime, y compris négative ou nulle — c'est justement ce qui la rend forçable.
const GENERATION_SCHEMA: Dictionary = {
	KEY_SEED: FieldKind.INT,
}

## Ancrages du monde. Les bornes se vérifient **contre les dimensions de la carte**
## (`_load_anchors`) : un ancrage dans la ceinture ou hors carte est rejeté.
const ANCHORS_SCHEMA: Dictionary = {
	KEY_SURFACE_COLUMN_MIN: FieldKind.INT,
	KEY_SURFACE_COLUMN_MAX: FieldKind.INT,
	KEY_SPAWN_COLUMN: FieldKind.INT,
	KEY_ANOMALY_COLUMN: FieldKind.INT,
	KEY_ANOMALY_ROW: FieldKind.INT,
}

## Une strate : jusqu'à quelle profondeur elle s'étend, et la dureté de sa tuile.
const STRATUM_SCHEMA: Dictionary = {
	KEY_DEPTH_MAX_M: FieldKind.FLOAT,
	KEY_HARDNESS: FieldKind.INT,
}

## Un palier de profondeur — clé commune à la table de loot (§2.2) et à la courbe
## de risque (§4.2), arbitrage Q30 : un seul découpage.
const DEPTH_LAYER_SCHEMA: Dictionary = {
	KEY_ID: FieldKind.STRING,
	KEY_DEPTH_MIN_M: FieldKind.FLOAT,
	KEY_DEPTH_MAX_M: FieldKind.FLOAT,
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
## Durée de forage. Vide si rejeté : `MiningSystem` refuse alors tout forage.
var _drilling: Dictionary[String, float] = {}
## Retour audiovisuel. Vide si rejeté : aucun retour de rareté n'est affiché.
var _feedback: Dictionary[String, float] = {}
## Messages transitoires. Vide si rejeté : le HUD n'affiche alors aucun message
## transitoire et le signale, plutôt que d'inventer une durée.
var _messages: Dictionary[String, float] = {}
## Dimensions de la carte en tuiles, graine, strates, paliers de profondeur et
## densités de minerai. Vides si rejetés : le générateur refuse alors de produire
## un terrain, plutôt que d'en produire un sur des valeurs inventées.
var _map: Dictionary[String, int] = {}
var _generation: Dictionary[String, int] = {}
## Ancrages indépendants de la graine. Vide si rejeté : la foreuse n'a alors aucun
## point d'apparition et le signale, au lieu d'apparaître à une position inventée.
var _anchors: Dictionary[String, int] = {}
var _strata: Array[Dictionary] = []
var _depth_layers: Array[Dictionary] = []
var _depth_layer_ids: Array[String] = []
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
	_load_generation()


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
	_load_drill_block(root, ROOT_DRILLING, DRILLING_SCHEMA, _drilling)
	_load_drill_block(root, ROOT_FEEDBACK, FEEDBACK_SCHEMA, _feedback)
	_load_drill_block(root, ROOT_MESSAGES, MESSAGES_SCHEMA, _messages)


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
		ROOT_DRILLING:
			return _accept_drilling_bounds(block, context)
		ROOT_FEEDBACK:
			return _accept_feedback_bounds(block, context)
		ROOT_MESSAGES:
			return _accept_messages_bounds(block, context)
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
# --- Génération du terrain -----------------------------------------------------
# Story 3.2. Ce fichier est la **source de vérité des dimensions de la carte** :
# le bloc `monde` y a été migré depuis `data/drill.json`, où la story 2.4
# l'hébergeait à titre temporaire (contrainte dérivée de Q24).

## Lecture unique du fichier, puis validation bloc par bloc — même contrat que
## `_load_drill()` : deux lectures dédoubleraient les messages d'erreur.
func _load_generation() -> void:
	var root: Dictionary = _read_root(GENERATION_PATH)
	if root.is_empty():
		return
	_load_map_block(root)
	_load_anchors(root)
	_load_generation_block(root)
	_load_strata(root)
	_load_depth_layers(root)
	_load_ore_density(root)
	_load_loot(root)


func _load_map_block(root: Dictionary) -> void:
	var context: String = "%s → %s" % [GENERATION_PATH, ROOT_WORLD]
	if not root.has(ROOT_WORLD):
		_report("%s : bloc manquant." % context)
		return
	var block: Dictionary = _accept_entry(root[ROOT_WORLD], MAP_SCHEMA, context)
	if block.is_empty():
		return
	for field: String in block:
		if block[field] <= 0:
			_report("%s : champ « %s » doit être strictement positif (lu : %d), bloc rejeté." % [context, field, block[field]])
			return
	# Il faut au moins une colonne intérieure entre les deux colonnes de ceinture,
	# sinon la carte est une paroi pleine et la descente est impossible.
	var minimum_width: int = 2 * block[KEY_MAP_BELT] + 1
	if block[KEY_MAP_WIDTH] < minimum_width:
		_report("%s : « %s » (%d) doit valoir au moins %d pour laisser une colonne creusable entre les deux ceintures, bloc rejeté." % [context, KEY_MAP_WIDTH, block[KEY_MAP_WIDTH], minimum_width])
		return
	for field: String in block:
		_map[field] = block[field]


## Ancrages du monde, validés **après** le bloc `monde` : leurs bornes en dépendent.
## Colonnes intérieures seulement (hors ceinture), apparition dans la zone de
## surface, anomalie sur une rangée creusable.
func _load_anchors(root: Dictionary) -> void:
	var context: String = "%s → %s" % [GENERATION_PATH, ROOT_ANCHORS]
	if not root.has(ROOT_ANCHORS):
		_report("%s : bloc manquant." % context)
		return
	var block: Dictionary = _accept_entry(root[ROOT_ANCHORS], ANCHORS_SCHEMA, context)
	if block.is_empty():
		return
	if not has_world_bounds():
		_report("%s : bloc « %s » invalide, impossible de borner les ancrages — bloc rejeté." % [context, ROOT_WORLD])
		return
	var first_column: int = _get_first_interior_column()
	var last_column: int = _get_last_interior_column()
	for field: String in [KEY_SURFACE_COLUMN_MIN, KEY_SURFACE_COLUMN_MAX, KEY_SPAWN_COLUMN, KEY_ANOMALY_COLUMN]:
		if block[field] < first_column or block[field] > last_column:
			_report("%s : « %s » (%d) hors des colonnes intérieures [%d, %d], bloc rejeté." % [context, field, block[field], first_column, last_column])
			return
	if block[KEY_SURFACE_COLUMN_MIN] > block[KEY_SURFACE_COLUMN_MAX]:
		_report("%s : « %s » supérieur à « %s », bloc rejeté." % [context, KEY_SURFACE_COLUMN_MIN, KEY_SURFACE_COLUMN_MAX])
		return
	if block[KEY_SPAWN_COLUMN] < block[KEY_SURFACE_COLUMN_MIN] or block[KEY_SPAWN_COLUMN] > block[KEY_SURFACE_COLUMN_MAX]:
		_report("%s : « %s » (%d) hors de la zone de surface, bloc rejeté." % [context, KEY_SPAWN_COLUMN, block[KEY_SPAWN_COLUMN]])
		return
	if block[KEY_ANOMALY_ROW] < 0 or block[KEY_ANOMALY_ROW] >= _map[KEY_MAP_DEPTH]:
		_report("%s : « %s » (%d) hors des rangées creusables [0, %d], bloc rejeté." % [context, KEY_ANOMALY_ROW, block[KEY_ANOMALY_ROW], _map[KEY_MAP_DEPTH] - 1])
		return
	for field: String in block:
		_anchors[field] = block[field]


func _load_generation_block(root: Dictionary) -> void:
	var context: String = "%s → %s" % [GENERATION_PATH, ROOT_GENERATION]
	if not root.has(ROOT_GENERATION):
		_report("%s : bloc manquant." % context)
		return
	var block: Dictionary = _accept_entry(root[ROOT_GENERATION], GENERATION_SCHEMA, context)
	if block.is_empty():
		return
	for field: String in block:
		_generation[field] = block[field]


## Strates de terrain, de la surface vers le fond. La **dernière** doit porter la
## sentinelle `DEPTH_UNBOUNDED` : sans elle, la partie basse de la carte n'aurait
## aucune strate déclarée et le générateur devrait inventer une tuile.
func _load_strata(root: Dictionary) -> void:
	var context: String = "%s → %s" % [GENERATION_PATH, ROOT_STRATA]
	var entries: Array = _extract_array(root, GENERATION_PATH, ROOT_STRATA)
	if entries.is_empty():
		_report("%s : aucune strate déclarée." % context)
		return
	var accepted: Array[Dictionary] = []
	var previous_depth: float = 0.0
	for index: int in entries.size():
		var entry_context: String = "%s[%d]" % [context, index]
		var entry: Dictionary = _accept_entry(entries[index], STRATUM_SCHEMA, entry_context)
		if entry.is_empty():
			return
		if entry[KEY_HARDNESS] <= 0:
			_report("%s : « %s » doit être strictement positif (lu : %d), strates rejetées." % [entry_context, KEY_HARDNESS, entry[KEY_HARDNESS]])
			return
		var depth: float = entry[KEY_DEPTH_MAX_M]
		var is_last: bool = index == entries.size() - 1
		if is_last:
			if not is_equal_approx(depth, DEPTH_UNBOUNDED):
				_report("%s : la dernière strate doit porter « %s » = %s (jusqu'au fond), lu %s — strates rejetées." % [entry_context, KEY_DEPTH_MAX_M, DEPTH_UNBOUNDED, depth])
				return
		elif depth <= previous_depth:
			_report("%s : « %s » (%s) doit être strictement croissant (précédent : %s), strates rejetées." % [entry_context, KEY_DEPTH_MAX_M, depth, previous_depth])
			return
		else:
			previous_depth = depth
		accepted.append(entry)
	_strata.assign(accepted)


## Paliers de profondeur — clé unique partagée par la table de loot (§2.2) et la
## courbe de risque (§4.2), arbitrage Q30. Ils doivent être **contigus** et partir
## de la surface : un trou entre deux paliers laisserait des cases sans table.
func _load_depth_layers(root: Dictionary) -> void:
	var context: String = "%s → %s" % [GENERATION_PATH, ROOT_DEPTH_LAYERS]
	var entries: Array = _extract_array(root, GENERATION_PATH, ROOT_DEPTH_LAYERS)
	if entries.is_empty():
		_report("%s : aucun palier de profondeur déclaré." % context)
		return
	var accepted: Array[Dictionary] = []
	var ids: Array[String] = []
	var expected_min: float = 0.0
	for index: int in entries.size():
		var entry_context: String = "%s[%d]" % [context, index]
		var entry: Dictionary = _accept_entry(entries[index], DEPTH_LAYER_SCHEMA, entry_context)
		if entry.is_empty():
			return
		var layer_id: String = entry[KEY_ID]
		if not _accept_id(layer_id, ids, entry_context):
			return
		if not is_equal_approx(entry[KEY_DEPTH_MIN_M], expected_min):
			_report("%s : « %s » doit valoir %s pour que les paliers soient contigus (lu %s), paliers rejetés." % [entry_context, KEY_DEPTH_MIN_M, expected_min, entry[KEY_DEPTH_MIN_M]])
			return
		var depth_max: float = entry[KEY_DEPTH_MAX_M]
		var is_last: bool = index == entries.size() - 1
		if is_last:
			if not is_equal_approx(depth_max, DEPTH_UNBOUNDED):
				_report("%s : le dernier palier doit porter « %s » = %s (jusqu'au fond), lu %s — paliers rejetés." % [entry_context, KEY_DEPTH_MAX_M, DEPTH_UNBOUNDED, depth_max])
				return
		elif depth_max <= entry[KEY_DEPTH_MIN_M]:
			_report("%s : « %s » (%s) doit dépasser « %s » (%s), paliers rejetés." % [entry_context, KEY_DEPTH_MAX_M, depth_max, KEY_DEPTH_MIN_M, entry[KEY_DEPTH_MIN_M]])
			return
		else:
			expected_min = depth_max
		ids.append(layer_id)
		accepted.append(entry)
	_depth_layers.assign(accepted)
	_depth_layer_ids.assign(ids)


## Densités de minerai par palier. Contrôles : un palier déclaré et un seul par
## entrée, des `resource_id` connus et **actifs au MVP** (K10), des probabilités
## dans `[0, 1]`, et une **somme strictement inférieure à 1** par palier — sans
## quoi il ne resterait aucune case stérile, donc aucune case pour le tirage de
## loot de la story 3.6 (arbitrage Q28 : la tuile décide, le reste est tiré).
## Table de loot des cases stériles (story 3.6). Validation opposable à l'audit :
## entrées uniques, **une et une seule** entrée « Rien » (ressource vide, critère 8),
## toute autre entrée liée à une ressource **active** (`K10` garanti par la
## structure), poids déclarés pour **chaque** palier et **seulement** eux (`Q30`),
## poids positifs, somme strictement positive et « Rien » strictement inférieur à
## la somme sur chaque palier (`K9`, règle §2.4). Tout écart rejette la table.
func _load_loot(root: Dictionary) -> void:
	var context: String = "%s → %s" % [GENERATION_PATH, ROOT_LOOT]
	if not root.has(ROOT_LOOT) or typeof(root[ROOT_LOOT]) != TYPE_DICTIONARY:
		_report("%s : bloc manquant ou non objet." % context)
		return
	var block: Dictionary = root[ROOT_LOOT]
	if _depth_layer_ids.is_empty():
		_report("%s : les paliers de profondeur n'ont pas été chargés, table rejetée." % context)
		return
	if not block.has(KEY_LOOT_ENTRIES) or typeof(block[KEY_LOOT_ENTRIES]) != TYPE_ARRAY or not block.has(KEY_LOOT_WEIGHTS) or typeof(block[KEY_LOOT_WEIGHTS]) != TYPE_DICTIONARY:
		_report("%s : « %s » (tableau) et « %s » (objet) sont requis, table rejetée." % [context, KEY_LOOT_ENTRIES, KEY_LOOT_WEIGHTS])
		return
	var entries: Array[Dictionary] = _read_loot_entries(block[KEY_LOOT_ENTRIES], context)
	if entries.is_empty():
		return
	var entry_ids: Array[String] = []
	var resources: Dictionary[String, String] = {}
	var high_rarity: Array[String] = []
	var nothing_id: String = ""
	for entry: Dictionary in entries:
		entry_ids.append(entry[KEY_ID])
		resources[entry[KEY_ID]] = entry[KEY_LOOT_RESOURCE_ID]
		if entry[KEY_LOOT_HIGH_RARITY]:
			high_rarity.append(entry[KEY_ID])
		if String(entry[KEY_LOOT_RESOURCE_ID]).is_empty():
			nothing_id = entry[KEY_ID]
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
		if typeof(raw) != TYPE_DICTIONARY or typeof(raw.get(KEY_ID)) != TYPE_STRING or typeof(raw.get(KEY_LOOT_RESOURCE_ID)) != TYPE_STRING or typeof(raw.get(KEY_LOOT_HIGH_RARITY)) != TYPE_BOOL or raw.size() != 3:
			_report("%s : entrée invalide (attendu : « %s » et « %s », chaînes, « %s », booléen) : %s — table rejetée." % [context, KEY_ID, KEY_LOOT_RESOURCE_ID, KEY_LOOT_HIGH_RARITY, raw])
			return []
		var entry_id: String = raw[KEY_ID]
		var resource_id: String = raw[KEY_LOOT_RESOURCE_ID]
		if entry_id.is_empty() or seen.has(entry_id):
			_report("%s : identifiant d'entrée vide ou en double (« %s »), table rejetée." % [context, entry_id])
			return []
		if resource_id.is_empty():
			if not nothing_id.is_empty():
				_report("%s : deux entrées « Rien » (« %s », « %s »), table rejetée." % [context, nothing_id, entry_id])
				return []
			if raw[KEY_LOOT_HIGH_RARITY]:
				_report("%s : l'entrée « Rien » (« %s ») ne peut pas être une rareté haute, table rejetée." % [context, entry_id])
				return []
			nothing_id = entry_id
		elif not has_resource(resource_id) or not is_resource_active_in_mvp(resource_id):
			_report("%s : entrée « %s » liée à « %s », inconnu ou `actif_mvp: false` (Q12) — table rejetée." % [context, entry_id, resource_id])
			return []
		seen[entry_id] = true
		accepted.append(raw)
	if nothing_id.is_empty():
		_report("%s : aucune entrée « Rien » explicite (ressource vide), table rejetée." % context)
		return []
	return accepted


## Poids de chaque palier, alignés sur l'ordre des entrées. Vide si un palier est
## inconnu, manquant, incomplet, négatif, ou à 0 % de drop (`K9`).
func _read_loot_weights(weights_block: Dictionary, entry_ids: Array[String], nothing_id: String, context: String) -> Dictionary[String, PackedFloat64Array]:
	var weights: Dictionary[String, PackedFloat64Array] = {}
	for layer_id: String in weights_block:
		if not _depth_layer_ids.has(layer_id):
			_report("%s : poids déclarés pour « %s », palier inconnu de « %s », table rejetée." % [context, layer_id, ROOT_DEPTH_LAYERS])
			return {}
	for layer_id: String in _depth_layer_ids:
		var layer_context: String = "%s → %s → %s" % [context, KEY_LOOT_WEIGHTS, layer_id]
		if not weights_block.has(layer_id) or typeof(weights_block[layer_id]) != TYPE_DICTIONARY:
			_report("%s : poids manquants, table rejetée." % layer_context)
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
		_report("%s : %d poids pour %d entrées, table rejetée." % [layer_context, layer.size(), entry_ids.size()])
		return PackedFloat64Array()
	var row: PackedFloat64Array = PackedFloat64Array()
	var total: float = 0.0
	for entry_id: String in entry_ids:
		if not layer.has(entry_id) or not _matches_kind(layer[entry_id], FieldKind.FLOAT) or float(layer[entry_id]) < 0.0:
			_report("%s : poids de « %s » absent, non numérique ou négatif, table rejetée." % [layer_context, entry_id])
			return PackedFloat64Array()
		row.append(float(layer[entry_id]))
		total += float(layer[entry_id])
	if total <= 0.0 or float(layer[nothing_id]) >= total:
		_report("%s : 0 %% de drop — somme %s, « %s » %s. La règle §2.4 exige une chance non nulle de drop sur chaque palier, table rejetée." % [layer_context, total, nothing_id, layer[nothing_id]])
		return PackedFloat64Array()
	return row


func _load_ore_density(root: Dictionary) -> void:
	var context: String = "%s → %s" % [GENERATION_PATH, ROOT_ORE_DENSITY]
	if not root.has(ROOT_ORE_DENSITY):
		_report("%s : bloc manquant." % context)
		return
	if typeof(root[ROOT_ORE_DENSITY]) != TYPE_DICTIONARY:
		_report("%s : le bloc doit être un objet JSON." % context)
		return
	var block: Dictionary = root[ROOT_ORE_DENSITY]
	if _depth_layer_ids.is_empty():
		_report("%s : les paliers de profondeur n'ont pas été chargés, densités rejetées." % context)
		return
	var accepted: Dictionary[String, Dictionary] = {}
	for layer_id: String in _depth_layer_ids:
		var layer_context: String = "%s → %s" % [context, layer_id]
		if not block.has(layer_id):
			_report("%s : palier sans densités déclarées." % layer_context)
			return
		if typeof(block[layer_id]) != TYPE_DICTIONARY:
			_report("%s : les densités d'un palier doivent être un objet JSON." % layer_context)
			return
		var densities: Dictionary[String, float] = {}
		var total: float = 0.0
		for resource_id: String in block[layer_id]:
			var value: Variant = block[layer_id][resource_id]
			if not _matches_kind(value, FieldKind.FLOAT):
				_report("%s : densité de « %s » non numérique." % [layer_context, resource_id])
				return
			var probability: float = float(value)
			if probability < 0.0 or probability > 1.0:
				_report("%s : densité de « %s » hors de [0, 1] (lue %s)." % [layer_context, resource_id, probability])
				return
			if not has_resource(resource_id):
				_report("%s : « %s » inconnu du catalogue %s." % [layer_context, resource_id, RESOURCES_PATH])
				return
			if not is_resource_active_in_mvp(resource_id):
				_report("%s : « %s » est `actif_mvp: false` et ne doit pas être généré au MVP." % [layer_context, resource_id])
				return
			densities[resource_id] = probability
			total += probability
		if total >= 1.0:
			_report("%s : la somme des densités vaut %s et doit rester strictement inférieure à 1, sinon aucune case stérile ne subsiste pour le tirage de loot." % [layer_context, total])
			return
		accepted[layer_id] = densities
	for layer_id: String in block:
		if not _depth_layer_ids.has(layer_id):
			_report("%s : palier « %s » inconnu — il ne figure pas dans « %s »." % [context, layer_id, ROOT_DEPTH_LAYERS])
			return
	for layer_id: String in accepted:
		_ore_density[layer_id] = accepted[layer_id]


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
	# Un forage gratuit rendrait faux le critère MVP « tuile détruite seulement si
	# carburant suffisant » : le coût par tuile est strictement positif.
	if block[KEY_FUEL_PER_DRILLED_TILE] <= 0.0:
		_report("%s : champ « %s » doit être strictement positif (lu : %s), bloc rejeté." % [context, KEY_FUEL_PER_DRILLED_TILE, block[KEY_FUEL_PER_DRILLED_TILE]])
		return false
	return true


func _accept_feedback_bounds(block: Dictionary, context: String) -> bool:
	if block[KEY_JACKPOT_DURATION] <= 0.0:
		_report("%s : champ « %s » doit être strictement positif (lu : %s), bloc rejeté." % [context, KEY_JACKPOT_DURATION, block[KEY_JACKPOT_DURATION]])
		return false
	return true


func _accept_messages_bounds(block: Dictionary, context: String) -> bool:
	if block[KEY_MESSAGE_DURATION] <= 0.0:
		_report("%s : champ « %s » doit être strictement positif (lu : %s), bloc rejeté." % [context, KEY_MESSAGE_DURATION, block[KEY_MESSAGE_DURATION]])
		return false
	var count: float = block[KEY_MESSAGE_MAX]
	if count < 1.0 or not is_equal_approx(count, roundf(count)):
		_report("%s : champ « %s » doit être un entier supérieur ou égal à 1 (lu : %s), bloc rejeté." % [context, KEY_MESSAGE_MAX, count])
		return false
	return true


func _accept_drilling_bounds(block: Dictionary, context: String) -> bool:
	if block[KEY_DRILL_BASE_DURATION] < 0.0:
		_report("%s : champ « %s » ne peut pas être négatif (lu : %s), bloc rejeté." % [context, KEY_DRILL_BASE_DURATION, block[KEY_DRILL_BASE_DURATION]])
		return false
	if block[KEY_DRILL_DURATION_PER_HARDNESS] <= 0.0:
		_report("%s : champ « %s » doit être strictement positif (lu : %s), bloc rejeté." % [context, KEY_DRILL_DURATION_PER_HARDNESS, block[KEY_DRILL_DURATION_PER_HARDNESS]])
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
	return "GameData — ressources : %d (%d actives MVP) · améliorations : %d (%d actives MVP) · événements : %d (%d actifs MVP) · physique foreuse : %d champs · carburant : %d champs · blindage : %d · caméra : %d · forage : %d · retour : %d · messages : %d · monde : %d tuiles · ancrages : %d · strates : %d · paliers : %d · loot : %d entrées · erreurs : %d" % [
		_resource_ids.size(), get_mvp_resource_ids().size(),
		_upgrade_ids.size(), get_mvp_upgrade_ids().size(),
		_event_ids.size(), get_mvp_event_ids().size(),
		_drill_physics.size(),
		_drill_fuel.size(),
		_armor.size(),
		_camera.size(),
		_drilling.size(),
		_feedback.size(),
		_messages.size(),
		_map.size(),
		_anchors.size(),
		_strata.size(),
		_depth_layers.size(),
		_loot_entry_ids.size(),
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
	var upgrade_id: String = get_upgrade_id_for_statistic(statistic_id)
	if upgrade_id.is_empty():
		return 0.0
	return get_upgrade_value(upgrade_id, get_upgrade_start_level(upgrade_id))


## Amélioration qui pilote une statistique (`STAT_*`). Permet à un système de
## lire la valeur **courante** d'une statistique — effet du niveau atteint dans
## `GameState` — sans connaître l'`id` de l'amélioration (story 3.4 : puissance du
## foret). Chaîne vide et erreur si aucune amélioration ne la pilote.
func get_upgrade_id_for_statistic(statistic_id: String) -> String:
	for upgrade_id: String in _upgrade_ids:
		if _upgrades[upgrade_id][KEY_STATISTIC] == statistic_id:
			return upgrade_id
	push_error("GameData — statistique inconnue : « %s »." % statistic_id)
	return ""


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
## **Verrouillé à 32 par la story 3.1** (décision utilisateur du 2026-09-27) :
## 1 tuile = 1 m = 32 px. La valeur n'est plus provisoire — elle est désormais
## égale à `TileSet.tile_size.x`, et l'égalité est vérifiée par assertion.
## ⚠️ La changer exigerait de recalculer **ensemble** cette valeur, les bords de
## carte, la conversion profondeur → mètres et les repères de la courbe de risque
## du §4.2 de l'amendement : une divergence fausserait la profondeur affichée,
## donc toute la courbe de risque.
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


## Carburant prélevé à chaque tuile détruite par le foret (story 3.4).
func get_fuel_per_drilled_tile() -> float:
	return _get_fuel_value(KEY_FUEL_PER_DRILLED_TILE)


# --- Forage -------------------------------------------------------------------
# Story 3.4. Durée seulement : la puissance est une statistique d'amélioration.

func has_drilling_settings() -> bool:
	return _drilling.size() == DRILLING_SCHEMA.size()


func has_feedback_settings() -> bool:
	return _feedback.size() == FEEDBACK_SCHEMA.size()


## Durée, en secondes, de visibilité du retour d'une rareté haute (story 3.7).
func get_jackpot_duration() -> float:
	if not has_feedback_settings():
		push_error("GameData — durée du retour de rareté indisponible (voir %s)." % DRILL_PATH)
		return 0.0
	return _feedback[KEY_JACKPOT_DURATION]


func has_message_settings() -> bool:
	return _messages.size() == MESSAGES_SCHEMA.size()


## Durée, en secondes, d'affichage d'un message transitoire de bord (story 4.2).
func get_message_duration() -> float:
	if not has_message_settings():
		push_error("GameData — durée des messages de bord indisponible (voir %s)." % DRILL_PATH)
		return 0.0
	return _messages[KEY_MESSAGE_DURATION]


## Nombre de messages transitoires affichés ensemble (story 4.2).
func get_message_max() -> int:
	if not has_message_settings():
		push_error("GameData — nombre de messages de bord indisponible (voir %s)." % DRILL_PATH)
		return 0
	return roundi(_messages[KEY_MESSAGE_MAX])


## Durée, en secondes, du forage d'une tuile de cette dureté.
func get_drilling_duration(hardness: int) -> float:
	if not has_drilling_settings():
		push_error("GameData — durée de forage indisponible (voir %s)." % DRILL_PATH)
		return 0.0
	return _drilling[KEY_DRILL_BASE_DURATION] + _drilling[KEY_DRILL_DURATION_PER_HARDNESS] * float(hardness)


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
	return _map.size() == MAP_SCHEMA.size()


## Bords de carte sous forme de rectangle monde, coin haut-gauche en `position`.
## Rendre les quatre bords d'un bloc évite qu'un appelant n'en oublie un.
##
## **Signature inchangée depuis la story 2.4** : c'est la condition (a) du critère 5
## de la story 3.2. Ce qui a changé est **invisible aux appelants** — `CameraSystem`
## et le confinement de `DrillRig` n'ont pas été modifiés : les quatre bords ne sont
## plus lus en pixels dans `data/drill.json`, ils sont **dérivés** des dimensions en
## tuiles de `data/generation.json`. Le générateur et le confinement ne peuvent donc
## plus décrire deux cartes différentes : ils lisent la même donnée. C'est la
## contrainte dérivée de Q24, refermée **par construction** et non par vigilance.
##
## Géométrie : `y = 0` est la ligne de surface. La bande au-dessus (`hauteur_surface`)
## reste libre — elle accueille la zone de surface de la story 3.3. La carte est
## centrée en `x`.
func get_world_bounds() -> Rect2:
	if not has_world_bounds():
		push_error("GameData — dimensions de carte indisponibles (voir %s)." % GENERATION_PATH)
		return Rect2()
	var tile: float = get_pixels_per_meter()
	var left: float = -float(_map[KEY_MAP_WIDTH] / 2) * tile
	var top: float = -float(_map[KEY_MAP_SURFACE]) * tile
	var width: float = float(_map[KEY_MAP_WIDTH]) * tile
	var height: float = float(_map[KEY_MAP_SURFACE] + _map[KEY_MAP_DEPTH] + _map[KEY_MAP_BELT]) * tile
	return Rect2(left, top, width, height)


# --- Dimensions et paramètres de génération ------------------------------------
# Story 3.2. Tout est exprimé **en tuiles** : le générateur travaille en cellules,
# et les pixels ne sont qu'une vue dérivée pour la caméra et la physique.

func has_generation_settings() -> bool:
	return (has_world_bounds()
			and _anchors.size() == ANCHORS_SCHEMA.size()
			and _generation.size() == GENERATION_SCHEMA.size()
			and not _strata.is_empty()
			and not _depth_layers.is_empty()
			and _ore_density.size() == _depth_layers.size())


## Graine de génération. **Forçable** : changer la valeur dans les données suffit,
## et c'est ce que le prérequis `P4` du plan de tests exige d'une campagne.
func get_generation_seed() -> int:
	if not _generation.has(KEY_SEED):
		push_error("GameData — graine de génération absente (voir %s)." % GENERATION_PATH)
		return 0
	return _generation[KEY_SEED]


## Largeur de la carte en tuiles, ceintures **comprises**.
func get_map_width_tiles() -> int:
	return _get_map_value(KEY_MAP_WIDTH)


## Hauteur de la bande libre au-dessus de la surface, en tuiles.
func get_map_surface_tiles() -> int:
	return _get_map_value(KEY_MAP_SURFACE)


## Nombre de rangées **creusables**, de la surface (`y = 0`) au-dessus de la ceinture.
func get_map_depth_tiles() -> int:
	return _get_map_value(KEY_MAP_DEPTH)


## Épaisseur de la ceinture indestructible, en tuiles.
func get_map_belt_tiles() -> int:
	return _get_map_value(KEY_MAP_BELT)


## Profondeur en mètres du centre d'une rangée de tuiles : 1 tuile = 1 m
## (verrouillé par la story 3.1), rangée 0 sous la surface. Source unique de cette
## conversion pour le générateur (strates, minerai) et le tirage de loot.
func get_row_depth_m(row: int) -> float:
	return float(row) + 0.5


# --- Table de loot (story 3.6) ---------------------------------------------------

func has_loot_table() -> bool:
	return not _loot_entry_ids.is_empty() and _loot_weights.size() == _depth_layer_ids.size()


## Entrées de la table, dans l'ordre déclaré (ordre de cumul du tirage).
func get_loot_entry_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.assign(_loot_entry_ids)
	return ids


## Ressource d'une entrée ; chaîne vide pour « Rien ».
func get_loot_entry_resource(entry_id: String) -> String:
	if not _loot_resources.has(entry_id):
		push_error("GameData — entrée de loot inconnue : « %s » (voir %s)." % [entry_id, GENERATION_PATH])
		return ""
	return _loot_resources[entry_id]


## L'entrée est-elle une rareté haute, qui déclenche le retour « jackpot » du
## §2.4 (`Q35`) ? Lu en données, jamais en dur.
func is_loot_entry_high_rarity(entry_id: String) -> bool:
	return _loot_high_rarity.has(entry_id)


## Poids du palier, alignés sur `get_loot_entry_ids()`. Copie.
func get_loot_weights(layer_id: String) -> PackedFloat64Array:
	if not _loot_weights.has(layer_id):
		push_error("GameData — palier de loot inconnu : « %s » (voir %s)." % [layer_id, GENERATION_PATH])
		return PackedFloat64Array()
	return _loot_weights[layer_id].duplicate()


## Première et dernière colonnes **intérieures** (hors ceinture). La carte est
## centrée : la colonne la plus à gauche vaut `-(largeur / 2)`. Même convention que
## `get_world_bounds()` et le générateur.
func _get_first_interior_column() -> int:
	return -(_map[KEY_MAP_WIDTH] / 2) + _map[KEY_MAP_BELT]


func _get_last_interior_column() -> int:
	return -(_map[KEY_MAP_WIDTH] / 2) + _map[KEY_MAP_WIDTH] - 1 - _map[KEY_MAP_BELT]


func has_anchors() -> bool:
	return _anchors.size() == ANCHORS_SCHEMA.size()


## Point de contact au sol du point d'apparition, en pixels monde : centre de la
## colonne `apparition_colonne`, sur la ligne de surface (`y = 0`). **Indépendant
## de la graine** (critère 5 de la story 3.3) : la rangée 0 est toujours pleine,
## le générateur ne laissant aucun vide sous la surface. La foreuse se pose en
## retranchant sa propre demi-hauteur, qu'elle seule connaît.
func get_spawn_ground_position() -> Vector2:
	if not has_anchors():
		push_error("GameData — point d'apparition indisponible (voir %s)." % GENERATION_PATH)
		return Vector2.ZERO
	var tile: float = get_pixels_per_meter()
	return Vector2((float(_anchors[KEY_SPAWN_COLUMN]) + 0.5) * tile, 0.0)


## Cellule de l'anomalie scénarisée, en coordonnées de tuile. **Marqueur seul** au
## sprint 3 : le générateur n'y pose jamais de minerai (`Q28` : la tuile décide).
## L'anomalie réelle est l'objet de la story 6.4.
func get_anomaly_cell() -> Vector2i:
	if not has_anchors():
		push_error("GameData — ancrage de l'anomalie indisponible (voir %s)." % GENERATION_PATH)
		return Vector2i.ZERO
	return Vector2i(_anchors[KEY_ANOMALY_COLUMN], _anchors[KEY_ANOMALY_ROW])


## Strates de terrain, de la surface vers le fond. Copie défensive : le catalogue
## reste immuable pour ses lecteurs.
func get_strata() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for stratum: Dictionary in _strata:
		out.append(stratum.duplicate())
	return out


## Identifiant du palier contenant cette profondeur. Chaîne vide si aucun — ce qui
## ne peut arriver que sur une profondeur négative, les paliers étant contigus et
## le dernier non borné.
func get_depth_layer_at(depth_m: float) -> String:
	for layer: Dictionary in _depth_layers:
		var maximum: float = layer[KEY_DEPTH_MAX_M]
		if depth_m < layer[KEY_DEPTH_MIN_M]:
			continue
		if is_equal_approx(maximum, DEPTH_UNBOUNDED) or depth_m < maximum:
			return layer[KEY_ID]
	return ""


## Probabilité qu'une case de ce palier porte ce minerai. `0.0` pour un minerai non
## déclaré sur ce palier : c'est une absence légitime, pas une erreur — un minerai
## profond n'a pas à figurer en surface.
func get_ore_density(layer_id: String, resource_id: String) -> float:
	if not _ore_density.has(layer_id):
		push_error("GameData — palier de profondeur inconnu : « %s » (voir %s)." % [layer_id, GENERATION_PATH])
		return 0.0
	return _ore_density[layer_id].get(resource_id, 0.0)


## Densités d'un palier, dans l'ordre de déclaration du catalogue de ressources —
## c'est cet ordre qui rend le tirage du générateur **reproductible**.
func get_ore_densities(layer_id: String) -> Dictionary[String, float]:
	var out: Dictionary[String, float] = {}
	if not _ore_density.has(layer_id):
		push_error("GameData — palier de profondeur inconnu : « %s » (voir %s)." % [layer_id, GENERATION_PATH])
		return out
	for resource_id: String in _resource_ids:
		if _ore_density[layer_id].has(resource_id):
			out[resource_id] = _ore_density[layer_id][resource_id]
	return out


func _get_map_value(field: String) -> int:
	if not _map.has(field):
		push_error("GameData — dimension de carte absente : « %s » (voir %s)." % [field, GENERATION_PATH])
		return 0
	return _map[field]


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
