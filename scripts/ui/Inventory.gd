extends Control

## Inventaire de soute — story 4.4.
##
## Porte l'action `toggle_inventory` du CDC (« Contrôles » : `I`, `Tab` — « Ouvre
## une interface et met le jeu en pause ») : un appui ouvre l'inventaire et fige
## le jeu, un second appui le referme et relance le jeu. Au MVP, sans
## consommables, l'inventaire **est** la soute : charge totale et contenu par
## ressource, en **lecture seule**.
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Lecture en `_unhandled_input()`** (`F4 [B]`), jamais en `_input()`
## (`F5 [B]`, arbitrage Q10). Seul l'appui **franc** bascule : la répétition
## clavier d'un `I` ou d'un `Tab` maintenu est ignorée (volet `echo` de `TM-1.5`).
## [br]— **Étanchéité** (`F6`) : ouvert, l'inventaire consomme **tout** événement
## qui lui parvient — déplacement, forage, freinage, objets rapides, relâchements
## et répétitions compris. Fermé, il consomme encore les événements de
## `toggle_inventory` (répétition et relâchement de la touche qui l'a refermé).
## L'inventaire ne contient **aucun contrôle focalisable** : `Tab`
## (`ui_focus_next`) n'a rien à parcourir et ne déplace aucun focus.
## [br]— **Une seule modale à la fois** (protocole `UiModal`) : l'inventaire ne
## s'ouvre pas si une autre modale l'est ; ouvert, il se referme sur l'action
## `pause`, que le menu pause lui laisse, et rend la main au jeu. La pause est
## dérivée de l'état de toutes les modales (`UiModal.sync_pause()`), jamais posée
## à la main : fermer l'inventaire ne relance pas un jeu qu'une autre modale fige.
## [br]— **Contenu lu à l'ouverture**, dans `GameState` (soute) et `GameData`
## (noms de `data/resources.json`) : aucun nom de ressource en dur (`D1`, `D3`).
## Le monde étant figé tant que l'inventaire est ouvert, la soute ne peut pas
## changer derrière lui. La charge est formatée par la fonction statique du HUD
## (`HUD.format_cargo()`, type nommé `HUD`) : même unité (unités de masse), même
## valeur.
## [br]— **Aucune économie** : ni prix ni valeur en crédits (vente : `5.2`, `Q37`).
## Aucune action sur les objets (consommables `use_item_1..3` : post-MVP).
## [br]— **Aucune apparence dans le code**, aucun libellé de touche : styles du
## thème unique `scenes/ui/UiTheme.tres` (`Q48`), libellés dans la scène.
## [br]— **Validation headless** : ce fichier référence les autoloads `GameState`
## et `GameData` — faux « Identifier not found » en `--check-only`, exception de
## la story 1.9.

const ACTION_TOGGLE: StringName = &"toggle_inventory"
const ACTION_PAUSE: StringName = &"pause"

@onready var _load_value: Label = %LoadValue
@onready var _empty_label: Label = %EmptyLabel
@onready var _contents: GridContainer = %Contents


func _ready() -> void:
	visible = false
	add_to_group(UiModal.GROUP)


func _unhandled_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed(ACTION_TOGGLE, false) or event.is_action_pressed(ACTION_PAUSE, false):
			_close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(ACTION_TOGGLE, false):
		if UiModal.is_other_open(self):
			return
		_open()
	if event.is_action(ACTION_TOGGLE):
		get_viewport().set_input_as_handled()


func _open() -> void:
	_refresh()
	visible = true
	UiModal.sync_pause(get_tree())


func _close() -> void:
	visible = false
	UiModal.sync_pause(get_tree())


## Reconstruit la charge et une ligne « nom — unités » par ressource présente,
## dans l'ordre du catalogue de `data/resources.json`.
func _refresh() -> void:
	_load_value.text = HUD.format_cargo(GameState.get_cargo_used(), GameState.get_cargo_capacity())
	for row: Node in _contents.get_children():
		_contents.remove_child(row)
		row.queue_free()
	var cargo: Dictionary[String, int] = GameState.get_cargo_contents()
	for resource_id: String in GameData.get_resource_ids():
		var units: int = cargo.get(resource_id, 0)
		if units <= 0:
			continue
		_add_row(GameData.get_resource_name(resource_id), units)
	_empty_label.visible = _contents.get_child_count() == 0
	_contents.visible = not _empty_label.visible


func _add_row(resource_name: String, units: int) -> void:
	var name_label: Label = Label.new()
	name_label.text = resource_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_contents.add_child(name_label)
	var units_label: Label = Label.new()
	units_label.text = str(units)
	units_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_contents.add_child(units_label)
