extends Control

## Dialogue et messages radio — story 6.2 (CDC « Scénario », « Direction
## sonore » : « messages radio courts du Commissaire, du Tech-Prêtre et de
## l'ordinateur de bord » ; « Architecture Godot » : `scenes/ui/Dialogue.tscn`).
##
## Affiche, ligne par ligne, les lignes de dialogue d'un événement déclenché par
## `NarrativeSystem` (signal `event_triggered`, story 6.3), sous le nom de son
## locuteur. Premier contenu : le prologue, déclenché en début de partie.
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Modal** (`Q72` (a), story 6.13) : protocole `UiModal` — une seule
## modale à la fois, pause **dérivée** de l'état de toutes les modales
## (`UiModal.sync_pause()`), jamais posée à la main. Le monde est figé par le
## `process_mode` (ce nœud hérite de `UI`, `ALWAYS`) : aucune rencontre hostile,
## aucun forage, aucune consommation pendant la lecture (`M4`, `G6`, `H3`, `H4`).
## [br]— **Déclenchement différé, jamais perdu ni superposé** : un événement
## reçu est mis en **file** ; il ne s'affiche que lorsque aucune autre modale
## n'est ouverte (pause, inventaire, station) **et** que la foreuse est
## opérationnelle (`GameState.is_drill_operational()`, hors transition de
## destruction, story 6.7). La file est relue à chaque image tant qu'elle n'est
## pas vide (`_process()`, actif pendant la pause) ; deux événements reçus
## ensemble s'affichent l'un après l'autre, chacun une seule fois — le flag de
## `NarrativeSystem` garantit déjà qu'un événement n'est émis qu'une fois.
## [br]— **Lecture en `_unhandled_input()`** (`F4 [B]`), jamais en `_input()`
## (`F5 [B]`, `Q10`). Actions **existantes** de l'Input Map, aucune ajoutée
## (`F2 [B]`) : `ui_accept` (action intégrée du moteur) passe à la ligne
## suivante, puis ferme après la dernière ; `pause` ferme le message à tout
## moment, comme toute modale ouverte (protocole `UiModal` : le menu pause lui
## laisse cet appui).
## [br]— **Validation au relâchement** de `ui_accept` d'un appui **commencé
## pendant la lecture** : `Espace` est aussi `drill`, lu en continu par le jeu ;
## fermer à l'appui laisserait la touche enfoncée au jeu relancé (forage
## involontaire, saut d'état, `H3`). Un appui commencé **avant** l'ouverture —
## forage en cours au déclenchement — ne fait donc rien à son relâchement. La
## répétition clavier (`echo`) est ignorée.
## [br]— **Étanchéité** (`F6`) : ouvert, le dialogue consomme **tout** événement
## qui lui parvient. Fermé, il n'en consomme aucun : les touches de `pause`
## (répétition, relâchement) sont déjà consommées par le menu pause, et
## `ui_accept` ferme au relâchement, sans rien laisser derrière lui.
## [br]— **Aucun texte narratif ni libellé de touche dans le code** (`D1 [B]`,
## `F1 [B]`, `Q2`) : nom du locuteur et lignes viennent de `data/events.json`
## par la façade `GameData` ; touches lues dans l'Input Map (`ActionKeyLabel`) ;
## libellés d'interface fixes dans la scène.
## [br]— **Aucun choix de réponse, aucun embranchement, aucun son de voix**
## (non-anticipation : « Quêtes du Mechanicus et choix narratifs », post-MVP).
## [br]— **Aucune apparence dans le code** : variations du thème unique
## `scenes/ui/UiTheme.tres` posées dans la scène (`Q48`).
## [br]— `NarrativeSystem` est **injecté par la scène** (`narrative_system_path`,
## renseigné dans `Main.tscn`, `Q38`) ; seule la connexion à son signal en est
## faite (`C3`).
## [br]— **Validation headless** : ce fichier référence les autoloads `GameData`
## et `GameState` — faux « Identifier not found » hors exécution du projet,
## exception `1.9`/`2.9`.

## Ligne suivante, puis fermeture après la dernière ligne.
const ACTION_NEXT: StringName = &"ui_accept"
## Fermeture immédiate, comme toute modale ouverte.
const ACTION_PAUSE: StringName = &"pause"
## Encadrement de la touche affichée, même forme que la station et le HUD.
const KEY_FORMAT: String = "[ %s ]"
## Rang de la ligne affichée sur le nombre de lignes du message.
const PROGRESS_FORMAT: String = "%d / %d"

## Moteur narratif dont ce dialogue affiche les déclenchements (`Q38`).
@export var narrative_system_path: NodePath

## Événements déclenchés, pas encore affichés, dans l'ordre de réception.
var _pending: Array[String] = []
## Lignes du message affiché et rang de la ligne courante.
var _lines: PackedStringArray = PackedStringArray()
var _line_index: int = 0
## Vrai si un appui franc sur `ACTION_NEXT` a commencé pendant la lecture : seul
## son relâchement fait avancer.
var _next_armed: bool = false

@onready var _speaker: Label = %Speaker
@onready var _line: Label = %Line
@onready var _progress: Label = %Progress
@onready var _next_key: Label = %NextKey
@onready var _next_caption: Label = %NextCaption
@onready var _last_caption: Label = %LastCaption
@onready var _skip_hint: Control = %SkipHint
@onready var _skip_key: Label = %SkipKey


func _ready() -> void:
	visible = false
	add_to_group(UiModal.GROUP)
	set_process(false)
	var narrative: NarrativeSystem = get_node_or_null(narrative_system_path) as NarrativeSystem
	if narrative == null:
		push_error("Dialogue — moteur narratif introuvable (« %s ») : aucun message radio ne sera affiché." % narrative_system_path)
		return
	narrative.event_triggered.connect(_on_event_triggered)


## Met l'événement en file ; il s'affichera dès que rien ne s'y oppose.
func _on_event_triggered(event_id: String) -> void:
	if _pending.has(event_id):
		return
	_pending.append(event_id)
	set_process(true)


## Actif seulement tant que la file n'est pas vide : attend qu'aucune autre
## modale ne soit ouverte et que la foreuse soit opérationnelle.
func _process(_delta: float) -> void:
	_open_next_pending()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(ACTION_PAUSE, false):
		_close()
	elif event.is_action_pressed(ACTION_NEXT, false):
		_next_armed = true
	elif event.is_action_released(ACTION_NEXT) and _next_armed:
		_next_armed = false
		_advance()
	get_viewport().set_input_as_handled()


## Ouvre le premier message en file si rien ne s'y oppose ; coupe la relecture
## de la file quand elle est vide ou qu'un message est affiché.
func _open_next_pending() -> void:
	if visible or _pending.is_empty():
		set_process(false)
		return
	if UiModal.is_other_open(self) or not GameState.is_drill_operational():
		return
	_open(_pending.pop_front())
	set_process(not visible and not _pending.is_empty())


func _open(event_id: String) -> void:
	_lines = GameData.get_event_lines(event_id)
	if _lines.is_empty():
		return
	_speaker.text = GameData.get_event_speaker_name(event_id)
	_next_key.text = KEY_FORMAT % ActionKeyLabel.for_action(ACTION_NEXT)
	_skip_key.text = KEY_FORMAT % ActionKeyLabel.for_action(ACTION_PAUSE)
	_line_index = 0
	_next_armed = false
	_show_line()
	visible = true
	UiModal.sync_pause(get_tree())


func _show_line() -> void:
	var last: bool = _line_index == _lines.size() - 1
	_line.text = _lines[_line_index]
	_progress.text = PROGRESS_FORMAT % [_line_index + 1, _lines.size()]
	_next_caption.visible = not last
	_last_caption.visible = last
	_skip_hint.visible = not last


func _advance() -> void:
	_line_index += 1
	if _line_index >= _lines.size():
		_close()
		return
	_show_line()


## Ferme le message ; le suivant en file, s'il y en a un, s'ouvre aussitôt, sans
## rendre une image au jeu entre les deux.
func _close() -> void:
	visible = false
	_lines = PackedStringArray()
	_next_armed = false
	_open_next_pending()
	UiModal.sync_pause(get_tree())
