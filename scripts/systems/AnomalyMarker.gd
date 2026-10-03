extends Node2D
class_name AnomalyMarker

## Représentation visible de l'anomalie scénarisée — story 6.4 (CDC « MVP
## jouable », point 7 ; arbitrages `Q69` (a), `Q71` (a)).
##
## **Décor seul**, comme la station de surface (story 5.1) : aucune collision,
## aucune entrée lue, aucune règle, aucun état. Le déclenchement de l'événement
## relève de `NarrativeSystem` (6.3), l'alerte de proximité d'`AnomalyDetector`.
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Position dérivée de l'ancrage** (`D1`, `K3 [B]`) : centre de la cellule
## d'ancrage de l'anomalie (`GameData.get_anomaly_center_position()`), identique
## pour toute graine. Aucune colonne, rangée ni coordonnée écrite ici ni dans la
## scène ; la cellule reste sans minerai (`Q28`, story 3.3).
## [br]— **Image substituable sans code** : sprite centré sur la cellule, quelle
## que soit la taille de `assets/sprites/prop_anomaly_necropolis.png`.
## [br]— **Placé sous `World/DecorationsLayer`** : dessiné par-dessus le terrain,
## sous la foreuse (ordre de l'arbre), comme la station.
## [br]— **Aucun effet de jeu** (`Q16`, `I5`) : ce n'est pas l'« Anomalie Warp »
## des « Dangers » du CDC principal, hors MVP.
## [br]— Sans ancrage chargé, l'anomalie n'est pas affichée et l'erreur est
## signalée — jamais de position de repli inventée (même règle que `DrillRig`).
## [br]— **Validation headless** : ce fichier référence l'autoload `GameData` —
## faux « Identifier not found » hors exécution du projet, exception `1.9`/`2.9`.

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if not GameData.has_anchors():
		push_error("AnomalyMarker — aucun ancrage chargé depuis %s : anomalie non affichée." % GameData.GENERATION_PATH)
		visible = false
		return
	if _sprite.texture == null:
		push_error("AnomalyMarker — image de l'anomalie non renseignée dans la scène : anomalie invisible.")
	_sprite.centered = true
	global_position = GameData.get_anomaly_center_position()
