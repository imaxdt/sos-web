# Skill - Google Sheets Database

## Quando usarla

Usala per `DATABASE.md`, `Setup.gs`, `Database.gs`, struttura fogli, colonne, seed, normalizzazione dati e migrazioni Google Sheets.

## Contesto minimo

- `AGENTS.md`
- `SPEC_SUMMARY.md`
- `PROGRESS.md`
- `DATABASE.md`
- `src/Config.gs`
- `src/Database.gs`
- `src/Setup.gs`
- Servizi che leggono o scrivono le tabelle coinvolte
- `DEPLOYMENT.md` se serve setup o migrazione reale

## Regole

- Aggiorna prima `DATABASE.md`, poi setup e servizi.
- Non rinominare colonne senza impatto e migrazione documentati.
- Non cancellare dati esistenti in setup o migrazioni.
- Conserva compatibilità con fogli già esistenti.
- Usa `attivo` o `stato` per record non più validi.
- Ricorda che `DISPONIBILITA` e `PRENOTAZIONI` sono legacy; il flusso principale usa `PACCHETTI_RECUPERO`, `LEZIONI_PACCHETTO`, `ISCRIZIONI_PACCHETTO`.

## Chiusura

Aggiorna `PROGRESS.md`, `DATABASE.md`, test e deployment se servono azioni su fogli reali.
