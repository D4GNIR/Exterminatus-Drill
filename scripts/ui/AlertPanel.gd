extends VBoxContainer
class_name AlertPanel

## Alertes et messages de bord — story 4.2.
##
## Rend **visibles** les alertes que la foreuse émet déjà (CDC « Direction
## sonore » et « Direction artistique », alertes rouges) :
## [br]— **alertes persistantes** — carburant bas, panne sèche, blindage faible,
## soute pleine : un bandeau de la scène, montré à l'entrée dans l'état et caché
## à sa sortie ;
## [br]— **messages transitoires** — minerai perdu (`G10`), forage refusé et son
## motif (écart `E20`) : une ligne qui s'efface d'elle-même ;
## [br]— **compteur cumulé** de minerai perdu (`G10`), visible dès la première perte.
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Aucun seuil ici** (critère 9, `D1`) : l'entrée **et** la sortie de
## chaque état persistant sont signalées par le composant qui détient le seuil
## (`FuelSystem`, `ArmorSystem`, `CargoSystem`). À l'initialisation, l'état en
## cours est **lu** sur ces mêmes composants, jamais recalculé.
## [br]— **Couplage** (`C3`, précision `Q38`) : les composants sont obtenus de la
## foreuse, **injectée par la scène** (`HUD.drill_rig_path`, renseigné dans
## `Main.tscn`) et transmise par `bind()`. Ce panneau ne fait que **s'abonner** à
## leurs signaux et lire leur état : aucune notification ne passe par un appel.
## Connexions par `Callable` (`C4`), défaites à la sortie de l'arbre (`C5`).
## [br]— **Durée et nombre de messages en données** (`D1`, `D4`) :
## `data/drill.json`, bloc `messages`, lu par `GameData`.
## [br]— **Aucune apparence dans le code** : couleurs, police et cadres viennent
## du thème unique `scenes/ui/UiTheme.tres` (`Q48`). Les libellés des bandeaux
## sont des propriétés de la scène ; seuls les messages composés (nom de
## ressource, quantité, motif) sont formés ici.
## [br]— **Le drop rare reste diégétique** (story 3.7, critère 5) : ce panneau
## n'écoute pas `loot_dropped`.
## [br]— **Validation headless** : ce fichier référence l'autoload `GameData` —
## faux « Identifier not found » hors exécution du projet, exception `1.9`/`2.9`.

## Variations de thème des messages transitoires (`UiTheme.tres`).
const MESSAGE_LOSS_VARIATION: StringName = &"MessageLossLabel"
const MESSAGE_REFUSED_VARIATION: StringName = &"MessageRefusedLabel"

## Textes composés. Unité de soute « u. », la même que le HUD (story 3.5, `4.1`).
const LOSS_COUNTER_FORMAT: String = "MINERAI PERDU : %d u."
const ORE_LOST_FORMAT: String = "Soute pleine : %s perdu (%d u.)"
const REFUSED_NO_FUEL: String = "Forage refusé : carburant épuisé"
const REFUSED_TOO_HARD: String = "Forage refusé : foret trop faible pour cette roche"
const REFUSED_INDESTRUCTIBLE: String = "Forage refusé : paroi indestructible"

@onready var _fuel_low_alert: Control = %FuelLowAlert
@onready var _fuel_depleted_alert: Control = %FuelDepletedAlert
@onready var _armor_low_alert: Control = %ArmorLowAlert
@onready var _cargo_full_alert: Control = %CargoFullAlert
@onready var _loss_counter: Label = %LossCounter
@onready var _messages: VBoxContainer = %Messages

var _fuel_system: FuelSystem
var _armor_system: ArmorSystem
var _cargo_system: CargoSystem
var _drill_system: MiningSystem
var _message_duration: float = 0.0
var _message_max: int = 0


## Branche le panneau sur les composants de la foreuse, puis affiche l'état
## **en cours** — une alerte déjà active avant le branchement n'est pas perdue.
func bind(rig: DrillRig) -> void:
	_fuel_system = rig.get_fuel_system()
	_armor_system = rig.get_armor_system()
	_cargo_system = rig.cargo_system
	_drill_system = rig.get_drill_system()
	if GameData.has_message_settings():
		_message_duration = GameData.get_message_duration()
		_message_max = GameData.get_message_max()
	else:
		push_error("AlertPanel — messages de bord non chargés depuis %s : pertes et refus non affichés." % GameData.DRILL_PATH)

	_fuel_system.fuel_low.connect(_on_fuel_low)
	_fuel_system.fuel_low_cleared.connect(_on_fuel_low_cleared)
	_fuel_system.fuel_depleted.connect(_on_fuel_depleted)
	_fuel_system.fuel_restored.connect(_on_fuel_restored)
	_armor_system.armor_low.connect(_on_armor_low)
	_armor_system.armor_low_cleared.connect(_on_armor_low_cleared)
	_cargo_system.cargo_full.connect(_on_cargo_full)
	_cargo_system.cargo_full_cleared.connect(_on_cargo_full_cleared)
	_cargo_system.ore_lost.connect(_on_ore_lost)
	_drill_system.drill_refused.connect(_on_drill_refused)

	_fuel_low_alert.visible = _fuel_system.is_fuel_low()
	_fuel_depleted_alert.visible = not _fuel_system.has_fuel()
	_armor_low_alert.visible = _armor_system.is_armor_low()
	_cargo_full_alert.visible = _cargo_system.is_full_alert_active()
	_show_loss_counter(_cargo_system.get_lost_units())


## Les composants peuvent survivre au HUD (et `CargoSystem`, objet partagé, lui
## survit toujours) : sans déconnexion, un rechargement de scène laisserait des
## connexions vers un panneau libéré.
func _exit_tree() -> void:
	if is_instance_valid(_fuel_system):
		_fuel_system.fuel_low.disconnect(_on_fuel_low)
		_fuel_system.fuel_low_cleared.disconnect(_on_fuel_low_cleared)
		_fuel_system.fuel_depleted.disconnect(_on_fuel_depleted)
		_fuel_system.fuel_restored.disconnect(_on_fuel_restored)
	if is_instance_valid(_armor_system):
		_armor_system.armor_low.disconnect(_on_armor_low)
		_armor_system.armor_low_cleared.disconnect(_on_armor_low_cleared)
	if _cargo_system != null:
		_cargo_system.cargo_full.disconnect(_on_cargo_full)
		_cargo_system.cargo_full_cleared.disconnect(_on_cargo_full_cleared)
		_cargo_system.ore_lost.disconnect(_on_ore_lost)
	if is_instance_valid(_drill_system):
		_drill_system.drill_refused.disconnect(_on_drill_refused)


## Texte du message d'un refus de forage, selon son motif (`E20`).
static func refusal_text(reason: MiningSystem.RefusalReason) -> String:
	match reason:
		MiningSystem.RefusalReason.NO_FUEL:
			return REFUSED_NO_FUEL
		MiningSystem.RefusalReason.TOO_HARD:
			return REFUSED_TOO_HARD
	# Troisième et dernier motif de l'énumération : `INDESTRUCTIBLE`.
	return REFUSED_INDESTRUCTIBLE


# --- Alertes persistantes -----------------------------------------------------

func _on_fuel_low(_ratio: float) -> void:
	_fuel_low_alert.visible = true


func _on_fuel_low_cleared() -> void:
	_fuel_low_alert.visible = false


func _on_fuel_depleted() -> void:
	_fuel_depleted_alert.visible = true


func _on_fuel_restored() -> void:
	_fuel_depleted_alert.visible = false


func _on_armor_low(_ratio: float) -> void:
	_armor_low_alert.visible = true


func _on_armor_low_cleared() -> void:
	_armor_low_alert.visible = false


func _on_cargo_full() -> void:
	_cargo_full_alert.visible = true


func _on_cargo_full_cleared() -> void:
	_cargo_full_alert.visible = false


# --- Messages transitoires ----------------------------------------------------

func _on_ore_lost(resource_id: String, units: int, total_lost: int) -> void:
	_push_message(ORE_LOST_FORMAT % [GameData.get_resource_name(resource_id), units], MESSAGE_LOSS_VARIATION)
	_show_loss_counter(total_lost)


func _on_drill_refused(_cell: Vector2i, reason: MiningSystem.RefusalReason) -> void:
	_push_message(refusal_text(reason), MESSAGE_REFUSED_VARIATION)


## Le compteur n'apparaît qu'à la première perte : tant qu'il vaut zéro, il n'y a
## rien à signaler, et un « 0 » permanent serait du bruit à l'écran.
func _show_loss_counter(total_lost: int) -> void:
	_loss_counter.visible = total_lost > 0
	_loss_counter.text = LOSS_COUNTER_FORMAT % total_lost


## Ajoute un message en bas de la pile ; au-delà du nombre permis, le plus ancien
## s'efface. Chaque message s'éteint seul après la durée lue en données. Le
## minuteur est **suspendu pendant la pause** (`process_always = false`, story
## 4.3) : bien que le panneau vive sous `UI` (`PROCESS_MODE_ALWAYS`), un message
## n'expire pas derrière le menu pause et reprend son compte à la reprise.
func _push_message(text: String, variation: StringName) -> void:
	if _message_max <= 0:
		return
	var label: Label = Label.new()
	label.text = text
	label.theme_type_variation = variation
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_messages.add_child(label)
	while _messages.get_child_count() > _message_max:
		var oldest: Node = _messages.get_child(0)
		_messages.remove_child(oldest)
		oldest.queue_free()
	get_tree().create_timer(_message_duration, false).timeout.connect(label.queue_free)
