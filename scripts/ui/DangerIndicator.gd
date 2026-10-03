extends CanvasLayer

## Indicateur de danger progressif **non chiffré** — story 6.8 (amendement §4.3).
##
## Fait **sentir** la montée du danger avec la profondeur, sans jamais l'écrire :
## une **teinte d'écran** (voile uniforme léger et assombrissement teinté des
## bords, centre laissé clair) et une **ambiance sonore en boucle** évoluent par
## palier de profondeur, avec un **fondu** à chaque changement. Les paliers profonds
## portent les « chœurs graves » de la « Direction sonore » du CDC principal.
##
## Contraintes de conception, opposables à l'audit `6.9` :
## [br]— **`M5`, `Q17` — aucun chiffre** : ce nœud n'a ni `Label` ni texte ; il ne
## lit ni probabilité ni profondeur, seulement l'`id` du palier.
## [br]— **`C3`, `Q30` — consommateur du palier publié** : abonné à
## `GameState.depth_layer_changed`, lecture initiale par
## `GameState.get_depth_layer_id()` — la même source que la courbe de risque
## (`6.6`) et le message de zone (`6.1`), hystérésis comprise. **Aucun calcul de
## palier ni de profondeur ici.**
## [br]— **`D1` — tout en données** : teinte, opacités, flux, volume et durée du
## fondu viennent du bloc `indicateur_danger` de `data/generation.json`, par
## `GameData`. Aucune couleur ni volume en dur ; la forme du dégradé des bords est
## une ressource de la scène. Un palier peut n'avoir **aucune** ambiance (chemin
## vide) : c'est le cas du premier, le palier sûr, dont le silence fait contraste.
## [br]— **Transition graduelle** (`TM-6.9`) : au changement de palier, la teinte
## glisse de sa valeur **affichée** vers celle du nouveau palier (courbe douce), et
## les deux ambiances se croisent (l'une monte, l'autre s'éteint) pendant
## `duree_transition_s`. Un changement survenant **pendant** un fondu repart des
## valeurs affichées : aucun saut.
## [br]— **Pause et modales** (`H3`, `H4`) : ce nœud vit **hors** de `UI`, enfant de
## `Main`, et hérite donc du mode **pausable** du monde. Pendant la pause ou une
## modale (`get_tree().paused`), la teinte reste figée à sa valeur affichée, le
## fondu en cours est suspendu et les ambiances sont mises en pause par le moteur ;
## à la reprise, tout repart de l'instant exact où il s'était arrêté.
## [br]— **Lisibilité** : `CanvasLayer` de même couche que `UI` mais placé
## **avant** elle dans `Main` — il se dessine au-dessus du monde et **sous** le HUD,
## les alertes et les modales. Ses `Control` sont en `mouse_filter = IGNORE` : il
## ne capte aucune entrée, et ne lit aucune entrée (`F5`).
## [br]— **Aucun aléa** : ni tirage, ni générateur (`K2`, `M6`).
## [br]— **Sondage limité au fondu** : `_process()` n'est actif que pendant une
## transition.
## [br]— **Validation headless** : ce fichier référence les autoloads `GameData` et
## `GameState` — faux « Identifier not found » hors exécution du projet,
## exception `1.9`/`2.9`.

## Silence de Godot, en décibels : volume d'un lecteur éteint.
const SILENCE_DB: float = -80.0

@onready var _veil: ColorRect = $Veil
@onready var _edges: TextureRect = $Edges
@onready var _player_a: AudioStreamPlayer = $AmbienceA
@onready var _player_b: AudioStreamPlayer = $AmbienceB

## Palier affiché (ou en cours d'affichage) : `id` de `couches_profondeur`.
var _layer_id: String = ""
var _duration: float = 0.0
var _elapsed: float = 0.0
var _veil_from: Color = Color(0.0, 0.0, 0.0, 0.0)
var _veil_to: Color = Color(0.0, 0.0, 0.0, 0.0)
var _edge_from: Color = Color(0.0, 0.0, 0.0, 0.0)
var _edge_to: Color = Color(0.0, 0.0, 0.0, 0.0)
## Les deux lecteurs du fondu enchaîné ; `_active` joue l'ambiance du palier courant.
var _players: Array[AudioStreamPlayer] = []
var _active: int = 0
## Gain **linéaire** courant, de départ et visé de chaque lecteur.
var _gain: Array[float] = [0.0, 0.0]
var _gain_from: Array[float] = [0.0, 0.0]
var _gain_to: Array[float] = [0.0, 0.0]
## Flux chargés une fois, par chemin.
var _streams: Dictionary[String, AudioStream] = {}


func _ready() -> void:
	_players = [_player_a, _player_b]
	_veil.color = _veil_from
	_edges.self_modulate = _edge_from
	for player: AudioStreamPlayer in _players:
		player.volume_db = SILENCE_DB
	set_process(false)
	if not GameData.has_danger_indicator_settings():
		push_error("DangerIndicator — bloc « indicateur_danger » absent ou rejeté (voir %s) : indicateur neutre et muet." % GameData.GENERATION_PATH)
		return
	_duration = GameData.get_danger_transition_duration()
	GameState.depth_layer_changed.connect(_on_depth_layer_changed)
	# Partie en cours : la teinte du palier est posée d'emblée (aucun palier
	# « précédent » à quitter) ; l'ambiance, elle, monte du silence.
	var layer_id: String = GameState.get_depth_layer_id()
	if layer_id.is_empty():
		return
	_layer_id = layer_id
	_veil_from = GameData.get_danger_veil_color(layer_id)
	_edge_from = GameData.get_danger_edge_color(layer_id)
	_start_transition(layer_id)


## Déconnexion (`C5`) et arrêt des boucles : une lecture laissée en cours à la
## sortie de l'arbre resterait détenue par le serveur audio (fuite à la fermeture).
func _exit_tree() -> void:
	if GameState.depth_layer_changed.is_connected(_on_depth_layer_changed):
		GameState.depth_layer_changed.disconnect(_on_depth_layer_changed)
	for player: AudioStreamPlayer in _players:
		player.stop()


func _process(delta: float) -> void:
	_advance(delta)


## Palier publié par `GameState` : seul déclencheur d'une transition.
func _on_depth_layer_changed(layer_id: String) -> void:
	if layer_id == _layer_id or layer_id.is_empty():
		return
	_layer_id = layer_id
	_veil_from = _veil.color
	_edge_from = _edges.self_modulate
	_start_transition(layer_id)


## Fixe les cibles du palier et lance le fondu depuis les valeurs **affichées**.
func _start_transition(layer_id: String) -> void:
	_veil_to = GameData.get_danger_veil_color(layer_id)
	_edge_to = GameData.get_danger_edge_color(layer_id)
	var stream: AudioStream = _stream_for(GameData.get_danger_ambience_path(layer_id))
	var target: float = db_to_linear(GameData.get_danger_ambience_volume_db(layer_id))
	var current: AudioStreamPlayer = _players[_active]
	if stream != null and current.stream == stream and current.playing:
		# Même flux : seul son volume change ; l'autre lecteur achève de s'éteindre.
		_retarget(_active, target)
	else:
		# Fondu enchaîné : le lecteur le plus discret reprend le nouveau flux, du
		# silence ; l'autre s'éteint depuis son volume courant.
		var incoming: int = 1 - _active if _gain[1 - _active] <= _gain[_active] else _active
		var outgoing: int = 1 - incoming
		var player: AudioStreamPlayer = _players[incoming]
		player.stop()
		player.stream = stream
		_gain[incoming] = 0.0
		player.volume_db = SILENCE_DB
		if stream != null:
			player.play()
		_gain_from[incoming] = 0.0
		_gain_to[incoming] = target if stream != null else 0.0
		_retarget(outgoing, 0.0)
		_active = incoming
	_elapsed = 0.0
	set_process(true)


func _retarget(index: int, target: float) -> void:
	_gain_from[index] = _gain[index]
	_gain_to[index] = target


## Avance le fondu de `delta` secondes. Teinte : courbe douce (`smoothstep`) ;
## ambiances : interpolation du gain linéaire. Fin du fondu : valeurs cibles
## exactes, lecteur éteint arrêté, sondage coupé.
func _advance(delta: float) -> void:
	_elapsed = minf(_elapsed + delta, _duration)
	var progress: float = _elapsed / _duration
	var weight: float = smoothstep(0.0, 1.0, progress)
	_veil.color = _veil_from.lerp(_veil_to, weight)
	_edges.self_modulate = _edge_from.lerp(_edge_to, weight)
	for index: int in _players.size():
		_gain[index] = lerpf(_gain_from[index], _gain_to[index], progress)
		_players[index].volume_db = maxf(linear_to_db(_gain[index]), SILENCE_DB) if _gain[index] > 0.0 else SILENCE_DB
	if _elapsed < _duration:
		return
	for index: int in _players.size():
		if _gain_to[index] <= 0.0:
			_players[index].stop()
	set_process(false)


## Flux chargé une seule fois ; `null` pour un palier sans ambiance (chemin vide
## en données : le premier palier, sûr, est silencieux). Le chemin a été validé au chargement des données
## (`DangerIndicatorSettings`) : un échec ici est une erreur bruyante, l'ambiance
## du palier reste muette, la teinte n'en dépend pas.
func _stream_for(path: String) -> AudioStream:
	if path.is_empty():
		return null
	if _streams.has(path):
		return _streams[path]
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		push_error("DangerIndicator — flux d'ambiance illisible : « %s »." % path)
	_streams[path] = stream
	return stream
