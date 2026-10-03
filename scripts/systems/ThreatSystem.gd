extends RefCounted
class_name ThreatSystem

## Courbe de risque et menaces par profondeur — story 6.6, amendement §4.1 et
## §4.2, arbitrages `Q17`, `Q20`, `Q67` (a).
##
## Une seule responsabilité (`B4`) : décider, à chaque tuile **réellement
## détruite** par le forage, si une **rencontre hostile** survient, et la faire
## encaisser par `ArmorSystem`. Il ne détruit rien (c'est `MiningSystem`), ne
## montre rien (le message est affiché par `AlertPanel`, le son et le retour
## visuel par `DrillFeedback`, abonnés à `threat_encountered`) et ne connaît
## aucune frontière de profondeur.
##
## **Emplacement** (`A3`, `Q25`) : `scripts/systems/`, comme `LootSystem` et
## `CargoSystem`. Objet et non nœud, détenu et branché par `DrillRig` comme
## `CargoSystem` : l'arbre de `DrillRig.tscn` est figé à 11 nœuds (story 2.1), et
## une rencontre n'a besoin ni de l'arbre ni d'un traitement par image.
##
## Contraintes, opposables à l'audit `6.9` :
## [br]— **`Q67` (a) — événement instantané** : la rencontre est résolue dans
## l'appel même qui signale la destruction de la tuile — dégâts, puis signal.
## **Aucune** scène, aucun nœud, aucun sprite de créature, aucun déplacement,
## aucune collision, aucun délai, aucune minuterie, aucun état « menace en
## cours » : ce système n'a pas d'autre état que son générateur.
## [br]— **`M6` — générateur dédié** : une instance `RandomNumberGenerator`
## **propre**, ensemencée **une fois** par la `graine` du bloc `menaces` (donnée,
## distincte de la graine de génération), journalisée au démarrage. Le terrain
## (`TerrainGenerator`) et le loot (`LootSystem`) ont chacun **leur** instance :
## une rencontre ne décale jamais le terrain à graine identique (`K2`).
## [br]— **Un tirage et un seul par tuile détruite** (critère 3) : abonné à
## `MiningSystem.tile_drilled`, émis **après** la destruction effective — jamais
## sur un forage refusé, abandonné, ni hors forage. Chaque tirage consomme
## **exactement un** `randf()`, rencontre ou non : à graine et suite de tuiles
## identiques, mêmes rencontres.
## [br]— **Palier : celui de la foreuse, publié par `GameState`** (`C3`, `Q30`,
## point de `6.1` et `6.14`) — `GameState.get_depth_layer_id()`, hystérésis
## comprise, le palier même que le message « Zone atteinte » annonce. Aucun
## second calcul de profondeur.
## [br]— **`M1` — dégâts par `ArmorSystem` seul** (`apply_threat()`) ; montant et
## probabilité en données (`M2`, `D1`). **`M4`** : aucun tirage pendant la
## transition de destruction ; en pause ou modale ouverte, le forage est
## suspendu avec l'arbre, donc aucune tuile n'est détruite et rien n'est tiré.
## [br]— **`Q16`** : ces menaces ne sont pas les « Dangers » du CDC principal ;
## la donnée de tuile `hazard_type` n'est pas lue.
##
## **Validation headless** : ce fichier référence les autoloads `GameData` et
## `GameState` — faux « Identifier not found » hors exécution du projet,
## exception `1.9`/`2.9`.

## Une rencontre vient d'être encaissée : `threat_id` est le type de menace du
## palier (données), `damage` les points retirés par `ArmorSystem`.
signal threat_encountered(threat_id: String, damage: float)

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _armor_system: ArmorSystem = null
## Rang du prochain tirage depuis l'ensemencement : il figure dans le journal des
## rencontres, pour qu'un testeur rejoue une séquence à graine identique.
var _draws: int = 0


## Refuse de s'activer sans courbe de risque valide (`GameData` a déjà nommé le
## champ fautif) : aucune rencontre plutôt qu'une probabilité inventée.
## Journalise la graine de menace (critère 1, `M6`).
func setup(armor_system: ArmorSystem) -> bool:
	if not GameData.has_threat_settings():
		push_error("ThreatSystem — courbe de risque non chargée depuis %s : aucune rencontre hostile." % GameData.GENERATION_PATH)
		return false
	_armor_system = armor_system
	_rng.seed = GameData.get_threat_seed()
	_draws = 0
	print("ThreatSystem — graine de menace : %d (générateur dédié, distinct du terrain et du loot) · un tirage par tuile détruite" % GameData.get_threat_seed())
	return true


## Branché sur `MiningSystem.tile_drilled` par `DrillRig`. La rencontre est
## résolue ici, dans l'instant : dégâts, journal, signal.
func on_tile_drilled(_cell: Vector2i, _resource_id: String) -> void:
	if _armor_system == null or not _armor_system.can_act():
		return
	var layer_id: String = GameState.get_depth_layer_id()
	var threat_id: String = roll(layer_id)
	if threat_id.is_empty():
		return
	var damage: float = GameData.get_threat_damage(threat_id)
	if not _armor_system.apply_threat(damage):
		return
	print("ThreatSystem — rencontre au tirage %d : palier %s · %s · %s dégâts" % [_draws, layer_id, threat_id, damage])
	threat_encountered.emit(threat_id, damage)


## Un tirage : `id` du type de menace du palier si la rencontre survient, chaîne
## vide sinon. Consomme **toujours** un et un seul `randf()`. Probabilité
## constante dans le palier (`Q67` (a)).
func roll(layer_id: String) -> String:
	var draw: float = _rng.randf()
	_draws += 1
	if draw < GameData.get_threat_probability(layer_id):
		return GameData.get_layer_threat_id(layer_id)
	return ""
