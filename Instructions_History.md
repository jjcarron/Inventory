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
27. 2026-02-16: User asked how to synchronize the three Git submodules in this repository.
28. 2026-02-16: User requested creating a one-command submodule synchronization script and committing it.
29. 2026-02-16: User reported restore_data checksum verification failure due to path mismatch in .sha256; requested troubleshooting and fix.
30. 2026-02-16: User requested troubleshooting and guidance to verify/update the uv environment after a WSL error: `pypyodbc.OdbcNoLibrary` (`libodbc.so` missing).
31. 2026-02-16: User requested committing all current root and submodule changes, including submodule permission updates.
