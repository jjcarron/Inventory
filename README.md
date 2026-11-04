# Inventory

Repository racine d'orchestration du projet Inventory.

## Sous-modules
Ce depot reference les 3 sous-projets comme sous-modules Git:
- `InventoryManager`
- `OrdersPostProcessingPipeline`
- `aliexpress_orders_exporter`

## Cloner sur une autre machine (recommande)
1. Cloner le depot racine:
- `git clone <url_repo_racine> Inventory`
2. Initialiser les sous-modules:
- `git -C Inventory submodule update --init --recursive`
3. Synchroniser les URLs des sous-modules puis revalider:
- `git -C Inventory submodule sync --recursive`
- `git -C Inventory submodule update --init --recursive`

## Reproduire exactement un etat local (avec changements non commit)
Si des sous-modules ont des changements locaux non commit, le clone Git ne les recupere pas.

Options:
1. Option propre:
- Commit/push les changements dans chaque sous-module.
- Commit/push le depot racine pour mettre a jour les pointeurs de sous-modules.
2. Option copie brute:
- Copier integralement le dossier `Inventory` (avec les dossiers `.git` du root et des sous-modules) via archive/`rsync`.

## Verification apres copie/clonage
- `git -C Inventory status`
- `git -C Inventory submodule foreach 'git status --short --branch'`

## Synchroniser tous les sous-modules (commande unique)
- `./sync_all.sh`

Ce script execute:
- `git submodule sync --recursive`
- `git submodule update --init --recursive`
- `git submodule update --remote --merge --recursive`

## Workflow macro
1. Export des commandes via `aliexpress_orders_exporter`.
2. Post-processing et validation manuelle via `OrdersPostProcessingPipeline`.
3. Import des donnees dans PostgreSQL via `InventoryManager`.

Documentation detaillee:
- `WORKFLOW.md`
- `DATA_CONTRACT.md`
- `DOCUMENTATION_AUDIT.md` : état des documents et écarts avec le code.
- `RECOVERY_STRATEGY.md` : propositions historiques, pas le mode opératoire actuel.

## Backup / Restore des donnees non versionnees
Sauvegarde (archive + checksum):
- `./backup_data.sh`
- `./backup_data.sh /chemin/vers/repertoire_backups`

Restauration:
- `./restore_data.sh /chemin/vers/inventory_data_YYYYMMDD_HHMMSS.tar.gz`
- `./restore_data.sh /chemin/vers/archive.tar.gz /chemin/vers/Inventory`

Notes:
- `backup_data.sh` sauvegarde init_data/input/output d’InventoryManager et les dossiers data du pipeline et du scraper. Il exclut `InventoryManager/data/static`, les secrets et la configuration du tunnel ; ces éléments doivent être sauvegardés séparément.
- `restore_data.sh` verifie automatiquement le checksum si le fichier `.sha256` est present a cote de l'archive.

## Environnement de développement Linux

Python 3.14, avec un dossier `.venv` propre à chaque sous-projet. Aucun sélecteur Windows/Linux n'est nécessaire.

Depuis `InventoryManager` :
```bash
uv sync
uv run pytest
```

Depuis `OrdersPostProcessingPipeline` ou `aliexpress_orders_exporter` :
```bash
uv venv --python 3.14 .venv
uv pip install --python .venv/bin/python -r requirements.txt
.venv/bin/python -m pytest
```

Pour travailler avec l'environnement actif : `source .venv/bin/activate`.
Le scraper utilise Brave sous Linux via ChromeDriver. Son profil dédié conserve les cookies et les préférences Suisse / Berne / Berne-Mittelland / Français / CHF. Voir `aliexpress_orders_exporter/README.md` pour le lancement.

Le parcours complet, du navigateur à l’application web, est décrit dans [WORKFLOW.md](WORKFLOW.md). Il distingue ajout de commandes, reconstruction et restauration, et précise les limites du prototype web.
