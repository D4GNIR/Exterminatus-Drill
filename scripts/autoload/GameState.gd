extends Node

## Autoload `GameState` — état de partie global.
##
## Porte l'**état mutable** d'une partie (jauges, soute, crédits, progression,
## flags narratifs) et le publie par **signaux**. Il ne porte aucune **règle** :
## forage, consommation de carburant, vente, dégâts et arbitrage de soute pleine
## appartiennent aux systèmes (point d'audit C6).
##
## Contraintes de conception, opposables aux phases suivantes :
## [br]— Aucun accès à l'arbre de scène, aucun `get_node`, aucun `_input()` ni
## `_unhandled_input()` : un autoload d'état ne lit jamais les entrées (Q10).
## [br]— Tout l'état est **sérialisable en JSON** : uniquement `bool`, `int`,
## `float`, `String` et dictionnaires de ces types. La position de la foreuse est
## donc stockée en deux `float` et non en `Vector2`, que JSON ne représente pas.
## [br]— Aucune donnée du catalogue `GameData` n'est recopiée ici : seuls les
## `id` qui y font référence sont conservés, afin que la sauvegarde de la phase 7
## ne persiste jamais de valeurs d'équilibrage.
## [br]— **Aucune valeur de gameplay** (arbitrage Q13) : les valeurs de départ
## sont lues dans `GameData` à chaque `reset_new_game()`. Les seules constantes
## qui subsistent sont des **garde-fous techniques** — bornes minimales et
## protections contre la division par zéro — sans rôle d'équilibrage.
## [br]— **Validation headless** : ce fichier référence l'autoload `GameData`.
## `godot --headless --check-only --script` ne peut pas résoudre un identifiant
## d'autoload (il n'est enregistré qu'au démarrage du projet) et signale un faux
## « Identifier not found ». Valider par `--headless --import`, `--headless
## --editor --quit` ou l'exécution du projet — cf. Notes de la story 1.5.
##
## Les champs sont privés et exposés par accesseurs typés : c'est le seul moyen
## de garantir que les bornes (`clamp`) ne peuvent pas être contournées par une
## écriture directe.

# --- Signaux ------------------------------------------------------------------
# Un signal par grandeur affichée en temps réel par le HUD (« Critères
# d'acceptation MVP »), pour que la phase 4 s'abonne sans couplage de nœuds.

## Émis à chaque variation du carburant courant ou de sa capacité.
signal fuel_changed(current: float, maximum: float)
## Émis à chaque variation du blindage courant ou de sa capacité.
## Décrémenté par `ArmorSystem`, **seul point d'entrée de dégâts** (story 2.5,
## point d'audit M1) : dégâts d'impact dès la phase 2, menaces de la courbe §4.2
## en phase 6. *L'arbitrage Q3 — « jauge statique au MVP » — est **annulé par
## Q17** : ne pas s'y référer.*
signal armor_changed(current: float, maximum: float)
## Émis à chaque variation du solde de crédits impériaux.
signal credits_changed(credits: int)
## Émis à chaque variation du contenu de la soute ou de sa capacité.
signal cargo_changed(used: int, capacity: int)
## Émis à chaque variation de la profondeur courante, en mètres.
signal depth_changed(depth_m: float)
## Émis **à la seule transition** de palier de profondeur (story 6.1), jamais à
## chaque image : `layer_id` est un `id` de `couches_profondeur`
## (`data/generation.json`), le découpage unique du loot et de la courbe de
## risque (`Q30`). Source commune de la courbe de risque (6.6), de l'indicateur de
## danger (6.8) et du contexte de l'anomalie (6.4).
signal depth_layer_changed(layer_id: String)
## Émis quand la foreuse entre dans la zone de surface ou en sort (story 5.1) :
## la station n'est accessible que dans cette zone, et le HUD y affiche son
## indication d'interaction.
signal surface_zone_changed(in_zone: bool)
## Émis quand la foreuse cesse d'être opérationnelle (entrée dans la transition
## de destruction) ou le redevient (story 6.7, `M4`) : la station, l'inventaire
## et l'indication d'interaction ne s'ouvrent pas pendant la transition.
signal drill_operational_changed(operational: bool)
## Émis après l'achat d'une amélioration (« la statistique associée est modifiée
## immédiatement », critères d'acceptation MVP). Story 5.5 : chaque système
## propriétaire d'une statistique s'y abonne et applique lui-même la valeur du
## niveau — `FuelSystem` (`carburant_max`), `ArmorSystem` (`blindage_max`),
## `CargoSystem` (`capacite_soute`) ; `MiningSystem` relit le niveau du foret à
## chaque demande. L'état ne porte pas cette règle (`C6`).
signal upgrade_level_changed(upgrade_id: String, level: int)
## Émis à la pose ou au retrait d'un flag narratif — consommé en phase 6.
signal narrative_flag_changed(flag_id: String, value: bool)

# --- Bornes -------------------------------------------------------------------
# Les maxima ne peuvent pas descendre à zéro : les ratios de jauge divisent par
# eux (H1). Ce sont les seules constantes de ce fichier : des garde-fous
# techniques, jamais des valeurs d'équilibrage (Q13). Ils bornent aussi ce que
# `GameData` renvoie, de sorte qu'un catalogue amputé produise un état dégradé
# mais cohérent — et non une division par zéro.

const MIN_GAUGE_MAX: float = 1.0
const MIN_CARGO_CAPACITY: int = 1
const MIN_UPGRADE_LEVEL: int = 1

# --- État ---------------------------------------------------------------------

# Les initialisations ci-dessous ne sont que des valeurs de construction bornées :
# `reset_new_game()`, appelée dès `_init()`, y substitue immédiatement les valeurs
# de départ du catalogue. L'état est donc valide dès la construction du singleton.
var _fuel: float = MIN_GAUGE_MAX
var _fuel_max: float = MIN_GAUGE_MAX
var _armor: float = MIN_GAUGE_MAX
var _armor_max: float = MIN_GAUGE_MAX
var _credits: int = 0
## Profondeur courante en **mètres**, 0.0 au niveau de la surface et croissante
## vers le bas. La conversion pixels → mètres dépend de la taille de tuile : elle
## appartient au système qui la connaît (phases 2 et 3), pas à l'état.
var _depth_m: float = 0.0
## Palier de profondeur courant : un `id` de `couches_profondeur`, jamais une
## borne. **Dérivé** de `_depth_m` à chaque publication de la profondeur, avec
## l'hystérésis lue en données (`GameData.get_depth_layer_with_hysteresis()`) :
## aucun second calcul de profondeur, aucun seuil ici (story 6.1, `C3`, `D1`).
var _depth_layer_id: String = ""
## Position monde de la foreuse en **pixels**, décomposée en deux `float` pour
## rester sérialisable en JSON. Distincte de la profondeur : la profondeur est
## une grandeur d'affichage, la position sert à restituer la partie (phase 7).
var _drill_position_x: float = 0.0
var _drill_position_y: float = 0.0
## La foreuse est-elle dans la zone de surface (story 5.1) ? Grandeur **dérivée**
## de la position et des ancrages, publiée par la foreuse comme la profondeur :
## l'état ne sait pas où est la zone, il retient seulement la réponse.
var _in_surface_zone: bool = false
## La foreuse est-elle opérationnelle — hors transition de destruction (story
## 6.7) ? Grandeur **dérivée** de `ArmorSystem.can_act()`, publiée par la foreuse
## comme la zone de surface. État **transitoire**, à ne pas sauvegarder (`7.1`) :
## une partie restaurée repart opérationnelle.
var _drill_operational: bool = true
## Contenu de la soute : `resource_id` → nombre d'unités. Les `resource_id` sont
## ceux de `data/resources.json` (story 1.5) ; aucune valeur de vente n'est
## stockée ici.
var _cargo: Dictionary[String, int] = {}
## Somme des unités en soute. Dérivé de `_cargo` : jamais écrit de l'extérieur.
var _cargo_used: int = 0
var _cargo_capacity: int = MIN_CARGO_CAPACITY
## `upgrade_id` → niveau atteint. Les `id`, les paramètres de progression et
## les effets chiffrés vivent dans `data/upgrades.json`, jamais ici : l'état ne
## connaît que des références. Peuplé par `reset_new_game()` depuis les
## améliorations actives au MVP déclarées par `GameData`.
var _upgrade_levels: Dictionary[String, int] = {}
## `flag_id` → posé ou non. Sert la progression narrative (phase 6).
var _narrative_flags: Dictionary[String, bool] = {}


## Initialisé dès la construction, et non dans `_ready()` : `GameData` étant
## déclaré avant `GameState` dans la section `[autoload]`, son catalogue est déjà
## chargé ici. Aucun lecteur ne peut donc observer un état non initialisé.
func _init() -> void:
	reset_new_game()


# --- Cycle de partie ----------------------------------------------------------

## Remet l'état aux valeurs de départ **du catalogue** et notifie tous les
## abonnés. Appelée à la construction et à chaque nouvelle partie.
## Les jauges partent pleines : c'est une règle de nouvelle partie (« quitter la
## surface avec une foreuse approvisionnée », CDC « Boucle de jeu »), pas un
## chiffre — le plein vaut ce que le catalogue déclare.
func reset_new_game() -> void:
	_fuel_max = maxf(GameData.get_start_stat(GameData.STAT_FUEL_MAX), MIN_GAUGE_MAX)
	_fuel = _fuel_max
	_armor_max = maxf(GameData.get_start_stat(GameData.STAT_ARMOR_MAX), MIN_GAUGE_MAX)
	_armor = _armor_max
	_credits = maxi(GameData.get_start_credits(), 0)
	# La surface est l'origine de la mesure : 0 m n'est pas un réglage.
	_depth_m = 0.0
	# Surface ⇒ premier palier : la profondeur nulle y appartient par construction
	# des données (paliers contigus depuis 0 m). Pas d'hystérésis au départ d'une
	# partie : le palier précédent n'a pas de sens pour une partie neuve.
	var start_layer_id: String = GameData.get_depth_layer_at(_depth_m)
	var layer_changed: bool = start_layer_id != _depth_layer_id
	_depth_layer_id = start_layer_id
	_drill_position_x = 0.0
	_drill_position_y = 0.0
	# Recalculée par la foreuse à sa prochaine publication : l'état de départ
	# n'affirme rien sur une position qu'il ne connaît pas encore.
	_in_surface_zone = false
	_drill_operational = true
	_cargo.clear()
	_cargo_used = 0
	_cargo_capacity = maxi(int(GameData.get_start_stat(GameData.STAT_CARGO_CAPACITY)), MIN_CARGO_CAPACITY)
	_narrative_flags.clear()
	_upgrade_levels.clear()
	for upgrade_id: String in GameData.get_mvp_upgrade_ids():
		_upgrade_levels[upgrade_id] = maxi(GameData.get_upgrade_start_level(upgrade_id), MIN_UPGRADE_LEVEL)

	fuel_changed.emit(_fuel, _fuel_max)
	armor_changed.emit(_armor, _armor_max)
	credits_changed.emit(_credits)
	cargo_changed.emit(_cargo_used, _cargo_capacity)
	depth_changed.emit(_depth_m)
	# Signal de transition : émis seulement si la nouvelle partie change de palier.
	if layer_changed:
		depth_layer_changed.emit(_depth_layer_id)
	surface_zone_changed.emit(_in_surface_zone)
	drill_operational_changed.emit(_drill_operational)
	for upgrade_id: String in _upgrade_levels:
		upgrade_level_changed.emit(upgrade_id, _upgrade_levels[upgrade_id])


# --- Carburant ----------------------------------------------------------------

func get_fuel() -> float:
	return _fuel


func set_fuel(value: float) -> void:
	var clamped: float = clampf(value, 0.0, _fuel_max)
	if is_equal_approx(clamped, _fuel):
		return
	_fuel = clamped
	fuel_changed.emit(_fuel, _fuel_max)


func get_fuel_max() -> float:
	return _fuel_max


func set_fuel_max(value: float) -> void:
	var clamped: float = maxf(value, MIN_GAUGE_MAX)
	if is_equal_approx(clamped, _fuel_max):
		return
	_fuel_max = clamped
	_fuel = minf(_fuel, _fuel_max)
	fuel_changed.emit(_fuel, _fuel_max)


## Ratio 0..1 pour l'affichage. Le dénominateur ne peut pas être nul.
func get_fuel_ratio() -> float:
	return _fuel / _fuel_max


# --- Blindage -----------------------------------------------------------------

func get_armor() -> float:
	return _armor


func set_armor(value: float) -> void:
	var clamped: float = clampf(value, 0.0, _armor_max)
	if is_equal_approx(clamped, _armor):
		return
	_armor = clamped
	armor_changed.emit(_armor, _armor_max)


func get_armor_max() -> float:
	return _armor_max


func set_armor_max(value: float) -> void:
	var clamped: float = maxf(value, MIN_GAUGE_MAX)
	if is_equal_approx(clamped, _armor_max):
		return
	_armor_max = clamped
	_armor = minf(_armor, _armor_max)
	armor_changed.emit(_armor, _armor_max)


## Ratio 0..1 pour l'affichage. Le dénominateur ne peut pas être nul.
func get_armor_ratio() -> float:
	return _armor / _armor_max


# --- Crédits ------------------------------------------------------------------

func get_credits() -> int:
	return _credits


## Le solde ne peut pas devenir négatif : c'est à l'appelant de vérifier qu'un
## achat est finançable avant de débiter (règle d'économie, phase 5).
func set_credits(value: int) -> void:
	var clamped: int = maxi(value, 0)
	if clamped == _credits:
		return
	_credits = clamped
	credits_changed.emit(_credits)


# --- Soute --------------------------------------------------------------------

func get_cargo_used() -> int:
	return _cargo_used


func get_cargo_capacity() -> int:
	return _cargo_capacity


## La capacité n'augmente qu'à l'achat de l'amélioration `soute` au MVP. Une
## réduction laisserait la soute au-dessus de sa capacité : l'arbitrage de
## l'excédent appartiendrait au système d'inventaire, pas à l'état.
func set_cargo_capacity(value: int) -> void:
	var clamped: int = maxi(value, MIN_CARGO_CAPACITY)
	if clamped == _cargo_capacity:
		return
	_cargo_capacity = clamped
	cargo_changed.emit(_cargo_used, _cargo_capacity)


func get_cargo_units(resource_id: String) -> int:
	return _cargo.get(resource_id, 0)


## Copie défensive : le dictionnaire interne ne doit pas être muté hors des
## accesseurs, sous peine de désynchroniser `_cargo_used`.
func get_cargo_contents() -> Dictionary[String, int]:
	return _cargo.duplicate()


func get_cargo_free_space() -> int:
	return _cargo_capacity - _cargo_used


## Fixe le nombre d'unités d'une ressource en soute. Le total est borné par la
## capacité (G8) : l'excédent n'est pas stocké. Décider quoi faire de cet
## excédent — Q5 : minerai perdu, tuile détruite quand même — est une règle du
## système de forage, qui appelle cet accesseur en connaissance de cause.
func set_cargo_units(resource_id: String, units: int) -> void:
	var others: int = _cargo_used - get_cargo_units(resource_id)
	var clamped: int = clampi(units, 0, _cargo_capacity - others)
	if clamped == get_cargo_units(resource_id):
		return
	if clamped == 0:
		_cargo.erase(resource_id)
	else:
		_cargo[resource_id] = clamped
	_cargo_used = others + clamped
	cargo_changed.emit(_cargo_used, _cargo_capacity)


## Vide la soute (vente à la surface, phase 5).
func clear_cargo() -> void:
	if _cargo.is_empty():
		return
	_cargo.clear()
	_cargo_used = 0
	cargo_changed.emit(_cargo_used, _cargo_capacity)


## Ratio 0..1 pour l'affichage. Le dénominateur ne peut pas être nul.
func get_cargo_ratio() -> float:
	return float(_cargo_used) / float(_cargo_capacity)


# --- Profondeur et position ---------------------------------------------------

func get_depth_m() -> float:
	return _depth_m


## Profondeur en mètres, jamais négative : au-dessus de la surface, elle vaut 0.
func set_depth_m(value: float) -> void:
	var clamped: float = maxf(value, 0.0)
	if is_equal_approx(clamped, _depth_m):
		return
	_depth_m = clamped
	depth_changed.emit(_depth_m)
	_update_depth_layer()


func get_depth_layer_id() -> String:
	return _depth_layer_id


## Retient le palier de la profondeur publiée et n'émet qu'à la transition. La
## règle (frontières, hystérésis) est une donnée lue par `GameData` ; l'état ne
## fait que retenir la réponse, comme pour la zone de surface.
func _update_depth_layer() -> void:
	var layer_id: String = GameData.get_depth_layer_with_hysteresis(_depth_m, _depth_layer_id)
	if layer_id == _depth_layer_id:
		return
	_depth_layer_id = layer_id
	depth_layer_changed.emit(_depth_layer_id)


## Conversion `Vector2` → deux `float` : l'état reste sérialisable en JSON alors
## que les appelants manipulent des positions Godot.
func set_drill_position(position: Vector2) -> void:
	_drill_position_x = position.x
	_drill_position_y = position.y


func get_drill_position() -> Vector2:
	return Vector2(_drill_position_x, _drill_position_y)


func is_in_surface_zone() -> bool:
	return _in_surface_zone


## Notifie seulement les changements : la foreuse publie à chaque image.
func set_in_surface_zone(value: bool) -> void:
	if value == _in_surface_zone:
		return
	_in_surface_zone = value
	surface_zone_changed.emit(_in_surface_zone)


func is_drill_operational() -> bool:
	return _drill_operational


## Notifie seulement les changements : la foreuse publie à chaque image.
func set_drill_operational(value: bool) -> void:
	if value == _drill_operational:
		return
	_drill_operational = value
	drill_operational_changed.emit(_drill_operational)


# --- Améliorations ------------------------------------------------------------

## Niveau atteint pour une amélioration. Un `id` inconnu renvoie le niveau
## plancher : l'état ne valide pas le catalogue, c'est au système d'améliorations
## (phase 5) de vérifier l'`id` auprès de `GameData`.
func get_upgrade_level(upgrade_id: String) -> int:
	return _upgrade_levels.get(upgrade_id, MIN_UPGRADE_LEVEL)


## Aucun plafond de niveau (story 5.6, `Q18`, `L2`) : seul le plancher, le niveau
## de départ, est garanti ici. Vérifier le coût et l'`id` appartient au système
## d'améliorations (story 5.4).
func set_upgrade_level(upgrade_id: String, level: int) -> void:
	var clamped: int = maxi(level, MIN_UPGRADE_LEVEL)
	if clamped == get_upgrade_level(upgrade_id):
		return
	_upgrade_levels[upgrade_id] = clamped
	upgrade_level_changed.emit(upgrade_id, clamped)


func get_upgrade_levels() -> Dictionary[String, int]:
	return _upgrade_levels.duplicate()


# --- Flags narratifs ----------------------------------------------------------

func has_narrative_flag(flag_id: String) -> bool:
	return _narrative_flags.get(flag_id, false)


func set_narrative_flag(flag_id: String, value: bool) -> void:
	if has_narrative_flag(flag_id) == value:
		return
	_narrative_flags[flag_id] = value
	narrative_flag_changed.emit(flag_id, value)


func get_narrative_flags() -> Dictionary[String, bool]:
	return _narrative_flags.duplicate()
