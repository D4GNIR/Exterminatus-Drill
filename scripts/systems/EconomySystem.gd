class_name EconomySystem
extends RefCounted

## Économie de la station — story 5.2 : vente du contenu de la soute ; story
## 5.3 : ravitaillement en carburant et réparation du blindage ; story 5.4 :
## cotation et achat des améliorations (rayon de la boutique).
##
## Les **crédits impériaux** sont la ressource pivot de la boucle (§3.1 de
## `cahier_des_charges_gameplay_addictif.md`, qui fait foi pour l'économie,
## `Q16`). Ce script est le **seul détenteur des règles de prix** (CDC
## « Architecture Godot », `scripts/systems/EconomySystem.gd`) ; `GameState`
## porte l'état (solde, soute) et ne décide de rien (`C6`), l'interface de
## station (`Shop.gd`) affiche et déclenche, sans calculer.
##
## Règles, opposables à l'audit `5.8` :
## [br]— **`Q37` — prix par tuile** : `valeur_credits` est le prix d'une tuile, et
## la soute compte en unités de masse (`3.5`). Une ligne de vente paie donc
## **`valeur_credits × unités ÷ masse_soute`**, jamais `valeur × unités` (sinon
## l'adamantium serait payé deux fois, la relique xeno trois fois).
## [br]— **Arrondi (`L3`)** : calcul **entier**, sans flottant ; le montant d'une
## ligne est arrondi à l'entier **inférieur** (division entière de
## `valeur_credits × unités` par `masse_soute`), le total est la **somme des
## montants de ligne**. La soute ne reçoit que des tuiles entières (« tout ou
## rien », `3.5`) : en jeu, la division tombe juste et l'arrondi ne joue pas ;
## il ne sert qu'à garantir qu'une fraction de tuile ne soit jamais payée.
## [br]— **Une seule fonction de calcul** : `quote_cargo()` produit la cotation
## affichée **avant** la vente (critère 5) ; `sell_cargo()` crédite **exactement**
## le total de cette même cotation. Affichage et crédit ne peuvent pas diverger.
## La cotation est calculable **sans vendre** : le secours carburant de `5.3`
## (`Q56`) s'en sert (`_cargo_value()`).
## [br]— **Données seules (`D1`, `L1`)** : prix et masses lus dans
## `data/resources.json` par la façade `GameData` ; aucun prix ni coefficient ici.
## [br]— **Échec bruyant (`D2`)** : une ressource de la soute **inconnue** du
## catalogue, ou de masse non positive ou de prix négatif, rend la cargaison invalide : `push_error`,
## et la vente est **refusée en entier** — ni crédit, ni soute vidée. Jamais de
## vente à zéro silencieuse, jamais de perte silencieuse de minerai. Une
## ressource connue mais `actif_mvp: false` se vend au prix du catalogue : la
## filtrer à l'entrée est la règle de la soute (`CargoSystem`, `Q12`/`K10`).
## [br]— **Vente à la station seulement** (critère 6) : refusée hors de la zone de
## surface (`GameState.is_in_surface_zone()`), même si un appelant l'invoquait.
## [br]— **Écriture de l'état par ses mutateurs seuls** (critère 7) :
## `GameState.set_credits()` (borné, jamais négatif) puis
## `GameState.clear_cargo()`, dans le même appel : HUD (crédits, charge) et
## réarmement de l'alerte de soute pleine (`CargoSystem`, `4.2`) suivent par les
## signaux `credits_changed` et `cargo_changed`, **à la même image**.
##
## Ravitaillement et réparation (story 5.3, `Q56` (a), `Q63` (a)) :
## [br]— **Tarifs en données** (`D1`) : prix par unité de carburant, prix par
## point de blindage et seuil de secours, bloc `station` de
## `data/upgrades.json`, lus par la façade. Aucun prix ici.
## [br]— **Arrondi (`L3`) — on paie des graduations entières de la jauge** : la
## quantité manquante est `round(maximum) − ceil(courant)`, **exactement la
## graduation qu'affiche le HUD** (`HUD.format_gauge()`). Le joueur paie ce qu'il
## voit manquer ; au plein complet, la fraction d'unité entamée est offerte et la
## jauge est portée au **maximum exact**. Une recharge partielle ajoute des unités
## entières : la jauge affichée monte d'autant. Calcul entier pour les crédits :
## `unités × prix`, jamais de fraction de crédit. Unités achetables à crédits
## donnés : division entière `crédits ÷ prix` (entier inférieur).
## [br]— **Une seule fonction de calcul par service** : `quote_refuel()` et
## `quote_repair()` produisent la cotation affichée ; `refuel()` et
## `repair_armor()` appliquent **cette même cotation** — débit = montant affiché.
## [br]— **Partiel à hauteur des crédits, crédits jamais négatifs** (`TM-5.7`,
## `H2`) : faute de crédits pour un service complet, on achète le maximum
## d'unités entières payables ; si les crédits n'en paient pas une seule, rien ne
## change.
## [br]— **Secours carburant (`Q56`)** : si le carburant est sous le seuil
## (`ratio × réservoir courant`) et que **crédits + valeur de vente de la soute**
## (`quote_cargo()`, règle `Q37`, sans rien vendre) ne paient pas les unités
## jusqu'au seuil, le carburant est porté **gratuitement jusqu'au seuil exact**,
## jamais au-delà ; les crédits disponibles achètent ensuite, au tarif normal, ce
## qu'ils peuvent au-dessus. Une soute **invendable** (`INVALID_CARGO`) compte
## pour zéro : elle ne peut rien rapporter. **Aucun secours pour le blindage**
## (`Q63`) : le blindage n'est pas nécessaire pour repartir.
## [br]— **À la station seulement**, comme la vente.
## [br]— **Écrivains** : carburant par `GameState.set_fuel()` (le composant
## `FuelSystem` constate la sortie de panne et de seuil bas par `fuel_changed`,
## comme il l'a prévu dès `2.3`) ; blindage **par `ArmorSystem.repair()`**, seul
## écrivain du blindage (`M1`), passé par l'appelant ; crédits par
## `GameState.set_credits()`. Réparation refusée pendant la transition de
## destruction (`ArmorSystem.can_act()`).
##
## Rayon des améliorations (story 5.4, `Q18`, `Q21`) :
## [br]— **Catalogue lu, jamais écrit ici** (`Q21`, `L5`) : le rayon cote les
## améliorations `actif_mvp: true` de `data/upgrades.json`, dans l'ordre du
## fichier (`GameData.get_mvp_upgrade_ids()`) ; aucune liste d'`id` dans le code.
## Une amélioration inconnue ou inactive n'est ni cotée ni vendue.
## [br]— **Coût et valeur calculés par `5.6`, jamais ici** (`Q18`, `L1`, `L3`) :
## `GameData.get_upgrade_next_cost(id, niveau courant)` et
## `GameData.get_upgrade_value(id, niveau)`. Aucun chiffre de coût, aucun
## arrondi supplémentaire : la cotation porte l'entier rendu par la façade, et
## `buy_upgrade()` débite **ce même entier** (coût affiché = débit).
## [br]— **Aucun plafond** (`Q18`, `L2`) : le niveau suivant est toujours
## `niveau + 1`, sans borne ni branche « niveau maximal » ; un achat n'est refusé
## que faute de crédits (ou hors station), jamais définitivement.
## [br]— **Crédits jamais négatifs** (`TM-5.7`) : crédits < coût ⇒ refus, rien
## ne change. Sinon `GameState.set_credits()` puis `GameState.set_upgrade_level()`
## dans le **même appel** : `credits_changed` et `upgrade_level_changed` partent
## à la même image. **L'effet sur les systèmes de jeu n'est pas appliqué ici** :
## les abonnés de `upgrade_level_changed` l'appliquent dans ce même appel (story
## 5.5 : `FuelSystem`, `ArmorSystem`, `CargoSystem` ; `MiningSystem` relit le
## niveau du foret), sans remplir ni réparer.
## [br]— **À la station seulement**, comme la vente et les services.
##
## **Validation headless** : ce fichier référence les autoloads `GameData` et
## `GameState` — faux « Identifier not found » hors exécution du projet,
## exception `qa/README.md` §4 (stories `1.9`, `2.9`).

## Issue d'une cotation ou d'une vente.
enum Outcome {
	## Cotation calculée, cargaison vendable.
	QUOTED,
	## Vente faite : crédits augmentés du total, soute vidée.
	SOLD,
	## Soute vide : rien à vendre, rien n'a changé.
	EMPTY,
	## Ressource inconnue du catalogue (ou de masse ou de prix invalide) : rien
	## n'a changé.
	INVALID_CARGO,
	## Foreuse hors de la zone de surface : aucune vente sous terre.
	NOT_AT_STATION,
}


## Issue d'une cotation ou d'un service de la station (story 5.3).
enum ServiceOutcome {
	## Service complet payable : jauge portée au maximum.
	FULL,
	## Crédits insuffisants pour le complet : maximum d'unités payables.
	PARTIAL,
	## Secours carburant gratuit jusqu'au seuil (`Q56`), plus ce que les
	## crédits paient au-dessus.
	RESCUE,
	## Jauge déjà pleine : rien à faire.
	ALREADY_FULL,
	## Crédits insuffisants pour une seule unité, sans secours : rien ne change.
	INSUFFICIENT_CREDITS,
	## Foreuse hors de la zone de surface.
	NOT_AT_STATION,
	## Service indisponible : tarifs non chargés, ou foreuse en cours de
	## destruction (réparation).
	UNAVAILABLE,
}


## Cotation d'un service, ou reçu une fois appliqué. Mêmes champs pour le
## carburant et le blindage ; `rescue_*` ne vaut que pour le carburant.
class ServiceQuote:
	extends RefCounted
	var outcome: ServiceOutcome = ServiceOutcome.UNAVAILABLE
	## Jauge avant le service, et son maximum courant.
	var current: float = 0.0
	var maximum: float = 0.0
	## Prix d'une unité (carburant) ou d'un point (blindage), en crédits.
	var unit_price: int = 0
	## Unités entières manquantes pour le complet (graduation du HUD), après
	## l'éventuel secours.
	var missing_units: int = 0
	## Unités payées, et leur coût : ce qui est affiché, ce qui est débité.
	var paid_units: int = 0
	var cost: int = 0
	## Carburant offert par le secours, jusqu'au seuil exact.
	var rescue_amount: float = 0.0
	## Seuil du secours (carburant), en quantité.
	var rescue_threshold: float = 0.0
	## Jauge après le service.
	var target: float = 0.0


## Issue d'une cotation ou d'un achat d'amélioration (story 5.4).
enum UpgradeOutcome {
	## Niveau suivant coté, payable avec les crédits disponibles.
	AFFORDABLE,
	## Niveau suivant coté, crédits insuffisants : l'achat serait refusé.
	INSUFFICIENT_CREDITS,
	## Achat fait : crédits débités du coût coté, niveau incrémenté.
	BOUGHT,
	## Foreuse hors de la zone de surface.
	NOT_AT_STATION,
	## Amélioration inconnue du catalogue, ou inactive au MVP : ni cotée ni
	## vendue.
	UNAVAILABLE,
}


## Cotation d'une amélioration, ou reçu une fois achetée. Les niveaux et
## valeurs sont ceux **d'avant** l'achat : `level` → `level + 1`.
class UpgradeQuote:
	extends RefCounted
	var outcome: UpgradeOutcome = UpgradeOutcome.UNAVAILABLE
	var upgrade_id: String = ""
	## Nom et description lus dans les données.
	var display_name: String = ""
	var description: String = ""
	## Niveau courant (avant l'achat), et niveau que l'achat fait atteindre.
	var level: int = 0
	var next_level: int = 0
	## Valeur du niveau courant et du niveau suivant (fonction de `5.6`).
	var current_value: float = 0.0
	var next_value: float = 0.0
	## Coût du niveau suivant : ce qui est affiché, ce qui est débité.
	var cost: int = 0
	## Crédits disponibles au moment de la cotation (avant l'achat).
	var credits: int = 0


## Une ligne de cotation : une ressource de la soute et ce qu'elle rapporte.
class SaleLine:
	extends RefCounted
	var resource_id: String = ""
	var display_name: String = ""
	## Unités de masse occupées en soute.
	var units: int = 0
	## Tuiles entières que représentent ces unités (`units ÷ masse_soute`).
	var tiles: int = 0
	## Montant de la ligne, en crédits (règle `Q37`, arrondi `L3`).
	var amount: int = 0


## Cotation de la soute entière, ou reçu d'une vente.
class SaleQuote:
	extends RefCounted
	var outcome: Outcome = Outcome.EMPTY
	## Lignes dans l'ordre du catalogue de `data/resources.json`.
	var lines: Array[SaleLine] = []
	## Somme des montants de ligne : ce qui est affiché, ce qui est crédité.
	var total: int = 0
	## `resource_id` de la soute que le catalogue ne sait pas vendre.
	var invalid_ids: Array[String] = []


## Montant d'une ligne de vente — **fonction pure** : `Q37` et règle d'arrondi
## (`L3`) en un seul point. Renvoie `-1` si la masse n'est pas positive ou si
## le prix ou la quantité est négatif : le montant n'a pas de sens, l'appelant
## doit refuser la vente.
static func line_amount(value_credits: int, units: int, mass: int) -> int:
	if mass <= 0 or value_credits < 0 or units < 0:
		return -1
	@warning_ignore("integer_division")
	return (value_credits * units) / mass


## Cote le contenu actuel de la soute, **sans rien vendre** ni rien écrire.
func quote_cargo() -> SaleQuote:
	var quote: SaleQuote = SaleQuote.new()
	var cargo: Dictionary[String, int] = GameState.get_cargo_contents()
	if cargo.is_empty():
		quote.outcome = Outcome.EMPTY
		return quote
	for resource_id: String in GameData.get_resource_ids():
		var units: int = cargo.get(resource_id, 0)
		if units <= 0:
			continue
		var line: SaleLine = _quote_line(resource_id, units)
		if line == null:
			quote.invalid_ids.append(resource_id)
			continue
		quote.lines.append(line)
		quote.total += line.amount
	# Ce que le catalogue ne connaît pas n'a pas été parcouru ci-dessus.
	var unknown_ids: Array[String] = []
	for resource_id: String in cargo:
		if not GameData.has_resource(resource_id):
			unknown_ids.append(resource_id)
	unknown_ids.sort()
	for resource_id: String in unknown_ids:
		push_error("EconomySystem — « %s » est en soute mais absente de %s : cargaison invendable, vente refusée." % [resource_id, GameData.RESOURCES_PATH])
		quote.invalid_ids.append(resource_id)
	quote.outcome = Outcome.QUOTED if quote.invalid_ids.is_empty() else Outcome.INVALID_CARGO
	return quote


## Vend toute la soute, **à la station seulement**. Crédite exactement le total
## de `quote_cargo()` et vide la soute ; dans tout autre cas, ne change rien.
## Renvoie le reçu (issue `SOLD`) ou la raison du refus.
func sell_cargo() -> SaleQuote:
	if not GameState.is_in_surface_zone():
		var refused: SaleQuote = SaleQuote.new()
		refused.outcome = Outcome.NOT_AT_STATION
		return refused
	var quote: SaleQuote = quote_cargo()
	if quote.outcome != Outcome.QUOTED:
		return quote
	GameState.set_credits(GameState.get_credits() + quote.total)
	GameState.clear_cargo()
	quote.outcome = Outcome.SOLD
	return quote


# --- Ravitaillement et réparation (story 5.3) -----------------------------------

## Unités entières manquantes d'une jauge — **fonction pure**, règle d'arrondi
## (`L3`) en un seul point : la graduation affichée par le HUD
## (`round(maximum) − ceil(courant)`), jamais négative.
static func missing_units(current: float, maximum: float) -> int:
	return maxi(roundi(maximum) - ceili(current), 0)


## Unités entières payables — **fonction pure** : `crédits ÷ prix`, entier
## inférieur. `0` pour un prix non positif (service non tarifé, refusé).
static func affordable_units(credits: int, unit_price: int) -> int:
	if unit_price <= 0 or credits <= 0:
		return 0
	@warning_ignore("integer_division")
	return credits / unit_price


## Cote le plein, secours compris, **sans rien écrire**.
func quote_refuel() -> ServiceQuote:
	var quote: ServiceQuote = ServiceQuote.new()
	quote.current = GameState.get_fuel()
	quote.maximum = GameState.get_fuel_max()
	quote.target = quote.current
	if not GameData.has_station_services():
		quote.outcome = ServiceOutcome.UNAVAILABLE
		return quote
	quote.unit_price = GameData.get_fuel_unit_price()
	quote.rescue_threshold = GameData.get_rescue_fuel_ratio() * quote.maximum
	var credits: int = GameState.get_credits()
	var base: float = quote.current
	if quote.current < quote.rescue_threshold:
		var to_threshold: int = missing_units(quote.current, quote.rescue_threshold) * quote.unit_price
		if credits + _cargo_value() < to_threshold:
			quote.rescue_amount = quote.rescue_threshold - quote.current
			base = quote.rescue_threshold
	quote.missing_units = missing_units(base, quote.maximum)
	quote.paid_units = mini(quote.missing_units, affordable_units(credits, quote.unit_price))
	quote.cost = quote.paid_units * quote.unit_price
	quote.outcome = _service_outcome(quote)
	quote.target = _target(quote, base)
	return quote


## Fait le plein selon `quote_refuel()`, **à la station seulement** : débite
## exactement le coût coté et porte le carburant à la cible cotée. Renvoie le
## reçu, ou la raison pour laquelle rien n'a changé.
func refuel() -> ServiceQuote:
	if not GameState.is_in_surface_zone():
		return _refused(ServiceOutcome.NOT_AT_STATION, GameState.get_fuel(), GameState.get_fuel_max())
	var quote: ServiceQuote = quote_refuel()
	if not _is_applicable(quote):
		return quote
	GameState.set_credits(GameState.get_credits() - quote.cost)
	GameState.set_fuel(quote.target)
	return quote


## Cote la réparation, **sans rien écrire**. Aucun secours (`Q63`). Indisponible
## sans composant de blindage, ou pendant la transition de destruction.
func quote_repair(armor_system: ArmorSystem) -> ServiceQuote:
	var quote: ServiceQuote = ServiceQuote.new()
	quote.current = GameState.get_armor()
	quote.maximum = GameState.get_armor_max()
	quote.target = quote.current
	if not GameData.has_station_services() or armor_system == null or not armor_system.can_act():
		quote.outcome = ServiceOutcome.UNAVAILABLE
		return quote
	quote.unit_price = GameData.get_armor_point_price()
	quote.missing_units = missing_units(quote.current, quote.maximum)
	quote.paid_units = mini(quote.missing_units, affordable_units(GameState.get_credits(), quote.unit_price))
	quote.cost = quote.paid_units * quote.unit_price
	quote.outcome = _service_outcome(quote)
	quote.target = _target(quote, quote.current)
	return quote


## Répare selon `quote_repair()`, **à la station seulement**, par
## `ArmorSystem.repair()` (`M1`). Les crédits ne sont débités que si le
## composant a accepté la réparation : jamais de paiement sans blindage rendu.
func repair_armor(armor_system: ArmorSystem) -> ServiceQuote:
	if not GameState.is_in_surface_zone():
		return _refused(ServiceOutcome.NOT_AT_STATION, GameState.get_armor(), GameState.get_armor_max())
	var quote: ServiceQuote = quote_repair(armor_system)
	if not _is_applicable(quote):
		return quote
	if not armor_system.repair(quote.target - quote.current):
		quote.outcome = ServiceOutcome.UNAVAILABLE
		quote.target = quote.current
		return quote
	GameState.set_credits(GameState.get_credits() - quote.cost)
	return quote


## Issue d'une cotation chiffrée : secours d'abord, puis complet, partiel, rien.
func _service_outcome(quote: ServiceQuote) -> ServiceOutcome:
	if quote.rescue_amount > 0.0:
		return ServiceOutcome.RESCUE
	if quote.missing_units == 0:
		return ServiceOutcome.ALREADY_FULL
	if quote.paid_units == quote.missing_units:
		return ServiceOutcome.FULL
	if quote.paid_units > 0:
		return ServiceOutcome.PARTIAL
	return ServiceOutcome.INSUFFICIENT_CREDITS


## Jauge après le service. Complet (secours compris) : le **maximum exact**, la
## fraction d'unité entamée étant offerte. Partiel : `base + unités payées`, la
## graduation affichée montant d'autant. Rien d'applicable : inchangée.
func _target(quote: ServiceQuote, base: float) -> float:
	if not _is_applicable(quote):
		return quote.current
	if quote.paid_units == quote.missing_units:
		return quote.maximum
	return minf(base + quote.paid_units, quote.maximum)


func _is_applicable(quote: ServiceQuote) -> bool:
	return quote.outcome == ServiceOutcome.FULL or quote.outcome == ServiceOutcome.PARTIAL or quote.outcome == ServiceOutcome.RESCUE


func _refused(outcome: ServiceOutcome, current: float, maximum: float) -> ServiceQuote:
	var quote: ServiceQuote = ServiceQuote.new()
	quote.outcome = outcome
	quote.current = current
	quote.maximum = maximum
	quote.target = current
	return quote


## Ce que la soute rapporterait si elle était vendue maintenant (`Q37`), sans
## la vendre ; zéro si elle est vide ou invendable.
func _cargo_value() -> int:
	var quote: SaleQuote = quote_cargo()
	return quote.total if quote.outcome == Outcome.QUOTED else 0


## Ligne d'une ressource **connue** ; `null` (et erreur signalée) si sa masse ou
## son prix rend le montant incalculable.
func _quote_line(resource_id: String, units: int) -> SaleLine:
	var mass: int = GameData.get_resource_mass(resource_id)
	var value: int = GameData.get_resource_value(resource_id)
	var amount: int = line_amount(value, units, mass)
	if amount < 0:
		push_error("EconomySystem — « %s » : valeur_credits %d / masse_soute %d invalides dans %s, prix incalculable : vente refusée." % [resource_id, value, mass, GameData.RESOURCES_PATH])
		return null
	var line: SaleLine = SaleLine.new()
	line.resource_id = resource_id
	line.display_name = GameData.get_resource_name(resource_id)
	line.units = units
	@warning_ignore("integer_division")
	line.tiles = units / mass
	line.amount = amount
	return line


# --- Rayon des améliorations (story 5.4) ---------------------------------------

## Cote **toutes** les améliorations actives au MVP, dans l'ordre du catalogue,
## sans rien écrire. La liste vient des données (`Q21`) : aucune n'est nommée ici.
func quote_upgrades() -> Array[UpgradeQuote]:
	var quotes: Array[UpgradeQuote] = []
	for upgrade_id: String in GameData.get_mvp_upgrade_ids():
		quotes.append(quote_upgrade(upgrade_id))
	return quotes


## Cote le niveau suivant d'une amélioration, **sans rien écrire** : niveau et
## valeur courants, valeur et coût du niveau suivant (fonctions de `5.6`).
## `UNAVAILABLE` pour une amélioration inconnue (erreur signalée par la façade)
## ou inactive au MVP.
func quote_upgrade(upgrade_id: String) -> UpgradeQuote:
	var quote: UpgradeQuote = UpgradeQuote.new()
	quote.upgrade_id = upgrade_id
	quote.credits = GameState.get_credits()
	if not GameData.is_upgrade_active_in_mvp(upgrade_id):
		return quote
	quote.display_name = GameData.get_upgrade_name(upgrade_id)
	quote.description = GameData.get_upgrade_description(upgrade_id)
	quote.level = GameState.get_upgrade_level(upgrade_id)
	quote.next_level = quote.level + 1
	quote.current_value = GameData.get_upgrade_value(upgrade_id, quote.level)
	quote.next_value = GameData.get_upgrade_value(upgrade_id, quote.next_level)
	quote.cost = GameData.get_upgrade_next_cost(upgrade_id, quote.level)
	quote.outcome = UpgradeOutcome.AFFORDABLE if quote.credits >= quote.cost else UpgradeOutcome.INSUFFICIENT_CREDITS
	return quote


## Achète le niveau suivant selon `quote_upgrade()`, **à la station seulement** :
## débite exactement le coût coté, puis incrémente le niveau dans `GameState`.
## Crédits insuffisants : rien ne change. Renvoie le reçu (`BOUGHT`, niveaux et
## valeurs d'avant l'achat) ou la cotation qui explique le refus.
func buy_upgrade(upgrade_id: String) -> UpgradeQuote:
	if not GameState.is_in_surface_zone():
		var refused: UpgradeQuote = UpgradeQuote.new()
		refused.upgrade_id = upgrade_id
		refused.outcome = UpgradeOutcome.NOT_AT_STATION
		refused.credits = GameState.get_credits()
		return refused
	var quote: UpgradeQuote = quote_upgrade(upgrade_id)
	if quote.outcome != UpgradeOutcome.AFFORDABLE:
		return quote
	GameState.set_credits(quote.credits - quote.cost)
	GameState.set_upgrade_level(upgrade_id, quote.next_level)
	quote.outcome = UpgradeOutcome.BOUGHT
	return quote
