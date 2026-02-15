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

## Workflow macro
1. Export des commandes via `aliexpress_orders_exporter`.
2. Post-processing et validation manuelle via `OrdersPostProcessingPipeline`.
3. Import des donnees dans PostgreSQL via `InventoryManager`.

Documentation detaillee:
- `WORKFLOW.md`
- `DATA_CONTRACT.md`
- `RECOVERY_STRATEGY.md`
