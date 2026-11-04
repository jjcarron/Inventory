# Instructions History

1. 2026-02-12: User provided AGENTS.md instructions for the Inventory project. I must support development, maintenance, and workflow optimization; document the workflow; suggest optimizations; orchestrate local agents with prepared prompts; and record every new instruction here with clear, numbered entries.
2. 2026-02-12: User asked to initialize git and commit AGENTS.md and .gitignore; revise and improve AGENTS.md; analyze the workflow and propose improvements mindful of base files (manually_modified_data/*.csv, base_data.xlsx, Staging_data.xlsx); provide steps to update those base files after DB evolution; and create WORKFLOW.md and CODEX_COMMENTS.md.
3. 2026-02-12: User requested to preserve the proposals and create CODEX_PROPOSALS.md with a first chapter listing them for later step-by-step clarification.
4. 2026-02-12: User asked to proceed with step-by-step clarification of the proposals.
5. 2026-02-12: User asked for an example of a DATA_CONTRACT.md to understand the intent.
6. 2026-02-12: User requested a complete DAT_CONTRACT with all current columns present in the data files.
7. 2026-02-12: User requested renaming DAT_CONTRACT.md to DATA_CONTRACT.md.
8. 2026-02-12: User clarified the data sources and workflow: scraper outputs a fixed-column CSV per new batch; LLM step creates short names and categories and must be manually validated; DB base data comes from InventoryManager/data/init_data/basic_data.xlsx and staging_data.xlsx (authoritative, edited manually, versioned as CSV in git); STG*.csv are versionable snapshots generated from the Excel files; manually_modified_data/*.csv are manually completed (e.g., item-container relations); base data currently only from files before app is live; later app will modify data and must support recovery strategy while inventory_manager.py load still ingests new manual order data.
9. 2026-02-12: User provided details on init_data file names, Stg* sheet naming, pipeline file conventions, and load pattern, and asked to adapt DATA_CONTRACT.md accordingly and propose a recovery strategy.
10. 2026-02-12: User clarified that scraper file naming must follow Aliexpress_orders_details_YYYYMMDD_YYYYMMDD.csv and that LLM quality fields (confidence, ai_status, ai_error, ai_raw_json) are not manually edited; user also asked whether a 10,000-item database changes future strategy considerations.
11. 2026-02-12: User requested the concrete future strategy; I added a two-level recovery strategy (simple then robust), including backup/restore procedures and import provenance requirements.
12. 2026-02-12: User requested clarification because current export tools are Excel-to-CSV (not DB exports), questioned utility of ImportBatches/checksums/counts, and asked about using PostgreSQL native backup/restore; strategy document updated to separate Excel exports from required DB snapshot tooling.
13. 2026-02-12: User requested to step back and simplify/uniform the current architecture first, because the existing solution was optimized for a different operational situation and a lighter structure is needed before defining future recovery mechanisms.
14. 2026-02-12: User proposed a new command model: `create` creates an empty DB only; `load_data` loads basic_data and staging_data from CSV (Excel kept only for editing then exported to CSV); `load_ali_orders` loads scraper files; generate input manifest before load; add `export_data` to dump real tables only to CSV + manifest for backup/restore validation; keep export_orders/process_orders manual due to browser-debug and LLM validation constraints.
15. 2026-02-12: User clarified the target input CSV list and suggested storing it in project config, confirmed manifest needs including tool_version, requested `create -> load_all -> export -> validate manifest` flow with configurable business-table scope, and noted duplicate Ali imports are already blocked by DB constraints while allowing optional preventive checks.
16. 2026-02-12: User requested immediate changes: add table lists to InventoryManager project config (input/load_all/export_data scope), using all models tables not starting with Stg for load_all/export_data, and create InventoryManager/TODO.md for the local agent to adapt the program.
17. 2026-02-12: User requested a concrete manifest JSON schema proposal first, to be validated before adding it to InventoryManager/TODO.md.
18. 2026-02-12: User validated the proposed manifest JSON schema (V1), and requested it to be added to InventoryManager/TODO.md.
19. 2026-02-12: User requested creating a dedicated JSON schema file and referencing it in InventoryManager/TODO.md for clarity.
20. 2026-02-15: User requested preparing a commit, converting the three project directories into Git submodules, updating documentation, and providing instructions to replicate the full structure on another machine.
21. 2026-02-15: User requested adding a root README.md including submodule setup and replication instructions for another machine.
22. 2026-02-15: User cleaned subproject repositories and asked to save any required changes and explain the standard procedure for handling submodule pointer updates.
23. 2026-02-15: User reported `git submodule update --init --recursive` appears to hang without copying files and requested troubleshooting guidance.
24. 2026-02-15: User confirmed submodule sync solved initialization and asked for the best way to recover non-git data on another machine.
25. 2026-02-15: User requested implementation of backup/restore scripts for non-versioned data; added root scripts `backup_data.sh` and `restore_data.sh` and documented usage in README.
26. 2026-02-15: User requested excluding backup directory from git and committing the change.
27. 2026-11-02: Lire tous les fichiers Markdown récupérés et évaluer si les sources, données, configurations et outils provenant de Windows permettent de poursuivre le développement sous Linux. Réaliser un diagnostic documenté, sans modifier les données de référence ni lancer de reconstruction de la base.
28. 2026-11-02: Utiliser Python 3.14 pour la reprise Linux ; identifier les deux scripts d'environnement absents avant de décider de leur récupération ; prévoir une adaptation du scraper à Brave ou Firefox et un renommage cohérent des médias. Le tunnel PostgreSQL est déjà installé et démarré comme service selon l'utilisateur. Fournir des exemples précis de références de médias sans fichier correspondant, sans lancer les adaptations à ce stade.

29. 2026-11-02: Configurer le développement exclusivement sous Linux avec Python 3.14 et un environnement .venv par sous-projet ; retirer les appels aux sélecteurs Windows/Linux devenus inutiles, installer les dépendances et vérifier les tests, sans modifier les données ni exécuter les imports PostgreSQL.

30. 2026-11-02: Créer et activer une nouvelle branche linux dans chacun des trois sous-projets, committer leur état de reprise Linux et pousser les branches sur origin.

31. 2026-11-03: Retenir Brave pour une future adaptation du scraper, puis vérifier l’actualité de la documentation et reconstituer le fonctionnement complet, de l’extraction AliExpress à l’application PostgreSQL/web. Comparer aux configurations et au code actuels, distinguer les opérations d’import/reconstruction/restauration et les objectifs historiques du prototype réellement présent, sans lancer d’extraction ou de modification de base.

32. 2026-11-03: Développer le workflow pour expliciter la flexibilité du pipeline, ses différents étages et fichiers YAML, les paramètres input/output/order, et les possibilités de réinjecter des fichiers corrigés manuellement à différents points sans écraser les corrections ni relancer inutilement l’IA.

33. 2026-11-03: Adapter le scraper à Brave puis extraire les commandes postérieures au 09.02.2026. Enregistrer dans le profil dédié les préférences Suisse / Berne (Bern en allemand) / Berne-Mittelland, Français et CHF ; conserver les cookies entre les lancements. Vérifier les montants en CHF sans conversion implicite, sans lancer les étapes IA ou PostgreSQL.

34. 2026-11-03: Tester la deuxième étape sur le nouvel export AliExpress : adapter postprocess.yml pour l’enrichissement IA, puis conserver l’étape manuelle avant de créer pipeline.process_data_4.yml pour les nouveaux fichiers et de passer ensuite à PostgreSQL. Préparer des sorties de revue séparées et préserver le CSV brut ainsi que les lots précédents.

35. 2026-11-03: Les nouvelles consignes AGENTS.md fournies remplacent les consignes AGENTS.md précédemment fournies ; conserver les invariants de données aux chemins vérifiés et la traçabilité numérotée.

36. 2026-11-03: Supprimer le fichier privé .secrets du pipeline et utiliser les secrets chargés en mémoire/environnement par l’utilisateur ; vérifier leur disponibilité sans révéler leurs valeurs puis reprendre le test IA du lot 4 si les identifiants sont accessibles.

37. 2026-11-03: L’utilisateur indique avoir interrompu puis relancé après chargement de OPENROUTER_API_KEY ; revérifier l’héritage de l’environnement et reprendre la passe IA si accessible. Vérification sans divulgation : la clé reste absente des commandes avec et sans shell de connexion, hors bac à sable, et de l’environnement initial du processus agent parent. Aucun nouvel appel API n’a été effectué.

38. 2026-11-03: Expliquer pourquoi la clé peut fonctionner avec le traducteur piloté par Codex mais rester absente des commandes Inventory ; fournir un contrôle sans révéler sa valeur. Corriger la conclusion trop catégorique sur l’export : Codex CLI 0.166.0 propose un serveur partagé et --no-daemon, donc tester une reprise sans réutiliser ce serveur constitue une piste, sans conclure que l’utilisateur n’a pas chargé la clé.

39. 2026-11-03: Expliquer l’environnement transmis aux commandes et fournir une méthode sans divulgation. L’utilisateur autorise le chargement de ~/.secrets ; charger ce fichier avec set -a puis lancer Python dans le même shell rend OPENROUTER_API_KEY accessible. Les commandes séparées ne conservent pas les variables du shell précédent. Reprendre le test IA par cette méthode, sans recréer de fichier .secrets dans le projet.

40. 2026-11-03: L’utilisateur précise que ~/.secrets contient déjà set -a et set +a ; ne pas répéter ces commandes. Sourcer le fichier puis lancer le programme dans le même appel suffit.

41. 2026-11-03: L’utilisateur a créé data_4_20261103.csv et autorise la suite : vérifier le lot corrigé, créer et exécuter pipeline.process_data_4.yml, valider les sorties puis poursuivre vers PostgreSQL en préservant les données existantes et en évitant le réimport des anciens lots.

42. 2026-11-03: Évaluer le développement et les tests locaux de l’API/interface par rapport aux tests directement sur le serveur, avec PostgreSQL conservé sur le serveur. Vérifier le code actuel, recommander une organisation des environnements et distinguer base utilisée et base de développement distante, sans créer de base ni lancer l’API à ce stade.

43. 2026-11-03: L’utilisateur indique disposer d’une application de test et probablement de la base distante inventorymanager_dev avec l’utilisateur codex_dev ; vérifier les informations locales disponibles et préciser uniquement les éléments manquants pour préparer le développement local et les tests distants, sans demander de secrets dans la conversation.

44. 2026-11-03: L’utilisateur précise que inventorymanager_dev est vide et peut être recréée ; la base principale reste actuellement reconstructible depuis les fichiers init_data et les quatre CSV d’import. Le prototype InventoryManager/web suffit pour valider le principe de développement local. Expliquer comment rendre le mot de passe de codex_dev accessible via le mécanisme de secrets existant, sans publication dans la conversation ni ajout au dépôt. Prévoir la variable dédiée INVENTORY_DEV_DB_PASSWORD, puis construire la connexion en mémoire.

45. 2026-11-03: L’utilisateur demande d’essayer les identifiants chargés. Connexion confirmée à inventorymanager_dev avec codex_dev (droits de schéma et base vide). Initialiser cette base de développement et préparer le lancement local de l’API et du prototype web, avec connexion construite en mémoire et garde empêchant de viser la base principale ; vérifier les opérations sur des données de test nettoyées ensuite.

46. 2026-11-03: L’utilisateur signale la réapparition des messages Failed to create stream fd. Comparaison contrôlée dans InventoryManager : tail produit trois messages avec login=true et aucun avec login=false. Utiliser désormais explicitement login=false pour les commandes et charger les secrets uniquement quand nécessaire ; consigne ajoutée à AGENTS.md pour éviter la régression.

47. 2026-11-03: Diagnostiquer l’échec de mise à jour de postgresql-client-18 lié à libpq5 >= 18.6 : vérifier les versions installées, les dépôts, les paquets retenus et la résolution APT par simulation avant toute modification système.

48. 2026-11-04: Documenter dans InventoryManager/docs le rôle des classeurs, CSV, médias et fichiers historiques d’initialisation, en distinguant sources de départ et état courant. Proposer une architecture pour un inventaire évolutif, compte tenu de l’origine RAD destinée aux bases statiques ; conserver cette évolution au stade de discussion. Pour l’interface, + et − ajustent les quantités et Supprimer supprime la fiche. Aucun changement du code ou des données demandé.

49. 2026-11-04: Créer et pousser un point de reprise par commit et tag Linux_version_0 dans les trois sous-projets et le dépôt racine avant la refonte. Préserver le framework à classes de base et les applications spécialisées par classes dérivées ; abandonner Access comme cible et retenir PostgreSQL avec SQLite, MariaDB pouvant devenir une autre cible. Revoir le découpage avant le frontend. L’ancien workflow Excel → Access → rapports explique le cadre initial. Exclure du commit les données et artefacts générés conformément aux consignes des projets ; les conserver localement.

50. 2026-02-16: User asked how to synchronize the three Git submodules in this repository.
51. 2026-02-16: User requested creating a one-command submodule synchronization script and committing it.
52. 2026-02-16: User reported restore_data checksum verification failure due to path mismatch in .sha256; requested troubleshooting and fix.
53. 2026-02-16: User requested troubleshooting and guidance to verify/update the uv environment after a WSL error: `pypyodbc.OdbcNoLibrary` (`libodbc.so` missing).
54. 2026-02-16: User requested committing all current root and submodule changes, including submodule permission updates.
