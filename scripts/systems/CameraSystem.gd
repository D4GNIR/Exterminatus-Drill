extends Camera2D

## Caméra de suivi — story 2.4.
##
## Suit la foreuse de façon amortie et **borne la vue aux limites de la carte**,
## pour qu'aucun bord ne dévoile le hors-monde (CDC « Vision » et « Règles
## interdites ou limitées »).
##
## Contraintes de conception, opposables à l'audit :
## [br]— **La caméra reste dans `Main.tscn`**, à la place que lui donne l'arbre
## contractuel du CDC, et c'est **elle** qui va chercher sa cible. La rattacher
## comme enfant de `DrillRig` aurait supprimé ce script, mais aurait ajouté un
## nœud à l'arbre **contractuel** de `DrillRig.tscn`, figé à 11 nœuds par la
## story 2.1 — l'arbre du CDC primait sur l'économie d'un fichier.
## [br]— **Aucun chemin de nœud en dur** (`C1`) : la cible est un `@export`
## renseigné dans la scène (`C2`), donc modifiable sans toucher au code.
## [br]— **Aucune valeur de gameplay ni de cadrage en dur** (`D1`/`D4`) :
## amortissement, zoom et bords viennent de `data/drill.json`.
## [br]— **Rien de lourd par frame** (`H6`) : le suivi ne fait qu'une affectation
## de position ; tous les réglages sont lus une fois, dans `_ready()`.
## [br]— **Validation headless** : ce fichier référence l'autoload `GameData` —
## faux « Identifier not found » en `--check-only`, exception de la story 1.9.

## Chemin du nœud suivi, renseigné dans `Main.tscn`. Un `NodePath` et non un
## `Node2D` : un export typé nœud n'est résolu par le moteur que si la scène
## porte la table `node_paths` que **l'éditeur** écrit, ce qu'un `.tscn` rédigé à
## la main n'a pas — l'export resterait vide au démarrage. Le `NodePath` est la
## forme explicitement admise par le point d'audit `C2`, et le chemin reste une
## **donnée de scène**, jamais un littéral du code (`C1`).
@export var target_path: NodePath

## Cible résolue une fois pour toutes : résoudre le chemin à chaque frame serait
## un travail inutile dans une boucle physique (`H6`).
var _target: Node2D = null


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node2D
	if _target == null:
		push_error("CameraSystem — cible introuvable ou non Node2D (« %s ») : suivi désactivé." % target_path)
		set_physics_process(false)
		return
	if not GameData.has_camera_settings() or not GameData.has_world_bounds():
		push_error("CameraSystem — réglages de caméra ou bords de carte non chargés depuis %s : suivi désactivé." % GameData.DRILL_PATH)
		set_physics_process(false)
		return

	enabled = true
	# La cible se déplace dans `_physics_process()` : amortir dans la même boucle
	# évite le décalage d'une frame qui se verrait comme un tremblement.
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	position_smoothing_enabled = true
	position_smoothing_speed = GameData.get_camera_smoothing()
	var factor: float = GameData.get_camera_zoom()
	zoom = Vector2(factor, factor)

	var bounds: Rect2 = GameData.get_world_bounds()
	limit_left = int(bounds.position.x)
	limit_top = int(bounds.position.y)
	limit_right = int(bounds.end.x)
	limit_bottom = int(bounds.end.y)
	_warn_if_view_exceeds_bounds(bounds, factor)

	# Cadrer immédiatement sur la foreuse : sans cela, la première seconde de jeu
	# serait un travelling depuis l'origine, que l'amortissement rendrait lent.
	global_position = _target.global_position
	reset_smoothing()


func _physics_process(_delta: float) -> void:
	global_position = _target.global_position


## Godot ignore une limite plus étroite que la vue : la caméra se recentre et
## montre alors le hors-carte, précisément ce que le critère interdit. Le cas ne
## vient pas d'un bug mais d'un réglage de données, donc il est signalé ici, avec
## les champs à corriger.
func _warn_if_view_exceeds_bounds(bounds: Rect2, factor: float) -> void:
	var visible_size: Vector2 = get_viewport_rect().size / factor
	if bounds.size.x < visible_size.x:
		push_error("CameraSystem — carte trop étroite (%.0f px) pour la vue (%.0f px) : élargir « %s »/« %s » ou augmenter « %s » dans %s." % [
			bounds.size.x, visible_size.x, GameData.KEY_WORLD_LEFT, GameData.KEY_WORLD_RIGHT, GameData.KEY_CAMERA_ZOOM, GameData.DRILL_PATH,
		])
	if bounds.size.y < visible_size.y:
		push_error("CameraSystem — carte trop basse (%.0f px) pour la vue (%.0f px) : élargir « %s »/« %s » ou augmenter « %s » dans %s." % [
			bounds.size.y, visible_size.y, GameData.KEY_WORLD_TOP, GameData.KEY_WORLD_BOTTOM, GameData.KEY_CAMERA_ZOOM, GameData.DRILL_PATH,
		])
