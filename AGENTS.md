# Inventory - Instructions Agent

Ce document est l'instrument de travail pour l'agent. Il doit rester a jour, clair, et actionnable.

## Role de l'agent
- Soutenir le developpement, la maintenance et l'amelioration continue du projet Inventory.
- Documenter le workflow et optimiser l'introduction de nouvelles donnees.
- Orchestrer les agents locaux propres a chaque sous-projet en preparant les prompts necessaires.

## Contexte
Le projet Inventory gere un stock de materiel pour un laboratoire d'electronique. Les objets proviennent en grande partie de commandes Aliexpress. Un scrapper extrait les commandes, un post-processing (avec une etape AI puis des nettoyages algorithmiques) categorise et nettoie les donnees. Les resultats sont importes dans une base PostgreSQL, puis exposes par une application web.

## Structure (vue racine)
.
├── InventoryManager
├── OrdersPostProcessingPipeline
└── aliexpress_orders_exporter

## Workflow (vue macro)
1. Exporter les commandes via `aliexpress_orders_exporter`.
2. Post-traiter avec `OrdersPostProcessingPipeline` (etape AI + nettoyages).
3. Corriger manuellement les donnees si necessaire.
4. Rejouer le pipeline de traitement pour produire les sorties finales.
5. Importer les donnees finales dans PostgreSQL via les scripts d'`InventoryManager`.

## Donnees de base (invariants)
Les fichiers suivants sont la base de reference pour reconstruire la base de donnees depuis zero, et doivent toujours rester coherents et exploitables :
- `OrdersPostProcessingPipeline/data/manually_processed_input/*.csv`
- `InventoryManager/data/init_data/Basic_Data.xlsx`
- `InventoryManager/data/init_data/Staging_Data.xlsx`
- Les médias référencés sous `InventoryManager/data/static/`.

Ces chemins vérifiés remplacent les anciens noms génériques `manually_modified_data`, `base_data.xlsx` et `Staging_data.xlsx`. Les CSV d’import correspondants sont décrits dans `DATA_CONTRACT.md`.

## Contraintes de travail
- Maintenir une documentation a jour pour faciliter la comprehension et la contribution.
- Assurer la tracabilite de la collaboration en consignant chaque nouvelle instruction dans `Instructions_History.md` avec numerotation.
- Les instructions consignées doivent etre un resume clair des consignes telles qu'interpretees.

## Qualite et discipline
- Preferer des actions reproductibles (scripts, configs versionnees).
- Signaler clairement les hypothèses ou zones d'incertitude.
- Eviter de modifier des fichiers de donnees de base sans procedure de mise a jour documentee.

## Exécution des commandes de l’agent
- Utiliser explicitement un shell sans profil de connexion (`login=false`) pour les commandes de travail. Le shell de connexion réintroduit dans certains sous-projets les messages `Failed to create stream fd: Operation not permitted`.
- Si des identifiants sont nécessaires, charger explicitement le script utilisateur `~/.secrets` dans le même appel que le programme, sans afficher de valeur.
