extends Node2D
class_name TerrainSystem

## Racine du monde — stories 3.1, 3.2 et 3.4.
##
## Trois responsabilités, toutes relatives **au terrain** : **valider** que le
## TileSet et le catalogue `data/resources.json` ne divergent pas, **générer le
## terrain** en déléguant à `TerrainGenerator` — l'ordre compte, générer sur des
## données incohérentes produirait une carte d'apparence normale et de contenu
## faux —, puis **répondre aux questions sur les cellules et les détruire** pour
## le `MiningSystem` (story 3.4). Ce script ne décide d'**aucune** règle de
## forage : il dit ce qu'est une cellule, et l'efface quand on le lui demande.
##
## Pourquoi ce contrôle existe (critère 7 de la story `3.1`). Deux grandeurs sont
## **nécessairement** présentes en double : le TileSet doit porter `hardness` et
## `value` — la section « Données de tuile » du CDC l'exige et le point d'audit
## `E1` est bloquant —, et `data/resources.json` les porte aussi, comme catalogue
## de référence. La duplication n'est donc pas évitable ; ce qui l'est, c'est
## qu'elles **divergent en silence**. La règle retenue :
## [br]— **`data/resources.json` est la source de vérité.** Les valeurs du TileSet
## en sont une **copie**, éditée à la main dans la scène.
## [br]— **Toute divergence est un échec bruyant au démarrage**, nommant la tuile,
## le champ, la valeur lue et la valeur attendue. Un `.tscn` ne se valide pas tout
## seul : c'est ce contrôle qui tient la promesse du critère 7.
##
## Contraintes de conception :
## [br]— **Aucune valeur de gameplay ici** (`D1`, `D4`) : ce script ne connaît ni
## dureté, ni prix, ni taille de tuile. Il **compare** deux sources, il n'en est
## pas une troisième.
## [br]— **Aucun chemin de nœud fragile** (`C1`) : uniquement des enfants directs,
## par chemin descendant (`C2`).
## [br]— **Validation headless** : ce fichier référence l'autoload `GameData` —
## faux « Identifier not found » hors exécution du projet, exception `1.9`/`2.9`.

## Noms des Custom Data Layers, tels que la section « Données de tuile » du CDC
## les impose. Ce sont des clés de TileSet, pas des valeurs de gameplay.
const DATA_MINEABLE: StringName = &"mineable"
const DATA_HARDNESS: StringName = &"hardness"
const DATA_RESOURCE_ID: StringName = &"resource_id"
const DATA_VALUE: StringName = &"value"
const DATA_DESTRUCTIBLE: StringName = &"destructible"

@onready var _terrain_layer: TileMapLayer = $TerrainLayer
@onready var _ore_layer: TileMapLayer = $OreLayer

var _generator: TerrainGenerator = TerrainGenerator.new()

## Nature d'une cellule vue par le forage. Trois cas **explicites** (`E3`) :
## jamais de `null` propagé, jamais de `TileData` nul laissé à l'appelant.
enum CellState { EMPTY, OUT_OF_MAP, SOLID }

## Réponse de `get_cell_info()`. Hors `SOLID`, les propriétés gardent leur valeur
## neutre : une cellule vide ou hors carte n'est ni minable ni destructible.
class CellInfo extends RefCounted:
	var state: CellState = CellState.EMPTY
	var mineable: bool = false
	var destructible: bool = false
	var hardness: int = 0
	var resource_id: String = ""


## Une seule passe, hors boucle de rendu (`H6`). La graine et le temps d'exécution
## sont **journalisés** : c'est ce que le prérequis `P4` du plan de tests exige pour
## qu'une campagne soit reproductible, et le point d'audit `K6` pour que le testeur
## puisse rapporter une anomalie exploitable.
func _ready() -> void:
	_validate_tileset_against_catalog()
	var report: TerrainGenerator.Report = _generator.generate(_terrain_layer, _ore_layer)
	if report == null:
		push_error("TerrainSystem — génération du terrain échouée : la carte est vide.")
		return
	print(report.to_line())


## Parcourt les tuiles porteuses d'un `resource_id` et confronte leurs `hardness`
## et `value` au catalogue. Les tuiles sans `resource_id` — terre, roche,
## bordure — n'ont rien à confronter : leur dureté n'appartient qu'au terrain.
func _validate_tileset_against_catalog() -> void:
	var tile_set: TileSet = _terrain_layer.tile_set
	if tile_set == null:
		push_error("TerrainSystem — aucun TileSet sur TerrainLayer : terrain invalide.")
		return
	if _ore_layer.tile_set != tile_set:
		push_error("TerrainSystem — TerrainLayer et OreLayer ne partagent pas le même TileSet : les données de tuile pourraient diverger d'une couche à l'autre.")

	for source_index: int in tile_set.get_source_count():
		var source: TileSetAtlasSource = tile_set.get_source(tile_set.get_source_id(source_index)) as TileSetAtlasSource
		if source == null:
			continue
		for tile_index: int in source.get_tiles_count():
			var coords: Vector2i = source.get_tile_id(tile_index)
			_validate_tile(source, coords)


func _validate_tile(source: TileSetAtlasSource, coords: Vector2i) -> void:
	var tile_data: TileData = source.get_tile_data(coords, 0)
	if tile_data == null:
		return
	var resource_id: String = tile_data.get_custom_data(DATA_RESOURCE_ID)
	if resource_id.is_empty():
		return

	var context: String = "tuile %s (« %s »)" % [coords, resource_id]
	# Q12 : un `resource_id` de tuile est toujours un id du catalogue.
	if not GameData.has_resource(resource_id):
		push_error("TerrainSystem — %s : `resource_id` inconnu du catalogue %s." % [context, GameData.RESOURCES_PATH])
		return
	# K10 : une ressource hors périmètre MVP n'a pas le droit d'avoir de tuile.
	if not GameData.is_resource_active_in_mvp(resource_id):
		push_error("TerrainSystem — %s : ressource `actif_mvp: false`, elle ne doit pas avoir de tuile au MVP." % context)

	_compare(context, DATA_VALUE, tile_data.get_custom_data(DATA_VALUE), GameData.get_resource_value(resource_id))
	_compare(context, DATA_HARDNESS, tile_data.get_custom_data(DATA_HARDNESS), GameData.get_resource_hardness(resource_id))

	# Une tuile de minerai que l'on ne pourrait pas creuser serait un minerai
	# inatteignable : incohérence de données, pas de code.
	if not tile_data.get_custom_data(DATA_MINEABLE) or not tile_data.get_custom_data(DATA_DESTRUCTIBLE):
		push_error("TerrainSystem — %s : une tuile de minerai doit être `mineable` et `destructible`." % context)


func _compare(context: String, field: StringName, tile_value: int, catalog_value: int) -> void:
	if tile_value == catalog_value:
		return
	push_error("TerrainSystem — %s : « %s » vaut %d dans le TileSet et %d dans le catalogue. Le catalogue fait foi : corriger la tuile dans scenes/world/World.tscn." % [context, field, tile_value, catalog_value])


# --- Accès aux cellules (story 3.4, critères 9 et 10 transférés de 3.1) ---------

## Cellule contenant une position monde.
func world_to_cell(world_position: Vector2) -> Vector2i:
	return _terrain_layer.local_to_map(_terrain_layer.to_local(world_position))


## Centre monde d'une cellule.
func cell_to_world(cell: Vector2i) -> Vector2:
	return _terrain_layer.to_global(_terrain_layer.map_to_local(cell))


## Propriétés d'une cellule, lues **uniquement** par `get_cell_tile_data()` +
## `get_custom_data()` (`E2`), jamais par ses coordonnées d'atlas. Si un minerai
## occupe la cellule, **c'est lui le bloc** : ses propriétés priment sur celles de
## la strate dessous (`Q28` : la tuile décide).
func get_cell_info(cell: Vector2i) -> CellInfo:
	var info: CellInfo = CellInfo.new()
	if not _is_inside_map(cell):
		info.state = CellState.OUT_OF_MAP
		return info
	var tile_data: TileData = _ore_layer.get_cell_tile_data(cell)
	if tile_data == null:
		tile_data = _terrain_layer.get_cell_tile_data(cell)
	if tile_data == null:
		return info
	info.state = CellState.SOLID
	info.mineable = tile_data.get_custom_data(DATA_MINEABLE)
	info.destructible = tile_data.get_custom_data(DATA_DESTRUCTIBLE)
	info.hardness = tile_data.get_custom_data(DATA_HARDNESS)
	info.resource_id = tile_data.get_custom_data(DATA_RESOURCE_ID)
	return info


## Efface une cellule sur les deux couches. Refuse — et le dit — tout ce qui n'est
## pas un bloc `mineable` **et** `destructible` : c'est la seconde barrière de la
## ceinture de bordure (`G5`), la première étant la règle de `MiningSystem`.
func destroy_cell(cell: Vector2i) -> bool:
	var info: CellInfo = get_cell_info(cell)
	if info.state != CellState.SOLID or not info.mineable or not info.destructible:
		push_error("TerrainSystem — destruction refusée de la cellule %s : pas un bloc minable et destructible." % cell)
		return false
	_terrain_layer.erase_cell(cell)
	_ore_layer.erase_cell(cell)
	return true


## Emprise de la carte en cellules — même convention que le générateur et que
## `GameData.get_world_bounds()` : carte centrée en x, bande libre au-dessus de
## la surface, ceinture comprise.
func _is_inside_map(cell: Vector2i) -> bool:
	var width: int = GameData.get_map_width_tiles()
	var left: int = -(width / 2)
	var top: int = -GameData.get_map_surface_tiles()
	var bottom: int = GameData.get_map_depth_tiles() + GameData.get_map_belt_tiles() - 1
	return cell.x >= left and cell.x < left + width and cell.y >= top and cell.y <= bottom
