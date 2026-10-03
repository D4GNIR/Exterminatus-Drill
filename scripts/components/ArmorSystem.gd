extends Node
class_name ArmorSystem

## Composant `ArmorSystem` — encaissement des dégâts (story 2.5, arbitrage Q20).
##
## **Seul point d'entrée de dégâts du jeu** (point d'audit `M1`) : aucun autre
## nœud ne mute le blindage de `GameState`. La **réparation** payée à la station
## (story 5.3) passe aussi par ce composant (`repair()`) : tous les écrivains du
## blindage restent ici, et le contrôle `M1` reste littéral. **Deux familles de
## dégâts** (`Q20`) : l'impact (`apply_impact()`, story 2.5) et, depuis la story
## 6.6, les menaces de la courbe de risque (`apply_threat()`, §4.2 de
## l'amendement), tirées par `ThreatSystem` — la seconde s'**ajoute** à la
## première, elle ne la remplace pas et ne la modifie pas (`M8`).
## **Retour après un échec** (story 6.7, `Q68` (a) et sa précision de `6.14`) :
## `restore_after_failure()` porte le blindage à la fraction de retour **s'il est
## en dessous**, jamais plus bas — une seule règle pour la destruction et la
## panne sèche, appelée par `RecoverySystem` et, à la sortie de destruction, par
## ce composant lui-même (jamais opérationnel à blindage nul, `M4`).
##
## Contraintes de conception, opposables à l'audit :
## [br]— **La capacité de blindage n'est pas ici** : c'est la statistique
## `blindage_max` de l'amélioration `blindage` (`data/upgrades.json`), active
## au MVP depuis la story 5.7 (`Q21`). Ce composant ne la redéclare pas : il la
## lit dans `GameState` (maximum de `armor_changed`), si bien que l'alerte se
## recalcule sur le nouveau maximum dès qu'il change. **Application de l'achat
## (story 5.5)** : il écoute `GameState.upgrade_level_changed` et porte ce
## maximum à la valeur du nouveau niveau (`GameData.get_upgrade_value()`), à la
## même image. **L'achat ne répare pas** : le blindage courant n'est jamais
## modifié par un achat (`GameState.set_armor_max()` ne le borne qu'à la baisse) ;
## la réparation reste une dépense de la station (`repair()`).
## [br]— **L'amélioration ne réduit pas les dégâts** (`Q60` (a), écart `E24` à
## la lettre du §3.2 de l'amendement, décidé par l'utilisateur) : un choc coûte
## le même nombre de points quel que soit le niveau de `blindage` ; seule la
## part de jauge entamée diminue. N'ajouter **aucun** coefficient de réduction.
## Le niveau d'amélioration n'est lu **que** pour fixer le maximum
## (`_apply_capacity()`), jamais par `apply_impact()`.
## [br]— **Aucune valeur de gameplay ici** (`D1`, `M8`) : seuil, coût par px/s,
## seuil d'alerte et durée de transition viennent de `data/drill.json`.
## [br]— **Le seuil d'impact n'est jamais nul** (`M8`) : en deçà, aucun dégât.
## Un déplacement ordinaire ne doit pas grignoter le blindage.
## [br]— **N'écrit dans aucun autre nœud** (`C3`) : il mute `GameState` et publie
## des signaux typés, que son parent connecte par `Callable` (`C4`).
## [br]— **Ne lit aucune entrée** (`F5`, Q10) : c'est `DrillRig` qui détecte le
## choc et lui transmet la vitesse.
## [br]— **Validation headless** : ce fichier référence les autoloads `GameData`
## et `GameState` — faux « Identifier not found » hors exécution du projet,
## exception des stories `1.9` et `2.9`.

## Émis **une fois** au franchissement descendant du seuil d'alerte, réarmé dès
## que le blindage repasse au-dessus.
signal armor_low(ratio: float)
## Émis **une fois** quand le blindage repasse au-dessus du seuil d'alerte : fin
## de l'état « blindage faible » (story 4.2, critère 9). Le seuil reste ici.
signal armor_low_cleared()
## Émis à l'entrée dans l'état « foreuse détruite » : blindage nul.
signal destruction_started()
## Émis à la sortie de cet état, la foreuse redevenant pilotable, blindage déjà
## relevé à la fraction de retour : `RecoverySystem` y enchaîne le rapatriement
## (story 6.7) dans le même appel.
signal destruction_finished()

## Tolérance d'arithmétique flottante du plafond de `restore_after_failure()`.
## Ce n'est pas une valeur de gameplay (`D1`) : un millionième de point.
const ROUNDING_TOLERANCE: float = 0.000001

## Amélioration qui pilote `blindage_max`, résolue une fois depuis le catalogue :
## aucun `id` d'amélioration n'est écrit ici.
var _capacity_upgrade_id: String = ""

var _impact_threshold: float = 0.0
var _damage_per_speed: float = 0.0
var _low_ratio: float = 0.0
var _destruction_duration: float = 0.0
## Fraction de `blindage_max` garantie au retour d'un échec (story 6.7), dans
## `]0, 1[`. Nulle si le bloc `rapatriement` a été rejeté : la foreuse détruite
## reste alors dans l'état détruit — panne visible, jamais de remise à neuf.
var _return_ratio: float = 0.0

## État « détruite » et son chronomètre. Ces deux variables portent la transition
## exigée par les points d'audit `M4` et `H3` : la foreuse est soit opérationnelle,
## soit en transition, jamais dans un tiers état.
var _destroyed: bool = false
var _destruction_elapsed: float = 0.0
## Verrou de l'alerte, pour ne pas réémettre le signal à chaque frame sous le seuil.
var _low_alert_sent: bool = false
## Faux si les données ont été rejetées : le composant refuse alors d'infliger
## des dégâts. C'est l'échec le moins nuisible — blindage intact plutôt que
## sévérité inventée — et il reste bruyant, `GameData` ayant nommé le champ fautif.
var _configured: bool = false


func _ready() -> void:
	# Avant tout le reste : le maximum suit l'amélioration même si les réglages
	# de dégâts sont absents.
	_bind_capacity_upgrade()
	if not GameData.has_armor_settings():
		push_error("ArmorSystem — dégâts non chargés depuis %s : aucun dégât ne sera infligé." % GameData.DRILL_PATH)
		set_physics_process(false)
		return
	_impact_threshold = GameData.get_armor_impact_threshold()
	_damage_per_speed = GameData.get_armor_damage_per_speed()
	_low_ratio = GameData.get_armor_low_ratio()
	_destruction_duration = GameData.get_armor_destruction_duration()
	if GameData.has_recovery_settings():
		_return_ratio = GameData.get_recovery_armor_ratio()
	else:
		push_error("ArmorSystem — rapatriement non chargé depuis %s : une foreuse détruite le restera." % GameData.DRILL_PATH)
	_configured = true
	GameState.armor_changed.connect(_on_armor_changed)
	# L'état initial est constaté, jamais émis : un enfant est prêt avant son
	# parent, et un signal tiré ici n'aurait pas encore d'abonné.
	_low_alert_sent = GameState.get_armor_ratio() <= _low_ratio


## Story 5.5 — branche le maximum du blindage sur le niveau de l'amélioration
## qui porte `blindage_max`, puis l'aligne sur le niveau **constaté** (sans effet
## en début de partie : la valeur du niveau de départ est la valeur de départ).
func _bind_capacity_upgrade() -> void:
	_capacity_upgrade_id = GameData.get_upgrade_id_for_statistic(GameData.STAT_ARMOR_MAX)
	if _capacity_upgrade_id.is_empty():
		push_error("ArmorSystem — aucune amélioration ne porte « %s » : le blindage ne suivra aucun achat." % GameData.STAT_ARMOR_MAX)
		return
	GameState.upgrade_level_changed.connect(_on_upgrade_level_changed)
	_apply_capacity(GameState.get_upgrade_level(_capacity_upgrade_id))


func _on_upgrade_level_changed(upgrade_id: String, level: int) -> void:
	if upgrade_id == _capacity_upgrade_id:
		_apply_capacity(level)


## Seul le **maximum** change (`Q60` (a)) : ni réparation, ni réduction de dégâts.
## L'alerte « blindage faible » se recalcule sur ce maximum par `armor_changed`.
func _apply_capacity(level: int) -> void:
	GameState.set_armor_max(GameData.get_upgrade_value(_capacity_upgrade_id, level))


## Chronomètre de la transition de destruction. Aucun traitement hors transition.
func _physics_process(delta: float) -> void:
	if not _destroyed:
		return
	_destruction_elapsed += delta
	if _destruction_elapsed < _destruction_duration:
		return
	_finish_destruction()


## Choc encaissé, à la vitesse donnée en px/s. Sous le seuil, il ne se passe
## **rien** — pas même un dégât arrondi à zéro : c'est la règle `M8`.
func apply_impact(speed: float) -> void:
	if not _configured or _destroyed:
		return
	if speed <= _impact_threshold:
		return
	var damage: float = (speed - _impact_threshold) * _damage_per_speed
	GameState.set_armor(GameState.get_armor() - damage)


## Rencontre hostile (story 6.6, `Q67` (a)) : `damage` points retirés **dans
## l'instant**, montant lu en données par l'appelant (`ThreatSystem`), sans aucun
## seuil — une menace n'est pas un choc. Refusée (faux, rien d'écrit) sans
## réglages valides, pendant la transition de destruction (`M4`) ou pour un
## montant non positif. Un blindage porté à zéro passe par l'état de destruction
## existant, constaté par `_on_armor_changed()` comme pour un impact. Comme pour
## l'impact, le niveau d'amélioration ne réduit pas les dégâts (`Q60` (a)).
func apply_threat(damage: float) -> bool:
	if not _configured or _destroyed or damage <= 0.0:
		return false
	GameState.set_armor(GameState.get_armor() - damage)
	return true


## Réparation de `points` de blindage, décidée et payée par `EconomySystem`
## (story 5.3) : ce composant ne connaît **aucun prix**, il applique. Refusée
## (faux, rien d'écrit) pendant la transition de destruction — la foreuse n'y est
## ni pilotable ni réparable, sans tiers état (`M4`, `H3`) — ou pour un nombre de
## points non positif. Le blindage reste borné par `GameState` (`M7`) ; le retour
## au-dessus du seuil d'alerte est constaté par `_on_armor_changed()`, comme
## pour toute variation.
func repair(points: float) -> bool:
	if _destroyed or points <= 0.0:
		return false
	GameState.set_armor(GameState.get_armor() + points)
	return true


## Story 6.7 — blindage au retour d'un échec (`Q68` (a), précision `6.14`) :
## `max(blindage courant, plancher)`, avec `plancher = max(1, ⌈fraction × blindage_max⌉)`
## — arrondi **au point supérieur**, donc toujours ≥ 1 ; jamais au-dessus du
## maximum, la fraction étant < 1 et `GameState` bornant (`M7`). **Jamais
## abaissé** : un blindage supérieur au plancher (panne sèche) est conservé, sans
## écriture. Seul écrivain du blindage (`M1`). Permis pendant la transition de
## destruction, contrairement à `repair()` : c'est elle qu'il clôt. Faux (rien
## d'écrit) sans réglages valides ; vrai sinon, que le blindage ait changé ou non.
func restore_after_failure() -> bool:
	if not _configured or _return_ratio <= 0.0:
		return false
	var maximum: float = GameState.get_armor_max()
	# La tolérance absorbe l'erreur d'arrondi binaire du produit (0,3 × 100 vaut
	# 30,000000000000004) : sans elle, le plafond donnerait 31.
	var floor_points: float = maxf(1.0, ceilf(_return_ratio * maximum - ROUNDING_TOLERANCE))
	if GameState.get_armor() >= floor_points:
		return true
	GameState.set_armor(minf(floor_points, maximum))
	return true


## La foreuse peut-elle agir — piloter, et à partir de la phase 3 forer ? Faux
## pendant toute la transition de destruction (`M4`).
func can_act() -> bool:
	return not _destroyed


## Le blindage est-il sous le seuil d'alerte ? État **constaté**, lu par le HUD
## (story 4.2) à son initialisation, sans qu'il connaisse le seuil.
func is_armor_low() -> bool:
	return _low_alert_sent


## Unique point d'évaluation des transitions : il vaut pour un impact comme pour
## une réparation en surface (phase 5), sans que ce composant ait à savoir qui a
## modifié le blindage.
func _on_armor_changed(current: float, maximum: float) -> void:
	_update_low_alert(current / maximum)
	if _destroyed or current > 0.0:
		return
	_destroyed = true
	_destruction_elapsed = 0.0
	destruction_started.emit()


func _update_low_alert(ratio: float) -> void:
	if ratio > _low_ratio:
		if _low_alert_sent:
			_low_alert_sent = false
			armor_low_cleared.emit()
		return
	if _low_alert_sent:
		return
	_low_alert_sent = true
	armor_low.emit(ratio)


## Sortie de l'état détruit (story 6.7, remplace le provisoire de `2.5` qui
## remettait le blindage au maximum sur place). Le blindage est d'abord relevé
## au plancher de retour (`restore_after_failure()`), **pendant** l'état détruit :
## la foreuse ne redevient jamais pilotable à blindage nul, et cette écriture ne
## peut pas relancer une transition. Puis l'état est levé et `destruction_finished`
## émis : `RecoverySystem` y enchaîne, dans le même appel, la perte de cargo, le
## carburant de secours et le rapatriement au point d'apparition — aucune image
## ne voit la foreuse pilotable sur le lieu de sa destruction. Sans réglages de
## rapatriement, la foreuse reste détruite (erreur signalée au démarrage).
func _finish_destruction() -> void:
	_destruction_elapsed = 0.0
	if not restore_after_failure():
		return
	_destroyed = false
	destruction_finished.emit()
