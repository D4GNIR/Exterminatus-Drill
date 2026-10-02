extends RefCounted
class_name CargoSystem

## Collecte des minerais et soute limitée — story 3.5, arbitrage `Q5`.
##
## Porte **la règle de soute** : ce qui entre, ce qui est perdu, et quand le
## joueur est averti. `GameState` porte **l'état** (contenu, capacité) et ne
## décide de rien (`C6`) ; `MiningSystem` **détruit et signale**, sans savoir ce
## que devient le minerai (`B4`). Aucun crédit n'est gagné ici : la soute stocke,
## la vente est l'objet de la story 5.2.
##
## Règles, opposables à l'audit `3.8` :
## [br]— **`Q28` — la tuile décide** : seule une tuile porteuse d'un `resource_id`
## est collectée. Une tuile stérile n'est pas l'affaire de la soute : elle passe
## par le tirage de loot de la story 3.6.
## [br]— **Quantité en données** (critère 7) : une tuile de minerai occupe
## `masse_soute` unités (`data/resources.json`). **Tout ou rien** : un minerai qui
## ne rentre pas **en entier** est perdu en entier — jamais de collecte partielle.
## [br]— **`Q5` — soute pleine : tuile détruite, minerai perdu**, forage jamais
## empêché. La soute ne dépasse jamais sa capacité (`G8`).
## [br]— **`G9 [B]` — l'alerte PRÉCÈDE toute perte**, par construction :
## `cargo_full` est émis (a) dès qu'une collecte laisse moins de place que le plus
## léger des minerais actifs — la soute est pleine, qu'une perte suive ou non —,
## et (b) au **début** du forage d'un minerai qui ne rentrera pas. Le forage
## commençant toujours avant la destruction, aucune perte ne peut précéder
## l'alerte. L'alerte n'est **jamais** conditionnée à la perte.
## [br]— **`G10` — la perte est observable** : signal `ore_lost` et compteur
## `get_lost_units()`, consommables par le HUD de la story 4.2.
## [br]— **`Q12`/`K10` — filtrage explicite** : une ressource `actif_mvp: false`
## n'entre jamais en soute, même si une tuile la portait par erreur de données.
## [br]— **Aucun traitement de faveur** (`TM-3.13`) : l'adamantium est perdu
## exactement comme le fer industriel.
## [br]— **Capacité suivie à l'achat** (story 5.5) : la soute écoute
## `GameState.upgrade_level_changed` et porte la capacité de `GameState` à la
## valeur du nouveau niveau de l'amélioration qui pilote `capacite_soute`
## (`GameData.get_upgrade_value()`, fonction de `5.6`), à la même image. Le
## contenu n'est pas touché ; le réarmement de l'alerte suit par `cargo_changed`.
##
## **Validation headless** : ce fichier référence les autoloads `GameData` et
## `GameState` — faux « Identifier not found » en `--check-only`, exception `1.9`.

## La soute ne peut plus accueillir de minerai (ou pas celui qu'on s'apprête à
## forer). Émis **une fois**, réarmé quand de la place se libère (vente, phase 5).
signal cargo_full()
## Fin de l'état « soute pleine » : un minerai peut de nouveau entrer (vente,
## amélioration de soute). Émis **une fois**, au réarmement de `cargo_full`
## (story 4.2, critère 9) : la règle de saturation reste ici, jamais dans l'UI.
signal cargo_full_cleared()
## Un minerai a été perdu faute de place (`Q5`) : `units` unités de `resource_id`,
## `total_lost` le cumul de la partie.
signal ore_lost(resource_id: String, units: int, total_lost: int)

## Masse du plus léger des minerais actifs : en deçà, plus aucun minerai ne peut
## entrer, la soute est pleine. Calculée une fois depuis le catalogue.
var _smallest_mass: int = 0
## Amélioration qui pilote `capacite_soute`, résolue une fois depuis le catalogue :
## aucun `id` d'amélioration n'est écrit ici.
var _capacity_upgrade_id: String = ""
var _full_alert_sent: bool = false
var _lost_units: int = 0


## Refuse de s'activer sans catalogue : une soute sans masses connues serait une
## soute sur des hypothèses. Renvoie `false` si aucune ressource active n'existe.
func setup() -> bool:
	_smallest_mass = 0
	for resource_id: String in GameData.get_mvp_resource_ids():
		var mass: int = GameData.get_resource_mass(resource_id)
		if _smallest_mass == 0 or mass < _smallest_mass:
			_smallest_mass = mass
	if _smallest_mass <= 0:
		push_error("CargoSystem — aucune ressource active de masse positive dans %s : soute désactivée." % GameData.RESOURCES_PATH)
		return false
	_bind_capacity_upgrade()
	GameState.cargo_changed.connect(_on_cargo_changed)
	# État initial constaté, jamais émis (même contrat que `FuelSystem`).
	_full_alert_sent = GameState.get_cargo_free_space() < _smallest_mass
	return true


## Story 5.5 — branche la capacité sur le niveau de l'amélioration qui porte
## `capacite_soute`, puis l'aligne sur le niveau **constaté** (sans effet en début
## de partie : la valeur du niveau de départ est la valeur de départ).
func _bind_capacity_upgrade() -> void:
	_capacity_upgrade_id = GameData.get_upgrade_id_for_statistic(GameData.STAT_CARGO_CAPACITY)
	if _capacity_upgrade_id.is_empty():
		push_error("CargoSystem — aucune amélioration ne porte « %s » : la soute ne suivra aucun achat." % GameData.STAT_CARGO_CAPACITY)
		return
	GameState.upgrade_level_changed.connect(_on_upgrade_level_changed)
	_apply_capacity(GameState.get_upgrade_level(_capacity_upgrade_id))


func _on_upgrade_level_changed(upgrade_id: String, level: int) -> void:
	if upgrade_id == _capacity_upgrade_id:
		_apply_capacity(level)


## La valeur est entière par construction (`valeur_depart` et `increment`
## entiers, story 5.6) : la conversion ne perd rien.
func _apply_capacity(level: int) -> void:
	GameState.set_cargo_capacity(int(GameData.get_upgrade_value(_capacity_upgrade_id, level)))


## Minerai perdu depuis le début de la partie, en unités de soute (`G10`).
func get_lost_units() -> int:
	return _lost_units


## L'alerte « soute pleine » est-elle en cours ? État **constaté**, lu par le HUD
## (story 4.2) à son initialisation.
func is_full_alert_active() -> bool:
	return _full_alert_sent


## (b) — Un forage commence. Si la tuile porte un minerai qui ne rentrera pas,
## l'alerte part **maintenant**, avant la destruction.
func on_drilling_started(resource_id: String) -> void:
	if not _is_collectable(resource_id):
		return
	if GameState.get_cargo_free_space() < GameData.get_resource_mass(resource_id):
		_alert_full()


## Une tuile a été détruite. Collecte, ou perte selon `Q5`.
func on_tile_drilled(resource_id: String) -> void:
	if resource_id.is_empty():
		return
	if not _is_collectable(resource_id):
		push_error("CargoSystem — « %s » n'est pas une ressource active du MVP (Q12) : non collectée." % resource_id)
		return
	var mass: int = GameData.get_resource_mass(resource_id)
	if GameState.get_cargo_free_space() < mass:
		_lost_units += mass
		ore_lost.emit(resource_id, mass, _lost_units)
		return
	GameState.set_cargo_units(resource_id, GameState.get_cargo_units(resource_id) + mass)
	# (a) — La soute vient de se remplir : l'alerte part tout de suite, qu'une
	# perte suive ou non.
	if GameState.get_cargo_free_space() < _smallest_mass:
		_alert_full()


func _is_collectable(resource_id: String) -> bool:
	return not resource_id.is_empty() and GameData.has_resource(resource_id) and GameData.is_resource_active_in_mvp(resource_id)


func _alert_full() -> void:
	if _full_alert_sent:
		return
	_full_alert_sent = true
	cargo_full.emit()


## Réarmement : dès qu'un minerai peut de nouveau entrer (vente, amélioration de
## soute), la prochaine saturation sera de nouveau annoncée.
func _on_cargo_changed(used: int, capacity: int) -> void:
	if capacity - used >= _smallest_mass and _full_alert_sent:
		_full_alert_sent = false
		cargo_full_cleared.emit()
