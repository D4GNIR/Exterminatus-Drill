extends Control

## Journal minimal — story 6.5 (CDC « Contrôles » : `toggle_journal`, `J` —
## « objectifs, logs, encyclopédie »).
##
## Porte l'action `toggle_journal` : un appui ouvre le journal et fige le jeu, un
## second appui le referme. Le MVP n'en livre que les **logs** : la liste des
## événements narratifs **déjà rencontrés**, dans l'ordre de rencontre, avec le
## nom de chaque événement, son locuteur et toutes ses lignes. Le joueur y relit
## un message radio coupé par `Échap` (story 6.2).
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Aucun état propre** : le contenu est **dérivé**, à chaque ouverture,
## des flags posés dans `GameState` et du catalogue de `data/events.json` (façade
## `GameData`). Un événement est « rencontré » si son flag est posé ; l'ordre de
## rencontre est l'ordre de première pose des flags
## (`GameState.get_narrative_flags()`). La sauvegarde (`7.1`) n'a donc que les
## flags à persister. Aucune écriture de flag ici : `NarrativeSystem` reste le
## seul écrivain.
## [br]— **Modale** (protocole `UiModal`, comme `Q72` (a) pour le dialogue) : une
## seule modale à la fois — le journal ne s'ouvre pas si une autre (pause,
## inventaire, station, dialogue) l'est ; pause **dérivée** de l'état de toutes
## les modales (`UiModal.sync_pause()`), jamais posée à la main. Le monde est figé
## par le `process_mode` (ce nœud hérite de `UI`, `ALWAYS`) : aucun flag ne peut
## changer derrière le journal ouvert, d'où une lecture unique à l'ouverture.
## [br]— **Jamais pendant la transition de destruction** (story 6.7, `M4`), comme
## l'inventaire : la pause, elle, reste disponible (`H4`).
## [br]— **Lecture en `_unhandled_input()`** (`F4 [B]`), jamais en `_input()`
## (`F5 [B]`, `Q10`). Actions **existantes** de l'Input Map, aucune ajoutée
## (`F2 [B]`) : `toggle_journal` ouvre et ferme, `pause` ferme. Seul l'appui
## **franc** bascule : la répétition clavier d'un `J` maintenu est ignorée
## (volet `echo` de `TM-1.5`).
## [br]— **Étanchéité** (`F6`) : ouvert, le journal consomme **tout** événement
## qui lui parvient. Fermé, il consomme encore les événements de
## `toggle_journal` (répétition et relâchement de la touche qui l'a refermé).
## Aucun contrôle focalisable. Aucune action de jeu ni consommable (`G6`).
## [br]— **Aucun texte narratif ni libellé de touche dans le code** (`D1 [B]`,
## `F1 [B]`, `Q2`) : noms, locuteurs et lignes viennent de `data/events.json` ;
## la touche de fermeture est lue dans l'Input Map (`ActionKeyLabel`) ; libellés
## d'interface fixes dans la scène.
## [br]— **Aucune apparence dans le code** : variations du thème unique
## `scenes/ui/UiTheme.tres` posées dans la scène (`Q48`) ; les nœuds d'une entrée
## sont **dupliqués** depuis le gabarit `EntryTemplate` de la scène, styles
## compris.
## [br]— **Non-anticipation** : ni objectifs, ni quotas (`Q11`), ni encyclopédie,
## ni carte (post-MVP).
## [br]— **Validation headless** : ce fichier référence les autoloads `GameData`
## et `GameState` — faux « Identifier not found » hors exécution du projet,
## exception `1.9`/`2.9`.

const ACTION_TOGGLE: StringName = &"toggle_journal"
const ACTION_PAUSE: StringName = &"pause"
## Encadrement de la touche affichée, même forme que le dialogue et la station.
const KEY_FORMAT: String = "[ %s ]"
## Nœuds d'une entrée, **descendants** du gabarit `EntryTemplate` (`C1` : aucun
## chemin vers un parent ni un frère).
const ENTRY_NAME_PATH: NodePath = ^"Header/Name"
const ENTRY_SPEAKER_PATH: NodePath = ^"Header/Speaker"
const ENTRY_LINES_PATH: NodePath = ^"Lines"
const ENTRY_LINE_PATH: NodePath = ^"Lines/Line"

@onready var _empty_label: Label = %EmptyLabel
@onready var _entries: VBoxContainer = %Entries
@onready var _entry_template: Control = %EntryTemplate
@onready var _close_key: Label = %CloseKey


func _ready() -> void:
	visible = false
	add_to_group(UiModal.GROUP)
	_entry_template.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed(ACTION_TOGGLE, false) or event.is_action_pressed(ACTION_PAUSE, false):
			_close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(ACTION_TOGGLE, false):
		if UiModal.is_other_open(self) or not GameState.is_drill_operational():
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


## Événements rencontrés, dans l'ordre de première pose de leur flag. Un flag
## qu'aucun événement du catalogue ne porte est ignoré.
static func encountered_event_ids() -> Array[String]:
	var event_by_flag: Dictionary[String, String] = {}
	for event_id: String in GameData.get_event_ids():
		event_by_flag[GameData.get_event_flag(event_id)] = event_id
	var encountered: Array[String] = []
	var flags: Dictionary[String, bool] = GameState.get_narrative_flags()
	for flag: String in flags:
		if flags[flag] and event_by_flag.has(flag):
			encountered.append(event_by_flag[flag])
	return encountered


## Reconstruit la liste des entrées depuis les flags et le catalogue.
func _refresh() -> void:
	_close_key.text = KEY_FORMAT % ActionKeyLabel.for_action(ACTION_TOGGLE)
	for entry: Node in _entries.get_children():
		_entries.remove_child(entry)
		entry.queue_free()
	for event_id: String in encountered_event_ids():
		_add_entry(event_id)
	_empty_label.visible = _entries.get_child_count() == 0
	_entries.visible = not _empty_label.visible


## Une entrée : nom de l'événement, locuteur, puis une étiquette par ligne de
## dialogue. Le gabarit porte une seule ligne, dupliquée autant que nécessaire ;
## la duplication garde les variations du thème posées dans la scène.
func _add_entry(event_id: String) -> void:
	var entry: Control = _entry_template.duplicate() as Control
	entry.unique_name_in_owner = false
	(entry.get_node(ENTRY_NAME_PATH) as Label).text = GameData.get_event_name(event_id)
	(entry.get_node(ENTRY_SPEAKER_PATH) as Label).text = GameData.get_event_speaker_name(event_id)
	var lines_box: Node = entry.get_node(ENTRY_LINES_PATH)
	var line_template: Label = entry.get_node(ENTRY_LINE_PATH) as Label
	lines_box.remove_child(line_template)
	for line: String in GameData.get_event_lines(event_id):
		var line_label: Label = line_template.duplicate() as Label
		line_label.text = line
		lines_box.add_child(line_label)
	line_template.free()
	entry.visible = true
	_entries.add_child(entry)
