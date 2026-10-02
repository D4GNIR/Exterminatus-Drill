class_name DrillSettings
extends RefCounted

## Chargeur et paramètres de `data/drill.json` — physique, carburant, blindage,
## caméra, forage, retour audiovisuel et messages de bord (stories 2.2 à 4.2,
## découpé de `GameData` par la story 5.11).
##
## Une seule responsabilité : lire, valider et servir ce fichier. Instancié
## **uniquement** par l'autoload `GameData`, qui reste la façade publique.
##
## Contrairement aux catalogues, ces blocs ne portent pas un tableau d'entrées
## mais **un seul objet** : il n'y a qu'une foreuse. Chacun est donc validé d'un
## coup, et rejeté d'un coup — un jeu de paramètres à moitié valide produirait un
## comportement incohérent, plus difficile à diagnostiquer qu'une foreuse inerte.
## Un bloc rejeté reste **vide** : aucune valeur de repli n'est substituée.

const PATH: String = "res://data/drill.json"

const ROOT_PHYSICS: String = "physique"
const ROOT_FUEL: String = "carburant"
const ROOT_ARMOR: String = "blindage"
const ROOT_CAMERA: String = "camera"
const ROOT_DRILLING: String = "forage"
const ROOT_FEEDBACK: String = "retour"
const ROOT_MESSAGES: String = "messages"

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
# `puissance_foret` de l'amélioration `foret`. Depuis la story 5.6 (`Q59` (b)),
# l'**excédent** de puissance au-delà de la dureté maximale forable du terrain
# raccourcit cette durée (`get_drilling_duration_for_power()`) ; en deçà, la
# durée ne dépend que de la dureté. Aucun axe ni `id` « vitesse » (`Q21`, `E12`
# partiellement couvert).
const KEY_DRILL_BASE_DURATION: String = "duree_base_s"
const KEY_DRILL_DURATION_PER_HARDNESS: String = "duree_par_hardness_s"
## Réduction de durée par point d'excédent de puissance (`Q59` (b)) — réel > 0.
const KEY_DRILL_EXCESS_REDUCTION: String = "reduction_par_excedent"
## Durée de visibilité du retour d'une rareté haute (story 3.7, §2.4).
const KEY_JACKPOT_DURATION: String = "duree_jackpot_s"
# Bloc `messages` (story 4.2) : messages transitoires du HUD.
const KEY_MESSAGE_DURATION: String = "duree_message_s"
const KEY_MESSAGE_MAX: String = "messages_max"

# Dégâts d'impact (story 2.5, arbitrage Q20). La **capacité** de blindage n'est
# pas ici : c'est la statistique `blindage_max` de l'amélioration `blindage` de
# data/upgrades.json.

const KEY_ARMOR_IMPACT_THRESHOLD: String = "seuil_impact_px_s"
const KEY_ARMOR_DAMAGE_PER_SPEED: String = "degats_par_px_s"
const KEY_ARMOR_LOW_RATIO: String = "seuil_alerte_ratio"
const KEY_ARMOR_DESTRUCTION_DURATION: String = "duree_destruction_s"

const KEY_CAMERA_SMOOTHING: String = "amortissement_position"
const KEY_CAMERA_ZOOM: String = "zoom"

## Tous les champs de physique sont des réels **strictement positifs** : une
## gravité, une friction ou une vitesse maximale nulle ne dégrade pas le
## comportement, elle le supprime. Le coefficient de freinage est en outre borné
## à `]0, 1]` — au-delà de 1, « freiner » accélérerait.
const PHYSICS_SCHEMA: Dictionary = {
	KEY_GRAVITY: DataValidator.FieldKind.FLOAT,
	KEY_H_ACCELERATION: DataValidator.FieldKind.FLOAT,
	KEY_H_FRICTION: DataValidator.FieldKind.FLOAT,
	KEY_H_MAX_SPEED: DataValidator.FieldKind.FLOAT,
	KEY_THRUST: DataValidator.FieldKind.FLOAT,
	KEY_DESCENT_ACCELERATION: DataValidator.FieldKind.FLOAT,
	KEY_MAX_RISE_SPEED: DataValidator.FieldKind.FLOAT,
	KEY_MAX_FALL_SPEED: DataValidator.FieldKind.FLOAT,
	KEY_BRAKE_FACTOR: DataValidator.FieldKind.FLOAT,
	KEY_PIXELS_PER_METER: DataValidator.FieldKind.FLOAT,
}

## Consommation de carburant. `consommation_repos_par_s` est le seul champ que
## zéro laisse valide : un moteur qui ne consomme rien à l'arrêt est un réglage
## légitime. Le seuil d'alerte est une **fraction** du réservoir, donc dans
## `]0, 1[` : à 0 l'alerte ne se déclencherait jamais, à 1 elle serait permanente.
const FUEL_SCHEMA: Dictionary = {
	KEY_FUEL_THRUST_PER_S: DataValidator.FieldKind.FLOAT,
	KEY_FUEL_IDLE_PER_S: DataValidator.FieldKind.FLOAT,
	KEY_FUEL_LOW_RATIO: DataValidator.FieldKind.FLOAT,
	KEY_FUEL_PER_DRILLED_TILE: DataValidator.FieldKind.FLOAT,
}

## Durée de forage. La base peut valoir 0 (seule la dureté compte alors) ; le
## coût par point de dureté est strictement positif, sinon toutes les tuiles se
## foreraient à la même vitesse et `hardness` perdrait son sens. La réduction par
## point d'excédent est strictement positive : nulle, un foret au-delà de la
## dureté maximale coûterait sans rien changer (`L5`, §3.3 de l'amendement).
const DRILLING_SCHEMA: Dictionary = {
	KEY_DRILL_BASE_DURATION: DataValidator.FieldKind.FLOAT,
	KEY_DRILL_DURATION_PER_HARDNESS: DataValidator.FieldKind.FLOAT,
	KEY_DRILL_EXCESS_REDUCTION: DataValidator.FieldKind.FLOAT,
}

## Retour audiovisuel du forage. Durée strictement positive : un retour de durée
## nulle ne serait pas « visible assez longtemps pour être perçu » (§2.4).
const FEEDBACK_SCHEMA: Dictionary = {
	KEY_JACKPOT_DURATION: DataValidator.FieldKind.FLOAT,
}

## Messages transitoires de bord (story 4.2). Durée strictement positive — un
## message de durée nulle serait une perte silencieuse (`G10`) — et nombre de
## messages simultanés **entier** d'au moins 1. Lu en `FLOAT` comme tout nombre
## JSON, l'entier est vérifié par les bornes.
const MESSAGES_SCHEMA: Dictionary = {
	KEY_MESSAGE_DURATION: DataValidator.FieldKind.FLOAT,
	KEY_MESSAGE_MAX: DataValidator.FieldKind.FLOAT,
}

## Dégâts d'impact. Les quatre champs sont strictement positifs, et le **seuil
## d'impact non nul** est une exigence d'audit (`M8`) autant qu'une règle de
## design : à seuil nul, le moindre déplacement grignoterait le blindage. Le
## seuil d'alerte est une fraction, donc dans `]0, 1[`.
const ARMOR_SCHEMA: Dictionary = {
	KEY_ARMOR_IMPACT_THRESHOLD: DataValidator.FieldKind.FLOAT,
	KEY_ARMOR_DAMAGE_PER_SPEED: DataValidator.FieldKind.FLOAT,
	KEY_ARMOR_LOW_RATIO: DataValidator.FieldKind.FLOAT,
	KEY_ARMOR_DESTRUCTION_DURATION: DataValidator.FieldKind.FLOAT,
}

## Paramètres de suivi de la caméra. Amortissement et zoom strictement positifs :
## un zoom nul annulerait la projection, un amortissement nul figerait la caméra.
const CAMERA_SCHEMA: Dictionary = {
	KEY_CAMERA_SMOOTHING: DataValidator.FieldKind.FLOAT,
	KEY_CAMERA_ZOOM: DataValidator.FieldKind.FLOAT,
}

var _validator: DataValidator
## Un dictionnaire `champ` → valeur par bloc. Vide si le bloc a été rejeté : le
## système consommateur se désactive alors (foreuse immobile, `FuelSystem` et
## `ArmorSystem` inertes, caméra immobile, forage refusé, aucun retour ni message)
## plutôt que de fonctionner sur un chiffre inventé.
var _physics: Dictionary[String, float] = {}
var _fuel: Dictionary[String, float] = {}
var _armor: Dictionary[String, float] = {}
var _camera: Dictionary[String, float] = {}
var _drilling: Dictionary[String, float] = {}
var _feedback: Dictionary[String, float] = {}
var _messages: Dictionary[String, float] = {}


func _init(validator: DataValidator) -> void:
	_validator = validator


## La racine n'est lue **qu'une fois** pour tous ses blocs : plusieurs lectures
## dédoubleraient les messages en cas de fichier absent ou malformé.
func load_file() -> void:
	var root: Dictionary = _validator.read_root(PATH)
	if root.is_empty():
		return
	_load_block(root, ROOT_PHYSICS, PHYSICS_SCHEMA, _physics)
	_load_block(root, ROOT_FUEL, FUEL_SCHEMA, _fuel)
	_load_block(root, ROOT_ARMOR, ARMOR_SCHEMA, _armor)
	_load_block(root, ROOT_CAMERA, CAMERA_SCHEMA, _camera)
	_load_block(root, ROOT_DRILLING, DRILLING_SCHEMA, _drilling)
	_load_block(root, ROOT_FEEDBACK, FEEDBACK_SCHEMA, _feedback)
	_load_block(root, ROOT_MESSAGES, MESSAGES_SCHEMA, _messages)


## Nombre de champs chargés d'un bloc — trace de chargement de `GameData`.
func get_block_field_count(root_key: String) -> int:
	match root_key:
		ROOT_PHYSICS:
			return _physics.size()
		ROOT_FUEL:
			return _fuel.size()
		ROOT_ARMOR:
			return _armor.size()
		ROOT_CAMERA:
			return _camera.size()
		ROOT_DRILLING:
			return _drilling.size()
		ROOT_FEEDBACK:
			return _feedback.size()
		ROOT_MESSAGES:
			return _messages.size()
	push_error("GameData — bloc inconnu de %s : « %s »." % [PATH, root_key])
	return 0


## Le dictionnaire de destination est passé par référence : c'est ce qui permet
## à tous les blocs de partager la même séquence lecture → schéma → bornes, sans
## dupliquer le contrôle ni l'oublier d'un côté.
func _load_block(root: Dictionary, root_key: String, schema: Dictionary, target: Dictionary[String, float]) -> void:
	var context: String = "%s → %s" % [PATH, root_key]
	var block: Dictionary = _validator.accept_block(root, root_key, schema, context)
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
		ROOT_PHYSICS:
			return _accept_physics_bounds(block, context)
		ROOT_FUEL:
			return _accept_fuel_bounds(block, context)
		ROOT_ARMOR:
			return _accept_armor_bounds(block, context)
		ROOT_CAMERA:
			return _accept_all_positive(block, context)
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
	_validator.report("%s : bloc « %s » sans contrôle de bornes déclaré dans _accept_drill_bounds(), bloc rejeté." % [context, root_key])
	return false


## Tous les champs strictement positifs ; rejet dès le premier champ fautif.
func _accept_all_positive(block: Dictionary, context: String) -> bool:
	for field: String in block:
		if block[field] <= 0.0:
			_reject(context, "champ « %s » doit être strictement positif (lu : %s)" % [field, block[field]])
			return false
	return true


func _accept_physics_bounds(block: Dictionary, context: String) -> bool:
	if not _accept_all_positive(block, context):
		return false
	if block[KEY_BRAKE_FACTOR] > 1.0:
		_reject(context, "champ « %s » doit être dans ]0, 1] (lu : %s)" % [KEY_BRAKE_FACTOR, block[KEY_BRAKE_FACTOR]])
		return false
	return true


func _accept_armor_bounds(block: Dictionary, context: String) -> bool:
	if not _accept_all_positive(block, context):
		return false
	var ratio: float = block[KEY_ARMOR_LOW_RATIO]
	if ratio >= 1.0:
		_reject(context, "champ « %s » doit être dans ]0, 1[ (lu : %s)" % [KEY_ARMOR_LOW_RATIO, ratio])
		return false
	return true


func _accept_fuel_bounds(block: Dictionary, context: String) -> bool:
	if block[KEY_FUEL_THRUST_PER_S] <= 0.0:
		_reject(context, "champ « %s » doit être strictement positif (lu : %s)" % [KEY_FUEL_THRUST_PER_S, block[KEY_FUEL_THRUST_PER_S]])
		return false
	if block[KEY_FUEL_IDLE_PER_S] < 0.0:
		_reject(context, "champ « %s » ne peut pas être négatif (lu : %s)" % [KEY_FUEL_IDLE_PER_S, block[KEY_FUEL_IDLE_PER_S]])
		return false
	var ratio: float = block[KEY_FUEL_LOW_RATIO]
	if ratio <= 0.0 or ratio >= 1.0:
		_reject(context, "champ « %s » doit être dans ]0, 1[ (lu : %s)" % [KEY_FUEL_LOW_RATIO, ratio])
		return false
	# Un forage gratuit rendrait faux le critère MVP « tuile détruite seulement si
	# carburant suffisant » : le coût par tuile est strictement positif.
	if block[KEY_FUEL_PER_DRILLED_TILE] <= 0.0:
		_reject(context, "champ « %s » doit être strictement positif (lu : %s)" % [KEY_FUEL_PER_DRILLED_TILE, block[KEY_FUEL_PER_DRILLED_TILE]])
		return false
	return true


func _accept_drilling_bounds(block: Dictionary, context: String) -> bool:
	if block[KEY_DRILL_BASE_DURATION] < 0.0:
		_reject(context, "champ « %s » ne peut pas être négatif (lu : %s)" % [KEY_DRILL_BASE_DURATION, block[KEY_DRILL_BASE_DURATION]])
		return false
	if block[KEY_DRILL_DURATION_PER_HARDNESS] <= 0.0:
		_reject(context, "champ « %s » doit être strictement positif (lu : %s)" % [KEY_DRILL_DURATION_PER_HARDNESS, block[KEY_DRILL_DURATION_PER_HARDNESS]])
		return false
	if block[KEY_DRILL_EXCESS_REDUCTION] <= 0.0:
		_reject(context, "champ « %s » doit être strictement positif (lu : %s)" % [KEY_DRILL_EXCESS_REDUCTION, block[KEY_DRILL_EXCESS_REDUCTION]])
		return false
	return true


func _accept_feedback_bounds(block: Dictionary, context: String) -> bool:
	if block[KEY_JACKPOT_DURATION] <= 0.0:
		_reject(context, "champ « %s » doit être strictement positif (lu : %s)" % [KEY_JACKPOT_DURATION, block[KEY_JACKPOT_DURATION]])
		return false
	return true


func _accept_messages_bounds(block: Dictionary, context: String) -> bool:
	if block[KEY_MESSAGE_DURATION] <= 0.0:
		_reject(context, "champ « %s » doit être strictement positif (lu : %s)" % [KEY_MESSAGE_DURATION, block[KEY_MESSAGE_DURATION]])
		return false
	var count: float = block[KEY_MESSAGE_MAX]
	if count < 1.0 or not is_equal_approx(count, roundf(count)):
		_reject(context, "champ « %s » doit être un entier supérieur ou égal à 1 (lu : %s)" % [KEY_MESSAGE_MAX, count])
		return false
	return true


## Rejet d'un bloc entier : même forme de message pour toutes les bornes.
func _reject(context: String, reason: String) -> void:
	_validator.report("%s : %s, bloc rejeté." % [context, reason])


# --- Physique -----------------------------------------------------------------

func has_physics() -> bool:
	return _physics.size() == PHYSICS_SCHEMA.size()


func get_physics_value(field: String) -> float:
	if not _physics.has(field):
		push_error("GameData — paramètre de physique absent : « %s » (voir %s)." % [field, PATH])
		return 0.0
	return _physics[field]


# --- Carburant ----------------------------------------------------------------

func has_fuel() -> bool:
	return _fuel.size() == FUEL_SCHEMA.size()


func get_fuel_value(field: String) -> float:
	if not _fuel.has(field):
		push_error("GameData — paramètre de carburant absent : « %s » (voir %s)." % [field, PATH])
		return 0.0
	return _fuel[field]


# --- Blindage -----------------------------------------------------------------

func has_armor() -> bool:
	return _armor.size() == ARMOR_SCHEMA.size()


func get_armor_value(field: String) -> float:
	if not _armor.has(field):
		push_error("GameData — paramètre de blindage absent : « %s » (voir %s)." % [field, PATH])
		return 0.0
	return _armor[field]


# --- Caméra -------------------------------------------------------------------

func has_camera() -> bool:
	return _camera.size() == CAMERA_SCHEMA.size()


func get_camera_value(field: String) -> float:
	if not _camera.has(field):
		push_error("GameData — paramètre de caméra absent : « %s » (voir %s)." % [field, PATH])
		return 0.0
	return _camera[field]


# --- Forage, retour, messages -------------------------------------------------

func has_drilling() -> bool:
	return _drilling.size() == DRILLING_SCHEMA.size()


## Durée de forage de la story 3.4 : `duree_base_s + duree_par_hardness_s ×
## hardness`, indépendante de la puissance. C'est la durée de **tout** foret dont
## la puissance ne dépasse pas la dureté maximale forable.
func get_drilling_duration(hardness: int) -> float:
	if not has_drilling():
		push_error("GameData — durée de forage indisponible (voir %s)." % PATH)
		return 0.0
	return _drilling[KEY_DRILL_BASE_DURATION] + _drilling[KEY_DRILL_DURATION_PER_HARDNESS] * float(hardness)


## **Seul point de calcul** de la durée de forage selon la puissance (story 5.6,
## `Q59` (b)) — fonction pure et déterministe :
## [br]`excédent = max(0, puissance − dureté_max)` ;
## [br]`durée = durée_3_4(hardness) / (1 + reduction_par_excedent × excédent)`.
## [br]— Puissance ≤ dureté maximale : diviseur exactement 1, durée **identique**
## à la story 3.4 (`get_drilling_duration()`).
## [br]— Au-delà : forme **hyperbolique**, strictement décroissante à chaque point
## d'excédent, strictement positive pour tout excédent, et qui ne s'annule
## jamais — **aucun plancher** atteint en un nombre fini de niveaux (`L2`, §3.3).
## Une forme géométrique (`r^excédent`) a été écartée : en flottant double, elle
## s'annulerait vers un excédent de quelques milliers, contredisant « durée
## strictement positive pour tout niveau ».
## [br]— Cette fonction **n'autorise rien** : une puissance inférieure à la
## dureté d'une tuile la laisse inforable (`MiningSystem`, `Q31`) ; la durée
## rendue n'a alors pas d'usage.
## [br]`max_hardness` est la dureté maximale forable, **dérivée des données** par
## `GameData` (strates et minerais actifs), jamais écrite dans le code.
func get_drilling_duration_for_power(hardness: int, drill_power: float, max_hardness: int) -> float:
	if not has_drilling():
		push_error("GameData — durée de forage indisponible (voir %s)." % PATH)
		return 0.0
	if max_hardness <= 0:
		push_error("GameData — dureté maximale forable indéterminée : durée de forage indisponible.")
		return 0.0
	var excess: float = maxf(drill_power - float(max_hardness), 0.0)
	return get_drilling_duration(hardness) / (1.0 + _drilling[KEY_DRILL_EXCESS_REDUCTION] * excess)


func has_feedback() -> bool:
	return _feedback.size() == FEEDBACK_SCHEMA.size()


func get_jackpot_duration() -> float:
	if not has_feedback():
		push_error("GameData — durée du retour de rareté indisponible (voir %s)." % PATH)
		return 0.0
	return _feedback[KEY_JACKPOT_DURATION]


func has_messages() -> bool:
	return _messages.size() == MESSAGES_SCHEMA.size()


func get_message_duration() -> float:
	if not has_messages():
		push_error("GameData — durée des messages de bord indisponible (voir %s)." % PATH)
		return 0.0
	return _messages[KEY_MESSAGE_DURATION]


func get_message_max() -> int:
	if not has_messages():
		push_error("GameData — nombre de messages de bord indisponible (voir %s)." % PATH)
		return 0
	return roundi(_messages[KEY_MESSAGE_MAX])
