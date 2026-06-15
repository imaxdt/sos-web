# Skill - Apps Script Backend

## Quando usarla

Usala per modifiche a `src/*.gs`, routing, servizi applicativi, funzioni server, include HTML, error handling e funzioni richiamate da `google.script.run`.

## Contesto minimo

- `AGENTS.md`
- `SPEC_SUMMARY.md`
- `PROGRESS.md`
- `CONTEXT_MAP.md`
- `ARCHITECTURE.md`
- `DATABASE.md` se il backend legge o scrive dati
- `TESTING.md` e test pertinenti

## File tipici

- `src/Code.gs`
- `src/Router.gs`
- `src/Auth.gs`
- `src/Database.gs`
- `src/*Service.gs`
- `src/Notifications.gs`
- `html/Index.html` solo per contratti server/client

## Regole

- Ricontrolla ruoli lato server prima di letture/scritture riservate.
- Mantieni compatibilità con Apps Script V8.
- Non introdurre dipendenze esterne non previste.
- Non mischiare backend, HTML, JavaScript client e CSS.
- Restituisci errori leggibili alla UI.
- Registra log e notifiche log-only dove previsto dal flusso.

## Chiusura

Aggiorna `PROGRESS.md`. Aggiorna `ARCHITECTURE.md`, `PROJECT_SPEC.md`, `DATABASE.md`, `TESTING.md` o `CHANGELOG.md` solo se il comportamento o i contratti cambiano.
