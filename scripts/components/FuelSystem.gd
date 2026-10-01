extends Node
class_name FuelSystem

## Composant `FuelSystem` — consommation de carburant et panne sèche (story 2.3).
##
## Porte **la règle**, `GameState` porte **l'état** (point d'audit `C6`) : ce
## composant décide de ce qui est consommé et quand la panne survient ; il ne
## stocke aucune jauge. Toute mutation passe par les accesseurs bornés de
## `GameState`, qui garantissent `0 ≤ carburant ≤ carburant_max` (`H2`).
##
## Contraintes de conception, opposables à l'audit :
## [br]— **La capacité du réservoir n'est pas ici** : c'est la statistique
## `carburant_max` de l'amélioration `reacteur` (`data/upgrades.json`, story
## `1.5`). La redéclarer créerait deux sources de vérité, et l'achat d'un
## réacteur en phase 5 cesserait d'avoir un effet.
## [br]— **Aucune valeur de gameplay ici** (`D1`) : les deux taux de consommation
## et le seuil d'alerte viennent de `data/drill.json`.
## [br]— **N'écrit dans aucun autre nœud** (`C3`) : il mute `GameState` et publie
## des **signaux typés**, que son parent connecte par `Callable` (`C4`).
## [br]— **Ne lit aucune entrée** (`F5`, Q10) : c'est `DrillRig` qui sait si les
## propulseurs poussent, et qui appelle `consume_thrust()` en conséquence.
## [br]— **Validation headless** : ce fichier référence les autoloads `GameData`
## et `GameState` — faux « Identifier not found » en `--check-only`, exception
## bornée de la story `1.9`.

## Émis à l'entrée en panne sèche : le réservoir vient d'atteindre zéro.
signal fuel_depleted()
## Émis à la sortie de panne sèche — ravitaillement (phase 5) ou nouvelle partie.
signal fuel_restored()
## Émis **une fois** au franchissement descendant du seuil d'alerte, avec le
## ratio de réservoir restant. Réarmé dès que le niveau repasse au-dessus.
signal fuel_low(ratio: float)
## Émis **une fois** quand le niveau repasse au-dessus du seuil d'alerte : fin de
## l'état « carburant bas » (story 4.2, critère 9). Le seuil reste ici, jamais
## recopié par l'interface qui affiche l'alerte.
signal fuel_low_cleared()

var _thrust_consumption: float = 0.0
var _idle_consumption: float = 0.0
var _low_ratio: float = 0.0
var _drilled_tile_consumption: float = 0.0

## Panne sèche en cours. Cet unique booléen porte la transition exigée par le
## point d'audit `H3` : il n'existe aucun état intermédiaire entre « peut agir »
## et « en panne ».
var _depleted: bool = false
## Verrou de l'alerte « carburant bas » : sans lui, le signal serait réémis à
## chaque frame sous le seuil, et l'alerte sonore bégaierait.
var _low_alert_sent: bool = false


func _ready() -> void:
	if not GameData.has_drill_fuel():
		# Panne sèche permanente, et non « carburant illimité » : sans taux de
		# consommation, laisser propulser serait un repli silencieux — la
		# foreuse volerait sans contrainte et le défaut passerait inaperçu.
		_depleted = true
		push_error("FuelSystem — consommation non chargée depuis %s : composant désactivé, propulsion interdite." % GameData.DRILL_PATH)
		set_physics_process(false)
		return
	_thrust_consumption = GameData.get_fuel_thrust_consumption()
	_idle_consumption = GameData.get_fuel_idle_consumption()
	_low_ratio = GameData.get_fuel_low_ratio()
	_drilled_tile_consumption = GameData.get_fuel_per_drilled_tile()
	GameState.fuel_changed.connect(_on_fuel_changed)
	# L'état initial n'est pas une transition : il est constaté, jamais émis.
	# Émettre ici enverrait un signal avant que le parent ait eu son `_ready()`
	# — un enfant est prêt avant son parent — et l'alerte serait perdue.
	_depleted = GameState.get_fuel() <= 0.0
	_low_alert_sent = GameState.get_fuel_ratio() <= _low_ratio


## Consommation au repos : le moteur tourne même sans poussée. Nulle si les
## données le disent, auquel cas `set_fuel()` ne déclenche aucun signal.
func _physics_process(delta: float) -> void:
	_consume(_idle_consumption * delta)


## Le carburant permet-il d'**agir** — propulser (story 2.2) et, à partir de la
## story 3.4, forer ? C'est la seule question que les autres systèmes posent :
## ils n'ont jamais à lire la jauge ni à connaître le seuil.
func has_fuel() -> bool:
	return not _depleted


## Le réservoir est-il sous le seuil d'alerte ? Lecture de l'état **constaté**,
## pour qu'un abonné arrivé après la dernière transition (le HUD, story 4.2)
## affiche l'alerte en cours sans connaître le seuil.
func is_fuel_low() -> bool:
	return _low_alert_sent


## Consommation d'une frame de poussée, appelée par `DrillRig` **uniquement
## quand les propulseurs poussent réellement**. En panne sèche, il n'y a pas de
## poussée, donc rien à consommer : la garde évite de compter une dépense pour
## une action qui n'a pas eu lieu.
func consume_thrust(delta: float) -> void:
	if _depleted:
		return
	_consume(_thrust_consumption * delta)


## Coût d'une tuile détruite, appelé par `MiningSystem` **après** la destruction
## (story 3.4, `TM-3.9`). `MiningSystem` a déjà vérifié `has_fuel()` avant de
## détruire : la garde ci-dessous n'est qu'une seconde barrière. Une dernière
## tuile peut faire passer le réservoir sous zéro, mais `GameState` borne à 0.
func consume_drilled_tile() -> void:
	if _depleted:
		return
	_consume(_drilled_tile_consumption)


func _consume(amount: float) -> void:
	if amount <= 0.0:
		return
	GameState.set_fuel(GameState.get_fuel() - amount)


## Unique point d'évaluation des transitions : il vaut pour la consommation
## comme pour un ravitaillement venu de la phase 5, sans que ce composant ait à
## connaître qui a rempli le réservoir.
func _on_fuel_changed(current: float, maximum: float) -> void:
	var ratio: float = current / maximum
	_update_depleted(current <= 0.0)
	_update_low_alert(ratio)


func _update_depleted(is_empty: bool) -> void:
	if is_empty == _depleted:
		return
	_depleted = is_empty
	if _depleted:
		fuel_depleted.emit()
	else:
		fuel_restored.emit()


func _update_low_alert(ratio: float) -> void:
	if ratio > _low_ratio:
		if _low_alert_sent:
			_low_alert_sent = false
			fuel_low_cleared.emit()
		return
	if _low_alert_sent:
		return
	_low_alert_sent = true
	fuel_low.emit(ratio)
