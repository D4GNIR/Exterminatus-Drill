extends Node
class_name AnomalyDetector

## Alerte « anomalie proche » — story 6.4 (CDC « Direction sonore » : alertes
## distinctes, dont « anomalie proche » ; arbitrage `Q71` (a), story 6.13).
##
## Signale l'**approche** de l'anomalie scénarisée : la foreuse entre dans le
## **rayon d'alerte** de la cellule d'ancrage, plus large que le rayon de
## déclenchement de l'événement narratif. Joue son propre son d'alerte et publie
## l'entrée et la sortie par signaux ; le HUD (story 4.2) affiche le bandeau.
##
## Contraintes de conception, opposables à l'audit :
## [br]— **Une seule responsabilité** : l'alerte. Le déclenchement de l'événement
## et la pose de son flag restent à `NarrativeSystem` (6.3), le décor à
## `AnomalyMarker` ; ce nœud n'écrit **aucun** flag ni état de `GameState`.
## [br]— **Aucun rayon ni coordonnée dans le code** (`D1`, `K3`) : rayon d'alerte,
## marge de sortie et événement visé viennent du bloc `alerte_anomalie_proche`
## de `data/events.json`, la position de l'ancrage de `data/generation.json`,
## par la façade `GameData` (`C3`). Même mesure que le déclenchement : distance
## du centre de la foreuse au centre de la cellule d'ancrage, en mètres.
## [br]— **Rayons cohérents par construction** : rayon d'alerte strictement
## supérieur au rayon de déclenchement, validé au chargement (`D2`) ; un bloc
## rejeté désactive l'alerte et le dit, jamais de rayon de repli.
## [br]— **Entrée stricte, sortie avec marge** : l'alerte s'allume à moins du
## rayon, s'éteint au-delà du rayon **plus** la marge — une foreuse qui oscille
## au bord ne rejoue pas le son à chaque image.
## [br]— **Muette une fois l'anomalie découverte** : l'alerte n'est donnée que
## tant que le flag de l'événement visé n'est pas posé ; au déclenchement, elle
## s'éteint et son son est coupé (le message radio prend le relais, `6.2`).
## [br]— **Aucun effet de jeu** (`Q16`, `I5`) : ni dégât, ni aléa, ni
## modification de la courbe de risque — ce n'est pas l'« Anomalie Warp » des
## « Dangers » du CDC principal, hors MVP. Aucun générateur tiré (`K2`, `M6`).
## [br]— **Pausable** (`process_mode` hérité) : rien n'est évalué pendant une
## modale, et son lecteur, enfant hérité, se tait avec le jeu.
## [br]— **Lecture de l'état publié** : placé **après** `DrillRig` et
## `NarrativeSystem` dans `Main.tscn` ; il lit donc la position de l'image
## courante et un flag posé à cette même image.
## [br]— **Son substituable sans code** : flux renseigné dans la scène
## (`scenes/world/AnomalyDetector.tscn`), fichier
## `assets/audio/sfx_alert_anomaly_near.wav` (`Q69` (a)).
## [br]— **Validation headless** : ce fichier référence les autoloads `GameData`
## et `GameState` — faux « Identifier not found » hors exécution du projet,
## exception `1.9`/`2.9`.

## Entrée de la foreuse dans le rayon d'alerte, anomalie non encore découverte.
signal anomaly_near()
## Fin de l'alerte : foreuse sortie du rayon (marge comprise) ou anomalie
## découverte.
signal anomaly_near_cleared()

@onready var _alert_audio: AudioStreamPlayer = $AlertAudio

## Flag de l'événement dont l'alerte annonce l'approche.
var _flag: String = ""
## Centre de la cellule d'ancrage de l'anomalie, en pixels monde.
var _anomaly_position: Vector2 = Vector2.ZERO
var _pixels_per_meter: float = 0.0
var _alert_radius_m: float = 0.0
var _clear_radius_m: float = 0.0
var _near: bool = false


func _ready() -> void:
	if not GameData.has_anomaly_alert():
		push_error("AnomalyDetector — alerte « anomalie proche » non chargée depuis %s : alerte inactive." % GameData.EVENTS_PATH)
		set_physics_process(false)
		return
	if not GameData.has_anchors():
		push_error("AnomalyDetector — ancrage de l'anomalie non chargé depuis %s : alerte inactive." % GameData.GENERATION_PATH)
		set_physics_process(false)
		return
	_pixels_per_meter = GameData.get_pixels_per_meter()
	if _pixels_per_meter <= 0.0:
		push_error("AnomalyDetector — conversion pixels/mètre indisponible (voir %s) : alerte inactive." % GameData.DRILL_PATH)
		set_physics_process(false)
		return
	if _alert_audio.stream == null:
		push_error("AnomalyDetector — son d'alerte non renseigné dans la scène : alerte muette.")
	_flag = GameData.get_event_flag(GameData.get_anomaly_alert_event_id())
	_anomaly_position = GameData.get_anomaly_center_position()
	_alert_radius_m = GameData.get_anomaly_alert_radius_m()
	_clear_radius_m = _alert_radius_m + GameData.get_anomaly_alert_exit_margin_m()


func _physics_process(_delta: float) -> void:
	_evaluate()


## État courant, pour un abonné branché après coup (HUD).
func is_anomaly_near() -> bool:
	return _near


func _evaluate() -> void:
	var discovered: bool = GameState.has_narrative_flag(_flag)
	var distance_m: float = GameState.get_drill_position().distance_to(_anomaly_position) / _pixels_per_meter
	if _near:
		if discovered or distance_m >= _clear_radius_m:
			_set_near(false)
	elif not discovered and distance_m < _alert_radius_m:
		_set_near(true)


func _set_near(near: bool) -> void:
	_near = near
	if near:
		_alert_audio.play()
		anomaly_near.emit()
	else:
		_alert_audio.stop()
		anomaly_near_cleared.emit()
