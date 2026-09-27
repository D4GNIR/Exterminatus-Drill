extends Node
class_name ArmorSystem

## Composant `ArmorSystem` — encaissement des dégâts (story 2.5, arbitrage Q20).
##
## **Seul point d'entrée de dégâts du jeu** (point d'audit `M1`) : aucun autre
## nœud ne mute le blindage de `GameState`. Les menaces de la phase 6 (§4.2 de
## l'amendement) passeront par ce même composant, avec leurs propres sources —
## elles s'**ajoutent** aux dégâts d'impact, elles ne les remplacent pas.
##
## Contraintes de conception, opposables à l'audit :
## [br]— **La capacité de blindage n'est pas ici** : c'est la statistique
## `blindage_max` de l'amélioration `blindage` (`data/upgrades.json`), qui
## deviendra achetable en phase 5 (Q21). Ce composant ne la redéclare pas.
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
## Émis à l'entrée dans l'état « foreuse détruite » : blindage nul.
signal destruction_started()
## Émis à la sortie de cet état, la foreuse redevenant pilotable.
signal destruction_finished()

var _impact_threshold: float = 0.0
var _damage_per_speed: float = 0.0
var _low_ratio: float = 0.0
var _destruction_duration: float = 0.0

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
	if not GameData.has_armor_settings():
		push_error("ArmorSystem — dégâts non chargés depuis %s : aucun dégât ne sera infligé." % GameData.DRILL_PATH)
		set_physics_process(false)
		return
	_impact_threshold = GameData.get_armor_impact_threshold()
	_damage_per_speed = GameData.get_armor_damage_per_speed()
	_low_ratio = GameData.get_armor_low_ratio()
	_destruction_duration = GameData.get_armor_destruction_duration()
	_configured = true
	GameState.armor_changed.connect(_on_armor_changed)
	# L'état initial est constaté, jamais émis : un enfant est prêt avant son
	# parent, et un signal tiré ici n'aurait pas encore d'abonné.
	_low_alert_sent = GameState.get_armor_ratio() <= _low_ratio


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


## La foreuse peut-elle agir — piloter, et à partir de la phase 3 forer ? Faux
## pendant toute la transition de destruction (`M4`).
func can_act() -> bool:
	return not _destroyed


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
		_low_alert_sent = false
		return
	if _low_alert_sent:
		return
	_low_alert_sent = true
	armor_low.emit(ratio)


## Sortie de l'état détruit. **Traitement provisoire et volontairement minimal** :
## le blindage est remis au maximum et la partie continue. Aucun état persistant
## n'est effacé — il n'existe à ce sprint ni cargo, ni crédits gagnés, ni
## sauvegarde. La conséquence réelle (perte d'une **fraction** du cargo, règle
## « la perte n'est jamais totale » du §4.3) est l'objet de la story 6.7 : la
## construire ici reviendrait à la refaire. L'ordre des deux lignes compte —
## lever l'état **avant** de restaurer, sinon la restauration relancerait une
## transition.
func _finish_destruction() -> void:
	_destroyed = false
	_destruction_elapsed = 0.0
	GameState.set_armor(GameState.get_armor_max())
	destruction_finished.emit()
