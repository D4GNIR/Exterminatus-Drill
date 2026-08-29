# Rapport de tests manuels — Sprint &lt;N&gt; (&lt;nom de la phase&gt;)

> Copier ce fichier vers `qa/rapports/sprint-<N>-tests-manuels-<AAAA-MM-JJ>.md` avant de le remplir.
> Ne jamais remplir ce template directement.

## 1. Contexte

| Champ | Valeur |
|---|---|
| Sprint / phase | |
| Date d'exécution | |
| Testeur | |
| Version de Godot | |
| OS / machine | |
| Commit / état du dépôt | |
| Itération | 1 (ou 2 après correction) |
| Verdict de l'audit préalable | Autorisé / KO — story n° |

## 2. Périmètre testé

Stories couvertes par cette passe :

- `<n.m> - <titre>`
- ...

Cas de test exécutés (référence `qa/plan-tests-manuels.md`) : `TM-x.y`, ...

Cas **non exécutés** et pourquoi :

- ...

## 3. Résultats

| ID | Cas de test | Attendu | Obtenu | Verdict | Sévérité |
|---|---|---|---|---|---|
| TM-x.y | | | | OK / KO / Non testé | Bloquant / Majeur / Mineur / — |

**Synthèse** : X cas exécutés · Y OK · Z KO · W non testés.

## 4. Anomalies détectées

### ANO-&lt;N&gt;-1 — &lt;titre court&gt;

| Champ | Valeur |
|---|---|
| Sévérité | Bloquant / Majeur / Mineur |
| Cas de test | TM-x.y |
| Reproductible | Oui / Non / Aléatoire |

**Étapes de reproduction**
1.
2.

**Comportement attendu** :

**Comportement observé** :

**Trace / message d'erreur** :

```
```

**Suite donnée** : story de correction `<n.m>` créée / anomalie mineure acceptée et reportée au backlog.

## 5. Ressenti de jeu (facultatif mais utile)

Lisibilité, réactivité des contrôles, rythme, frustration, clarté du HUD, ambiance :

- ...

## 6. Verdict de fin de sprint

- [ ] Tous les cas **bloquants** sont OK
- [ ] Les anomalies restantes sont tracées (rapport + backlog)
- [ ] Les critères d'acceptation `[H]` des stories du sprint sont vérifiés
- [ ] Les statuts des stories concernées ont été mis à jour

**Verdict** : Sprint **validé** / **à corriger**

**Commit de phase autorisé** : Oui / Non

**Commentaire du testeur** :
