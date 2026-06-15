# Skill - Deployment Release

## Quando usarla

Usala per `clasp`, `sync2gscript.sh`, `.claspignore`, manifest Apps Script, deployment Web App, rollback, versioni e sincronizzazione GitHub.

## Contesto minimo

- `AGENTS.md`
- `SPEC_SUMMARY.md`
- `PROGRESS.md`
- `DEPLOYMENT.md`
- `TESTING.md`
- `.claspignore`
- `appsscript.json`
- `sync2gscript.sh`
- `sync2github.sh` solo se l'utente chiede commit/push

## Regole

- Chiedi conferma prima di push GAS, deploy, rollback, commit o push GitHub.
- Esegui `./sync2gscript.sh status` prima di ogni push Apps Script.
- Verifica `.claspignore` se cambiano file da includere/escludere.
- Non dichiarare "ultima versione stabile" senza controllare `./sync2gscript.sh deployments` o uno storico esplicito.
- Dopo deploy, registrare deployment ID, versione, descrizione, test eseguiti e rollback possibile.

## Chiusura

Aggiorna `PROGRESS.md`, `DEPLOYMENT.md` e `CHANGELOG.md`. Riporta test automatici, test manuali richiesti e rischi operativi.
