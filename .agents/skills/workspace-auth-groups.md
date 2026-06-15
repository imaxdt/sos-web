# Skill - Workspace Auth Groups

## Quando usarla

Usala per autenticazione Google Workspace, email utente, domini, gruppi Google, ruoli, foglio `ADMIN`, Admin SDK Directory, cache utenti e permessi server-side.

## Contesto minimo

- `AGENTS.md`
- `SPEC_SUMMARY.md`
- `PROGRESS.md`
- `ARCHITECTURE.md`
- `DATABASE.md`
- `DEPLOYMENT.md`
- `src/Auth.gs`
- `src/Router.gs`
- `appsscript.json`
- `autenticazione_docenti.md` se cambia il controllo gruppo docenti

## Regole

- Normalizza sempre le email.
- Mantieni ruoli: `ADMIN`, `DOCENTE`, `STUDENTE`, `NON_AUTORIZZATO`.
- Non introdurre login/password custom.
- Verifica permessi lato server in ogni funzione protetta.
- Usa `AdminDirectory` per gruppo docenti quando disponibile, fallback `DOCENTI` solo come previsto.
- Non esporre dati riservati a utenti non autorizzati.
- Se tocchi `AdminDirectory`, verifica manifest, scope e servizio avanzato.

## Chiusura

Aggiorna `PROGRESS.md`, `ARCHITECTURE.md`, `DATABASE.md`, `DEPLOYMENT.md` e test auth se cambia il flusso.
