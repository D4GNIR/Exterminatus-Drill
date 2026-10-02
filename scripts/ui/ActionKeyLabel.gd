class_name ActionKeyLabel
extends RefCounted

## Libellé de la touche d'une action, **lu dans l'Input Map** — story 5.1.
##
## L'indication « Interagir » du HUD et l'interface de station affichent la
## touche de l'action `interact` (`Q62` (a)). Aucun libellé de touche n'est écrit
## dans une scène ni dans un script (`Q2`, `F1 [B]`) : la touche affichée suit
## l'Input Map de `project.godot`, et changerait avec elle.
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Lecture seule** de l'Input Map : aucune touche n'est comparée ni
## choisie ici. Les seuls accès aux champs de touche d'un événement servent à
## **nommer** la touche que l'Input Map déclare — c'est l'inverse d'une touche en
## dur, et la raison pour laquelle le contrôle par recherche de `F1` remonte ce
## fichier (Notes de la story 5.1).
## [br]— **Touche physique nommée dans la disposition du joueur** quand le
## serveur d'affichage la connaît (`Q2` : les actions sont déclarées en
## `physical_keycode`) : sur un clavier AZERTY, la touche physique de `move_up`
## s'affiche « Z ». Sans disposition connue — serveur `headless` —, le nom
## physique du moteur est rendu tel quel.
## [br]— Fonctions statiques, aucun état, aucun nœud.

## Libellé de la **première touche clavier** associée à l'action. Chaîne vide si
## l'action n'existe pas ou n'a aucune touche clavier : l'appelant décide de
## l'affichage, ce module ne signale rien.
static func for_action(action: StringName) -> String:
	if not InputMap.has_action(action):
		return ""
	for event: InputEvent in InputMap.action_get_events(action):
		var key_event: InputEventKey = event as InputEventKey
		if key_event != null:
			return _key_text(key_event)
	return ""


static func _key_text(key_event: InputEventKey) -> String:
	if key_event.physical_keycode != KEY_NONE:
		if DisplayServer.keyboard_get_layout_count() > 0:
			return OS.get_keycode_string(DisplayServer.keyboard_get_label_from_physical(key_event.physical_keycode))
		return key_event.as_text_physical_keycode()
	return key_event.as_text()
