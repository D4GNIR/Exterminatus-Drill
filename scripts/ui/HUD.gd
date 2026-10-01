extends Control
class_name HUD

## HUD de bord — story 4.1.
##
## Affiche en temps réel les cinq grandeurs du critère d'acceptation MVP —
## carburant, blindage, crédits, charge de soute, profondeur — **à partir de
## `GameState` seul** (CDC « Critères d'acceptation MVP »).
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Jauges branchées sur `GameState` seul** (`C3`) : chaque grandeur est
## rafraîchie par le signal typé correspondant, connecté par `Callable` (`C4`) et
## déconnecté à la sortie de l'arbre (`C5`). Aucun sondage par frame ; les
## jauges ne lisent ni `DrillRig` ni `World`. La seule référence à la foreuse
## (story 4.2) sert au panneau d'alertes : voir « Alertes de bord » ci-dessous.
## [br]— **Type nommé** (`class_name HUD`, story 4.10) : les fonctions de format
## statiques sont appelées par l'inventaire (`HUD.format_cargo()`), sans
## `preload`.
## [br]— **Valeurs de départ dès la première image** : `_ready()` lit l'état
## courant par les accesseurs de `GameState`, sans attendre un premier signal.
## Aucun nombre de départ n'est écrit ici : ils viennent de `data/` (`D1`, `D4`).
## [br]— **Aucune apparence dans le code** : couleurs, police et cadres viennent
## du thème unique `scenes/ui/UiTheme.tres` (arbitrages `Q46`, `Q48`), affecté
## par la scène. Les libellés fixes sont des propriétés de la scène.
## [br]— **Format d'affichage** : carburant et blindage courants arrondis à
## l'entier **supérieur** — la jauge n'affiche `0` que lorsque le réservoir est
## réellement vide —, maxima arrondis à l'entier le plus proche, profondeur en
## mètres entiers tronqués, crédits et soute en entiers. Les jauges reçoivent un
## ratio borné à `[0, 1]`, calculé sans division par zéro (`H1`, `H2`).
## [br]— **Alertes de bord** (story 4.2) : elles ne sont **pas** des grandeurs de
## `GameState` mais des signaux des composants de la foreuse. Le HUD reçoit donc
## la foreuse **par injection de scène** (`drill_rig_path`, renseigné dans
## `Main.tscn`, résolu une fois — précision `Q38` de `C3`) et la **transmet** à
## son panneau d'alertes (`AlertSlot`, `AlertPanel.gd`), qui s'y abonne. Le HUD
## lui-même n'appelle rien sur la foreuse : les cinq jauges restent branchées
## sur `GameState` seul.
## [br]— **Validation headless** : ce fichier référence l'autoload `GameState` —
## faux « Identifier not found » en `--check-only`, exception de la story 1.9.

## Foreuse dont les alertes sont affichées, renseignée dans `Main.tscn`. Vide,
## les jauges fonctionnent et l'absence d'alertes est signalée.
@export var drill_rig_path: NodePath

@onready var _fuel_bar: ProgressBar = %FuelBar
@onready var _fuel_value: Label = %FuelValue
@onready var _armor_bar: ProgressBar = %ArmorBar
@onready var _armor_value: Label = %ArmorValue
@onready var _cargo_bar: ProgressBar = %CargoBar
@onready var _cargo_value: Label = %CargoValue
@onready var _credits_value: Label = %CreditsValue
@onready var _depth_value: Label = %DepthValue
@onready var _alert_panel: AlertPanel = $AlertSlot


func _ready() -> void:
	GameState.fuel_changed.connect(_on_fuel_changed)
	GameState.armor_changed.connect(_on_armor_changed)
	GameState.credits_changed.connect(_on_credits_changed)
	GameState.cargo_changed.connect(_on_cargo_changed)
	GameState.depth_changed.connect(_on_depth_changed)

	_on_fuel_changed(GameState.get_fuel(), GameState.get_fuel_max())
	_on_armor_changed(GameState.get_armor(), GameState.get_armor_max())
	_on_credits_changed(GameState.get_credits())
	_on_cargo_changed(GameState.get_cargo_used(), GameState.get_cargo_capacity())
	_on_depth_changed(GameState.get_depth_m())

	var rig: DrillRig = get_node_or_null(drill_rig_path) as DrillRig
	if rig == null:
		push_error("HUD — foreuse introuvable (« %s ») : alertes de bord non affichées." % drill_rig_path)
		return
	_alert_panel.bind(rig)


## `GameState` est un autoload : il survit au HUD. Sans déconnexion, un
## rechargement de la scène principale laisserait des connexions orphelines.
func _exit_tree() -> void:
	GameState.fuel_changed.disconnect(_on_fuel_changed)
	GameState.armor_changed.disconnect(_on_armor_changed)
	GameState.credits_changed.disconnect(_on_credits_changed)
	GameState.cargo_changed.disconnect(_on_cargo_changed)
	GameState.depth_changed.disconnect(_on_depth_changed)


# --- Format d'affichage -------------------------------------------------------
# Publics et statiques pour que la règle de format soit une seule fonction,
# appelée par le HUD et par l'inventaire (`Inventory.gd`, story 4.4), et opposable
# telle quelle par une vérification externe.

## « courant / maximum » d'une jauge à virgule : courant arrondi au-dessus.
static func format_gauge(current: float, maximum: float) -> String:
	return "%d / %d" % [ceili(current), roundi(maximum)]


## « utilisé / capacité » de la soute, dans l'unité de `GameState`.
static func format_cargo(used: int, capacity: int) -> String:
	return "%d / %d" % [used, capacity]


## Profondeur en mètres entiers, tronquée : `0 m` jusqu'au premier mètre plein.
static func format_depth(depth_m: float) -> String:
	return "%d m" % floori(depth_m)


## Ratio de remplissage d'une jauge, borné à `[0, 1]`. Un maximum nul ou
## négatif donne une jauge vide plutôt qu'une division par zéro (`H1`).
static func gauge_ratio(current: float, maximum: float) -> float:
	if maximum <= 0.0:
		return 0.0
	return clampf(current / maximum, 0.0, 1.0)


# --- Réception des signaux de `GameState` -------------------------------------

func _on_fuel_changed(current: float, maximum: float) -> void:
	_fuel_bar.value = gauge_ratio(current, maximum)
	_fuel_value.text = format_gauge(current, maximum)


func _on_armor_changed(current: float, maximum: float) -> void:
	_armor_bar.value = gauge_ratio(current, maximum)
	_armor_value.text = format_gauge(current, maximum)


func _on_credits_changed(credits: int) -> void:
	_credits_value.text = str(credits)


func _on_cargo_changed(used: int, capacity: int) -> void:
	_cargo_bar.value = gauge_ratio(float(used), float(capacity))
	_cargo_value.text = format_cargo(used, capacity)


func _on_depth_changed(depth_m: float) -> void:
	_depth_value.text = format_depth(depth_m)
