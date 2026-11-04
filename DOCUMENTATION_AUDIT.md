# Audit de la documentation

Date : 2026-11-03. Vérification contre le code, les YAML, les CSV récupérés et la définition locale du tunnel. Les documents ont été lus lors de l’audit de reprise puis recoupés avec l’état actuel des branches `linux`. Les README des caches pytest et les fichiers de dépendances installées ne constituent pas de la documentation projet.

## Résultat

La documentation décrit correctement l’architecture en trois projets, mais elle était insuffisante comme procédure actuelle : anciennes commandes, noms de fichiers historiques, instructions Windows, documents de conception non distingués des fonctions implémentées, et déploiement serveur décrit seulement dans des fragments d’historique.

Le point d’entrée opérationnel est désormais [WORKFLOW.md](WORKFLOW.md). [DATA_CONTRACT.md](DATA_CONTRACT.md) décrit les échanges réels ; [LINUX_READINESS.md](LINUX_READINESS.md) conserve les observations de migration et les résultats des tests.

## État des documents

| Document(s) | État et action |
| --- | --- |
| Racine `WORKFLOW.md` | Réécrit : étapes réelles, commandes actuelles, données, médias, tunnel, limites web et sauvegardes |
| Racine `DATA_CONTRACT.md` | Corrigé : 14 colonnes brutes, commande d’import, noms CSV exacts, variantes des lots manuels, snapshots et médias |
| Racine `README.md` | Entrée générale utilisable ; liens vers cet audit et clarification des exclusions de backup ajoutés |
| Racine `AGENTS.md` | Noms réels des fichiers de référence actualisés, avec conservation de l’invariant de reconstruction |
| Racine `LINUX_READINESS.md` | Audit de récupération, complété par les environnements Python 3.14 installés ; les sections initiales restent historiques |
| Racine `RECOVERY_STRATEGY.md` | Proposition de février 2026 ; bannière ajoutée pour ne plus la lire comme procédure actuelle. Certains outils proposés existent depuis, la provenance et l’automatisation ne sont pas démontrées |
| Racine `CODEX_COMMENTS.md`, `CODEX_PROPOSALS.md` | Observations et propositions datées, pas état fonctionnel ni liste à exécuter telle quelle |
| Racine et sous-projets `Instructions_History.md` | Traces de décisions successives ; les noms/comportements anciens ne sont pas des commandes actuelles. Nouvelle instruction consignée à la racine |
| Scraper `README.md` | Actualisé pendant l’adaptation Brave : profil persistant, préférences Suisse/français/CHF, ChromeDriver, trois étapes et commandes Linux |
| Scraper `New_driver_installation.md` | Remplacé par le guide Brave/ChromeDriver et Selenium Manager sous Linux |
| Scraper `AGENTS.md` | Python 3.14 et références ChromeDriver/Brave actualisés |
| Scraper `instructions_draft.md` | Brouillon historique, pas guide d’utilisation |
| Pipeline `PIPELINE.md` | Document de conception utile (séparation sémantique/déterministe), mais utilise `item_tag_id` au lieu du `item_tag_code` actuel, décrit des étapes optionnelles et des taux de réussite non mesurés par cet audit |
| Pipeline `AGENTS.md` | Contraintes de contribution utiles, mais objectif historique Excel/GitHub Models et ancien schéma six clés ne correspondent pas au flux actuel CSV/OpenRouter disponible et réponse sémantique trois clés |
| Pipeline `pipeline_runner/prompt.md` | Prompt réellement utilisé, taxonomie et sortie `db_item_name`, `item_tag_code`, `confidence`. Contenu utilisateur conservé sans modification |
| Pipeline `LIMITATIONS.md` | Quotas GitHub observés historiquement ; pas une description vérifiée des quotas actuels ou d’OpenRouter. Aucun accès fournisseur pour les revalider |
| Pipeline `to_be_fixed.md` | Notes historiques, notamment `tag_id`, à requalifier avant de les traiter comme défauts actuels |
| InventoryManager `README.md` | Les cinq commandes et leurs grands rôles correspondent au CLI. Le lecteur doit activer le venv ou utiliser `.venv/bin/python`. Réimport, médias et déploiement insuffisamment détaillés : complétés dans le workflow global |
| InventoryManager `tools/README.md` | Catalogue globalement conforme aux scripts. Quelques descriptions Excel parlent encore de `basic_data_*.csv` alors que l’export écrit `<NomDeFeuille>.csv`. Les exemples WSL/Pwsh sont historiques ; sélecteurs supprimés du workflow shell |
| InventoryManager `TODO.md` | Plan de février 2026 largement dépassé : `load_all`/`export_data` remplacés par `restore_data`/`save_data`, et `load_data` inclut les commandes AliExpress |
| InventoryManager `AGENTS.md` | Consignes Python actualisées, mais commandes typiques `load`/`export` historiques ; utiliser le README et le CLI actuels |
| InventoryManager `AGENTS_Proposal.md`, `Instructions_draft.md` | Documents de préparation historiques ; certains modules listés n’existent plus |
| InventoryManager `PENDING_ERRORS.md` | Problème console Windows ; pas un obstacle Linux établi. Les trois échecs de tests actuels sont dans `LINUX_READINESS.md` |
| InventoryManager `docs/PROJECT_REQUIREMENTS.md` | Vision fonctionnelle et cadre de contribution ; cases non cochées et exigences ne prouvent pas leur implémentation |
| InventoryManager `docs/USER_STORIES.md` | Six actions de prototype présentes dans l’API : créer, supprimer et déplacer objets/contenants |
| InventoryManager `docs/Instructions_History.md` | Indices utiles sur une stack serveur externe (`pg_net`, conteneurs, montages), mais pas un dossier de déploiement reproductible complet |

Les documents historiques ont été conservés. Cet audit et le workflow global donnent les correspondances actuelles sans réécrire rétroactivement les décisions passées.

## Points que le code précise mieux que les anciens guides

1. Le scraper exporte deux champs de plus que l’ancien contrat brut : `db_item_name` et `db_item_img`.
2. La configuration DeepSeek historique active uniquement l’IA et l’ajout de colonnes. Pour le nouveau lot 4, `postprocess.yml` est désormais la passe IA suivie des exports de revue ; les calculs déterministes et l’import restent en aval de la validation manuelle.
3. Les trois configurations de lots produisent directement leurs CSV dans le projet InventoryManager voisin.
4. `load_data` inclut les commandes AliExpress ; `create` efface le schéma ; `restore_data` restaure les tables métier sans post-traitement.
5. Les snapshots CSV excluent `StgAliItemOrders`, car son nom commence par `Stg`. Leur périmètre diffère de celui d’un dump PostgreSQL.
6. Le réimport n’est pas démontré idempotent : la phase Items construit de nouveaux objets pour les lignes traitées, y compris après identification d’une commande existante. La phrase historique « doublons bloqués par contraintes » ne suffit pas à garantir l’absence de duplication d’Items.
7. La copie physique des médias et leur déploiement ne sont pas automatisés dans les scripts trouvés.
8. Le calcul effectif du coût est `item_unit_price / quantité totale`, malgré un docstring parlant d’`order_price`. Ce point métier reste à valider, sans changement de code dans cet audit.
9. Le lot manuel 1 est séparé par des virgules ; les repliements du lecteur expliquent sa lecture malgré le `;` de la configuration. Les nouveaux exports restent au format `;`.
10. L’application locale est un prototype HTML/JS + API FastAPI, avec plusieurs exigences futures non implémentées. Un `/health` réussi ne teste pas une requête PostgreSQL.

## Ce qui manque pour décrire toute l’installation serveur

Le service utilisateur `postgresql-tunnel.service` a été retrouvé sur le poste ; son port et sa cible concordent avec la configuration du CLI. La stack web distante est seulement évoquée dans les historiques, les Dockerfiles, Nginx et les outils backup/restore.

Il faut encore retrouver dans le dépôt d’exploitation :

- le Compose et ses éventuels profils/overrides ;
- la commande Uvicorn, la version d’image/code déployée et le Python serveur ;
- l’URL web, le reverse proxy et les ports publiés ;
- les montages réels des fichiers statiques et leur procédure de mise à jour ;
- la valeur de connexion effective côté API, fournie par le déploiement ;
- les tâches de sauvegarde réellement installées, leur rétention et les tests de restauration.

Le Dockerfile backend local utilise encore Python 3.13 et lance `bash` par défaut. Aucun Compose n’est présent ici. Ces observations empêchent de certifier depuis ce seul dossier que l’installation serveur est alignée sur les changements Linux locaux.

## Complément : flexibilité du pipeline

Le workflow décrit désormais les champs YAML, tous les étages disponibles, les douze configurations présentes et les reprises après corrections manuelles. L’import statique des fonctions sélectionnées est correct pour les sept configurations racine. Les cinq templates de modèles ont une référence non appelable pour `ensure_extra_columns`, à remplacer par le chemin explicite `pipeline_runner.steps.ensure_extra_columns.ensure_extra_columns` avant utilisation. Cette anomalie est documentée sans modification des configurations. Les deux exemples YAML du workflow ont été exécutés dans un dossier temporaire avec des données synthétiques : ajout des colonnes et reprise après correction des valeurs/quantités, avec recalcul du coût. Les corrections et le rangement sont conservés ; aucun fichier de données du projet n’est modifié et aucun appel IA n’est exécuté. Cette validation a aussi révélé un import circulaire lorsque le module de compatibilité `pipeline_modules` est importé en premier ; le premier exemple utilise donc le chemin explicite vers la fonction.

## Vérifications et portée

Audit documentaire et statique, lecture des headers CSV et de la définition du service, recoupement des noms de commandes et destinations. Aucun appel IA, extraction authentifiée, import, création/restauration de base, démarrage d’API ou déploiement n’a été exécuté. Le démarrage de l’API lui-même peut créer des tables ; il n’a donc pas été utilisé comme simple vérification documentaire.

Les tests Python réalisés lors de la mise en place restent : pipeline 57 réussis ; scraper 7 réussis ; InventoryManager 73 réussis et trois échecs documentés. Aucune modification de code depuis ces tests n’est apportée par cet audit.

## Essai IA du lot 4

`postprocess.yml` a été réaffecté à la passe IA du nouveau CSV, avec DeepSeek/OpenRouter et des fichiers de checkpoint/revue dédiés. L’ancienne configuration est archivée sous le dossier data du pipeline. Le chargeur accepte maintenant le fichier privé `.secrets` ordinaire et les erreurs HTTP 401/403 interrompent les lots après sauvegarde ; 61 tests passent. Le premier essai distant a été refusé par HTTP 401 « User not found » ; son diagnostic est conservé séparément. La reprise en sourçant le fichier utilisateur `~/.secrets` dans le même shell que le pipeline est réussie : 32 lignes enrichies, données brutes conservées, cinq lignes à confiance inférieure à 0,8 dont trois catégories de repli. Le fichier privé local au projet reste supprimé. La revue manuelle, le parcours déterministe du lot 4 et l’import PostgreSQL sont encore en attente.

## Passage du lot 4 en base

Le fichier corrigé par l’utilisateur a été traité par `pipeline.process_data_4.yml`, ajouté à `process_all.sh`, puis importé seul grâce à `load_ali_orders --input-file`. Le coût unitaire des commandes multi-unités, l’allocation des identifiants de nouvelles commandes et le mapping `order_price → item_order_price` ont été corrigés. La sélection d’un lot rejette les réimports et limite les synchronisations staging/médias aux données concernées. Sauvegarde préalable et empreintes avant/après attestent la préservation des données existantes. Résultat : 32 objets et 32 lignes de commandes ajoutés. Les trois échecs historiques de tests InventoryManager restent inchangés ; les nouveaux tests d’import incrémental passent. Les images sont copiées localement ; le déploiement web distant reste hors vérification.
