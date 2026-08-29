# Convention stories/

Toute action concrète menée sur le projet *doit* être documentée par un fichier dans le dossier stories/ à la racine du projet.

## Nomenclature

- Format obligatoire : `<numéro de phase>.<numéro de sous-tâche> - <titre>.md`
- Exemples : `1.1 - Initialisation projet.md`, `3.2 - Chrono 60 secondes.md`
- Numérotation séquentielle dans la phase, pas de saut, pas de zéro non significatif.

## Contenu minimum d'une story

Chaque fichier doit comporter au moins :

1. **Phase** (numéro et nom)
2. **Statut** : À faire | En cours | Terminée | Bloquée
3. **Objectif** : ce que la tâche doit produire
4. **Dépendances** : autres stories requises avant celle-ci
5. **Critères d'acceptation** : conditions vérifiables de fin
6. **Référence cahier des charges** : sections concernées
7. **Notes / décisions** (rempli au fur et à mesure)

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

## Fin de sprint — audit puis tests humains (obligatoire)

À la fin de chaque sprint (voir `stories/BACKLOG.md` et `qa/README.md`), enchaîner **deux stories dédiées**, dans cet ordre :

1. **Audit qualité code** — checklist `qa/audit-qualite-reference.md` · verdict **Autorisé** ou **KO** en Notes.
2. **Tests manuels humains** — plan `qa/plan-tests-manuels.md` · rapport `qa/rapport-test-template.md`.

- Ne **pas** démarrer la story tests si l'audit n'est pas **Autorisé**.
- Ne **pas** commiter la phase tant que les deux stories du sprint ne sont pas **Terminée** (en plus des stories dev du sprint).
- Exemples réels du projet : `0.4` audit → `0.5` revue · `1.7` audit → `1.8` tests · `3.7` audit → `3.8` tests (gate vertical slice). Les couples exacts font foi dans `stories/BACKLOG.md`.

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
