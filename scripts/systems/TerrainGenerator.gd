extends RefCounted
class_name TerrainGenerator

## Générateur de terrain semi-procédural — story 3.2, arbitrage `Q6`.
##
## Pose les strates de terrain, les veines de minerai et la **ceinture
## indestructible** du pourtour, à partir des seules données de
## `data/generation.json`.
##
## Contraintes de conception, opposables à l'audit `3.8` :
## [br]— **Aucun nombre magique** (`K5`, `D4`) : dimensions, seuils de strate,
## densités et graine viennent tous des données. Ce fichier ne contient aucune
## valeur de gameplay.
## [br]— **Aucune coordonnée d'atlas en dur** (`E2`) : les tuiles à poser sont
## trouvées en **lisant les Custom Data Layers** du TileSet — la strate par sa
## `hardness`, le minerai par son `resource_id`, la ceinture par son
## `destructible = false`. Réordonner l'atlas ne casse donc rien.
## [br]— **Tout l'aléa passe par une instance `RandomNumberGenerator` ensemencée**
## (`K1`) : aucun `randomize()`, aucun `randi()`/`randf()` global. Le déterminisme
## de `K2` en découle, à condition de ne jamais faire dépendre le tirage d'autre
## chose que de la graine et de l'ordre de parcours — d'où le balayage en ordre
## fixe, ligne par ligne, et l'itération des minerais dans l'ordre du catalogue.
## [br]— **Une seule passe, hors boucle de rendu** (`H6`) : `generate()` est appelée
## une fois par `TerrainSystem._ready()`.
## [br]— **Validation headless** : ce fichier référence l'autoload `GameData` —
## faux « Identifier not found » hors exécution du projet, exception `1.9`/`2.9`.

const DATA_HARDNESS: StringName = &"hardness"
const DATA_RESOURCE_ID: StringName = &"resource_id"
const DATA_DESTRUCTIBLE: StringName = &"destructible"

const KEY_DEPTH_MAX_M: String = "profondeur_max_m"
const KEY_HARDNESS: String = "hardness"

## Résultat d'une génération, pour journalisation et pour les tests. Aucune de ces
## grandeurs n'est un paramètre : ce sont des constats.
class Report extends RefCounted:
	var seed_used: int = 0
	var terrain_cells: int = 0
	var ore_cells: int = 0
	var belt_cells: int = 0
	var duration_ms: float = 0.0

	func to_line() -> String:
		return "TerrainGenerator — graine : %d · terrain : %d cellules · minerai : %d · ceinture : %d · %.1f ms" % [
			seed_used, terrain_cells, ore_cells, belt_cells, duration_ms,
		]

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
## `hardness` → coordonnées d'atlas de la tuile de terrain correspondante.
var _terrain_tiles: Dictionary[int, Vector2i] = {}
## `resource_id` → coordonnées d'atlas de la tuile de minerai.
var _ore_tiles: Dictionary[String, Vector2i] = {}
## Coordonnées de la tuile indestructible, celle de la ceinture.
var _belt_tile: Vector2i = Vector2i(-1, -1)
var _source_id: int = -1


## Remplit `terrain_layer` et `ore_layer`. Renvoie `null` si les données ou le
## TileSet sont inexploitables : une carte partiellement générée serait pire
## qu'une absence de carte, car elle aurait l'air de fonctionner.
func generate(terrain_layer: TileMapLayer, ore_layer: TileMapLayer, override_seed: int = 0, use_override: bool = false) -> Report:
	if not GameData.has_generation_settings():
		push_error("TerrainGenerator — paramètres de génération non chargés depuis %s : aucun terrain produit." % GameData.GENERATION_PATH)
		return null
	if not _index_tiles(terrain_layer.tile_set):
		return null

	var report: Report = Report.new()
	report.seed_used = override_seed if use_override else GameData.get_generation_seed()
	# Affecter `seed` réinitialise aussi `state` : le flux repart du même point à
	# chaque génération, et deux générations successives à graine égale coïncident.
	# Ne **jamais** forcer `state` ensuite — cela écraserait la graine et rendrait
	# toutes les cartes identiques (défaut constaté et corrigé en story 3.2).
	_rng.seed = report.seed_used

	var started_us: int = Time.get_ticks_usec()
	terrain_layer.clear()
	ore_layer.clear()
	_fill(terrain_layer, ore_layer, report)
	report.duration_ms = float(Time.get_ticks_usec() - started_us) / 1000.0
	return report


## Indexe les tuiles par leurs **données**, jamais par leur position dans l'atlas.
func _index_tiles(tile_set: TileSet) -> bool:
	_terrain_tiles.clear()
	_ore_tiles.clear()
	_belt_tile = Vector2i(-1, -1)
	if tile_set == null:
		push_error("TerrainGenerator — aucun TileSet : impossible d'indexer les tuiles.")
		return false

	for source_index: int in tile_set.get_source_count():
		var source_id: int = tile_set.get_source_id(source_index)
		var source: TileSetAtlasSource = tile_set.get_source(source_id) as TileSetAtlasSource
		if source == null:
			continue
		_source_id = source_id
		for tile_index: int in source.get_tiles_count():
			var coords: Vector2i = source.get_tile_id(tile_index)
			var tile_data: TileData = source.get_tile_data(coords, 0)
			if tile_data == null:
				continue
			if not tile_data.get_custom_data(DATA_DESTRUCTIBLE):
				_belt_tile = coords
				continue
			var resource_id: String = tile_data.get_custom_data(DATA_RESOURCE_ID)
			if resource_id.is_empty():
				_terrain_tiles[tile_data.get_custom_data(DATA_HARDNESS)] = coords
			else:
				_ore_tiles[resource_id] = coords

	if _belt_tile == Vector2i(-1, -1):
		push_error("TerrainGenerator — aucune tuile `destructible = false` dans le TileSet : la ceinture du pourtour (K4) est impossible à poser.")
		return false
	for stratum: Dictionary in GameData.get_strata():
		var hardness: int = stratum[KEY_HARDNESS]
		if not _terrain_tiles.has(hardness):
			push_error("TerrainGenerator — aucune tuile de terrain de `hardness` %d dans le TileSet, exigée par une strate de %s." % [hardness, GameData.GENERATION_PATH])
			return false
	return true


## Balayage en ordre fixe, ligne par ligne puis colonne par colonne. **Cet ordre
## fait partie du contrat de déterminisme** (`K2`) : le changer changerait le
## terrain produit à graine identique.
func _fill(terrain_layer: TileMapLayer, ore_layer: TileMapLayer, report: Report) -> void:
	var width: int = GameData.get_map_width_tiles()
	var depth: int = GameData.get_map_depth_tiles()
	var belt: int = GameData.get_map_belt_tiles()
	var left: int = -(width / 2)
	var right: int = left + width - 1
	var strata: Array[Dictionary] = GameData.get_strata()
	var anomaly_cell: Vector2i = GameData.get_anomaly_cell()

	for y: int in range(0, depth + belt):
		var is_belt_row: bool = y >= depth
		for x: int in range(left, right + 1):
			var cell: Vector2i = Vector2i(x, y)
			var is_belt_column: bool = x < left + belt or x > right - belt
			if is_belt_row or is_belt_column:
				terrain_layer.set_cell(cell, _source_id, _belt_tile)
				report.belt_cells += 1
				continue
			var depth_m: float = GameData.get_row_depth_m(y)
			terrain_layer.set_cell(cell, _source_id, _stratum_tile(strata, depth_m))
			report.terrain_cells += 1
			var ore: Vector2i = _roll_ore(depth_m)
			# Ancrage de l'anomalie (story 3.3, `K3`) : le tirage a **lieu** puis est
			# ignoré, pour que le flux d'aléa des autres cases ne dépende pas de la
			# position de l'ancrage. Le déplacer ne rebat donc pas la carte.
			if cell == anomaly_cell:
				continue
			if ore != Vector2i(-1, -1):
				ore_layer.set_cell(cell, _source_id, ore)
				report.ore_cells += 1


## Tuile de la strate couvrant cette profondeur. La dernière strate porte la
## sentinelle « jusqu'au fond », d'où l'absence de cas non couvert.
func _stratum_tile(strata: Array[Dictionary], depth_m: float) -> Vector2i:
	for stratum: Dictionary in strata:
		var maximum: float = stratum[KEY_DEPTH_MAX_M]
		if is_equal_approx(maximum, GameData.DEPTH_UNBOUNDED) or depth_m < maximum:
			return _terrain_tiles[stratum[KEY_HARDNESS]]
	# Inatteignable si les données sont valides — la validation de `GameData`
	# impose une dernière strate non bornée. Signalé plutôt que replié en silence.
	push_error("TerrainGenerator — aucune strate ne couvre la profondeur %.1f m." % depth_m)
	return _terrain_tiles[strata[strata.size() - 1][KEY_HARDNESS]]


## Tirage du minerai d'une case. **Un seul `randf()` par case**, comparé aux seuils
## cumulés dans l'ordre du catalogue : c'est ce qui rend le tirage indépendant du
## nombre de minerais déclarés sur le palier, donc stable si l'un passe à 0.
func _roll_ore(depth_m: float) -> Vector2i:
	var layer_id: String = GameData.get_depth_layer_at(depth_m)
	if layer_id.is_empty():
		return Vector2i(-1, -1)
	var roll: float = _rng.randf()
	var threshold: float = 0.0
	for resource_id: String in GameData.get_ore_densities(layer_id):
		threshold += GameData.get_ore_density(layer_id, resource_id)
		if roll < threshold:
			if not _ore_tiles.has(resource_id):
				push_error("TerrainGenerator — aucune tuile pour « %s », déclaré dans les densités de « %s »." % [resource_id, layer_id])
				return Vector2i(-1, -1)
			return _ore_tiles[resource_id]
	return Vector2i(-1, -1)
