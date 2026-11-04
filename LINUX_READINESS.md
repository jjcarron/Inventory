# Évaluation de la reprise sous Linux

Date : 2026-11-02. Périmètre : les 29 fichiers Markdown présents, les trois dépôts, leurs configurations, les sources Python et les données récupérées.

Décisions après l'audit : utiliser Python 3.14 ; évaluer l'utilité des deux sélecteurs d'environnement avant récupération ; adapter ultérieurement le scraper à Brave ou Firefox ; renommer les médias de manière cohérente. L'utilisateur confirme que le tunnel PostgreSQL est déjà en place et démarré comme service. Le constat initial d'absence d'écouteur IPv4 ci-dessous ne constitue donc pas un diagnostic de l'état actuel du service.

## Mise en place réalisée après l'audit

Les trois sous-projets disposent maintenant chacun d'un `.venv` utilisant Python 3.14.4 et d'un fichier `.python-version` fixé à 3.14. Les dépendances sont installées ; celles d'InventoryManager sont verrouillées dans `uv.lock`. Les contraintes de dépendances ont été ajustées pour cette version de Python, notamment pandas/NumPy, pytest et lxml. Le point d'entrée installé d'InventoryManager a été corrigé et les dépendances API/Argon2 alignées sur les usages existants.

Les six lanceurs shell d'InventoryManager n'appellent plus `select_venv.sh`. `process_all.sh` utilise directement le `.venv` du pipeline, indépendamment du répertoire courant. Les scripts PowerShell sont conservés comme outils historiques hors du workflow Linux.

Validation après installation : pipeline **57 tests réussis** ; scraper **7 tests réussis** ; InventoryManager **73 réussis et 3 échecs**. Ces échecs concernent `test_get_parameters` (méthode absente), `test_get_resource_string_default_value` (traduction attendue différente) et `test_items_db_item_values_expands_rows` (aucune insertion observée). Leur lien avec Python 3.14 n'est pas établi ; ils restent à diagnostiquer séparément. L'aide CLI d'InventoryManager fonctionne. Aucune reconstruction PostgreSQL, aucun appel IA ni extraction connectée n'a été lancé.

Les observations ci-dessous décrivent l'état initial de l'audit ; les environnements absents et les appels aux sélecteurs ont depuis été corrigés comme indiqué ci-dessus.

## Conclusion

Oui, les fichiers récupérés permettent de reprendre le développement sous Linux. Les sources, les données corrigées manuellement, les deux classeurs de référence, les CSV d'import, les snapshots et plusieurs sauvegardes PostgreSQL sont présents. La chaîne ne peut toutefois pas encore être exécutée intégralement dans l'environnement actuel.

La récupération complète des médias n'est pas démontrée : des références du snapshot ne correspondent pas aux fichiers locaux. Sans inventaire ou checksums de la machine Windows, cet audit ne peut pas certifier que la copie est exhaustive ou qu'elle représente le dernier état de cette machine.

## Adaptation Brave effectuée le 2026-11-03

Le scraper utilise désormais Brave/ChromeDriver, un profil dédié persistant et un cache Selenium Manager local au projet. La connexion réelle a été vérifiée avec Chromium/ChromeDriver 156.0.8078.80. Les préférences enregistrées et relues après rechargement sont Suisse / Berne / Berne-Mittelland / Français / CHF. Les libellés actuels `Date:` et `N° de référence:` sont pris en charge. Les prix dans une autre devise sont refusés. Les 21 tests du scraper passent ; le contrôle Pylint du programme et des nouveaux tests passe. L’extraction après le 09.02.2026 est terminée et vérifiée : 23 commandes, 32 lignes, dates réelles du 18.03.2026 au 23.10.2026, prix CHF et toutes les images récupérées. Les identifiants correspondent exactement à ceux attendus depuis la liste capturée ; aucun avertissement ni erreur dans le journal. CSV, Excel et rapport de validation SHA-256 sont sous `aliexpress_orders_exporter/data/csv/Aliexpress_orders_details_20260210_20261103.*`. Aucune étape IA ni import PostgreSQL n’a été lancé.

## Éléments récupérés et vérifiés

| Élément | Vérification |
| --- | --- |
| Trois sous-projets Git | Dépôts lisibles ; commits correspondant aux pointeurs du dépôt racine |
| Sources Python et tests | 116 fichiers Python hors données/build/environnements analysés sans erreur de syntaxe avec Python 3.14 |
| Scripts shell | Syntaxe des 15 scripts des sous-projets et des deux scripts backup/restore racine valide ; pas de CRLF dans les 15 scripts des sous-projets |
| `InventoryManager/data/init_data/Basic_Data.xlsx` | Archive XLSX intacte ; feuilles Resources, Tags, Countries, UserRoles présentes |
| `InventoryManager/data/init_data/Staging_Data.xlsx` | Archive XLSX intacte ; neuf feuilles Stg* présentes |
| `OrdersPostProcessingPipeline/data/manually_processed_input` | Trois lots corrigés présents : data_1_20251211.csv, data_2_20251224.csv, data_3_20260209.csv |
| `InventoryManager/data/input` | 13 CSV base/staging et trois CSV de commandes ; 1 327 lignes de commandes au total ; nombre de champs cohérent pour toutes les lignes des 16 CSV |
| Manifeste d'entrée `manifest.input.load_data.json` | Les 16 fichiers référencés sont présents et leurs SHA-256 correspondent |
| Snapshot `InventoryManager/data/output` | Les 16 CSV référencés correspondent aux SHA-256 du manifeste de sortie |
| Snapshots `data/output/wsl/{1,2,3}` et `pwsh/{1,2,3}` | Les fichiers correspondent aux SHA-256 de leurs manifestes respectifs |
| Dumps PostgreSQL | Quatre fichiers `.dump` du 13 février 2026 ; `pg_restore --list` réussit pour chacun, avec 222 entrées ; restauration réelle non testée |
| Médias | 1 296 fichiers sous `InventoryManager/data/static`, dont 920 images et 372 icônes ; 920 images également présentes dans les assets du scraper |
| Identifiants | Fichiers `.secrets` présents dans InventoryManager et le pipeline ; présence des noms de paramètres vérifiée sans reproduire leurs valeurs ; validité des identifiants non testée |

Les hashes prouvent la cohérence avec les manifestes récupérés, pas l'intégrité par rapport à un inventaire Windows indépendant. L'intégrité ZIP des classeurs ne valide pas les règles métier de leurs cellules.

## Obstacles concrets

### 1. Environnements Python à recréer

Aucun `.venv`, `.venv-linux` ou `.linux_venv` n'est présent dans les trois projets. Le Python système est 3.14.4 ; InventoryManager fixe 3.13 dans `.python-version`, et les consignes demandent Python 3.13. `uv` est disponible, mais aucun Python 3.13 n'a été trouvé dans le PATH ou le répertoire habituel des Python gérés par uv.

Des dépendances essentielles manquent dans le Python actuel : notamment pandas, SQLAlchemy, openpyxl, httpx, Selenium, pypyodbc et psycopg2. Recréer des environnements Linux en Python 3.14 conformément au choix de l'utilisateur, puis vérifier les dépendances et ajuster le pin 3.13 existant ; un environnement Windows copié ne serait pas réutilisable.

InventoryManager possède `pyproject.toml` et `uv.lock`. Le pipeline et le scraper utilisent chacun `requirements.txt` ; ils n'ont pas de pyproject. Les versions de pandas diffèrent entre projets, ce qui justifie des environnements séparés.

### 2. Lanceurs incomplets

`InventoryManager/tools/select_venv.sh` et `select_venv.ps1` sont suivis par Git mais absents du disque. Les scripts de reconstruction, sauvegarde CSV et restauration les appellent : ces lanceurs s'arrêteront avant leur commande Python.

`OrdersPostProcessingPipeline/process_all.sh` exige un environnement `.linux_venv`, absent lui aussi. Les trois configurations `pipeline.process_data_*.yml` trouvent néanmoins leurs CSV d'entrée, et leurs sorties ciblent correctement le dossier voisin `InventoryManager/data/input`.

### 3. Scraper lié à Edge Windows

`aliexpress_orders_exporter/aliexpress_orders_export.py`, fonction `setup_driver`, impose `C:\\WebDrivers\\Edge\\msedgedriver.exe`. Le navigateur Edge et son pilote Linux ne sont pas présents dans le PATH.

Les étapes utilisant le navigateur nécessitent un chemin de pilote configurable et un navigateur Linux avec débogage distant. L'étape 3 de lecture d'un HTML déjà sauvegardé pourra être vérifiée séparément après installation des dépendances. Les HTML historiques sont présents.

### 4. Chargement des identifiants IA

Le fichier récupéré est `OrdersPostProcessingPipeline/.secrets`, un fichier ordinaire contenant notamment les paramètres GitHub/OpenRouter. Or `pipeline_runner/config.py` lit les variables d'environnement, `.env`, ou `.secrets/.env` ; il ne lit pas directement le fichier `.secrets` actuel.

Sans variables déjà exportées, ces identifiants ne seront pas pris en compte. Il faut aligner le chargeur ou l'emplacement du fichier avant un appel IA. Aucun appel payant ou distant n'a été effectué pendant cet audit.

### 5. PostgreSQL et tunnel

La configuration vise `localhost:15432`. Aucun écouteur IPv4 sur ce port n'a été observé pendant l'audit. Les clients `psql`, `pg_dump`, `pg_restore`, ainsi que SSH et Docker, sont installés ; l'alias SSH `jp2s` existe.

`PostgresTunnel_2_jp2s.xml` est une tâche Windows qui lance `pwsh`, puis `wsl`, puis `/home/jjcarron/wsl_utils/start_pg_tunnel.sh`. Cette tâche ne configure pas de tunnel natif Linux. Il faut retrouver la cible exacte du tunnel et son script, ou fournir une connexion adaptée via `DB_URI`. L'accès au serveur et les droits PostgreSQL restent à tester.

### 6. Casse et fichiers médias

Le snapshot `data/output/Media.csv` contient 1 484 références. Parmi elles, 591 ne trouvent pas de fichier au chemin exact sous `data/static` :

- 372 correspondent à des fichiers existants avec une casse différente : par exemple `icon/a_s.webp` référence le fichier `icon/A_s.webp`. Cette différence est significative sur ce système Linux.
- 219 références PNG n'ont pas de correspondance même en ignorant la casse dans `data/static`, ni d'alternative JPG/WebP au même emplacement et avec le même nom de base.

Il faut distinguer les médias réellement à récupérer des anciennes références du snapshot. Ne pas renommer les fichiers ou réécrire les données de référence avant d'avoir choisi et documenté une convention cohérente avec le générateur de médias.

### 7. Dépendances et packaging à harmoniser

Dans InventoryManager, `requirements.txt` inclut `argon2-cffi`, FastAPI et Uvicorn, absents des dépendances de `pyproject.toml`. Le code utilise Argon2 pour les mots de passe et FastAPI pour l'API. `uv sync` seul ne couvre donc pas tous ces usages.

Le point d'entrée installé `main` désigne `InventoryManager.inventorymanager.inventory_manager:main`, alors que le package applicatif est `inventorymanager`. Utiliser la commande module documentée pendant la reprise et vérifier le packaging séparément.

L'ancien support Access dépend d'un pilote Microsoft ; il n'est pas requis pour la cible PostgreSQL. L'import de `pypyodbc` est toutefois inconditionnel dans `this_project.py`, donc sa dépendance et le runtime ODBC restent nécessaires avec le code actuel. Le runtime `libodbc` est présent sur cette machine.

## Écarts entre documents et état réel

- `WORKFLOW.md` mentionne encore `run import.ps1`, absent, et des noms de classeurs anciens. Les noms réels sont `Basic_Data.xlsx` et `Staging_Data.xlsx`.
- Les commandes actuelles du README InventoryManager sont `create`, `load_data`, `load_ali_orders`, `save_data`, `restore_data`. `TODO.md`, certaines consignes et la stratégie de récupération décrivent aussi des noms ou comportements historiques.
- Le dossier documenté `manually_modified_data` n'a pas été trouvé dans les emplacements attendus. Les trois lots corrigés utilisés par les configurations actives sont bien dans `data/manually_processed_input` ; ne pas conclure qu'un dossier historique différent n'a jamais existé.
- `pipeline.example.yml` et `postprocess.yml` référencent des entrées absentes. Les trois configurations de lots et `deepseek.deepseek-v3.2.yml` trouvent leurs entrées. Cette dernière traite un lot de 2026 mais conserve certains noms de sorties finissant en 20251211 : vérifier les destinations avant exécution.
- Le vieux `data/input/manifest.input.load_all.json` n'est pas un manifeste valide des fichiers actuellement placés dans ce répertoire : 12 fichiers référencés absents et quatre hashes différents. Le manifeste actif `manifest.input.load_data.json` est cohérent.
- Les snapshots finaux WSL et PowerShell ne sont pas identiques : le comparateur fourni détecte des différences dans Docs, ItemExtras, Item_Media, Items et Media, ainsi que dans le manifeste normalisé. Cela ne démontre pas une corruption de copie ; il faut identifier le snapshot de référence et expliquer les différences.
- `backup_data.sh` sauvegarde init_data/input/output d'InventoryManager, mais pas son dossier `data/static`, ni les secrets ou la configuration SSH. Il ne suffit donc pas à lui seul pour refaire une copie complète de cet environnement.

## Vérifications exécutées et limites

- Dix tests du pipeline passent : configuration dotenv/OpenRouter, validation des réponses et comparaison CSV. Exécution avec le Python système disponible, sans appel réseau.
- La collecte complète pytest échoue : 17 erreurs de collecte dans InventoryManager, 12 dans le pipeline et une dans le scraper, avec des imports de dépendances manquantes. Ce résultat ne permet pas de juger les suites complètes après installation.
- Le comparateur existant a été exécuté entre `data/output/wsl/3` et `data/output/pwsh/3` : résultat DIFFERENT.
- Aucun `create`, import, restore, appel IA ou navigateur authentifié n'a été lancé. En particulier, `create` supprime les tables : les essais de reconstruction devront cibler une base de développement dédiée.

Git signale des suppressions locales antérieures à l'audit : 61 fichiers sous `InventoryManager/build/lib`, les deux scripts `select_venv`, et `aliexpress_orders_exporter/README.MD`. Le fichier `README.md` du scraper existe ; la différence de casse explique potentiellement ce dernier écart. Les fichiers de build sont des copies générées ; leur absence n'empêche pas d'utiliser les sources actives. Les deux sélecteurs d'environnement, en revanche, sont utilisés par les lanceurs.

## Ordre de reprise proposé

1. Conserver l'état Git local et compléter la sauvegarde avec `InventoryManager/data/static` et les configurations privées nécessaires.
2. Utiliser Python 3.14 et créer un environnement Linux séparé pour chaque projet ; ajuster le pin Python, installer les dépendances appropriées et aligner celles d'InventoryManager.
3. Rétablir ou simplifier les sélecteurs d'environnement, puis exécuter les suites complètes de tests.
4. Aligner le chargement des secrets IA et vérifier la connexion PostgreSQL sans écriture via le tunnel déjà démarré comme service.
5. Choisir le snapshot de référence et régler les chemins de médias, puis vérifier une restauration dans une base dédiée.
6. Rejouer les traitements déterministes vers un dossier temporaire, comparer aux CSV récupérés, puis adapter et tester le navigateur Linux pour les nouvelles extractions.

La reprise du développement peut commencer avec ces fichiers ; une validation complète extraction → IA → import PostgreSQL reste à réaliser après ces adaptations.

## Suite du lot 4 — 2026-11-03

Après l’extraction et la passe IA, le fichier manuel data_4_20261103.csv a été traité puis importé dans la base inventory : 32 Items et 32 lignes de commandes ajoutés. Une sauvegarde préalable et des empreintes avant/après confirment la préservation des données existantes. La commande load_ali_orders dispose désormais de --input-file avec rejet des commandes déjà présentes. Coûts multi-unités, identifiants incrémentaux et mapping des totaux de commandes corrigés ; pipeline 63 tests réussis, InventoryManager 75 réussis et trois échecs préexistants. Les 23 images distinctes sont copiées dans data/static/img localement ; la synchronisation au serveur web reste à vérifier. Voir WORKFLOW.md pour le résultat détaillé.
