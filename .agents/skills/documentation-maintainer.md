# Skill - Documentation Maintainer

## Quando usarla

Usala per README, specifiche, database, architettura, UI, progress, testing, deploy, changelog, direttive agenti e skill locali.

## Contesto minimo

- `AGENTS.md`
- `SPEC_SUMMARY.md`
- `PROGRESS.md`
- `CONTEXT_MAP.md`
- Documento specifico da modificare
- Documenti correlati indicati dalla mappa contesto

## Regole

- Evita duplicazioni: se un documento esistente basta, aggiorna quello.
- Mantieni `PROGRESS.md` compatto; archivia cronologia lunga in `docs/archive/`.
- Non eliminare contenuti storici senza spostarli o segnalarli.
- Distingui documentazione corrente, storico e analisi futura.
- Non dichiarare deploy/test come verificati se non sono stati eseguiti in questa sessione; usa "documentato" o "registrato" se deriva dallo storico.
- Aggiorna `CHANGELOG.md` per cambi rilevanti di manutenzione.

## Chiusura

Esegui almeno `git diff --check` per patch Markdown. Riporta file modificati, controlli, rischi e se conviene `/compact`.
