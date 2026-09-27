# Convention stories/

Toute action concrète menée sur le projet *doit* être documentée par un fichier dans le dossier stories/ à la racine du projet.

## Nomenclature

- Format obligatoire : `<numéro de phase>.<numéro de sous-tâche> - <titre>.md`
- Exemples : `1.1 - Initialisation projet.md`, `3.2 - Chrono 60 secondes.md`
- Numérotation séquentielle dans la phase, pas de saut, pas de zéro non significatif.

## Contenu minimum d'une story

Chaque fichier doit comporter au moins :

1. **Phase** (numéro et nom)
2. **Statut** : À faire | En cours | Terminée | Bloquée | Reportée | Annulée
   - `Reportée` : story volontairement décalée à plus tard, fichier conservé (ex. gates de tests humains → `7.8`, story `2.8`).
   - `Annulée` : story écartée définitivement, fichier conservé (ex. `0.5`, story `0.10`).
3. **Objectif** : ce que la tâche doit produire
4. **Dépendances** : autres stories requises avant celle-ci
5. **Critères d'acceptation** : conditions vérifiables de fin
6. **Référence cahier des charges** : sections concernées
7. **Notes / décisions** (rempli au fur et à mesure)

> **Le cahier des charges est en deux documents** (arbitrage `Q16` du 2026-09-06, story `1.10`) :
> `cahier_des_charges_motherload_40k_godot.md`, la référence principale, **amendée par** `cahier_des_charges_gameplay_addictif.md`.
> **Préséance** : l'amendement fait foi pour le loot, l'économie, la courbe de risque et la durée de boucle ; le CDC principal fait foi pour l'univers, les contrôles, les règles de forage, l'architecture Godot et les données de tuile.
> Le champ « Référence cahier des charges » d'une story doit **nommer le document** en plus de la section quand la story touche à l'un de ces quatre domaines.

## Règles de mise à jour

- **Avant** de commencer une tâche : passer le statut à En cours.
- **Pendant** : consigner les décisions techniques notables dans la section Notes.
- **À la fin** : passer le statut à Terminée et lister les artefacts produits (fichiers créés/modifiés).
- **Nouvelle action non prévue** : créer une nouvelle story avant de coder.

## Méthodologie d'exécution (obligatoire)

**Le développement se fait étape par étape, dans l'ordre, jamais tout d'un coup.**

- **Une seule story En cours à la fois.** On termine la story N avant d'ouvrir la N+1.
- **À l'intérieur d'une story : exécuter les étapes séquentiellement** (étape 1, puis étape 2, puis étape 3). Pas de création parallèle de plusieurs fichiers ou actions sans rapport direct dans le même tour.
- **Exception autorisée** : on peut grouper plusieurs actions dans le même tour uniquement si elles sont strictement liées (ex. créer un fichier et son test associé, ou plusieurs imports d'un même module en cours d'écriture).
- **Point de validation** : à la fin de chaque story, faire le point avec l'utilisateur (résumé bref des artefacts + critères d'acceptation auto-vérifiés) avant de passer à la story suivante.
- **Action critique** (commit Git, push, configuration cloud, suppression) : annoncer avant exécution.

## Fin de sprint — audit qualité (obligatoire)

> **Décision utilisateur du 2026-09-26 (story `2.8`) : plus de tests manuels humains en fin de sprint.** La vérification humaine est **regroupée en une seule recette de fin de projet**, la story `7.8`. La gate de fin de sprint est donc **unique**.

À la fin de chaque sprint (voir `stories/BACKLOG.md` et `qa/README.md`), **une seule story dédiée** :

1. **Audit qualité code** — checklist `qa/audit-qualite-reference.md` · verdict **Autorisé** ou **KO** en Notes.

- Un audit **KO** ⇒ story de correction dans la phase courante, puis **nouvel audit** consigné dans la même story d'audit.
- Ne **pas** commiter la phase tant que les stories dev **et** la story d'audit ne sont pas **Terminée**. L'audit **Autorisé** suffit désormais à autoriser le commit.
- Les critères **[H]** (rendu, ressenti de contrôle, équilibrage, audio, ergonomie) ne sont **jamais cochés par un agent** : ils restent **en attente** et sont tous vérifiés à la recette `7.8`. Chaque story liste ce qui reste à valider visuellement.
- Les gates de tests humains des sprints 2 à 6 (`2.7`, `3.9`, `4.6`, `5.9`, `6.10`) sont au statut **Reportée** vers `7.8` : fichiers conservés, aucune renumérotation.
- Exemples réels du projet : `0.4` audit → `0.5` revue **annulée** (`0.10`) · `1.7` audit → `1.8` tests **close sans exécution** · `2.6` audit, `2.7` **reportée** (`2.8`). Les numéros des phases ≥ 3 sont **prévisionnels** et se déplacent à chaque insertion de story : ne les recopie pas ici, **les numéros exacts font foi dans `stories/BACKLOG.md`**, tableau de la phase concernée.

## Commits Git (obligatoire à la fin de chaque phase)

**Un commit Git doit être effectué à la fin de chaque phase complète**, et uniquement à ce moment-là (sauf demande explicite contraire).

- **Pré-conditions** : toutes les stories de la phase doivent être au statut Terminée.
- **Avant le commit** : vérifier `git status` et `git diff --stat` pour s'assurer du périmètre.
- **Format du message** :
  - **Titre** : `Phase <N> — <nom de la phase>`
  - **Corps** : liste à puces des stories incluses (`- 1.1 - Initialisation projet`, etc.) puis liste des artefacts principaux (fichiers créés/modifiés majeurs).
- **Méthode** : utiliser un HEREDOC pour préserver le formatage multi-ligne.
- **Pas de commit intermédiaire** au sein d'une phase, sauf si l'utilisateur le demande explicitement ou si une étape critique le justifie (à annoncer).
- **Pas de push automatique** : le push reste à l'initiative de l'utilisateur.

Exemple de message de commit :

```
Phase 1 — Fondations

Stories incluses :
- 1.1 - Initialisation projet
- 1.2 - Architecture modulaire

Artefacts :
- index.html (squelette + meta OG)
- css/main.css (reset, variables, mobile-first)
- js/main.js (bootstrap)
- js/<modules>/* (stubs)
- README.md, .gitignore
```

## Interdits

- Ne pas modifier le numéro d'une story déjà créée (renommer casserait les références).
- Ne pas supprimer une story terminée (historique du projet).
- Ne pas commencer un travail sans story associée.
- Ne pas avancer plusieurs stories en parallèle.
- Ne pas enchaîner sans pause sur la story suivante après avoir terminé la story courante.
- Ne pas commiter au milieu d'une phase, sauf demande explicite.
- Ne pas pousser sur le remote sans demande explicite de l'utilisateur.
