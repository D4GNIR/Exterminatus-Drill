extends Control

## Interface de station de surface — story 5.1.
##
## Le lieu où le joueur revient (CDC « Boucle de jeu », étapes 4 et 5). La story
## `5.1` en a livré la **coquille** — ouverture, fermeture, pause, étanchéité des
## entrées, thème — ; la story `5.2` y ajoute la section **vente**, la story
## `5.3` la section **ravitaillement et réparation**, la story `5.4` le **rayon
## des améliorations**, dans un second cadre à droite de celui de la station.
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Ouverture** (`Q54` (b)) : sur l'action `interact`, **seulement** si la
## foreuse est dans la zone de surface (`GameState.is_in_surface_zone()`, zone
## lue dans les ancrages de `data/generation.json`, `K3`), hors destruction (6.7),
## et qu'aucune autre modale n'est ouverte. Jamais sous terre, jamais automatiquement.
## [br]— **Fermeture** (`Q62` (a)) : sur `interact` (bascule, modèle de
## `toggle_inventory`) **et** sur `pause`. Une seule pression ferme : le menu
## pause, qui reçoit l'appui le premier, le laisse à la modale ouverte (protocole
## `UiModal`) ; cette interface le consomme après s'être fermée, et rien ne la
## rouvre dans la même image.
## [br]— **Lecture en `_unhandled_input()`** (`F4 [B]`), jamais en `_input()`
## (`F5 [B]`, `Q10`). Seul l'appui **franc** bascule : la répétition clavier est
## ignorée.
## [br]— **Étanchéité** (`F6`) : ouverte, l'interface consomme **tout** événement
## qui lui parvient ; fermée, elle consomme encore les événements de `interact`
## (répétition et relâchement de la touche qui l'a fermée, appui hors zone).
## Contrôles focalisables : les boutons de vente (story 5.2), de plein et de
## réparation (story 5.3), un bouton d'achat par amélioration active (story
## 5.4) ; celui de vente prend le focus à l'ouverture — même
## procédé que le menu pause (`4.3`) : `ui_accept` (`Entrée`, `Espace`) valide le
## bouton focalisé, la navigation du focus (`ui_up`/`ui_down`, `Tab`) est traitée
## par l'interface avant ce script, les autres touches sont consommées ici.
## [br]— **Vente** (story 5.2) : la section affiche, **avant** la vente, le
## contenu vendu et le montant total, tels que les cote `EconomySystem`
## (`quote_cargo()`) ; le bouton appelle `EconomySystem.sell_cargo()`, qui
## crédite **ce même total**. Aucun prix ni calcul ici (`D1`, `L1`, `L3`) : ce
## script met en forme. Après la vente, la section garde le **reçu** (ce qui a été
## vendu, le gain) jusqu'à la fermeture ; la cotation est relue à chaque
## ouverture. Soute vide : rien ne se passe, et la section le dit.
## [br]— **Ravitaillement et réparation** (story 5.3) : jauges courantes, puis
## ce que le service **rend** et ce qu'il **coûte**, tels que les cotent
## `EconomySystem.quote_refuel()` / `quote_repair()` ; les boutons appellent
## `refuel()` / `repair_armor()`, qui appliquent **ces mêmes cotations** (débit =
## montant affiché). Les cotations sont relues à l'ouverture et après **chaque**
## opération de la station (une vente change crédits et soute, donc le plein,
## la réparation et le droit au secours). Le secours gratuit (`Q56`) est **dit
## comme tel**. Aucun prix ni calcul ici ; jauges au format du HUD
## (`HUD.format_gauge()`). Le composant de blindage, seul écrivain du blindage
## (`M1`), est obtenu de la foreuse **injectée par la scène** (`drill_rig_path`,
## renseigné dans `Main.tscn`), comme pour le HUD (`Q38`).
## [br]— **Rayon des améliorations** (story 5.4, `Q18`, `Q21`) : une ligne par
## amélioration **cotée par `EconomySystem.quote_upgrades()`** — donc par les
## améliorations `actif_mvp: true` des données, dans leur ordre, sans liste dans
## ce script — : nom (données), niveau courant, valeur courante et valeur du
## niveau suivant, **coût du niveau suivant, toujours affiché**, bouton
## d'achat. Le bouton appelle `EconomySystem.buy_upgrade()`, qui débite **ce même
## coût** ; aucun calcul ici. Les boutons restent **toujours actifs** (`L2`) : un
## achat refusé faute de crédits **dit pourquoi**, et le coût d'un niveau
## inabordable est seulement grisé (variation `MessageRefusedLabel`). La
## description de l'amélioration focalisée ou survolée s'affiche sous la grille.
## Les grands montants sont écrits **en entier**, chiffres groupés par trois
## (`group_digits()`, espace insécable) : ni troncature ni notation abrégée,
## l'égalité « coût affiché = débit » reste lisible (`L3`). Rayon relu à
## l'ouverture et après chaque opération de la station (une vente ou un service
## change les crédits). L'**effet** d'un achat sur les systèmes de jeu n'est pas
## l'affaire de cette interface (story 5.5).
## [br]— **Pause dérivée** (`UiModal.sync_pause()`), jamais posée à la main : le
## monde est figé par le `process_mode`, ce nœud hérite de `UI` (`ALWAYS`).
## [br]— **Aucune sauvegarde** au retour en surface (`7.4`, `Q7`).
## [br]— **Aucune apparence dans le code** : variations du thème unique
## `scenes/ui/UiTheme.tres` (`Q48`) — `Modal…`, `HudCaption`, `InventoryGrid`,
## `HintKey` posées dans la scène, `MessageRefusedLabel` nommée ici pour le coût
## refusé du rayon. Libellés fixes dans la scène ; ce script porte les **textes
## produits à l'exécution** des trois sections (vente, services, rayon) : gabarits
## chiffrés, messages de cotation et d'état non chiffrés (`SALE_STATUS_EMPTY`,
## `FUEL_QUOTE_ALREADY_FULL`…) et libellé du bouton d'achat créé par le code
## (`UPGRADE_BUY_LABEL`), comme le panneau d'alertes (`4.2`) ; la touche de
## fermeture affichée est lue dans l'Input Map (`ActionKeyLabel`, `Q2`).
## [br]— **Validation headless** : ce fichier référence l'autoload `GameState`
## (et, par `EconomySystem`, `GameData`) — faux « Identifier not found » hors
## exécution du projet, exception `1.9`/`2.9`.

const ACTION_INTERACT: StringName = &"interact"
const ACTION_PAUSE: StringName = &"pause"
## Encadrement de la touche affichée, même forme que l'indication du HUD.
const KEY_FORMAT: String = "[ %s ]"

# --- Gabarits de la section vente (story 5.2) ---------------------------------
## Quantité d'une ligne : tuiles entières, puis unités de masse de la soute.
const SALE_QUANTITY_FORMAT: String = "×%d (%d u.)"
## Montant d'une ligne ou du total, en crédits impériaux.
const SALE_AMOUNT_FORMAT: String = "%d cr"
## En-tête de la section une fois la vente conclue (reçu).
const SALE_HEADER_SOLD: String = "CHARGEMENT VENDU"
const SALE_STATUS_SOLD: String = "Vente conclue : +%d crédits impériaux"
const SALE_STATUS_EMPTY: String = "Rien à vendre : la soute est vide."
const SALE_STATUS_INVALID: String = "Vente refusée : cargaison non reconnue par le catalogue."
const SALE_STATUS_NOT_AT_STATION: String = "Vente impossible hors de la station."

# --- Gabarits de la section ravitaillement et réparation (story 5.3) -----------
## Cotations : ce que le service rend, ce qu'il coûte.
const FUEL_QUOTE_FULL: String = "Plein : +%d u. — %d cr"
const FUEL_QUOTE_PARTIAL: String = "Plein partiel (crédits) : +%d u. sur %d — %d cr"
const FUEL_QUOTE_RESCUE: String = "Secours gratuit : réservoir porté à %s — 0 cr"
const FUEL_QUOTE_RESCUE_PAID: String = ", puis +%d u. — %d cr"
const FUEL_QUOTE_ALREADY_FULL: String = "Réservoir plein"
const FUEL_QUOTE_INSUFFICIENT: String = "Crédits insuffisants : %d cr l'unité"
const ARMOR_QUOTE_FULL: String = "Réparation : +%d pts — %d cr"
const ARMOR_QUOTE_PARTIAL: String = "Réparation partielle (crédits) : +%d pts sur %d — %d cr"
const ARMOR_QUOTE_ALREADY_FULL: String = "Blindage intact"
const ARMOR_QUOTE_INSUFFICIENT: String = "Crédits insuffisants : %d cr le point"
const SERVICE_QUOTE_UNAVAILABLE: String = "Service indisponible"
## Messages après une opération.
const FUEL_STATUS_FULL: String = "Plein effectué : +%d u. pour %d crédits."
const FUEL_STATUS_PARTIAL: String = "Plein partiel : +%d u. pour %d crédits, faute de crédits pour le reste."
const FUEL_STATUS_RESCUE: String = "Ravitaillement de SECOURS gratuit : réservoir porté à %s, crédits et soute ne suffisant pas."
const FUEL_STATUS_RESCUE_PAID: String = " Puis +%d u. pour %d crédits."
const FUEL_STATUS_ALREADY_FULL: String = "Le réservoir est déjà plein."
const FUEL_STATUS_INSUFFICIENT: String = "Crédits insuffisants : aucun carburant acheté."
const ARMOR_STATUS_FULL: String = "Blindage réparé : +%d points pour %d crédits."
const ARMOR_STATUS_PARTIAL: String = "Réparation partielle : +%d points pour %d crédits, faute de crédits pour le reste."
const ARMOR_STATUS_ALREADY_FULL: String = "Le blindage est intact."
const ARMOR_STATUS_INSUFFICIENT: String = "Crédits insuffisants pour un seul point : rien n'est réparé. Vous pouvez repartir."
const SERVICE_STATUS_NOT_AT_STATION: String = "Service impossible hors de la station."
const SERVICE_STATUS_UNAVAILABLE: String = "Service indisponible."

# --- Gabarits du rayon des améliorations (story 5.4) ----------------------------
## Séparateur des milliers : espace **insécable** (U+00A0, présent dans la police
## du thème), pour qu'un montant ne soit jamais coupé en fin de ligne.
const DIGIT_GROUP_SEPARATOR: String = "\u00A0"
const DIGIT_GROUP_SIZE: int = 3
const UPGRADE_LEVEL_FORMAT: String = "%d"
## Valeur courante » valeur du niveau suivant.
const UPGRADE_EFFECT_FORMAT: String = "%s » %s"
const UPGRADE_COST_FORMAT: String = "%s cr"
const UPGRADE_CREDITS_FORMAT: String = "%s cr"
const UPGRADE_BUY_LABEL: String = "Acheter"
## Coût d'un niveau que les crédits ne paient pas encore : grisé, jamais masqué.
const UPGRADE_COST_REFUSED_VARIATION: StringName = &"MessageRefusedLabel"
const UPGRADE_STATUS_BOUGHT: String = "%s : niveau %d atteint (%s » %s) pour %s crédits."
const UPGRADE_STATUS_INSUFFICIENT: String = "Achat refusé, crédits insuffisants : %s niveau %d coûte %s cr, vous disposez de %s cr."
const UPGRADE_STATUS_NOT_AT_STATION: String = "Achat impossible hors de la station."
const UPGRADE_STATUS_UNAVAILABLE: String = "Amélioration indisponible."


## Contrôles d'une ligne du rayon, créés depuis la cotation.
class UpgradeRow:
	extends RefCounted
	var upgrade_id: String = ""
	var description: String = ""
	var name_label: Label
	var level_label: Label
	var effect_label: Label
	var cost_label: Label
	var buy_button: Button


## Foreuse dont on répare le blindage, injectée par `Main.tscn`.
@export var drill_rig_path: NodePath

var _economy: EconomySystem = EconomySystem.new()
## Seul écrivain du blindage (`M1`) ; nul si la foreuse n'est pas injectée, la
## réparation est alors indisponible (et l'erreur signalée au démarrage).
var _armor_system: ArmorSystem = null
## En-tête de cotation, tel qu'écrit dans la scène, restauré à chaque ouverture.
var _quote_header: String = ""
## Lignes du rayon, dans l'ordre de la cotation (story 5.4).
var _upgrade_rows: Array[UpgradeRow] = []

@onready var _close_key: Label = %CloseKey
@onready var _sale_header: Label = %SaleHeader
@onready var _sale_empty: Label = %SaleEmpty
@onready var _sale_lines: GridContainer = %SaleLines
@onready var _sale_total: Label = %SaleTotal
@onready var _sell_button: Button = %SellButton
@onready var _sale_status: Label = %SaleStatus
@onready var _fuel_gauge: Label = %FuelGauge
@onready var _fuel_quote: Label = %FuelQuote
@onready var _refuel_button: Button = %RefuelButton
@onready var _armor_gauge: Label = %ArmorGauge
@onready var _repair_quote: Label = %RepairQuote
@onready var _repair_button: Button = %RepairButton
@onready var _service_status: Label = %ServiceStatus
@onready var _upgrade_credits: Label = %UpgradeCredits
@onready var _upgrade_lines: GridContainer = %UpgradeLines
@onready var _upgrade_detail: Label = %UpgradeDetail
@onready var _upgrade_status: Label = %UpgradeStatus


func _ready() -> void:
	visible = false
	add_to_group(UiModal.GROUP)
	_quote_header = _sale_header.text
	_sell_button.pressed.connect(_on_sell_pressed)
	_refuel_button.pressed.connect(_on_refuel_pressed)
	_repair_button.pressed.connect(_on_repair_pressed)
	var rig: DrillRig = get_node_or_null(drill_rig_path) as DrillRig
	if rig == null:
		push_error("Shop — foreuse introuvable (« %s ») : réparation du blindage indisponible." % drill_rig_path)
	else:
		_armor_system = rig.get_armor_system()


func _unhandled_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed(ACTION_INTERACT, false) or event.is_action_pressed(ACTION_PAUSE, false):
			_close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(ACTION_INTERACT, false) and _can_open():
		_open()
	if event.is_action(ACTION_INTERACT):
		get_viewport().set_input_as_handled()


func _can_open() -> bool:
	return GameState.is_in_surface_zone() and GameState.is_drill_operational() and not UiModal.is_other_open(self)


func _open() -> void:
	_close_key.text = KEY_FORMAT % ActionKeyLabel.for_action(ACTION_INTERACT)
	var quote: EconomySystem.SaleQuote = _economy.quote_cargo()
	_show_sale(quote, _quote_header)
	# Soute vide : la section le dit déjà ; une cargaison invendable, elle, est
	# signalée dès l'ouverture.
	_sale_status.text = _status_text(quote) if quote.outcome == EconomySystem.Outcome.INVALID_CARGO else ""
	_service_status.text = ""
	_upgrade_status.text = ""
	_refresh_services()
	_refresh_upgrades()
	_upgrade_detail.text = _upgrade_rows.front().description if not _upgrade_rows.is_empty() else ""
	visible = true
	UiModal.sync_pause(get_tree())
	_sell_button.grab_focus()


func _close() -> void:
	visible = false
	UiModal.sync_pause(get_tree())


# --- Section vente (story 5.2) -------------------------------------------------

## Vend la soute. Le reçu remplace la cotation ; un refus ne change rien à la
## soute, laisse la cotation affichée et dit pourquoi.
func _on_sell_pressed() -> void:
	var result: EconomySystem.SaleQuote = _economy.sell_cargo()
	match result.outcome:
		EconomySystem.Outcome.SOLD:
			_show_sale(result, SALE_HEADER_SOLD)
		EconomySystem.Outcome.EMPTY, EconomySystem.Outcome.INVALID_CARGO:
			# Le refus porte la cotation courante : l'afficher suffit.
			_show_sale(result, _quote_header)
	_sale_status.text = _status_text(result)
	_refresh_services()
	_refresh_upgrades()


## Une ligne « nom — quantité — montant » par ressource cotée, puis le total.
func _show_sale(quote: EconomySystem.SaleQuote, header: String) -> void:
	_sale_header.text = header
	for cell: Node in _sale_lines.get_children():
		_sale_lines.remove_child(cell)
		cell.queue_free()
	for line: EconomySystem.SaleLine in quote.lines:
		_add_cell(line.display_name, HORIZONTAL_ALIGNMENT_LEFT, true)
		_add_cell(SALE_QUANTITY_FORMAT % [line.tiles, line.units], HORIZONTAL_ALIGNMENT_RIGHT, false)
		_add_cell(SALE_AMOUNT_FORMAT % line.amount, HORIZONTAL_ALIGNMENT_RIGHT, false)
	_sale_empty.visible = quote.lines.is_empty() and quote.outcome == EconomySystem.Outcome.EMPTY
	_sale_lines.visible = not quote.lines.is_empty()
	_sale_total.text = SALE_AMOUNT_FORMAT % quote.total


func _add_cell(text: String, alignment: HorizontalAlignment, expand: bool) -> void:
	var cell: Label = Label.new()
	cell.text = text
	cell.horizontal_alignment = alignment
	if expand:
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sale_lines.add_child(cell)


## Message de la section : vide quand la cotation est vendable et rien n'est
## encore fait ; sinon, l'issue de la vente ou la raison du refus.
func _status_text(result: EconomySystem.SaleQuote) -> String:
	match result.outcome:
		EconomySystem.Outcome.SOLD:
			return SALE_STATUS_SOLD % result.total
		EconomySystem.Outcome.EMPTY:
			return SALE_STATUS_EMPTY
		EconomySystem.Outcome.INVALID_CARGO:
			return SALE_STATUS_INVALID
		EconomySystem.Outcome.NOT_AT_STATION:
			return SALE_STATUS_NOT_AT_STATION
	return ""


# --- Section ravitaillement et réparation (story 5.3) --------------------------

func _on_refuel_pressed() -> void:
	var result: EconomySystem.ServiceQuote = _economy.refuel()
	_service_status.text = _refuel_status(result)
	_refresh_services()
	_refresh_upgrades()


func _on_repair_pressed() -> void:
	var result: EconomySystem.ServiceQuote = _economy.repair_armor(_armor_system)
	_service_status.text = _repair_status(result)
	_refresh_services()
	_refresh_upgrades()


## Jauges et cotations courantes des deux services.
func _refresh_services() -> void:
	var fuel: EconomySystem.ServiceQuote = _economy.quote_refuel()
	_fuel_gauge.text = HUD.format_gauge(fuel.current, fuel.maximum)
	_fuel_quote.text = _refuel_quote_text(fuel)
	var armor: EconomySystem.ServiceQuote = _economy.quote_repair(_armor_system)
	_armor_gauge.text = HUD.format_gauge(armor.current, armor.maximum)
	_repair_quote.text = _repair_quote_text(armor)


func _refuel_quote_text(quote: EconomySystem.ServiceQuote) -> String:
	match quote.outcome:
		EconomySystem.ServiceOutcome.FULL:
			return FUEL_QUOTE_FULL % [quote.paid_units, quote.cost]
		EconomySystem.ServiceOutcome.PARTIAL:
			return FUEL_QUOTE_PARTIAL % [quote.paid_units, quote.missing_units, quote.cost]
		EconomySystem.ServiceOutcome.RESCUE:
			return FUEL_QUOTE_RESCUE % HUD.format_gauge(quote.rescue_threshold, quote.maximum) + _rescue_paid_text(quote, FUEL_QUOTE_RESCUE_PAID)
		EconomySystem.ServiceOutcome.ALREADY_FULL:
			return FUEL_QUOTE_ALREADY_FULL
		EconomySystem.ServiceOutcome.INSUFFICIENT_CREDITS:
			return FUEL_QUOTE_INSUFFICIENT % quote.unit_price
	return SERVICE_QUOTE_UNAVAILABLE


func _repair_quote_text(quote: EconomySystem.ServiceQuote) -> String:
	match quote.outcome:
		EconomySystem.ServiceOutcome.FULL:
			return ARMOR_QUOTE_FULL % [quote.paid_units, quote.cost]
		EconomySystem.ServiceOutcome.PARTIAL:
			return ARMOR_QUOTE_PARTIAL % [quote.paid_units, quote.missing_units, quote.cost]
		EconomySystem.ServiceOutcome.ALREADY_FULL:
			return ARMOR_QUOTE_ALREADY_FULL
		EconomySystem.ServiceOutcome.INSUFFICIENT_CREDITS:
			return ARMOR_QUOTE_INSUFFICIENT % quote.unit_price
	return SERVICE_QUOTE_UNAVAILABLE


func _refuel_status(result: EconomySystem.ServiceQuote) -> String:
	match result.outcome:
		EconomySystem.ServiceOutcome.FULL:
			return FUEL_STATUS_FULL % [result.paid_units, result.cost]
		EconomySystem.ServiceOutcome.PARTIAL:
			return FUEL_STATUS_PARTIAL % [result.paid_units, result.cost]
		EconomySystem.ServiceOutcome.RESCUE:
			return FUEL_STATUS_RESCUE % HUD.format_gauge(result.rescue_threshold, result.maximum) + _rescue_paid_text(result, FUEL_STATUS_RESCUE_PAID)
		EconomySystem.ServiceOutcome.ALREADY_FULL:
			return FUEL_STATUS_ALREADY_FULL
		EconomySystem.ServiceOutcome.INSUFFICIENT_CREDITS:
			return FUEL_STATUS_INSUFFICIENT
		EconomySystem.ServiceOutcome.NOT_AT_STATION:
			return SERVICE_STATUS_NOT_AT_STATION
	return SERVICE_STATUS_UNAVAILABLE


func _repair_status(result: EconomySystem.ServiceQuote) -> String:
	match result.outcome:
		EconomySystem.ServiceOutcome.FULL:
			return ARMOR_STATUS_FULL % [result.paid_units, result.cost]
		EconomySystem.ServiceOutcome.PARTIAL:
			return ARMOR_STATUS_PARTIAL % [result.paid_units, result.cost]
		EconomySystem.ServiceOutcome.ALREADY_FULL:
			return ARMOR_STATUS_ALREADY_FULL
		EconomySystem.ServiceOutcome.INSUFFICIENT_CREDITS:
			return ARMOR_STATUS_INSUFFICIENT
		EconomySystem.ServiceOutcome.NOT_AT_STATION:
			return SERVICE_STATUS_NOT_AT_STATION
	return SERVICE_STATUS_UNAVAILABLE


## Part payée au-dessus du seuil de secours, s'il y en a une.
func _rescue_paid_text(quote: EconomySystem.ServiceQuote, template: String) -> String:
	if quote.paid_units <= 0:
		return ""
	return template % [quote.paid_units, quote.cost]


# --- Rayon des améliorations (story 5.4) ----------------------------------------

## Achète le niveau suivant. Le reçu ou le refus est dit ; le rayon et les
## services sont relus (les crédits ont pu changer).
func _on_buy_pressed(upgrade_id: String) -> void:
	var result: EconomySystem.UpgradeQuote = _economy.buy_upgrade(upgrade_id)
	_upgrade_status.text = _upgrade_status_text(result)
	_refresh_services()
	_refresh_upgrades()


## Relit la cotation de toutes les améliorations et met le rayon à jour. Les
## lignes ne sont recréées que si la liste cotée change : le focus d'un bouton
## d'achat survit à l'achat.
func _refresh_upgrades() -> void:
	var quotes: Array[EconomySystem.UpgradeQuote] = _economy.quote_upgrades()
	_upgrade_credits.text = UPGRADE_CREDITS_FORMAT % group_digits(str(GameState.get_credits()))
	if not _rows_match(quotes):
		_rebuild_upgrade_rows(quotes)
	for index: int in quotes.size():
		_show_upgrade(_upgrade_rows[index], quotes[index])


func _rows_match(quotes: Array[EconomySystem.UpgradeQuote]) -> bool:
	if quotes.size() != _upgrade_rows.size():
		return false
	for index: int in quotes.size():
		if quotes[index].upgrade_id != _upgrade_rows[index].upgrade_id:
			return false
	return true


func _rebuild_upgrade_rows(quotes: Array[EconomySystem.UpgradeQuote]) -> void:
	for row: UpgradeRow in _upgrade_rows:
		for cell: Control in [row.name_label, row.level_label, row.effect_label, row.cost_label, row.buy_button]:
			_upgrade_lines.remove_child(cell)
			cell.queue_free()
	_upgrade_rows.clear()
	for quote: EconomySystem.UpgradeQuote in quotes:
		var row: UpgradeRow = UpgradeRow.new()
		row.upgrade_id = quote.upgrade_id
		row.name_label = _add_upgrade_cell(HORIZONTAL_ALIGNMENT_LEFT, true)
		row.level_label = _add_upgrade_cell(HORIZONTAL_ALIGNMENT_RIGHT, false)
		row.effect_label = _add_upgrade_cell(HORIZONTAL_ALIGNMENT_RIGHT, false)
		row.cost_label = _add_upgrade_cell(HORIZONTAL_ALIGNMENT_RIGHT, false)
		row.buy_button = Button.new()
		row.buy_button.text = UPGRADE_BUY_LABEL
		row.buy_button.pressed.connect(_on_buy_pressed.bind(quote.upgrade_id))
		row.buy_button.focus_entered.connect(_show_upgrade_detail.bind(row))
		row.buy_button.mouse_entered.connect(_show_upgrade_detail.bind(row))
		_upgrade_lines.add_child(row.buy_button)
		_upgrade_rows.append(row)


func _add_upgrade_cell(alignment: HorizontalAlignment, expand: bool) -> Label:
	var cell: Label = Label.new()
	cell.horizontal_alignment = alignment
	if expand:
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_upgrade_lines.add_child(cell)
	return cell


## Nom, niveau, valeur courante » valeur suivante, coût du niveau suivant —
## toujours affiché, grisé s'il dépasse les crédits.
func _show_upgrade(row: UpgradeRow, quote: EconomySystem.UpgradeQuote) -> void:
	row.description = quote.description
	row.name_label.text = quote.display_name
	row.level_label.text = UPGRADE_LEVEL_FORMAT % quote.level
	row.effect_label.text = UPGRADE_EFFECT_FORMAT % [format_value(quote.current_value), format_value(quote.next_value)]
	row.cost_label.text = UPGRADE_COST_FORMAT % group_digits(str(quote.cost))
	row.cost_label.theme_type_variation = UPGRADE_COST_REFUSED_VARIATION if quote.outcome == EconomySystem.UpgradeOutcome.INSUFFICIENT_CREDITS else &""


func _show_upgrade_detail(row: UpgradeRow) -> void:
	_upgrade_detail.text = row.description


func _upgrade_status_text(result: EconomySystem.UpgradeQuote) -> String:
	match result.outcome:
		EconomySystem.UpgradeOutcome.BOUGHT:
			return UPGRADE_STATUS_BOUGHT % [result.display_name, result.next_level, format_value(result.current_value), format_value(result.next_value), group_digits(str(result.cost))]
		EconomySystem.UpgradeOutcome.INSUFFICIENT_CREDITS:
			return UPGRADE_STATUS_INSUFFICIENT % [result.display_name, result.next_level, group_digits(str(result.cost)), group_digits(str(result.credits))]
		EconomySystem.UpgradeOutcome.NOT_AT_STATION:
			return UPGRADE_STATUS_NOT_AT_STATION
	return UPGRADE_STATUS_UNAVAILABLE


## Valeur d'amélioration (entière par construction des données, `5.6`), écrite
## en entier, chiffres groupés. `%.0f` plutôt qu'une conversion en entier : exact
## et sans débordement quelle que soit la valeur.
static func format_value(value: float) -> String:
	return group_digits("%.0f" % value)


## Groupe par trois les chiffres d'un entier écrit en décimal
## (« 9007199254740992 » → « 9 007 199 254 740 992 », espace insécable) — mise
## en forme seule : aucun chiffre retiré ni arrondi, le signe éventuel conservé.
static func group_digits(digits: String) -> String:
	var prefix: String = "-" if digits.begins_with("-") else ""
	var reversed: String = digits.trim_prefix("-").reverse()
	var grouped: String = ""
	for index: int in reversed.length():
		if index > 0 and index % DIGIT_GROUP_SIZE == 0:
			grouped = DIGIT_GROUP_SEPARATOR + grouped
		grouped = reversed[index] + grouped
	return prefix + grouped
