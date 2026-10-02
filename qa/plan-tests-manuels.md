# Plan de tests manuels humains — MVP *Exterminatus Drill*

Ce plan liste les cas de test **exécutés par l'humain dans Godot**, sprint par sprint.
Les agents vérifient en amont ce qui est automatisable en headless ; ce plan ne couvre que ce qui exige un jugement humain à l'écran — cf. `qa/README.md` §4.

Référence fonctionnelle : `cahier_des_charges_motherload_40k_godot.md`, **amendé par `cahier_des_charges_gameplay_addictif.md`** (arbitrage **Q16** du 2026-09-06, story `1.10`). Les cas ajoutés le 2026-09-06 portent la mention de leur § d'origine.

> ⛔ **Régime d'exécution changé le 2026-09-26 — décision utilisateur, story `2.8`.** Il n'y a plus de campagne par sprint : **ce plan est exécuté en une seule fois, en fin de projet**, à la story `7.8` (*recette humaine unique du MVP*). Le plan est **conservé intégralement** — aucun cas supprimé, aucun cas renuméroté : le report change **quand** les cas sont joués, pas **ce qui** est joué. Les sections « Sprint N » ci-dessous restent la structure de lecture et l'**ordre d'exécution** de la campagne finale.

- Chaque cas a un identifiant stable `TM-<phase>.<n>` : **ne pas renuméroter**.
- Sévérité indicative : **B** = bloquant (interdit la validation du MVP), **M** = majeur, **m** = mineur. *Avant `2.8`, « B » interdisait le commit de phase ; le commit ne dépend plus que de l'audit qualité.*
- **Campagne unique, dans l'ordre des sprints** : `TM-1.x`, puis `TM-2.x`, … jusqu'à `TM-7.x`. Le marquage `[REG]` perd son rôle de sélection — tous les cas sont joués — mais il est **conservé** : il désigne les cas à **rejouer en priorité** après une correction ou une itération.
- Les cas du **sprint 0** restent les seuls hors périmètre : ils ont été annulés par la story `0.10`.
- Le résultat est consigné dans un rapport créé depuis `qa/rapport-test-template.md`, déposé dans `qa/rapports/`.

---

## 0. Prérequis

| # | Prérequis | Statut |
|---|---|---|
| P1 | **Godot 4.x stable installé** sur la machine de test | ✅ satisfait — Godot **4.7.2 stable** (`godot --version` → `4.7.2.stable.official.ed1daf0bf`), installé en story `0.6`. À revérifier sur tout nouveau poste de test. |
| P2 | Le dépôt est cloné/ouvert localement | |
| P3 | Le projet s'importe dans l'éditeur sans erreur d'import | |
| P4 | **Graine de génération figée** pour toute la campagne de tests du sprint (à partir du sprint 3) : la graine est fixée avant le premier cas, notée dans le rapport, et **n'est pas modifiée** jusqu'au dernier cas — sauf pour les cas qui la font varier explicitement (`TM-3.14`, `TM-3.15`), après lesquels la graine de campagne est restaurée | à partir du sprint 3 |
| P5 | **Graine du tirage de loot journalisée et reportée** (amendement §2) : la graine effectivement utilisée pour le tirage de loot est affichée au démarrage et **recopiée en en-tête du rapport**. Elle peut être la même que celle de la génération de terrain, mais elle doit être **lisible**. Sans elle, aucun cas de loot n'est rejouable et toute anomalie de drop est irrecevable | à partir du sprint 3 |
| P6 | **Graine du tirage de menace journalisée** (amendement §4, arbitrage Q17) : le tirage de menace utilise un RNG **distinct** de celui de la génération ; sa graine est journalisée et reportée. Une rencontre hostile ne doit jamais décaler le terrain à graine identique | à partir du sprint 6 |

> Si l'un des prérequis `P1` à `P3` n'est **pas** satisfait sur le poste de test, la story de recette `7.8` passe à **Bloquée**, pas à Terminée, et la cause est notée. `P1` étant satisfait depuis la story `0.6`, cette règle ne bloque plus la campagne. **`P4`, `P5` et `P6` (graines figées et journalisées) s'appliquent à toute la campagne finale**, et non plus « à partir du sprint N » : la colonne « Statut » conserve le sprint qui les introduit, mais ils sont tous exigibles à `7.8`.

> **Charge de la campagne finale** : le report des gates `2.7`, `3.9`, `4.6`, `5.9` et `6.10` porte `7.8` à l'intégralité des cas `TM-1.1` à `TM-7.12`, soit une soixantaine de cas en une seule passe. Prévoir **plusieurs séances** et consigner au fil de l'eau — un cas non exécuté se note « Non exécuté », **jamais `OK`**.

> **Règle de campagne (arbitrage Q6, 2026-08-29)** : le terrain étant semi-procédural dès le MVP, **aucun résultat n'est reproductible sans graine fixe**. Toute anomalie rapportée sans la graine de campagne est irrecevable : le rapport de test doit mentionner la graine utilisée en en-tête. Changer de graine en cours de campagne invalide les cas déjà exécutés sur le terrain.

---

## Sprint 0 — Amorçage (documentation & dépôt)

| ID | Cas | Procédure | Attendu | Sév. |
|---|---|---|---|---|
> ⛔ **Sprint 0 — cas non exécutés.** La story `0.5` a été **annulée** le 2026-08-29 sur décision de l'utilisateur (story `0.10`). Les trois cas ci-dessous n'ont pas été joués et ne le seront pas. `TM-0.2`, de sévérité bloquante, était le seul contrôle **humain** de la couverture du CDC par le découpage ; cette couverture ne repose désormais que sur les tables de traçabilité de `stories/BACKLOG.md`, produites par des agents. Les cas des sprints 1 à 7 restent, eux, pleinement en vigueur.

| TM-0.1 | Lisibilité du backlog | Lire `stories/BACKLOG.md` et `stories/AVANCEMENT.md` | Le découpage phases/sprints est compris et validé par l'utilisateur | M |
| TM-0.2 | Couverture du CDC | Confronter le backlog aux « MVP jouable » (8 points) et « Critères d'acceptation MVP » du CDC | Chaque point est couvert par au moins une story | B |
| TM-0.3 | Dépôt Git | `git status` à la racine | Dépôt initialisé, `.gitignore` présent, aucun fichier généré suivi | M |

---

## Sprint 1 — Fondations techniques Godot

| ID | Cas | Procédure | Attendu | Sév. |
|---|---|---|---|---|
| TM-1.1 `[REG]` | Ouverture du projet | Ouvrir le projet dans Godot 4.x | Import terminé, **0 erreur** dans le dock *Debugger*/*Output* | B |
| TM-1.2 `[REG]` | Lancement | `F5` | La scène principale se lance, fenêtre affichée, aucune erreur console | B |
| TM-1.3 | Arborescence | Inspecter le *FileSystem* | `scenes/`, `scripts/`, `data/`, `assets/` conformes au CDC | M |
| TM-1.4 | Input Map | *Project Settings > Input Map* | Les 12 actions du CDC existent, avec les touches par défaut attendues | B |
| TM-1.5 ⏭ | ~~Test des touches~~ **→ exécuté au sprint 2** | *Non joué au sprint 1* : aucun code ne consomme les entrées avant la phase 2, et la « scène de test d'input » n'a volontairement pas été créée (elle serait un artefact de debug au sens du point d'audit A5). Voir le rappel en tête du sprint 2. | — | M |
| TM-1.6 | Autoload `GameState` | *Projet > Paramètres du projet…* → onglet **AutoLoad** (« Chargements automatiques »), puis `F5` et, **pendant l'exécution**, dock **Scène** → sélecteur **Distant** | **Bloquant** : `GameData` puis `GameState` sont déclarés et activés, dans cet ordre (Q4), aucun autre autoload, et le jeu démarre sans erreur. **Non bloquant** : si l'Inspecteur distant les affiche, les valeurs initiales sont conformes — ce sont des variables **privées non exportées**, dont l'affichage n'est pas garanti. Leur non-affichage n'est **pas** un KO ; la vérification est alors **transférée à `TM-4.1`**. *Procédure corrigée par la story `1.12` : le vocabulaire initial (*Globals*, arbre distant dans le *Débogueur*) était du Godot 3.* | B |
| TM-1.7 | Arbre de `Main.tscn` **et** de `World.tscn` | Ouvrir `scenes/main/Main.tscn`, puis `scenes/world/World.tscn` **séparément** | **En deux écrans** : `Main.tscn` affiche **8 nœuds** (`World` est une **instance** — l'éditeur n'affiche pas ses enfants) ; `World.tscn` ouverte seule affiche **5 nœuds** et **c'est là** que se constatent les 3 avertissements « TileSet manquant ». Total projet 12 nœuds, vérifié en deux temps. **Ne pas activer « Modifiable enfants »** sur `World`. *Procédure corrigée par la story `1.12`.* | M |
| TM-1.8 | Chargement des données | Lancer le jeu | Les JSON de `data/` sont chargés sans erreur de parsing ; le nombre d'entrées est loggé | M |

---

## Sprint 2 — Foreuse et déplacement

| ID | Cas | Procédure | Attendu | Sév. |
|---|---|---|---|---|
| TM-1.5 ⏮ | **Test des touches** *(reporté du sprint 1)* | Presser successivement chacune des 12 touches pendant une partie, en maintenant l'appui une seconde | Chaque action est reconnue **une et une seule fois par appui** — la répétition clavier (`echo`) ne redéclenche pas l'action ponctuelle. Identifiant conservé : un cas de test ne se renumérote pas. | M |
| TM-2.1 `[REG]` | Déplacement 4 directions | Se déplacer dans un tunnel libre avec ZQSD puis les flèches | Déplacement fluide dans les 4 directions, les deux jeux de touches équivalents | B |
| TM-2.2 `[REG]` | Directions opposées | Poser la foreuse **au sol** dans un tunnel, puis presser **gauche+droite** ensemble, relâcher, puis **haut+bas** ensemble. Répéter une fois **en vol**, au-dessus d'un vide. *Procédure précisée par la story `2.2`.* | **Au sol : aucun mouvement**, aucune vibration, aucune oscillation, aucune erreur. **En vol** : les touches s'annulent aussi — ni poussée, ni descente forcée — mais **la gravité continue de s'appliquer** : la chute se poursuit, identique à celle observée touches relâchées. Ce n'est **pas** une anomalie : la gravité n'est pas une direction commandée, et le CDC n'annule que les paires de directions. | B |
| TM-2.3 | Gravité et chute | Se placer au-dessus d'un vide et lâcher les touches | La foreuse tombe, atterrit sans traverser le sol | B |
| TM-2.4 | Propulsion | Maintenir `move_up` dans un tunnel vide | Montée progressive, consommation de carburant visible | M |
| TM-2.5 | Freinage | Maintenir `brake` en mouvement | Vitesse et inertie visiblement réduites | m |
| TM-2.6 `[REG]` | Collisions | Foncer contre un bloc non détruit dans chaque direction | Impossible de traverser, pas de blocage/téléportation | B |
| TM-2.7 | Caméra | Se déplacer largement | La caméra suit sans saccade et ne sort pas des limites définies | m |
| TM-2.8 `[REG]` | Panne sèche | Épuiser le carburant | Ni forage ni propulsion possibles ; la chute reste possible ; message/alerte clair | B |
| TM-2.9 `[REG]` | **Dégâts de chute et d'impact** (Q20, amendement §4.3) | Trois chutes de hauteurs croissantes : (a) une chute courte, sous le seuil ; (b) une chute moyenne ; (c) la plus haute chute possible sur la carte. Relever la valeur de blindage avant et après chacune | (a) **aucun dégât** : sous le seuil, le déplacement normal n'est jamais punitif — un déplacement ordinaire qui grignote le blindage est un échec. (b) et (c) : le blindage est **réellement décrémenté** à l'écran, et les dégâts **croissent avec la vitesse d'impact** — la chute (c) coûte nettement plus que la (b). Consigner les 3 valeurs. Ce cas est la **preuve visible** que l'`ArmorSystem` a un appelant dès le sprint 2 | B |
| TM-2.11 `[REG]` | **Arbre de `DrillRig.tscn` et foreuse visible** (story `2.1`) | Ouvrir `scenes/player/DrillRig.tscn` dans l'éditeur et déplier l'arbre dans le dock **Scène** (*Scene*). Puis ouvrir `Main.tscn` et lancer `F5` | L'arbre affiche **exactement 10 nœuds** — `DrillRig` (**CharacterBody2D**), `Sprite2D`, `CollisionShape2D`, `DrillSystem`, `FuelSystem`, `ArmorSystem`, `ScannerSystem`, `Audio`, et sous `Audio` : `EngineAudio`, `DrillAudio`, `AlertAudio` (soit 11 avec les 3 enfants d'`Audio` — les compter à l'écran). **Aucun avertissement de configuration** : une `CollisionShape2D` sans forme en produirait un. Dans `Main.tscn`, `DrillRig` apparaît comme **instance** entre `World` et `Camera2D`, et **la foreuse est visible à l'écran** au lancement | M |
| TM-2.10 | **État de destruction de la foreuse** (Q17, Q20) | Enchaîner des chutes jusqu'à amener le blindage à **zéro** | La transition vers l'état « détruite » est **explicite et lisible** (retour visuel et sonore) ; le jeu ne plante pas, ne se fige pas, et la foreuse n'est ni pilotable ni capable de forer pendant la transition. **Au sprint 2, il n'y a encore ni cargo ni sauvegarde** : la vérification complète de la règle §4.3 (« la perte n'est jamais totale ») est faite par `TM-6.8`, une fois le cargo et la sauvegarde livrés. Ici, seul le comportement de l'état est jugé | M |

---

## Sprint 3 — Terrain destructible et forage

| ID | Cas | Procédure | Attendu | Sév. |
|---|---|---|---|---|
| TM-3.1 `[REG]` | Forage vers le bas | Maintenir `move_down`/`drill` sur une tuile minable | La tuile disparaît après un délai lié à sa dureté ; la foreuse descend | B |
| TM-3.2 `[REG]` | **Aucun forage vers le haut** | Maintenir `move_up` sous une tuile minable | **La tuile n'est jamais détruite**, quelle que soit la durée | B |
| TM-3.3 `[REG]` | Forage latéral soutenu | Poser la foreuse sur un sol solide, forer à gauche puis à droite | Le forage latéral fonctionne | B |
| TM-3.4 `[REG]` | **Pas de forage latéral dans le vide** | En chute ou en vol stationnaire, tenter de forer latéralement | **Aucune destruction** de tuile | B |
| TM-3.5 | Roche dure | Forer une tuile de `hardness` élevée avec le foret MK-I | Forage très lent ou impossible, retour visuel/sonore clair, pas de blocage du jeu | M |
| TM-3.6 `[REG]` | Tuile indestructible | Forer une bordure de carte / tuile `destructible=false` | Aucune destruction, aucune sortie de carte | B |
| TM-3.7 `[REG]` | Collecte de minerai | Forer les 2 minerais du MVP | La charge de soute augmente de la bonne quantité, minerai identifié | B |
| TM-3.8 `[REG]` | Soute pleine | Remplir la soute puis forer un minerai | **Q5 : la tuile est détruite et le minerai est perdu.** Le forage n'est **pas** empêché, la soute ne dépasse jamais sa capacité, la perte est signalée — jamais de dépassement ni de perte silencieuse | B |
| TM-3.9 | Coût en carburant | Forer plusieurs tuiles | Le carburant baisse à chaque forage ; forage impossible à 0 | B |
| TM-3.10 | Retour visuel | Observer un cycle de forage complet | Progression du forage lisible (animation/particules/son), pas de disparition instantanée sans feedback | m |
| TM-3.11 `[REG]` | **Alerte de soute pleine antérieure à la perte** (Q5) | Remplir la soute jusqu'au dernier emplacement, puis forer un minerai supplémentaire | L'alerte « soute pleine » (visuelle **et** sonore) est déclenchée **avant** que le premier minerai ne soit perdu — jamais après, jamais en même temps que la perte | B |
| TM-3.12 `[REG]` | **Perte de minerai visible** (Q5) | Forer 3 minerais consécutifs en soute pleine | Chaque perte donne un retour explicite à l'écran (message et/ou compteur de minerai perdu incrémenté) ; aucune perte silencieuse | B |
| TM-3.13 | **Minerai rare perdu en soute pleine** (Q5) | En soute pleine, forer une tuile du minerai le plus précieux | La tuile est bien détruite et le minerai est **définitivement perdu** — pas d'exception ni de mise en réserve pour les minerais de valeur ; le comportement est identique à celui du minerai commun | M |
| TM-3.14 `[REG]` | **Reproductibilité à graine identique** (Q6) | Forcer la graine `S`, noter le terrain sur 3 écrans (strates, positions de minerai). Quitter, relancer avec la **même** graine `S` | Les deux parties produisent un terrain **strictement identique** : mêmes strates, mêmes tuiles de minerai aux mêmes coordonnées | B |
| TM-3.15 `[REG]` | **Ancrages déterministes indépendants de la graine** (Q6) | Lancer successivement 3 parties avec 3 graines différentes ; relever la position de la zone de surface et celle de l'emplacement de l'anomalie | Zone de surface et emplacement de l'anomalie sont **au même endroit dans les 3 parties** : ils ne dépendent pas de la graine. Au sprint 3 l'anomalie n'est qu'un marqueur — **le contrôle sur l'anomalie réelle est repris par `TM-6.6`**. Restaurer ensuite la graine de campagne (`P4`) | B |
| TM-3.16 `[REG]` | **Bordures indestructibles sur tout le pourtour** (Q6) | Sur au moins 2 graines différentes, longer les 4 bords de la carte (gauche, droite, fond) et tenter d'y forer ; tenter de sortir par le haut hors zone de surface | Une ceinture de tuiles `destructible=false` est présente sur **tout** le pourtour, sans trou ; aucune destruction, aucune sortie de carte, quelle que soit la graine | B |
| TM-3.17 `[REG]` | **Reproductibilité du loot à graine identique** (amendement §2.1, Q19) | Forcer la graine `S`, creuser une **séquence de tuiles notée** (par ex. 30 cases en descente droite) et relever, case par case, le drop obtenu et sa rareté. Quitter, relancer avec la **même** graine `S`, rejouer **exactement** la même séquence | Les deux parties produisent la **même suite de drops**, dans le même ordre, avec les mêmes raretés. Un seul écart invalide le déterminisme du tirage et interdit tout diagnostic d'équilibrage. Reporter la graine en en-tête du rapport (`P5`) | B |
| TM-3.18 `[REG]` | **Jamais 0 % de drop, même à la surface** (règle de design §2.4) | Dans la **couche de surface** uniquement, creuser 100 tuiles minables et compter les drops non vides. Répéter sur une seconde graine | Au moins un drop non vide est obtenu sur les 100 cases, sur **chacune** des deux graines. Aucune couche du jeu ne peut renvoyer « Rien » systématiquement : c'est la règle de design §2.4, le joueur doit être en tension dès la première case. Consigner le nombre de drops obtenus | B |
| TM-3.19 | **Feedback de drop rare** (règle de design §2.4) | Jouer jusqu'à obtenir un drop de rareté haute (relique rare ou artefact légendaire). Si la rareté ne sort pas naturellement en 10 min, forcer temporairement les poids en éditant `data/generation.json`, puis **restaurer le fichier** | Le drop rare déclenche un retour **visuel** (lumière/flash) **et** un retour **sonore distinct** de celui d'un minerai commun. Le retour reste perceptible **suffisamment longtemps** pour être remarqué sans être cherché (repère indicatif : ≥ 1,5 s). Un drop rare visuellement identique à un drop commun est un échec | M |
| TM-3.20 | **Gradient de rareté par profondeur** (amendement §2.2) | À graine de campagne fixe, creuser 50 tuiles dans la couche de surface, puis 50 dans la couche la plus profonde accessible. Relever la répartition des raretés dans chaque échantillon | La proportion de raretés hautes **augmente** visiblement avec la profondeur et celle de « Rien » diminue, dans le sens de la table §2.2. Ce cas mesure une tendance, pas des pourcentages exacts : consigner les deux répartitions dans le rapport, elles alimentent l'équilibrage de la story `7.6` | M |
| TM-3.21 `[REG]` | **Aucune ressource inactive dans le loot** (Q12) | Sur au moins 2 graines, creuser 100 tuiles réparties sur toutes les couches accessibles et relever l'identifiant de chaque ressource obtenue | Seules les ressources `actif_mvp: true` de `data/resources.json` apparaissent (au MVP : `fer_industriel` et `adamantium`). L'apparition d'une ressource inactive — `cuivre`, `promethium_brut`, `cristaux_plasma`, `relique_xeno` — est un échec bloquant. *Ce cas comble une contrainte Q12 qui, jusqu'au 2026-09-06, était annoncée sans être couverte* | B |
| TM-3.22 `[REG]` | **Point d'apparition posé et intact** (story `3.3`, arbitrage `Q33`) | Lancer une **nouvelle partie** et **ne toucher à rien pendant 10 s**. Répéter sur **3 graines** différentes | La foreuse apparaît **posée sur le sol** de la zone de surface, **au même endroit** quelle que soit la graine ; aucune chute, aucune alerte sonore ; profondeur **0 m** et blindage **inchangé** (lisibles au HUD à partir de la phase 4). Le premier écran montre la foreuse et le sous-sol dessous, jamais un écran noir ni une chute | B |

---

## Sprint 4 — HUD et interfaces de bord

| ID | Cas | Procédure | Attendu | Sév. |
|---|---|---|---|---|
| TM-4.1 `[REG]` | HUD temps réel **+ valeurs de départ (transfert de `TM-1.6`)** | Lancer une **nouvelle partie** et relever les 5 valeurs au HUD **avant tout déplacement**, puis jouer un cycle complet | Carburant, blindage, crédits, charge de soute et **profondeur** s'actualisent en temps réel. **De plus (transfert depuis `TM-1.6` e-l, story `1.12`)** : au démarrage d'une partie neuve, le HUD affiche les valeurs de départ résolues depuis `data/upgrades.json` — carburant `100/100`, blindage `100/100`, crédits `0`, soute `0/50`, profondeur `0`. C'est **ici** que ces valeurs deviennent observables par un humain, les variables de `GameState` étant privées et non exportées | B |
| TM-4.2 | Exactitude | Comparer les valeurs HUD avec l'état réel (soute pleine, crédits après vente) | Aucune désynchronisation | B |
| TM-4.3 | Alertes | Descendre le carburant / le blindage sous le seuil, remplir la soute | Alerte visuelle distincte pour chaque cas | M |
| TM-4.4 | Inventaire | `I` puis `Tab` | L'inventaire s'ouvre, **le jeu est en pause**, la refermeture rend la main | M |
| TM-4.5 `[REG]` | Pause | `Échap` en jeu | Menu pause, jeu figé, reprise correcte | B |
| TM-4.6 | Étanchéité des inputs | Ouvrir l'inventaire puis presser les touches de mouvement/forage | La foreuse ne bouge pas et ne fore pas | B |
| TM-4.7 | Lisibilité | Observer le HUD en jeu | Lisible, non masquant, cohérent avec la DA « terminal industriel » | m |

---

## Sprint 5 — Surface, économie et améliorations

| ID | Cas | Procédure | Attendu | Sév. |
|---|---|---|---|---|
| TM-5.1 `[REG]` | Retour surface | Remonter par les galeries | Détection de la zone de surface, interface disponible *(précisé le 2026-10-02, `Q54`, story `5.12` : l'interface s'ouvre quand la foreuse est dans la zone **et** que le joueur presse l'action « Interagir » — touche `E` ; elle ne s'ouvre jamais seule ni sous terre)* *(complété le 2026-10-02, `Q62` (a), story `5.13` : dans la zone de surface, station fermée, une indication « Interagir » avec la touche (`E` par défaut) est visible à l'écran, et disparaît hors de la zone ou station ouverte ; presser `E` à nouveau **ferme** la station ; Échap la ferme aussi, **sans** ouvrir le menu pause)* | B |
| TM-5.2 `[REG]` | Vente | Vendre une cargaison mixte | Crédits crédités selon `data/resources.json`, soute vidée | B |
| TM-5.3 | Ravitaillement | Faire le plein | Carburant au max, crédits débités du bon montant | B |
| TM-5.4 | Réparation | Se faire endommager puis réparer | Blindage restauré, crédits débités *(complété le 2026-10-02, `Q63` (a), story `5.13` : rejouer avec des crédits **insuffisants** pour une réparation complète — le blindage remonte **en partie**, à hauteur des crédits, crédits débités du montant affiché, jamais négatifs, message clair ; **aucune** réparation gratuite, même sans crédits)* | M |
| TM-5.5 `[REG]` | Achat d'amélioration | Acheter capacité de soute, carburant max, puissance du foret | **La statistique change immédiatement** (visible au HUD et en jeu) | B |
| TM-5.6 | Foret amélioré | Forer une roche dure avant/après amélioration du foret | Forage nettement plus rapide/possible après achat | M |
| TM-5.7 | Crédits insuffisants | Tenter un achat trop cher | Achat refusé, message clair, aucun crédit négatif | B |
| TM-5.8 `[REG]` | **Boucle complète non bloquante** | Partir, creuser, collecter, remonter, vendre, ravitailler, repartir — 3 cycles | Aucun blocage définitif de la partie (jamais coincé sans issue ni crédits) | B |
| TM-5.9 | **Mesure du cumul Q5 × Q7** (point d'arbitrage) | Sur les 3 cycles de `TM-5.8`, relever : (a) le nombre d'unités de minerai perdues en soute pleine et leur valeur en crédits, (b) la valeur de la cargaison la plus élevée transportée sans sauvegarde | Le rapport de test **chiffre** les deux pertes potentielles. Ce cas ne peut pas échouer : il impose la mesure, pas un seuil. Il matérialise la réévaluation de l'interaction Q5 × Q7 annoncée au backlog — perte de minerai **et** absence de sauvegarde automatique se cumulent. **La décision d'ajuster ou de conserver le réglage revient à l'utilisateur, au vu de ces chiffres.** *(Depuis Q17, une troisième perte s'ajoute au cumul — la destruction de la foreuse — mais elle n'est jouable qu'au sprint 6 : elle est mesurée par `TM-6.8` puis au playtest `TM-7.11`.)* | B |
| TM-5.10 `[REG]` | **Progression infinie, aucun plafond dur** (règle de design §3.3, Q18) | Pour **chaque** amélioration proposée, acheter des niveaux successifs jusqu'à épuisement des crédits, en notant le coût affiché à chaque palier | Aucun « niveau maximal atteint » n'apparaît, aucun bouton ne devient définitivement inactif : le **coût du niveau suivant est toujours affiché** et l'achat redevient possible dès que les crédits suffisent. Les coûts relevés doivent **croître de façon géométrique** (chaque coût est un multiple à peu près constant du précédent), conformément à `cout = base × facteur^niveau` | B |
| TM-5.11 | **Coût atteignable en 1 à 3 descentes** (règle de design §3.3) | Sur 3 cycles complets, relever pour chaque amélioration : (a) le coût du prochain niveau, (b) le gain moyen en crédits d'une descente | Le rapport **chiffre** le nombre de descentes nécessaires pour chaque amélioration : `coût ÷ gain moyen`. Cible §3.3 : **entre 1 et 3**. Comme `TM-5.9`, ce cas impose la mesure et non un seuil bloquant ; hors de la fourchette, une story d'équilibrage est ouverte et le réglage est repris au playtest `TM-7.11`. **La décision revient à l'utilisateur** | B |
| TM-5.12 | **Amélioration ressentie immédiatement** (règle de design §3.3) | Pour chaque amélioration, faire une descente de référence, acheter un niveau, refaire la **même** descente, et décrire la différence perçue **sans regarder le HUD** | La différence est **perceptible en jeu** : plus de minerai emporté avant d'être plein, forage sensiblement plus rapide, descente plus longue avant la panne sèche, dégâts visiblement mieux encaissés. Une amélioration dont on ne perçoit l'effet qu'en lisant un chiffre est un échec au sens du §3.3 | M |
| TM-5.13 `[REG]` | **Quatrième amélioration : `blindage` achetable et ressentie** (Q21) | Vérifier que `Blindage` apparaît dans la boutique avec un coût **non nul** à partir du palier 2. Faire une chute de référence, relever le blindage perdu, acheter un niveau, refaire **exactement** la même chute | `blindage` est bien **actif et achetable** — il ne se limite plus au palier 1 de coût nul. Après achat, **la même chute coûte visiblement moins de blindage** : l'effet est ressenti dès la descente suivante (§3.3), sans avoir à lire un chiffre. Ce cas n'est jouable que parce que Q20 a livré une source de dégâts contrôlable par le joueur. *Précisé le 2026-10-02 (`Q60` option (a), story `5.12`) : l'amélioration augmente le **blindage maximal** ; réparer au maximum avant de refaire la chute — la même chute retire **le même nombre de points**, mais une **part visiblement plus faible de la jauge**. C'est ce constat qui est attendu.* | B |
| TM-5.14 | **Exactement quatre améliorations actives** (Q21) | Ouvrir la boutique et lister toutes les améliorations proposées | La boutique propose **exactement quatre** améliorations : `Soute`, `Réacteur`, `Foret`, `Blindage`. **Aucune amélioration « profondeur max sûre »** n'apparaît : elle est reportée post-MVP. Le minimum de 4 stats du §3.2 est donc satisfait sans `id` nouveau. Une cinquième entrée, ou l'absence de l'une des quatre, est un échec | M |

---

## Sprint 6 — Zone profonde et anomalie scénarisée

| ID | Cas | Procédure | Attendu | Sév. |
|---|---|---|---|---|
| TM-6.1 | Accès profondeur | Descendre jusqu'à la strate profonde | Transition de zone perceptible (visuel/son/message) | M |
| TM-6.2 `[REG]` | Déclenchement de l'anomalie | Atteindre le point scénarisé | Le dialogue/événement se déclenche **une seule fois** | B |
| TM-6.3 | Dialogue | Lire et fermer le dialogue | Texte lisible, fermeture propre, jeu rendu au joueur | M |
| TM-6.4 | Flag narratif | Re-passer sur la zone après déclenchement | L'événement ne se rejoue pas ; le flag est bien mémorisé | B |
| TM-6.5 | Journal | `J` | Le journal s'ouvre et reflète l'événement rencontré | m |
| TM-6.6 | **Ancrages déterministes sur l'anomalie réelle** (Q6) | Lancer 3 parties avec 3 graines différentes ; descendre jusqu'à l'anomalie et relever sa position exacte, ainsi que celle de la zone de surface | L'anomalie et la surface sont **au même endroit dans les 3 parties**. Complète `TM-3.15`, qui ne pouvait vérifier qu'un marqueur au sprint 3, l'anomalie n'étant alors pas implémentée. Restaurer ensuite la graine de campagne (`P4`) | B |
| TM-6.7 `[REG]` | **Courbe de risque croissante avec la profondeur** (amendement §4.1, §4.2, Q17) | Creuser **50 cases** dans chacun des 4 paliers de profondeur (0-50 m, 50-150 m, 150-300 m, 300 m+) et compter les rencontres hostiles déclenchées dans chaque palier | Le nombre de rencontres **croît strictement** d'un palier au suivant et suit l'ordre de grandeur de la table §4.2 (≈ 1, 4, 9, 18 rencontres sur 50 cases). Aucun palier profond ne doit rester **sans aucune** rencontre. Consigner les 4 comptages : ils alimentent l'équilibrage de `7.6`. Vérifier au passage que le terrain n'a **pas** été décalé par les combats à graine identique (`P6`) | B |
| TM-6.8 `[REG]` | **La perte n'est JAMAIS totale** (règle de design §4.3, Q17 — annule Q8) | Sauvegarder en surface avec des crédits, des améliorations achetées et au moins un flag narratif posé. Descendre, remplir la soute, **se laisser détruire** par une menace. Observer l'état après destruction, puis inspecter `user://` | La partie **continue** : seule une **partie** du cargo est perdue. Sont **intacts** : le fichier de sauvegarde, les crédits, les niveaux d'amélioration et les flags narratifs. Aucun écran de « game over » définitif, aucune remise à zéro, aucune suppression de sauvegarde. La perte du cargo est **explicitement signalée** au joueur. Un seul de ces manquements est un échec **bloquant** : c'est la règle qui empêche le joueur d'associer le risque à une punition disproportionnée | B |
| TM-6.9 | **Indicateur de danger progressif et non chiffré** (règle de design §4.3) | Descendre lentement et continûment de la surface jusqu'au palier le plus profond, en observant l'écran et en écoutant | La tension monte de façon **perceptible et graduelle** : teinte d'écran et/ou ambiance sonore évoluent au passage de chaque palier, sans transition brutale. **Aucun pourcentage de risque, aucun chiffre de danger n'est affiché au joueur.** Le testeur doit pouvoir dire « je sens que ça devient dangereux » sans avoir lu de valeur | M |
| TM-6.10 | **Dilemme « remonter ou pousser »** (amendement §4.1) | Descendre avec une cargaison de valeur croissante, jusqu'à hésiter entre remonter vendre et continuer | Le joueur dispose à tout instant de ce qu'il faut pour arbitrer : profondeur, charge de soute, état du blindage, et la tension du danger — **sans qu'aucune probabilité ne lui soit donnée**. Le testeur consigne s'il a réellement hésité, et à quelle profondeur. Cas subjectif : il documente le ressenti visé par le §4.1, il n'échoue que si l'information de base manque | m |

---

## Sprint 7 — Sauvegarde locale et recette MVP

> Ces cas closent la campagne unique `7.8` : ils sont joués **après** `TM-1.x` à `TM-6.x`, pas à leur place.

| ID | Cas | Procédure | Attendu | Sév. |
|---|---|---|---|---|
| TM-7.1 `[REG]` | Sauvegarde/chargement | Jouer, sauvegarder, quitter, relancer, charger | **Position, ressources, crédits, améliorations et flags narratifs** restitués à l'identique | B |
| TM-7.2 | Terrain restauré | Après chargement, inspecter les tunnels creusés | Les tuiles détruites le restent | B |
| TM-7.3 | Première partie | Supprimer la sauvegarde puis lancer | Nouvelle partie propre, aucune erreur | B |
| TM-7.4 | Sauvegarde corrompue | Altérer volontairement le fichier `user://` puis lancer | Message d'erreur maîtrisé, pas de crash | M |
| TM-7.5 | **Recette MVP** | Rejouer les 7 « Critères d'acceptation MVP » du CDC un par un | Les 7 critères sont satisfaits | B |
| TM-7.6 | Session longue | Jouer 15 minutes d'affilée | Aucune fuite de performance, aucune erreur console accumulée | M |
| TM-7.7 `[REG]` | **Quitter sans sauvegarder** (Q7) | Charger une partie, jouer 5 minutes (creuser, collecter, vendre), quitter **sans** sauvegarder, relancer et charger | La progression des 5 dernières minutes est perdue et la partie repart du dernier point sauvegardé. **Comportement attendu et conforme à l'arbitrage Q7 : ce résultat ne doit pas être consigné comme une anomalie.** Le seul motif d'échec est un plantage, une sauvegarde corrompue ou une restitution partielle/incohérente de l'ancien point de sauvegarde | B |
| TM-7.8 | **Rappel de sauvegarde au retour en surface** (Q7) | Descendre, collecter, remonter en zone de surface avec une progression non sauvegardée | Un rappel « progression non sauvegardée » s'affiche, **sans bloquer** : le joueur peut continuer à jouer, vendre, repartir ou ignorer le message sans clic obligatoire ; le rappel disparaît de lui-même ou se ferme sans figer le jeu | M |
| TM-7.9 | **Confirmation avant de quitter** (Q7) | Avec une progression non sauvegardée, demander à quitter (menu pause et croix de la fenêtre) | Une confirmation explicite apparaît dans les deux cas et propose au minimum « quitter sans sauvegarder » / « annuler ». Refaire le test après une sauvegarde : la confirmation n'apparaît plus (ou signale une progression à jour) | M |
| TM-7.10 `[REG]` | **Aucune sauvegarde automatique** (Q7) | Supprimer la sauvegarde, jouer un cycle complet (descente, collecte, retour surface, vente, achat, anomalie) **sans jamais** déclencher la sauvegarde, puis inspecter `user://` | **Aucun fichier de sauvegarde n'a été créé** : ni au retour en surface, ni à la vente, ni sur minuterie, ni à la fermeture du jeu. La sauvegarde n'existe qu'après une action volontaire du joueur | B |
| TM-7.11 | **Durée de la boucle de session : 3 à 8 minutes** (amendement §5) | Chronométrer **3 boucles complètes** consécutives, chacune de la sortie de surface au retour au même point après vente et achat d'une amélioration. Ne pas interrompre le chrono ; noter les 3 durées et le contenu de chaque boucle | Les 3 durées sont consignées. Cible §5 : **chaque boucle entre 3 et 8 minutes**. En dessous de 3 min, la descente est trop courte pour créer de la tension ; au-dessus de 8 min, la boucle décourage le « encore une descente ». Hors fourchette, une **story d'équilibrage** est ouverte (ajustement par édition de `data/` uniquement, sans code). Relever aussi, sur ces 3 boucles, le cumul des pertes (soute pleine `TM-5.9`, destruction `TM-6.8`, progression non sauvegardée `TM-7.7`). **La décision d'ajustement revient à l'utilisateur** | B |
| TM-7.12 | **« Encore une descente »** (amendement §5, objectif) | Après 20 minutes de jeu ininterrompu, arrêter et consigner par écrit : ai-je envie de refaire une descente, et pourquoi ? Qu'est-ce qui m'a donné envie de continuer, qu'est-ce qui m'a fait décrocher ? | Réponse consignée dans le rapport, avec ses raisons. Cas **qualitatif** : il ne peut pas échouer formellement, il capte le seul objectif que l'amendement se donne au §5. Une réponse négative n'est pas une anomalie mais un signal d'équilibrage, à instruire dans la story `7.6` | m |

---

## Traçabilité — Critères d'acceptation MVP du CDC

| Critère CDC | Cas de test |
|---|---|
| Partir, creuser, collecter, revenir vendre sans bloquer la partie | TM-5.8, TM-5.1, TM-5.2 |
| Tuile minable détruite seulement si puissance de foret et carburant suffisants | TM-3.1, TM-3.5, TM-3.9, TM-5.6 |
| Collisions empêchant la traversée des blocs non détruits | TM-2.6, TM-3.6 |
| Directions opposées : ni mouvement ni comportement instable | TM-2.2 |
| HUD temps réel (carburant, blindage, crédits, soute, profondeur) | TM-4.1, TM-4.2 |
| Amélioration achetée ⇒ statistique modifiée immédiatement | TM-5.5, TM-5.6 |
| Sauvegarde restituant position, ressources, crédits, améliorations, flags | TM-7.1, TM-7.2 |

## Traçabilité — arbitrages utilisateur du 2026-08-29

| Arbitrage | Décision | Cas de test |
|---|---|---|
| **Q5** — soute pleine | Tuile détruite, minerai perdu | TM-3.8, TM-3.11, TM-3.12, TM-3.13 (+ alerte au HUD : TM-4.3) |
| **Q6** — terrain semi-procédural dès le MVP | Génération à graine explicite et forçable, ancrages déterministes | TM-3.14, TM-3.15, TM-3.16, **TM-6.6** (+ prérequis de campagne `P4`) |
| **Q7** — sauvegarde manuelle uniquement | Aucune sauvegarde automatique, garde-fous non bloquants | TM-7.7, TM-7.8, TM-7.9, TM-7.10 |
| **Q5 × Q7** — cumul des deux pertes | Mesure chiffrée au sprint 5, décision d'ajustement à l'utilisateur | **TM-5.9** |

## Traçabilité — vérifications transférées entre sprints

> Une vérification qu'une procédure ne sait pas observer est **transférée et tracée**, jamais abandonnée (point d'audit `I5`).

| Vérification | Cas d'origine | Motif | Transférée à | Story |
|---|---|---|---|---|
| Valeurs de départ de `GameState` lues à l'écran (carburant, blindage, crédits, soute, profondeur) | `TM-1.6` e-l | Variables **privées non exportées** : l'Inspecteur ne les affiche pas de façon garantie, et aucun artefact de debug ne peut être créé pour y remédier (`A5`) | **`TM-4.1`** (sprint 4, HUD) | `1.12` |
| Déclenchement d'une action par appui, une seule fois | `TM-1.5` | Aucun code ne consomme les entrées avant la phase 2 | **Sprint 2** — identifiant conservé | `1.3` / **Q9** |
| **Volet « action ponctuelle » de `TM-1.5`** : une action ponctuelle ne se redéclenche pas sous la répétition clavier (`echo`) | `TM-1.5` | La story `2.2` ne livre que du **déplacement continu** (`Input.is_action_pressed` / `get_axis`), par nature insensible à l'`echo`. **Aucune action ponctuelle n'existe encore** dans le jeu, et en créer une pour le test serait un artefact de debug (`A5`). Le volet « touches de déplacement reconnues, une fois par appui » reste, lui, jouable dès `2.2` | **Sprint 3**, avec `drill` (story `3.4`) — premier `_unhandled_input()` du projet | `2.2` |
| **Volet « action ponctuelle » de `TM-1.5`** — *second transfert* | `TM-1.5` | La story `3.4` implémente `drill` en lecture **continue** (`Input.is_action_pressed`, appui maintenu conforme à `TM-3.1`) : le forage est, comme le déplacement, insensible à l'`echo`. **Aucune action ponctuelle n'existe toujours**, et en fabriquer une pour rendre le test jouable serait un artefact `A5`. Décision prise en Notes de `3.4`, **une bonne fois** : le volet part avec les premières actions **ponctuelles par nature** | **Phase 4**, avec `pause` / `toggle_inventory` — premier `_unhandled_input()` du projet | `3.4` |
| **Volet « action ponctuelle » de `TM-1.5`** — *aboutissement du second transfert* | `TM-1.5` | La story `4.3` livre `pause` (`Échap`), **première action ponctuelle** du jeu, lue en `_unhandled_input()` : un appui = une bascule du menu pause, la répétition clavier (`echo`) d'un `Échap` maintenu est ignorée et consommée. La story `4.4` livre `toggle_inventory` (`I`, `Tab`) sur la même règle : un appui = une bascule de l'inventaire | **Jouable à partir de la story `4.3`** (maintenir `Échap` : le menu ne clignote pas), **et de la story `4.4`** pour `I` et `Tab` (maintenir la touche : l'inventaire ne clignote pas) — exécution à la recette **`7.8`**, avec `TM-4.4` et `TM-4.5`, cas **non coché** | `3.4` → `4.3`, `4.4` |
| **Volet visuel de l'alerte `Q5`** : bandeau « soute pleine » affiché **avant** toute perte | `TM-3.11` | La story `3.5` livre l'alerte **sonore** et le signal `cargo_full`, sans aucun affichage (aucun HUD avant la phase 4) | **Jouable à partir de la story `4.2`** (bandeau `CargoFullAlert`) — exécution à la recette **`7.8`**, cas **non coché** | `3.5` → `4.2` |
| **Perte de minerai observable** (`G10`) : message par perte et compteur cumulé | `TM-3.12` | La story `3.5` livre le signal `ore_lost` et le compteur `get_lost_units()`, sans affichage | **Jouable à partir de la story `4.2`** (message « Soute pleine : … perdu », compteur « MINERAI PERDU ») — exécution à la recette **`7.8`**, cas **non coché** | `3.5` → `4.2` |
| **Volet visuel de `TM-3.5`** : le joueur voit **pourquoi** une tuile ne cède pas | `TM-3.5` | La story `3.4` émet `drill_refused` et son motif, avec un bip ; le retour visuel, renvoyé à `3.7`, n'y a pas été porté (écart `E20`) | **Jouable à partir de la story `4.2`** (message « Forage refusé : » + motif, son dédié) — exécution à la recette **`7.8`**, cas **non coché** | `3.4` → `4.2` |

## Traçabilité — amendement « gameplay addictif » et arbitrages du 2026-09-06

| Origine | Exigence | Cas de test |
|---|---|---|
| §2.1 – §2.3 · **Q19** | Loot pondéré par couche, tirage reproductible | TM-3.17, TM-3.20 (+ prérequis `P5`) |
| §2.4 · **règle de design** | Jamais 0 % de drop, même à la surface | **TM-3.18** |
| §2.4 · **règle de design** | Feedback visuel et sonore fort et durable sur les raretés hautes | **TM-3.19** |
| **Q12** *(contrainte jusque-là sans cas de test)* | Aucune ressource `actif_mvp: false` dans le loot | **TM-3.21** |
| **Q33** — point d'apparition *(lacune signalée en `3.3`)* | Foreuse posée au sol et intacte au lancement, indépendamment de la graine | **TM-3.22** |
| §3.2 – §3.3 · **Q18** | Progression infinie, aucun plafond dur, coût géométrique | **TM-5.10** |
| §3.3 · **règle de design** | Prochain palier atteignable en 1 à 3 descentes | **TM-5.11**, TM-7.11 |
| §3.3 · **règle de design** | Amélioration ressentie dès la descente suivante | **TM-5.12** |
| §4.1 – §4.2 · **Q17** | Courbe de risque croissante par profondeur | **TM-6.7** (+ prérequis `P6`) |
| §4.3 · **règle de design** | **La perte n'est jamais totale** | **TM-6.8** |
| §4.3 · **règle de design** | Indicateur de danger progressif et non chiffré | **TM-6.9** |
| §4.1 | Dilemme « remonter vendre / pousser plus loin » | TM-6.10 |
| §5 · **boucle de session** | Boucle complète de 3 à 8 minutes | **TM-7.11** |
| §5 · **objectif** | Sentiment « encore une descente » | TM-7.12 |

## Traçabilité — arbitrages Q20 à Q22 du 2026-09-06

| Origine | Exigence | Cas de test |
|---|---|---|
| **Q20** — dégâts de chute et d'impact | Dégâts proportionnels à la vitesse, seuil en deçà duquel rien n'est infligé, blindage réellement décrémenté | **TM-2.9** |
| **Q20** × **Q17** | État de destruction explicite dès le sprint 2 *(règle §4.3 complète vérifiée par `TM-6.8`)* | TM-2.10 |
| Arbre contractuel de `DrillRig.tscn` (« Architecture Godot ») | 10 nœuds affichés, aucun avertissement, foreuse visible en jeu | TM-2.11 |
| **Q21** — quatre améliorations actives | `blindage` achetable au-delà du palier 1 et **ressenti** (§3.3) | **TM-5.13** |
| **Q21** — périmètre du catalogue | Exactement 4 améliorations, aucune « profondeur max sûre » | TM-5.14 |
| **Q21** — non-couverture assumée | « Vitesse de forage » du §3.2 : `foret` reste une **puissance** au MVP | *aucun cas — non couvert, tracé au backlog, à rouvrir post-MVP* |
| **Q22** — surcharge du sprint 6 acceptée | Aucun effet sur le plan de tests : la phase 6 conserve une seule gate et ses cas `TM-6.1` à `TM-6.10` | *sans objet* |
| **Q65** (b) *(ajout du 2026-10-02, story `5.16`)* — phase 6 en deux sprints, 6a « risque » et 6b « narration » | Aucun cas renuméroté : les cas `TM-6.1` à `TM-6.10` restent sous la gate reportée `6.10`, joués à `7.8` ; seuls les audits sont dédoublés (`6.9`, `6.11`). *La ligne `Q22` ci-dessus est historique pour la gate d'audit.* | *sans objet* |
| **Q66** (b) *(ajout du 2026-10-02, story `5.16`)* — panne sèche sous la surface traitée par la règle de la destruction (`6.7`) | Carburant nul hors zone de surface : perte d'une partie du cargo et retour en surface, jamais crédits, améliorations, flags ni sauvegarde. **Jusqu'à la livraison de `6.7`, `TM-5.8` peut échouer sur ce seul cas (risque connu, écart `E25`).** Le cas dédié est à ajouter au plan à l'ouverture de `6.7`, en prolongeant la numérotation du sprint 6. | TM-5.8, TM-6.8 *(cas dédié à créer avec `6.7`)* |

> **Ajout du 2026-09-27 (story `3.11`, arbitrage `Q33`)** : `TM-3.22` prolonge la numérotation du sprint 3 ; aucun cas n'est renuméroté.
>
> **Aucun cas de test antérieur n'a été renuméroté** le 2026-09-06 : les identifiants ajoutés prolongent la numérotation de leur sprint (`TM-3.17` à `TM-3.21`, `TM-5.10` à `TM-5.12`, `TM-6.7` à `TM-6.10`, `TM-7.11` et `TM-7.12` pour la story `1.10` ; `TM-2.9`, `TM-2.10`, `TM-5.13` et `TM-5.14` pour la story `1.11`), conformément à la règle « ne pas renuméroter » de l'en-tête.
