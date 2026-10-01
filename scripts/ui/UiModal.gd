class_name UiModal
extends RefCounted

## Protocole des interfaces modales — story 4.4.
##
## Une interface modale (menu pause, inventaire, puis boutique et dialogue des
## phases 5 et 6) fige le jeu tant qu'elle est ouverte. Plusieurs modales
## coexistent sous `UI` : si chacune posait et levait `get_tree().paused` pour
## son compte, la fermeture de l'une relancerait le jeu alors qu'une autre reste
## ouverte. Ce protocole en fait **une seule source de vérité** :
## [br]— **La pause est dérivée, jamais posée à la main** : `sync_pause()` met
## `get_tree().paused` à « au moins une modale ouverte », en relisant l'état de
## toutes les modales. Ni compteur à incrémenter, ni propriétaire à mémoriser :
## rien ne peut dériver, et `paused` est toujours cohérent avec les modales
## (`H3`, `H4`).
## [br]— **Une modale est un `CanvasItem` du groupe `GROUP`**, ouverte quand elle
## est visible. Elle rejoint le groupe dans son `_ready()` et appelle
## `sync_pause()` après chaque ouverture et chaque fermeture.
## [br]— **Une seule modale à la fois** : une modale ne s'ouvre pas si
## `is_other_open()` est vrai. Celle qui est ouverte se referme sur l'action
## `pause` ; la modale du menu pause lui laisse donc cet appui au lieu de s'ouvrir
## par-dessus.
## [br]— Aucun état propre : fonctions statiques sur l'arbre, aucun chemin de
## nœud (`C1`), aucune entrée lue ici.

## Groupe des interfaces modales sous `UI`.
const GROUP: StringName = &"ui_modal"


## Vrai si une modale **autre que** `modal` est ouverte.
static func is_other_open(modal: CanvasItem) -> bool:
	for node: Node in modal.get_tree().get_nodes_in_group(GROUP):
		if node != modal and (node as CanvasItem).visible:
			return true
	return false


## Fige le jeu si au moins une modale est ouverte, le relance sinon.
static func sync_pause(tree: SceneTree) -> void:
	var any_open: bool = false
	for node: Node in tree.get_nodes_in_group(GROUP):
		if (node as CanvasItem).visible:
			any_open = true
			break
	tree.paused = any_open
