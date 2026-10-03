extends PanelContainer

## Indication contextuelle « Interagir » du HUD — story 5.1, arbitrage `Q62` (a).
##
## Dit au joueur, quand la foreuse est dans la zone de surface, qu'il peut ouvrir
## la station, et par quelle touche. Elle porte sur la **station seule** : ce
## n'est pas un système générique d'invites (non-anticipation, `5.13`).
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Visible si et seulement si** la foreuse est en zone de surface
## (`GameState.surface_zone_changed`, zone lue dans les ancrages par la foreuse,
## `K3`), que la foreuse est opérationnelle (hors transition de destruction,
## `GameState.drill_operational_changed`, story 6.7) **et** que le jeu n'est pas figé. Le jeu n'est figé que par une modale
## ouverte — `UiModal.sync_pause()` est le seul écrivain de `paused` (story 4.4) :
## station ouverte, inventaire ou menu pause ouverts, l'indication disparaît.
## [br]— **Aucun sondage par image** : ce nœud est en `PROCESS_MODE_PAUSABLE`
## (posé dans `HUD.tscn`) sous `UI`, qui est en `ALWAYS`. Il reçoit donc
## `NOTIFICATION_PAUSED` / `NOTIFICATION_UNPAUSED` à chaque bascule de la pause,
## et c'est là qu'il se réévalue. Il ne traite rien d'autre : le mode pausable ne
## fige aucune logique.
## [br]— **Touche lue dans l'Input Map** (`ActionKeyLabel`, `Q2`, `F1 [B]`),
## relue à chaque réévaluation : un remappage s'afficherait sans relancer.
## [br]— **Aucune apparence dans le code** (`Q48`) : cadre, police et couleur de la
## touche viennent de `UiTheme.tres` ; le libellé « Interagir » est dans la scène.
## [br]— **Validation headless** : ce fichier référence l'autoload `GameState` —
## faux « Identifier not found » hors exécution du projet, exception `1.9`/`2.9`.

const ACTION_INTERACT: StringName = &"interact"
## Encadrement de la touche affichée, le seul texte composé ici.
const KEY_FORMAT: String = "[ %s ]"

@onready var _key_label: Label = $Row/Key


func _ready() -> void:
	GameState.surface_zone_changed.connect(_on_surface_zone_changed)
	GameState.drill_operational_changed.connect(_on_drill_operational_changed)
	if ActionKeyLabel.for_action(ACTION_INTERACT).is_empty():
		push_error("InteractHint — action « %s » sans touche clavier dans l'Input Map : indication sans touche." % ACTION_INTERACT)
	_refresh()


## `GameState` est un autoload : il survit au HUD (même règle que `HUD.gd`, `C5`).
func _exit_tree() -> void:
	GameState.surface_zone_changed.disconnect(_on_surface_zone_changed)
	GameState.drill_operational_changed.disconnect(_on_drill_operational_changed)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED or what == NOTIFICATION_UNPAUSED:
		_refresh()


func _on_surface_zone_changed(_in_zone: bool) -> void:
	_refresh()


func _on_drill_operational_changed(_operational: bool) -> void:
	_refresh()


func _refresh() -> void:
	visible = GameState.is_in_surface_zone() and GameState.is_drill_operational() and not get_tree().paused
	if visible:
		_key_label.text = KEY_FORMAT % ActionKeyLabel.for_action(ACTION_INTERACT)
