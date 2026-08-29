# Plan de tests manuels humains — MVP *Exterminatus Drill*

Ce plan liste les cas de test **exécutés par l'humain dans Godot**, sprint par sprint.
Les agents vérifient en amont ce qui est automatisable en headless ; ce plan ne couvre que ce qui exige un jugement humain à l'écran — cf. `qa/README.md` §4.

- Chaque cas a un identifiant stable `TM-<phase>.<n>` : **ne pas renuméroter**.
- Sévérité indicative : **B** = bloquant (interdit le commit de phase), **M** = majeur, **m** = mineur.
- À chaque fin de sprint : exécuter les cas du sprint **+ les cas de régression** des sprints précédents marqués `[REG]`.
- Le résultat est consigné dans un rapport créé depuis `qa/rapport-test-template.md`, déposé dans `qa/rapports/`.

---

## 0. Prérequis

| # | Prérequis | Statut |
|---|---|---|
| P1 | **Godot 4.x stable installé** sur la machine de test | ✅ satisfait — Godot **4.7.2 stable** (`godot --version` → `4.7.2.stable.official.ed1daf0bf`), installé en story `0.6`. À revérifier sur tout nouveau poste de test. |
| P2 | Le dépôt est cloné/ouvert localement | |
| P3 | Le projet s'importe dans l'éditeur sans erreur d'import | |
| P4 | **Graine de génération figée** pour toute la campagne de tests du sprint (à partir du sprint 3) : la graine est fixée avant le premier cas, notée dans le rapport, et **n'est pas modifiée** jusqu'au dernier cas — sauf pour les cas qui la font varier explicitement (`TM-3.14`, `TM-3.15`), après lesquels la graine de campagne est restaurée | à partir du sprint 3 |

> Si l'un des prérequis `P1` à `P3` n'est **pas** satisfait sur le poste de test, la story de tests manuels du sprint passe à **Bloquée**, pas à Terminée, et la cause est notée. `P1` étant satisfait depuis la story `0.6`, cette règle ne bloque plus la gate du sprint 1.

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
| TM-1.5 | Test des touches | Lancer la scène de test d'input (ou lire l'Output) et presser chaque touche | Chaque action est bien reconnue une et une seule fois | M |
| TM-1.6 | Autoload `GameState` | *Project Settings > Autoload* puis `F5` | `GameState` est chargé, ses valeurs initiales sont lisibles sans erreur | B |
| TM-1.7 | Arbre de `Main.tscn` | Ouvrir `scenes/main/Main.tscn` | Hiérarchie conforme au CDC (World + 3 TileMapLayer + Hazards, Camera2D, UI/CanvasLayer) | M |
| TM-1.8 | Chargement des données | Lancer le jeu | Les JSON de `data/` sont chargés sans erreur de parsing ; le nombre d'entrées est loggé | M |

---

## Sprint 2 — Foreuse et déplacement

| ID | Cas | Procédure | Attendu | Sév. |
|---|---|---|---|---|
| TM-2.1 `[REG]` | Déplacement 4 directions | Se déplacer dans un tunnel libre avec ZQSD puis les flèches | Déplacement fluide dans les 4 directions, les deux jeux de touches équivalents | B |
| TM-2.2 `[REG]` | Directions opposées | Presser gauche+droite, puis haut+bas | **Aucun mouvement**, aucune vibration/oscillation, aucune erreur | B |
| TM-2.3 | Gravité et chute | Se placer au-dessus d'un vide et lâcher les touches | La foreuse tombe, atterrit sans traverser le sol | B |
| TM-2.4 | Propulsion | Maintenir `move_up` dans un tunnel vide | Montée progressive, consommation de carburant visible | M |
| TM-2.5 | Freinage | Maintenir `brake` en mouvement | Vitesse et inertie visiblement réduites | m |
| TM-2.6 `[REG]` | Collisions | Foncer contre un bloc non détruit dans chaque direction | Impossible de traverser, pas de blocage/téléportation | B |
| TM-2.7 | Caméra | Se déplacer largement | La caméra suit sans saccade et ne sort pas des limites définies | m |
| TM-2.8 `[REG]` | Panne sèche | Épuiser le carburant | Ni forage ni propulsion possibles ; la chute reste possible ; message/alerte clair | B |

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

---

## Sprint 4 — HUD et interfaces de bord

| ID | Cas | Procédure | Attendu | Sév. |
|---|---|---|---|---|
| TM-4.1 `[REG]` | HUD temps réel | Jouer un cycle complet | Carburant, blindage, crédits, charge de soute et **profondeur** s'actualisent en temps réel | B |
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
| TM-5.1 `[REG]` | Retour surface | Remonter par les galeries | Détection de la zone de surface, interface disponible | B |
| TM-5.2 `[REG]` | Vente | Vendre une cargaison mixte | Crédits crédités selon `data/resources.json`, soute vidée | B |
| TM-5.3 | Ravitaillement | Faire le plein | Carburant au max, crédits débités du bon montant | B |
| TM-5.4 | Réparation | Se faire endommager puis réparer | Blindage restauré, crédits débités | M |
| TM-5.5 `[REG]` | Achat d'amélioration | Acheter capacité de soute, carburant max, puissance du foret | **La statistique change immédiatement** (visible au HUD et en jeu) | B |
| TM-5.6 | Foret amélioré | Forer une roche dure avant/après amélioration du foret | Forage nettement plus rapide/possible après achat | M |
| TM-5.7 | Crédits insuffisants | Tenter un achat trop cher | Achat refusé, message clair, aucun crédit négatif | B |
| TM-5.8 `[REG]` | **Boucle complète non bloquante** | Partir, creuser, collecter, remonter, vendre, ravitailler, repartir — 3 cycles | Aucun blocage définitif de la partie (jamais coincé sans issue ni crédits) | B |
| TM-5.9 | **Mesure du cumul Q5 × Q7** (point d'arbitrage) | Sur les 3 cycles de `TM-5.8`, relever : (a) le nombre d'unités de minerai perdues en soute pleine et leur valeur en crédits, (b) la valeur de la cargaison la plus élevée transportée sans sauvegarde | Le rapport de test **chiffre** les deux pertes potentielles. Ce cas ne peut pas échouer : il impose la mesure, pas un seuil. Il matérialise la réévaluation de l'interaction Q5 × Q7 annoncée au backlog — perte de minerai **et** absence de sauvegarde automatique se cumulent. **La décision d'ajuster ou de conserver le réglage revient à l'utilisateur, au vu de ces chiffres.** | B |

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

---

## Sprint 7 — Sauvegarde locale et recette MVP

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
