extends RefCounted
class_name RecoverySystem

## Conséquence des deux échecs — story 6.7, amendement §4.3, arbitrages `Q17`,
## `Q66` (b), `Q68` (a) et sa précision (story `6.14`).
##
## Une seule responsabilité (`B4`) : décider **quand** la foreuse est rapatriée
## et enchaîner, dans un **chemin unique**, les conséquences de l'échec :
## [br]1. perte d'une **fraction** de la soute (`CargoSystem.lose_fraction()`) ;
## [br]2. blindage relevé à la fraction de retour s'il est inférieur
## (`ArmorSystem.restore_after_failure()`, seul écrivain du blindage, `M1`) ;
## [br]3. carburant porté au seuil de secours s'il est inférieur
## (`FuelSystem.raise_to_rescue_threshold()`, `Q56`) ;
## [br]4. signal `recovered` : la foreuse se replace au point d'apparition
## (`DrillRig`, propriétaire de sa position) et le HUD dit ce qui a été perdu
## (`AlertPanel`).
##
## **Deux déclencheurs, un seul chemin** (`Q66` (b)) :
## [br]— **Destruction** (blindage nul, par impact **ou** par rencontre hostile :
## les deux passent par l'état de destruction d'`ArmorSystem`) : à la fin de la
## transition, sur `ArmorSystem.destruction_finished`.
## [br]— **Panne sèche hors zone de surface** : carburant nul (`FuelSystem.has_fuel()`
## faux), foreuse opérationnelle et hors zone de surface (`GameState`) pendant
## `delai_panne_seche_s` secondes **consécutives** (donnée, ≥ 0). Carburant
## regagné, retour en zone de surface ou destruction pendant ce délai remettent
## le compte à zéro : **une seule** perte par échec. En zone de surface, rien :
## le secours de la station (`Q56`) s'applique.
##
## **Emplacement** (`A3`, critère 9) : `scripts/systems/`, objet et non nœud,
## détenu et branché par `DrillRig` comme `CargoSystem` et `ThreatSystem` —
## l'arbre de `DrillRig.tscn` est figé à 11 nœuds (story 2.1). Le délai avance
## par `tick()`, appelé par la foreuse dans son `_physics_process()` : il est
## donc **suspendu avec l'arbre** (pause, modale ouverte, `H4`). Aucun motif
## d'abonnement à `upgrade_level_changed` ici (critère 9, point hérité de `5.5`).
##
## **Ce qui n'est jamais touché** (`M3 [B]`, §4.3) : crédits, niveaux
## d'amélioration, flags narratifs, sauvegarde (aucune écriture dans `user://`,
## `H7`). **Aucun tirage aléatoire** (`K2`, `M6`) : la perte est déterministe.
##
## **Validation headless** : ce fichier référence les autoloads `GameData` et
## `GameState` — faux « Identifier not found » hors exécution du projet,
## exception `1.9`/`2.9`.

## Cause du rapatriement, transmise au HUD pour nommer l'échec.
enum Cause { DESTRUCTION, STRANDED }

## Rapatriement accompli : soute, blindage et carburant déjà mis à jour. `lost`
## donne les unités perdues par ressource, dans l'ordre du catalogue ; vide si
## la soute ne contenait pas de quoi perdre (perte jamais totale).
signal recovered(cause: Cause, lost: Dictionary[String, int])

var _fuel_system: FuelSystem = null
var _armor_system: ArmorSystem = null
var _cargo_system: CargoSystem = null
var _cargo_loss_fraction: float = 0.0
var _stranded_delay: float = 0.0
## Secondes consécutives de panne sèche hors zone de surface.
var _stranded_elapsed: float = 0.0


## Refuse de s'activer sans bloc `rapatriement` valide (`GameData` a nommé le
## champ fautif) : ni perte ni retour inventés. La foreuse détruite reste alors
## détruite (`ArmorSystem`), panne visible.
func setup(fuel_system: FuelSystem, armor_system: ArmorSystem, cargo_system: CargoSystem) -> bool:
	if not GameData.has_recovery_settings():
		push_error("RecoverySystem — rapatriement non chargé depuis %s : ni retour en surface, ni perte de cargo." % GameData.DRILL_PATH)
		return false
	_fuel_system = fuel_system
	_armor_system = armor_system
	_cargo_system = cargo_system
	_cargo_loss_fraction = GameData.get_recovery_cargo_loss_fraction()
	_stranded_delay = GameData.get_recovery_stranded_delay()
	_armor_system.destruction_finished.connect(_on_destruction_finished)
	return true


## Vrai si le délai de panne sèche hors zone de surface est en cours.
func is_stranded_pending() -> bool:
	return _stranded_elapsed > 0.0


## Avance le délai de panne sèche ; rapatrie à son terme. Appelé à chaque image
## physique par la foreuse, après la publication de son état.
func tick(delta: float) -> void:
	if _armor_system == null:
		return
	if not _is_stranded():
		_stranded_elapsed = 0.0
		return
	_stranded_elapsed += delta
	if _stranded_elapsed < _stranded_delay:
		return
	_stranded_elapsed = 0.0
	_recover(Cause.STRANDED)


## Panne sèche **hors** zone de surface, foreuse hors transition de destruction
## (la destruction a son propre chemin : une seule perte).
func _is_stranded() -> bool:
	return _armor_system.can_act() and not _fuel_system.has_fuel() and not GameState.is_in_surface_zone()


func _on_destruction_finished() -> void:
	_stranded_elapsed = 0.0
	_recover(Cause.DESTRUCTION)


## Le chemin unique. L'ordre compte : la perte est calculée sur la soute **de
## l'échec**, puis blindage et carburant sont relevés **avant** le signal, pour
## que la foreuse replacée soit déjà en état de repartir.
func _recover(cause: Cause) -> void:
	var lost: Dictionary[String, int] = _cargo_system.lose_fraction(_cargo_loss_fraction)
	_armor_system.restore_after_failure()
	_fuel_system.raise_to_rescue_threshold()
	# Journal des rapatriements, sortie observable voulue (comme le journal des
	# rencontres de `ThreatSystem`) : cause et unités perdues, pour qu'un testeur
	# diagnostique une perte contestée à la recette `7.8` (`TM-6.8`, `TM-6.11`).
	# Le joueur, lui, est prévenu par `AlertPanel` (`recovered`).
	print("RecoverySystem — rapatriement (%s) : perdu %s" % [Cause.keys()[cause], lost])
	recovered.emit(cause, lost)
