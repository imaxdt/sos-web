# Skill - Booking Concurrency

## Quando usarla

Usala per iscrizioni, cancellazioni, overbooking, ultimo posto, doppie iscrizioni, stato attività, conteggio posti e sezioni protette da `LockService`.

## Contesto minimo

- `AGENTS.md`
- `SPEC_SUMMARY.md`
- `PROGRESS.md`
- `DATABASE.md`
- `src/StudentiService.gs`
- `src/DocentiService.gs`
- `TESTING.md`
- `tests/e2e/course-flows.spec.ts` se cambia il comportamento testabile

## Regole

- Ogni iscrizione deve usare `LockService`.
- Dentro il lock: rileggi attività, conta iscrizioni attive, verifica posti, verifica duplicati, scrivi iscrizione, aggiorna stato, rilascia in `finally`.
- Blocca doppia iscrizione attiva dello stesso studente alla stessa attività.
- Blocca overbooking sull'attività intera.
- Riapri attività `COMPLETO` quando una cancellazione porta i posti occupati sotto il massimo.
- Mantieni controlli server-side anche se la UI disabilita pulsanti.
- Non cambiare stati o colonne senza aggiornare `DATABASE.md`.

## Chiusura

Aggiorna `PROGRESS.md`, test e changelog. Se non puoi testare ultimo posto/doppia iscrizione, lascia rischio esplicito.
