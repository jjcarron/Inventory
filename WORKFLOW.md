# Workflow Inventory

Ce document decrit le workflow global et les points de controle clefs.

## Vue d'ensemble
1. Extraire les commandes Aliexpress.
2. Post-traiter et nettoyer les donnees via le pipeline (LLM + regles deterministes).
3. Appliquer les corrections manuelles si necessaire.
4. Rejouer le pipeline pour produire les sorties finales.
5. Importer dans PostgreSQL via InventoryManager.

## Etape 1 - Extraction (aliexpress_orders_exporter)
- Objectif: recuperer les nouvelles commandes depuis une date de reference.
- Sorties attendues: `data/csv/Aliexpress_orders_details_YYYYMMDD_YYYYMMDD.csv`.
- Sorties attendues: `data/assets/img/*` (assets associes).

## Etape 2 - Post-processing initial (OrdersPostProcessingPipeline)
- Lancer le pipeline LLM + deterministic: `uv run python -m pipeline_runner.pipeline_runner --config deepseek.deepseek-v3.2.yml`.
- Adapter `deepseek.deepseek-v3.2.yml` pour pointer vers le CSV exporte.
- Produire un fichier de sortie brut pour correction.

## Etape 3 - Corrections manuelles
- Copier la sortie dans `OrdersPostProcessingPipeline/data/manually_processed_input`.
- Effectuer les corrections necessaires (erreurs de tagging, noms, valeurs).
- Creer un nouveau fichier `pipeline.process_data_N.yml`.

## Etape 4 - Regeneration complete
- Mettre a jour `process_all.sh` pour rejouer tous les fichiers de `data/manually_processed_input`.
- Lancer: `uv run python -m pipeline_runner.pipeline_runner --config pipeline.process_data_N.yml`.

## Etape 5 - Import en base (InventoryManager)
- Utiliser les sorties finales pour creer/recreer la base PostgreSQL.
- Lancer `run import.ps1` depuis `InventoryManager`.

## Donnees de base a preserver
Ces fichiers doivent toujours permettre une reconstruction complete depuis zero:
- `manually_modified_data/*.csv`
- `base_data.xlsx`
- `Staging_data.xlsx`

## Points de controle
- Chaque execution du pipeline doit etre reproducible.
- Les corrections manuelles doivent etre tracees et rejouables.
- Les donnees de base doivent rester synchronisees avec la base PostgreSQL.

## Depot racine et sous-modules
- Le depot racine versionne la documentation et l'orchestration globale.
- Les repertoires suivants sont des sous-modules Git:
- `InventoryManager`
- `OrdersPostProcessingPipeline`
- `aliexpress_orders_exporter`

## Copier la structure sur une autre machine
Mode recommande (Git propre, historique conserve):
1. Cloner le depot racine: `git clone <url_repo_racine> Inventory`
2. Initialiser les sous-modules: `git -C Inventory submodule update --init --recursive`
3. Mettre a jour les sous-modules sur leurs commits references: `git -C Inventory submodule sync --recursive && git -C Inventory submodule update --init --recursive`

Mode copie brute (inclut l'etat local non committe):
1. Copier le dossier complet `Inventory` (avec les repertoires `.git` et les sous-dossiers `.git` des sous-modules) via `rsync`/archive.
2. Sur la machine cible, verifier l'etat: `git -C Inventory status` puis `git -C Inventory submodule foreach 'git status --short --branch'`.

Important:
- Si tu veux retrouver exactement le meme etat sur une autre machine via Git, il faut commit/push les changements dans chaque sous-module, puis commit/push le pointeur des sous-modules dans le depot racine.
