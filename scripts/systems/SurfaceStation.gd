extends Node2D

## Station de surface dans le monde — story 5.1, arbitrage `Q55` (a).
##
## Représente à l'écran le lieu où le joueur revient. **Décor seul** : aucune
## collision, aucune entrée lue, aucune règle. L'accès à la station est jugé sur
## la zone de surface des ancrages (publiée par la foreuse dans `GameState`) et
## l'interface s'ouvre sous `UI/Shop` ; ce nœud ne connaît ni l'une ni l'autre.
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Position dérivée des ancrages** (`D1`, `K3`) : milieu de la zone de
## surface, sur la ligne de surface (`GameData.get_station_ground_position()`).
## Aucune colonne, rangée ni coordonnée écrite ici ni dans la scène ; graine
## changée, même place.
## [br]— **Image substituable sans code** : le pied de l'image est posé sur la
## ligne de surface d'après la **hauteur de la texture**, lue à l'exécution.
## Remplacer `assets/sprites/prop_surface_station.png` par une image d'une autre
## taille ne demande de toucher ni à ce script ni à la scène.
## [br]— Sans ancrage chargé, la station n'est pas affichée et l'erreur est
## signalée — jamais de position de repli inventée (même règle que `DrillRig`).
## [br]— **Validation headless** : ce fichier référence l'autoload `GameData` —
## faux « Identifier not found » hors exécution du projet, exception `1.9`/`2.9`.

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if not GameData.has_anchors():
		push_error("SurfaceStation — aucun ancrage chargé depuis %s : station non affichée." % GameData.GENERATION_PATH)
		visible = false
		return
	if _sprite.texture == null:
		push_error("SurfaceStation — image de la station non renseignée dans la scène : station invisible.")
		return
	global_position = GameData.get_station_ground_position()
	_sprite.centered = true
	_sprite.offset = Vector2(0.0, -_sprite.texture.get_size().y * 0.5)
