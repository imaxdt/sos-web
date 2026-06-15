# PROJECT SPEC - SOS Recuperi

## Scopo

Realizzare una web app Google Apps Script interna al dominio scolastico per gestire attività di recupero dei docenti, materie/laboratori disponibili, iscrizioni degli studenti, lettura ordinata degli iscritti da parte dei docenti, notifiche e log essenziali.

## Cosa fa l’app

### Area docente

Il docente può accedere tramite account Google Workspace, dichiarare materie/laboratori, creare **attività di recupero** per una coppia materia/docente, scegliere tra `SOS` e `Recupero Estivo`, definire il monte ore previsto quando richiesto, aggiungere una o più lezioni all'attività, compilare note visibili agli studenti, argomenti, campo principale e altri dettagli, definire minimo/massimo studenti sull'attività intera, indicare se accettare solo studenti della stessa classe, consultare studenti iscritti, perfezionare l'argomento indicato dallo studente nell'iscrizione ed eventualmente inviare messaggi rapidi.

### Area studente

Lo studente può accedere tramite account Google Workspace, consultare attività di recupero disponibili, filtrare per materia/docente/giorno/fascia oraria/posti disponibili, visualizzare note, argomenti e calendario lezioni, scegliere una attività, confermare iscrizione all'attività intera, vedere le proprie iscrizioni e cancellare se consentito.

### Area admin

L’admin può verificare configurazione, gestire parametri globali, controllare log, intervenire su dati anomali, gestire tabelle di base, bloccare/sbloccare temporaneamente uno studente dalle nuove iscrizioni SOS e verificare deploy/configurazioni. I superadmin possono modificare da interfaccia solo i parametri operativi autorizzati, inclusa l'attivazione controllata delle notifiche email.

Gli admin sono definiti nel foglio `ADMIN` del database, con email nella colonna `admin` e valore booleano `superadmin` nella seconda colonna.

## Cosa non fa l’app

La web app non deve gestire scrutinio, voti, recupero debiti ufficiale, presenze, registro lezioni ufficiale, firma elettronica, verbali, consuntivo economico, pagamento ore docenti o integrazione obbligatoria con registro elettronico.

## Flusso docente

```text
Accesso docente → Dashboard docente → Gestione materie/laboratori → Creazione attività di recupero → Aggiunta lezioni → Consultazione iscritti → Eventuale messaggio agli iscritti
```

## Flusso studente

```text
Accesso studente → Esplora recuperi → Filtri → Scelta attività di recupero → Conferma iscrizione all'attività → Consulta iscrizioni
```

## Campi principali dell'attività di recupero

| Campo | Scopo |
|---|---|
| materia/laboratorio | Materia dell'attività |
| tipo_corso | `SOS` o `RECUPERO_ESTIVO` |
| modalita_generazione | `SINGOLA`, `GIORNALIERA`, `SETTIMANALE` |
| ripetizione_fino | Data limite per generazione automatica |
| lezioni_previste | Numero lezioni attese |
| titolo_corso | Titolo visibile |
| ore_previste | Monte ore previsto; `SOS` usa durata lezione, `RECUPERO_ESTIVO` usa 10 |
| note_studenti | Note visibili agli studenti |
| argomenti | Argomenti trattati o previsti |
| principale | Tipologia o focus principale |
| altri_dettagli | Ulteriori informazioni |
| min_studenti | Numero minimo studenti sull'attività |
| max_studenti | Numero massimo studenti sull'attività |
| solo_stessa_classe | Vincolo stessa classe |
| stato | BOZZA/PUBBLICATO/COMPLETO/ANNULLATO/CHIUSO |

## Campi principali della lezione

| Campo | Scopo |
|---|---|
| data | Data della lezione |
| ora_inizio | Ora di inizio in formato HH:MM |
| durata | 1h o 2h |
| ora_fine | Calcolata automaticamente |
| stato | PROGRAMMATA/ANNULLATA |

## Regole funzionali

1. Solo utenti autorizzati possono accedere.
2. Un docente può gestire solo i propri corsi.
3. Uno studente può iscriversi solo ad attività pubblicate.
4. Uno studente non può iscriversi due volte alla stessa attività.
5. Una attività non può superare `max_studenti`.
6. Se una attività raggiunge `max_studenti`, può diventare `COMPLETO`.
7. Una iscrizione deve essere atomica tramite `LockService`.
8. Una lezione annullata non cancella l'attività; il docente può aggiungere una lezione sostitutiva.
9. Una attività in bozza non è visibile agli studenti.
10. Le azioni rilevanti devono essere loggate.
11. L'ora di inizio lezione deve essere tra 08:00 e 18:00 con step di 15 minuti; durata ammessa 1h o 2h.
12. I giorni disponibili per i corsi sono configurati in `CONFIG.giorni_corsi_disponibili` con formato `1-5` o `1-6`.
13. `SOS` e' una sola lezione; la ripetizione genera piu' corsi SOS separati.
14. `RECUPERO_ESTIVO` e' un pacchetto unico da 5 lezioni di 2h; la generazione automatica si ferma a 5 lezioni o alla data limite e segnala le lezioni mancanti.
15. Il docente può modificare `nota_studente` solo per iscrizioni attive collegate alle proprie attività; il valore precedente resta tracciato in `LOG_AZIONI`.
16. Un blocco studente attivo impedisce nuove iscrizioni `SOS`, ma non cancella lo studente e non impedisce la consultazione delle iscrizioni esistenti.

## Regole autenticazione e ruoli

- Gli studenti usano il dominio secondario `@studenti.liceoduca.it`.
- Gli account con dominio `@studenti.liceoduca.it` sono candidati al ruolo `STUDENTE`.
- I docenti usano il dominio `@liceoduca.it`.
- Gli account `@liceoduca.it` diventano `DOCENTE` solo se appartengono allo specifico gruppo Google docenti configurato in `CONFIG.gruppo_docenti`.
- Gli admin sono letti dal foglio `ADMIN`.
- Gli utenti che non soddisfano le regole precedenti risultano `NON_AUTORIZZATO`.

## MVP

La prima versione deve includere setup database, autenticazione e ruoli, dashboard docente minima, gestione materie docente, creazione attività di recupero, aggiunta/annullamento lezioni, esplora attività studente, iscrizione studente all'attività, elenco iscrizioni studente, blocco overbooking sull'attività, blocco doppia iscrizione e log azioni.
