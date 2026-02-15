# CODEX COMMENTS

## Chapitre 1 - Situation au 2026-02-12

Observations generales:
- L'architecture multi-projets est claire (exporter, pipeline, import).
- Le pipeline est bien documente dans `OrdersPostProcessingPipeline/PIPELINE.md`.
- Les donnees de base pour la reconstruction complete ne sont pas explicitement reliees au workflow global.

Axes d'amelioration structurelle:
- Unifier la documentation d'entree/sortie par etape (noms de fichiers, formats, conventions de colonnes).
- Formaliser la procedure de mise a jour des donnees de base apres evolution de la base PostgreSQL.
- Ajouter un index des scripts critiques (entrypoints) par sous-projet.

Risques potentiels:
- Si les donnees de base ne sont pas regenerees apres une correction en base, la reconstruction complete deviendra incoherente.
- Les corrections manuelles ne sont pas encore tracees par une convention de changelog.
