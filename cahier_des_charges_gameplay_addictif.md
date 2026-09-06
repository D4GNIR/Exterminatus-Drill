# Cahier des charges — Gameplay Addictif
## Projet : Warhammer 40K Motherload-like (Godot)

---

## 1. Objectif

Définir les mécaniques de gameplay qui créent une boucle de rejouabilité forte, basées sur des principes éprouvés (récompense variable, progression infinie, risque croissant). Le but : que le joueur ait toujours une raison de "faire une descente de plus".

---

## 2. Boucle de récompense variable (loot system)

### 2.1 Principe
Chaque case creusée a une chance de contenir un drop, selon une table de poids qui varie par couche de profondeur.

### 2.2 Table de loot (exemple, à ajuster en playtest)

| Rareté | Poids (surface) | Poids (profondeur moyenne) | Poids (profondeur extrême) |
|---|---|---|---|
| Rien | 40% | 25% | 10% |
| Minerai commun | 45% | 40% | 25% |
| Relique mineure | 12% | 25% | 30% |
| Relique rare | 2.8% | 9% | 25% |
| Artefact légendaire | 0.2% | 1% | 10% |

### 2.3 Implémentation technique
- `Dictionary` de poids par couche + tirage via `randf()`
- Chaque type de loot associé à une valeur de revente et (optionnel) un effet gameplay (ex: relique = buff temporaire)

### 2.4 Règle de design
- Ne jamais avoir 0% de drop, même à la surface (garder le joueur en tension dès la première case)
- Les raretés hautes doivent rester visibles à l'écran assez longtemps après le drop (feedback visuel fort : lumière, son distinct) pour renforcer la sensation de jackpot

---

## 3. Progression infinie (économie & upgrades)

### 3.1 Ressource pivot
Crédits (obtenus en vendant le loot à un point de vente : Adeptus Mechanicus, marché noir, etc.)

### 3.2 Stats upgradables (4 minimum pour le MVP)

| Stat | Effet | Formule de coût |
|---|---|---|
| Capacité cargo | Plus de loot transportable par descente | `cost = 100 * 1.15^level` |
| Résistance/armure | Réduit dégâts subis | `cost = 150 * 1.18^level` |
| Vitesse de forage | Creuse plus vite | `cost = 120 * 1.15^level` |
| Profondeur max sûre | Recule le seuil où le risque augmente fortement | `cost = 200 * 1.20^level` |

### 3.3 Règle de design
- Pas de plafond dur : le coût augmente indéfiniment, mais reste toujours atteignable en 1-3 descentes supplémentaires (jamais un mur qui décourage)
- Chaque upgrade doit être ressenti immédiatement à la descente suivante (feedback tangible, pas juste un chiffre qui change)

---

## 4. Risque croissant avec la profondeur (push your luck)

### 4.1 Principe
Plus `depth` augmente, plus la probabilité de spawn d'ennemis/dégâts warp augmente. Le joueur choisit à chaque instant : continuer à descendre (plus de loot, plus de risque) ou remonter vendre (sécuriser le gain).

### 4.2 Courbe de risque (exemple)

| Profondeur | Probabilité de rencontre hostile / case | Type de menace |
|---|---|---|
| 0-50m | 2% | Aucune / mineure |
| 50-150m | 8% | Créatures xenos mineures |
| 150-300m | 18% | Nécrons qui se réveillent |
| 300m+ | 35%+ | Corruption warp, essaims Tyranides |

### 4.3 Règle de design
- La perte en cas d'échec ne doit jamais être totale (ex: perte d'une partie du cargo, pas de la sauvegarde) — sinon le joueur associe le risque à une punition trop dure et arrête de prendre le risque
- Afficher un indicateur de danger progressif (couleur d'écran, son ambiant) pour que le joueur sente la tension monter sans avoir besoin d'un chiffre explicite

---

## 5. Boucle de session type (à valider en playtest)

1. Le joueur descend, creuse, accumule du loot (récompense variable)
2. Le risque augmente avec la profondeur (tension croissante)
3. Le joueur décide de remonter (perte du risque, sécurisation du gain) ou de pousser plus loin (jackpot potentiel)
4. Vente du loot → upgrades → nouvelle capacité de descendre plus profond/plus longtemps
5. Retour à l'étape 1 avec un palier légèrement plus haut

Cette boucle doit durer entre 3 et 8 minutes pour une session courte, l'objectif étant le sentiment "encore une descente".

---

## 6. Ce qui est explicitement hors scope pour le MVP

- Système de streak/connexion quotidienne (nécessite infra de sauvegarde de dates)
- Leaderboard / multijoueur (nécessite serveur)
- Mécanique de near-miss compétitif (pertinente seulement en contexte multi ou classement)

Ces éléments pourront être ajoutés une fois la boucle solo validée comme suffisamment addictive en interne.

---

## 7. Priorités de développement (ordre conseillé)

1. Loot table + tirage pondéré par couche
2. Système économique de base (vente + 4 upgrades)
3. Courbe de risque par profondeur
4. Feedback visuel/sonore sur drops rares et danger croissant
5. Playtest interne pour ajuster les poids et les coûts avant d'aller plus loin
