extends Node2D
class_name DrillFeedback

## Retour audiovisuel du forage — story 3.7, amendement §2.4.
##
## Une seule responsabilité (`B4`) : **montrer** ce que `MiningSystem` signale. Il
## ne décide de rien, ne lit aucune entrée et ne touche à aucun état de partie.
##
## - **Progression du forage** (critère 1, `TM-3.10`) : des fissures apparaissent
##   sur la tuile visée et s'opacifient au rythme exact du forage, des débris
##   s'en échappent. La tuile ne disparaît donc jamais sans avoir été « attaquée »
##   à l'écran.
## - **Rareté haute** (critères 3, 4 ; arbitrages `Q35`, `Q36`) : sur un **drop
##   tiré** dont l'entrée de loot est marquée `rarete_haute` en données, une
##   lumière et une gerbe d'étincelles restent visibles pendant `duree_jackpot_s`
##   (`data/drill.json`), et un son **distinct** du son de forage est joué. Une
##   tuile de minerai ne déclenche **jamais** ce retour : `loot_dropped` n'est émis
##   que pour un gain tiré.
##
## Contraintes, opposables à l'audit `3.8` :
## [br]— **Diégétique, pas de HUD** (critère 5) : tout vit dans le monde.
## [br]— **Hors de l'arbre contractuel** (critère 6) : scène d'effet instanciée au
## démarrage sous `World`, par `DrillRig` ; ni `DrillRig.tscn` ni `World.tscn` ne
## gagnent de nœud.
## [br]— **Aucune ressource chargée en boucle** (critère 7, `H6`) : textures et sons
## sont des ressources de la scène, chargées avec elle.
## [br]— **Aucune valeur d'apparence dans le code** : couleurs, tailles, quantités
## de particules et intensité de lumière sont des propriétés de la scène
## `DrillFeedback.tscn` ; la seule durée de gameplay vient des données (`D1`).
## [br]— **Validation headless** : ce fichier référence l'autoload `GameData` —
## faux « Identifier not found » en `--check-only`, exception `1.9`.

@onready var _cracks: Sprite2D = $Cracks
@onready var _debris: CPUParticles2D = $Debris
@onready var _jackpot: Node2D = $Jackpot
@onready var _light: PointLight2D = $Jackpot/Light
@onready var _sparks: CPUParticles2D = $Jackpot/Sparks
@onready var _rare_drop_audio: AudioStreamPlayer2D = $RareDropAudio

var _drilling: bool = false
var _elapsed: float = 0.0
var _duration: float = 0.0
## Intensité de la lumière de jackpot telle que réglée dans la scène : elle
## décroît de cette valeur à zéro sur la durée du retour.
var _light_energy: float = 0.0
var _jackpot_duration: float = 0.0
var _jackpot_left: float = 0.0


func _ready() -> void:
	_light_energy = _light.energy
	_cracks.visible = false
	_jackpot.visible = false
	_debris.emitting = false
	if GameData.has_feedback_settings():
		_jackpot_duration = GameData.get_jackpot_duration()
	else:
		push_error("DrillFeedback — durée du retour de rareté non chargée depuis %s : retour « jackpot » désactivé." % GameData.DRILL_PATH)
	set_process(false)


## Branché par `DrillRig` sur le `MiningSystem` de la foreuse (`C4`).
func bind(mining: MiningSystem) -> void:
	mining.drilling_started.connect(_on_drilling_started)
	mining.drilling_stopped.connect(_on_drilling_stopped)
	mining.loot_dropped.connect(_on_loot_dropped)


func _on_drilling_started(_cell: Vector2i, _direction: Vector2i, cell_center: Vector2, duration: float, _resource_id: String) -> void:
	_cracks.global_position = cell_center
	_cracks.modulate.a = 0.0
	_cracks.visible = true
	_debris.global_position = cell_center
	_debris.emitting = true
	_elapsed = 0.0
	_duration = duration
	_drilling = true
	set_process(true)


func _on_drilling_stopped() -> void:
	_drilling = false
	_cracks.visible = false
	_debris.emitting = false
	set_process(_jackpot_left > 0.0)


func _on_loot_dropped(_cell: Vector2i, cell_center: Vector2, entry_id: String, _resource_id: String) -> void:
	if _jackpot_duration <= 0.0 or not GameData.is_loot_entry_high_rarity(entry_id):
		return
	_jackpot.global_position = cell_center
	_jackpot.visible = true
	_light.energy = _light_energy
	_sparks.restart()
	_rare_drop_audio.global_position = cell_center
	_rare_drop_audio.play()
	_jackpot_left = _jackpot_duration
	set_process(true)


func _process(delta: float) -> void:
	if _drilling:
		_elapsed += delta
		_cracks.modulate.a = clampf(_elapsed / _duration, 0.0, 1.0)
	if _jackpot_left > 0.0:
		_jackpot_left -= delta
		_light.energy = _light_energy * maxf(_jackpot_left, 0.0) / _jackpot_duration
		if _jackpot_left <= 0.0:
			_jackpot.visible = false
	if not _drilling and _jackpot_left <= 0.0:
		set_process(false)
