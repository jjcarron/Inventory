# CODEX PROPOSALS

## Chapitre 1 - Propositions initiales (2026-02-12)

- Formaliser un registre des entrees/sorties par etape avec nom exact de fichier, schema de colonnes, et exemple minimal. Detail: un tableau par etape dans `WORKFLOW.md` ou un `DATA_CONTRACT.md`.
- Ajouter une etape de validation automatique avant import DB (schema, types, champs obligatoires, valeurs anormales). Detail: script de validation simple en CSV/Excel, bloque l’import si KO.
- Tracabilite des corrections manuelles par un changelog par lot. Detail: un fichier `manually_modified_data/changes_YYYYMMDD.md` qui liste les decisions manuelles.
- Versionner les configs de pipeline par lot et lier le lot a un identifiant unique. Detail: nommer `pipeline.process_data_N.yml` avec un suffixe date.
- Verrouiller l’invariant “reconstruction from scratch” via un script de regeneration complet. Detail: un script qui repart de `manually_modified_data/*.csv`, `base_data.xlsx`, `Staging_data.xlsx` et regenere les sorties.
- Ajouter des checksums pour les fichiers de base. Detail: stocker un `base_data.checksums.txt` pour detecter toute derive involontaire.
- Centraliser les “entrypoints” par sous-projet dans un mini index. Detail: une section “Commandes principales” dans `WORKFLOW.md`.
