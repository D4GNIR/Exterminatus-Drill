extends RefCounted
class_name LootSystem

## Tirage de loot des cases stériles — story 3.6, amendement §2.1 à §2.3.
##
## Une seule responsabilité (`B4`) : dire **quelle entrée de la table** sort d'une
## case donnée. Il ne décide pas **si** une case est tirée — c'est `MiningSystem`,
## qui applique `Q28` (la tuile décide) —, et ne touche pas à la soute : le drop
## emprunte le chemin unique de `CargoSystem` (critère 9).
##
## Contraintes, opposables à l'audit `3.8` :
## [br]— **`K7` — table entièrement en données** : entrées, ressources et poids
## par palier viennent de `data/generation.json`. Ce fichier ne contient aucune
## probabilité, aucune rareté, aucun seuil.
## [br]— **`K8` — tirage ensemencé et journalisé** : une instance
## `RandomNumberGenerator` **dédiée**, ensemencée par la **graine de génération**
## (donnée) **et les coordonnées de la case**. Aucun `randf()` global, aucun
## `randomize()`. Le §2.3 de l'amendement dit « tirage via `randf()` » : il s'agit
## ici de `_rng.randf()` sur l'instance ensemencée — précision technique imposée
## par `K8`, non un écart.
## [br]— **Tirage PAR CASE** : une case donne toujours le même drop, quel que soit
## l'ordre de forage, le moment ou le nombre de tentatives. C'est plus fort que
## « même séquence ⇒ mêmes drops » (critère 5) : le résultat ne dépend que de la
## graine et de la case (critère 6, `K2`). C'est aussi ce qui permet de tirer
## **au début du forage**, avant la destruction, sans changer le résultat — et
## donc à la soute d'alerter avant une perte (`G9`).
## [br]— **« Rien » est une entrée tirée comme les autres** (critère 8), jamais un
## `else` implicite.
##
## **Validation headless** : ce fichier référence l'autoload `GameData` — faux
## « Identifier not found » en `--check-only`, exception `1.9`.

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _seed: int = 0
var _entry_ids: Array[String] = []


## Refuse de s'activer sans table valide. Journalise la graine de loot (`P5`).
func setup() -> bool:
	if not GameData.has_loot_table():
		push_error("LootSystem — table de loot non chargée depuis %s : aucun tirage." % GameData.GENERATION_PATH)
		return false
	_seed = GameData.get_generation_seed()
	_entry_ids = GameData.get_loot_entry_ids()
	print("LootSystem — graine de loot : %d (graine de génération) · tirage par case · %d entrées" % [_seed, _entry_ids.size()])
	return true


## Entrée de la table tirée pour cette case. Le palier est celui de la
## **profondeur de la case** (critère 6), jamais celle de la foreuse ni un état
## du joueur. Tirage pondéré : un seul `randf()`, comparé aux poids cumulés dans
## l'ordre déclaré de la table.
func roll_entry(cell: Vector2i) -> String:
	var layer_id: String = GameData.get_depth_layer_at(GameData.get_row_depth_m(cell.y))
	var weights: PackedFloat64Array = GameData.get_loot_weights(layer_id)
	var total: float = 0.0
	for weight: float in weights:
		total += weight
	_rng.seed = hash([_seed, cell.x, cell.y])
	var roll: float = _rng.randf() * total
	var threshold: float = 0.0
	for index: int in weights.size():
		threshold += weights[index]
		if roll < threshold:
			return _entry_ids[index]
	# `randf()` est dans [0, 1[ : inatteignable, sauf arrondi flottant sur la
	# dernière borne. La dernière entrée de poids non nul est alors la bonne.
	for index: int in range(weights.size() - 1, -1, -1):
		if weights[index] > 0.0:
			return _entry_ids[index]
	return _entry_ids[0]
