# SPEC SUMMARY - SOS Recuperi

## Prodotto

SOS Recuperi e' una web app interna Google Workspace per gestire attività di recupero scolastico, sportelli didattici e recuperi estivi. Il backend e' Google Apps Script V8, il database e' Google Sheets, il frontend e' HTML/CSS/JavaScript servito da `HtmlService`.

## Ruoli

- `ADMIN`: gestisce configurazione, log, test `viewAs`/`runAs`, setup e controlli.
- `DOCENTE`: dichiara materie/laboratori, crea attività, aggiunge o annulla lezioni, consulta iscritti.
- `STUDENTE`: esplora attività, filtra, vede calendario/posti, conferma iscrizione, consulta e cancella le proprie iscrizioni.
- `NON_AUTORIZZATO`: vede pagina di accesso negato.

## Dominio funzionale

Una attività di recupero e' una riga in `PACCHETTI_RECUPERO`; le singole lezioni sono righe in `LEZIONI_PACCHETTO`; le iscrizioni sono righe in `ISCRIZIONI_PACCHETTO`.

- `SOS`: una sola lezione da 1h o 2h. Se ripetuto, genera attività SOS separate.
- `RECUPERO_ESTIVO`: pacchetto unico da 5 lezioni da 2h, totale 10 ore. Se la data limite non consente 5 lezioni, il sistema salva quelle generate e segnala le mancanti.

I vecchi fogli `DISPONIBILITA` e `PRENOTAZIONI` sono legacy e non sono il flusso principale.

## Regole critiche

- Le iscrizioni studente devono usare `LockService` per evitare overbooking.
- Il limite posti vale sull'attività intera, non sulla singola lezione.
- Uno studente non puo' avere due iscrizioni attive alla stessa attività.
- Le funzioni server devono ricontrollare ruolo e permessi anche se la UI nasconde azioni.
- Le notifiche email restano disabilitate di default: `CONFIG.notifiche_email_attive = FALSE` produce solo righe `LOG_ONLY`.

## Stato operativo

Alla data 2026-06-12 il blocco manuale T85.* risulta completato e pushato nel commit `149435a`. La documentazione precedente conteneva parti storiche e prompt iniziali: usare `AGENTS.md`, questo file, `PROGRESS.md` e `CONTEXT_MAP.md` come ingresso operativo.

## Stack e comandi

- Apps Script project: `16DA8Gg4OTJuhCxPVSYZg_VjpYivO7s2MEcC2vDSLK9sJcIIeItDnMw0e`
- Sheet DB: `1Ugy2gYe9uHsqZXIRi7_SIMcwXPYYNmEnoKvLHIwI9TU`
- Sync GAS: `./sync2gscript.sh status`, `./sync2gscript.sh push`
- E2E: `npm run e2e:auth`, `npm run e2e:smoke`, `npm run e2e:write`

## Confini

La versione corrente non gestisce voti, presenze, scrutini, recupero debiti ufficiale, pagamenti o registro elettronico. La migrazione SQL e' documentata come analisi futura in `docs/migration/`, non come attività corrente.
