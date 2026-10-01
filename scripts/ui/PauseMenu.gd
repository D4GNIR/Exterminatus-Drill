extends Control

## Menu pause — story 4.3.
##
## Porte l'action `pause` du CDC (« Contrôles » : `Échap`, menu pause) : un appui
## ouvre le menu et fige le jeu (`get_tree().paused = true`), un second appui ou
## l'entrée « Reprendre » le referme et relance le jeu. « Quitter le jeu » ferme
## l'application.
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Lecture en `_unhandled_input()`** (`F4 [B]`), **jamais** en `_input()`
## (`F5 [B]`, arbitrage Q10) : un bouton qui a le focus traite `ui_accept` et
## `ui_up`/`ui_down` **avant** ce gestionnaire ; `Échap`, qu'aucun bouton ne
## consomme, arrive ici. L'événement est déclaré traité (`F6`) : aucun second
## gestionnaire ne le reçoit, ni `ui_cancel` (même touche) ni une action de jeu.
## Menu ouvert, **tout** événement non traité par les boutons est consommé.
## [br]— **Un appui, une bascule** (volet `echo` de `TM-1.5`) : la répétition
## clavier d'un `Échap` maintenu est ignorée (`allow_echo = false`).
## [br]— **Monde figé par le `process_mode`, pas par ce script** : ce nœud vit sous
## `UI` (`PROCESS_MODE_ALWAYS`, story 1.6) et en hérite, donc il répond pendant la
## pause ; `World`, `DrillRig` et `Camera2D` héritent du mode pausable de la
## racine et cessent tout traitement. Table complète en Notes de la story 4.3.
## [br]— **Aucune sauvegarde** (`H7 [B]`, Q7) : « Quitter le jeu » quitte, sans rien
## écrire. Les entrées de sauvegarde (`7.1`) et la confirmation de sortie (`7.4`)
## sont des points d'extension de la phase 7, absents ici.
## [br]— **Aucune apparence dans le code**, aucun libellé de touche : styles du
## thème unique `scenes/ui/UiTheme.tres` (`Q48`), libellés dans la scène.
## [br]— **Modale parmi d'autres** (story 4.4, protocole `UiModal`) : le menu ne
## pose plus `get_tree().paused` lui-même, il le fait **dériver** de l'état de
## toutes les modales. Si une autre modale (l'inventaire) est ouverte, l'appui sur
## `pause` lui est **laissé** — elle se referme — au lieu d'ouvrir le menu
## par-dessus : une seule modale à la fois, et fermer l'une ne relance jamais le
## jeu tant qu'une autre reste ouverte.

const ACTION_PAUSE: StringName = &"pause"

@onready var _resume_button: Button = %ResumeButton
@onready var _quit_button: Button = %QuitButton


## « Reprendre » ferme en **différé** : le bouton valide au relâchement
## (`ACTION_MODE_BUTTON_RELEASE`), et ce relâchement poursuit sa propagation
## jusqu'à `_unhandled_input()`. Le menu, encore ouvert à cet instant, le
## consomme : aucun relâchement orphelin d'`Espace` ou du clic n'atteint le jeu.
func _ready() -> void:
	visible = false
	add_to_group(UiModal.GROUP)
	_resume_button.pressed.connect(_close, CONNECT_DEFERRED)
	_quit_button.pressed.connect(_on_quit_pressed)


## Seul l'appui **franc** bascule ; sa répétition (`echo`) et son relâchement sont
## néanmoins consommés, comme tout événement que les boutons n'ont pas traité
## pendant que le menu est ouvert : rien ne passe derrière une interface modale
## (`F6`, CDC « Règles interdites ou limitées »). Seule exception : l'appui franc
## sur `pause` alors qu'une autre modale est ouverte n'est **pas** consommé, pour
## que cette modale le reçoive et se referme.
func _unhandled_input(event: InputEvent) -> void:
	var was_open: bool = visible
	if event.is_action_pressed(ACTION_PAUSE, false):
		if was_open:
			_close()
		elif UiModal.is_other_open(self):
			return
		else:
			_open()
	if was_open or event.is_action(ACTION_PAUSE):
		get_viewport().set_input_as_handled()


## Le focus clavier est posé sur « Reprendre » : les actions `ui_*` naviguent et
## valident d'emblée, sans passage par la souris.
func _open() -> void:
	visible = true
	UiModal.sync_pause(get_tree())
	_resume_button.grab_focus()


## Masquer le menu lui retire le focus : hors pause, aucun bouton ne capte plus
## `Espace` ni les flèches, rendus au forage et au déplacement.
func _close() -> void:
	visible = false
	UiModal.sync_pause(get_tree())


func _on_quit_pressed() -> void:
	get_tree().quit()
