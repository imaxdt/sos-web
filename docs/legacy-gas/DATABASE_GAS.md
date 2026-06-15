# DATABASE - SOS Recuperi

## Scopo

Questo file descrive la struttura del database applicativo della web app **SOS Recuperi**. Il database è un file **Google Sheet** usato come archivio dati tramite Google Apps Script.

File database: `SOS_RECUPERI_DB`.

ID Google Sheet: `1Ugy2gYe9uHsqZXIRi7_SIMcwXPYYNmEnoKvLHIwI9TU`.

Ogni foglio del Google Sheet rappresenta una tabella logica.

## Principi generali

1. Ogni tabella ha una prima riga di intestazione.
2. I nomi delle colonne devono rimanere stabili.
3. Gli ID sono stringhe generate dall’app.
4. Gli utenti non devono modificare direttamente il database.
5. Docenti e studenti devono usare solo la web app.
6. Le azioni importanti devono essere registrate in `LOG_AZIONI`.
7. Le iscrizioni devono usare `LockService` per evitare overbooking.
8. Per record non più validi usare campi `attivo` o `stato`.

## Tabelle / Fogli

```text
CONFIG
ADMIN
UTENTI_CACHE
DOCENTI
STUDENTI
MATERIE
DOCENTI_MATERIE
PACCHETTI_RECUPERO
LEZIONI_PACCHETTO
ISCRIZIONI_PACCHETTO
STUDENTI_BLOCCATI
DISPONIBILITA
PRENOTAZIONI
NOTIFICHE
LOG_AZIONI
```

# CONFIG

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| chiave | string | sì | Nome univoco del parametro |
| valore | string | sì | Valore del parametro |
| descrizione | string | no | Descrizione leggibile |
| aggiornato_il | datetime | sì | Data ultimo aggiornamento |

Esempi: `app_name`, `database_spreadsheet_id`, `script_id`, `timezone`, `dominio_docenti`, `dominio_studenti`, `gruppo_docenti`, `admin_da_tabella`, `studenti_da_dominio`, `anno_scolastico`, `max_prenotazioni_per_studente`, `modifica_entro_ore`, `cancellazione_entro_ore`, `giorni_corsi_disponibili`, `notifiche_email_attive`.

`giorni_corsi_disponibili` usa formato `1-5` o `1-6`, con `1=lunedi` e `7=domenica`; il default operativo e' `1-6`.

# ADMIN

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| admin | string | sì | Email admin autorizzato |
| superadmin | boolean | sì | TRUE se l'admin ha privilegi completi |
| attivo | boolean | sì | TRUE/FALSE |
| note | string | no | Note operative |
| aggiornato_il | datetime | sì | Data ultimo aggiornamento |

Le prime due colonne devono restare `admin` e `superadmin`. Gli admin vengono letti da questa tabella, non da un gruppo Google admin.

# UTENTI_CACHE

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| email | string | sì | Email Google dell’utente |
| nome | string | no | Nome utente |
| cognome | string | no | Cognome utente |
| ruolo | enum | sì | ADMIN / DOCENTE / STUDENTE / NON_AUTORIZZATO |
| gruppi | string | no | Gruppi o sorgente ruolo |
| ultimo_accesso | datetime | sì | Ultimo accesso alla web app |
| attivo | boolean | sì | TRUE/FALSE |

# DOCENTI

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| docente_id | string | sì | ID interno docente |
| email | string | sì | Email istituzionale |
| nome | string | sì | Nome |
| cognome | string | sì | Cognome |
| telefono | string | no | Telefono facoltativo |
| min_studenti_materia | number | sì | Minimo studenti predefinito per corsi materia |
| max_studenti_materia | number | sì | Massimo studenti predefinito per corsi materia |
| min_studenti_laboratorio | number | sì | Minimo studenti predefinito per corsi laboratorio |
| max_studenti_laboratorio | number | sì | Massimo studenti predefinito per corsi laboratorio |
| max_prenotazioni_studente | number | sì | Limite iscrizioni/prenotazioni per studente verso questo docente |
| solo_stessa_classe_default | boolean | sì | Valore predefinito per limitazione stessa classe |
| notifiche_email | boolean | sì | TRUE se il docente riceve notifiche |
| attivo | boolean | sì | TRUE/FALSE |

# STUDENTI

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| studente_id | string | sì | ID interno studente |
| email | string | sì | Email studente |
| nome | string | sì | Nome |
| cognome | string | sì | Cognome |
| classe | string | sì | Classe, es. 3A |
| sezione | string | no | Eventuale sezione |
| attivo | boolean | sì | TRUE/FALSE |

# MATERIE

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| materia_id | string | sì | ID materia/laboratorio |
| nome | string | sì | Nome visibile |
| tipo | enum | sì | MATERIA / LABORATORIO |
| descrizione | string | no | Descrizione standard |
| attiva | boolean | sì | TRUE/FALSE |
| ordine | number | no | Ordinamento nella UI |

Esempi: `MATEMATICA`, `INGLESE`, `DIRITTO`, `FILOSOFIA`, `FISICA`, `INFORMATICA`, `ENGLISH_LAB`.

# DOCENTI_MATERIE

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| docente_materia_id | string | sì | ID collegamento |
| docente_id | string | sì | Riferimento a DOCENTI.docente_id |
| materia_id | string | sì | Riferimento a MATERIE.materia_id |
| descrizione_docente | string | no | Descrizione visibile o utile per la UI |
| note_interne | string | no | Note visibili solo al docente/admin |
| attiva | boolean | sì | TRUE/FALSE |
| creato_il | datetime | sì | Data creazione |

Vincolo: la coppia `docente_id + materia_id` dovrebbe essere unica tra i record attivi.

# PACCHETTI_RECUPERO

Tabella principale delle **attività di recupero**. Una attività e' un pacchetto materia/docente a cui gli studenti si iscrivono; le singole lezioni sono righe collegate in `LEZIONI_PACCHETTO`.

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| pacchetto_id | string | sì | ID tecnico dell'attività/pacchetto |
| docente_id | string | sì | Riferimento a DOCENTI.docente_id |
| materia_id | string | sì | Riferimento a MATERIE.materia_id |
| tipo_corso | enum | sì | `SOS` o `RECUPERO_ESTIVO` |
| modalita_generazione | enum | sì | `SINGOLA`, `GIORNALIERA`, `SETTIMANALE` |
| ripetizione_fino | date | no | Data limite della generazione automatica |
| lezioni_previste | number | sì | 1 per SOS, 5 per Recupero Estivo |
| generazione_gruppo_id | string | no | Gruppo tecnico per SOS ripetuti generati insieme |
| titolo_corso | string | sì | Titolo visibile dell'attività di recupero |
| ore_previste | number | sì | Monte ore previsto; `SOS` usa durata lezione, `RECUPERO_ESTIVO` usa 10 |
| ore_programmate | number | sì | Somma ore delle lezioni non annullate |
| note_studenti | text | no | Note visibili agli studenti |
| argomenti | text | no | Argomenti principali dell'attività |
| principale | string | no | Sintesi principale, es. Ripasso/Esercitazione |
| altri_dettagli | text | no | Dettagli aggiuntivi |
| min_studenti | number | sì | Numero minimo studenti per l'attività |
| max_studenti | number | sì | Numero massimo studenti per l'attività |
| solo_stessa_classe | boolean | sì | TRUE/FALSE |
| stato | enum | sì | BOZZA/PUBBLICATO/COMPLETO/ANNULLATO/CHIUSO |
| segnalazioni_generazione | text | no | Lezioni non generate o mancanti per completare l'attività |
| creato_da | string | sì | Email creatore |
| creato_il | datetime | sì | Data creazione |
| aggiornata_il | datetime | sì | Ultimo aggiornamento |

Regole: il limite posti vale sull'attività intera. `SOS` e' una sola lezione e, se ripetuto, genera piu' attività separate. `RECUPERO_ESTIVO` e' una attività unica da 5 lezioni di 2 ore, totale 10 ore; se la data limite non consente il completamento, il sistema salva le lezioni generate e segnala quelle mancanti. Sono ammesse piu' attività attive con stessa coppia docente/materia quando serve duplicare una proposta per richieste elevate.

# LEZIONI_PACCHETTO

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| lezione_id | string | sì | ID lezione |
| pacchetto_id | string | sì | Riferimento a PACCHETTI_RECUPERO.pacchetto_id |
| data | date | sì | Data della lezione |
| ora_inizio | time | sì | Ora inizio, HH:MM, step 15 minuti, range 08:00-18:00 |
| ora_fine | time | sì | Ora fine calcolata da ora_inizio + durata |
| durata_minuti | number | sì | 60 o 120 |
| stato | enum | sì | PROGRAMMATA/ANNULLATA |
| note_lezione | text | no | Note specifiche della lezione |
| creata_da | string | sì | Email creatore |
| creata_il | datetime | sì | Data creazione |
| aggiornata_il | datetime | sì | Ultimo aggiornamento |

Regole: l'utente inserisce solo `ora_inizio` e durata `1h`/`2h`; `ora_fine` viene calcolata. L'ora di inizio deve essere nel range 08:00-18:00 con step di 15 minuti.

# ISCRIZIONI_PACCHETTO

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| iscrizione_id | string | sì | ID iscrizione |
| pacchetto_id | string | sì | Riferimento a PACCHETTI_RECUPERO.pacchetto_id |
| studente_id | string | sì | Riferimento a STUDENTI.studente_id |
| email_studente | string | sì | Email ridondante per lettura rapida |
| classe_studente | string | sì | Classe ridondante per filtri |
| stato | enum | sì | ATTIVA/CANCELLATA_STUDENTE/CANCELLATA_DOCENTE/ANNULLATA |
| nota_studente | text | no | Nota opzionale dello studente |
| iscritta_il | datetime | sì | Timestamp iscrizione |
| aggiornata_il | datetime | sì | Ultima modifica |

Vincoli: no doppia iscrizione attiva dello stesso studente alla stessa attività; iscrizione solo su attività pubblicate e non piene; controllo posti con `LockService`.

# STUDENTI_BLOCCATI

Tabella dei blocchi temporanei per impedire nuove iscrizioni `SOS` a uno studente senza cancellare il profilo e senza modificare iscrizioni storiche.

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| blocco_id | string | sì | ID tecnico del blocco |
| studente_id | string | sì | Riferimento a STUDENTI.studente_id |
| email_studente | string | sì | Email studente bloccato |
| motivo | text | sì | Motivo operativo del blocco |
| inizio_blocco | date | sì | Data inizio validità blocco |
| fine_blocco | date | no | Data fine blocco opzionale |
| attivo | boolean | sì | TRUE/FALSE |
| creato_da | string | sì | Email admin che ha creato il blocco |
| creato_il | datetime | sì | Data creazione blocco |
| aggiornato_da | string | no | Email admin ultimo aggiornamento |
| aggiornato_il | datetime | sì | Data ultimo aggiornamento |

Regole: un blocco attivo con `inizio_blocco` raggiunta e `fine_blocco` vuota o non scaduta impedisce nuove iscrizioni a corsi `SOS`. Lo studente resta autorizzato ad accedere alla web app e a consultare le proprie iscrizioni. Blocco e sblocco sono registrati in `LOG_AZIONI`.

# DISPONIBILITA

Tabella legacy degli slot singoli. Il nuovo flusso usa `PACCHETTI_RECUPERO` e `LEZIONI_PACCHETTO`.

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| disponibilita_id | string | sì | ID slot |
| docente_id | string | sì | Riferimento a DOCENTI.docente_id |
| materia_id | string | sì | Riferimento a MATERIE.materia_id |
| titolo_slot | string | sì | Titolo breve dello slot |
| data | date | sì | Data dello slot |
| ora_inizio | time | sì | Ora inizio |
| ora_fine | time | sì | Ora fine |
| durata_minuti | number | sì | Durata calcolata |
| note_studenti | text | no | Note visibili agli studenti |
| argomenti | text | no | Argomenti principali |
| principale | string | no | Sintesi principale, es. Ripasso/Esercitazione |
| altri_dettagli | text | no | Dettagli aggiuntivi |
| min_studenti | number | sì | Numero minimo studenti |
| max_studenti | number | sì | Numero massimo studenti |
| solo_stessa_classe | boolean | sì | TRUE/FALSE |
| stato | enum | sì | BOZZA/PUBBLICATA/COMPLETA/ANNULLATA/CHIUSA |
| ripetizione_gruppo_id | string | no | ID comune per slot generati da ripetizione |
| creata_da | string | sì | Email creatore |
| creata_il | datetime | sì | Data creazione |
| aggiornata_il | datetime | sì | Ultimo aggiornamento |

Campi UI: Note = `note_studenti`; Argomenti = `argomenti`; Principale = `principale`; Altri = `altri_dettagli`.

# PRENOTAZIONI

Tabella legacy delle prenotazioni su singolo slot. Il nuovo flusso usa `ISCRIZIONI_PACCHETTO`.

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| prenotazione_id | string | sì | ID prenotazione |
| disponibilita_id | string | sì | Riferimento a DISPONIBILITA.disponibilita_id |
| studente_id | string | sì | Riferimento a STUDENTI.studente_id |
| email_studente | string | sì | Email ridondante per lettura rapida |
| classe_studente | string | sì | Classe ridondante per filtri |
| stato | enum | sì | ATTIVA/CANCELLATA_STUDENTE/CANCELLATA_DOCENTE/ANNULLATA |
| nota_studente | text | no | Nota opzionale dello studente |
| prenotata_il | datetime | sì | Timestamp prenotazione |
| aggiornata_il | datetime | sì | Ultima modifica |

Vincoli: no doppia prenotazione attiva dello stesso slot; prenotazione solo su slot `PUBBLICATA`; controllo posti con `LockService`.

# NOTIFICHE

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| notifica_id | string | sì | ID notifica |
| tipo | enum | sì | PRENOTAZIONE/CANCELLAZIONE/PROMEMORIA/MESSAGGIO_DOCENTE/ERRORE |
| destinatario | string | sì | Email destinatario |
| oggetto | string | sì | Oggetto email |
| esito | enum | sì | INVIATA/ERRORE/NON_INVIATA |
| riferimento_tipo | string | no | Entità collegata |
| riferimento_id | string | no | ID entità collegata |
| inviata_il | datetime | sì | Timestamp invio |

# LOG_AZIONI

| Colonna | Tipo logico | Obbligatorio | Descrizione |
|---|---|---:|---|
| log_id | string | sì | ID log |
| timestamp | datetime | sì | Data e ora azione |
| email_utente | string | sì | Utente che ha eseguito l’azione |
| ruolo | enum | sì | Ruolo al momento dell’azione |
| azione | string | sì | Nome azione |
| entita | string | sì | Tabella o area interessata |
| entita_id | string | no | ID record interessato |
| dettaglio | text | no | Descrizione leggibile |
| ip_o_sessione | string | no | Facoltativo |

# Relazioni logiche

```text
DOCENTI 1 ─── N DOCENTI_MATERIE
MATERIE 1 ─── N DOCENTI_MATERIE
DOCENTI 1 ─── N PACCHETTI_RECUPERO
MATERIE 1 ─── N PACCHETTI_RECUPERO
PACCHETTI_RECUPERO 1 ─── N LEZIONI_PACCHETTO
PACCHETTI_RECUPERO 1 ─── N ISCRIZIONI_PACCHETTO
STUDENTI 1 ─── N ISCRIZIONI_PACCHETTO
STUDENTI 1 ─── N STUDENTI_BLOCCATI
DOCENTI 1 ─── N DISPONIBILITA
MATERIE 1 ─── N DISPONIBILITA
DISPONIBILITA 1 ─── N PRENOTAZIONI
STUDENTI 1 ─── N PRENOTAZIONI
ADMIN abilita accesso amministrativo tramite email
```

# Regola per Codex

Prima di modificare la struttura del database, Codex deve leggere questo file, proporre la modifica, indicare impatti, aggiornare prima `DATABASE.md`, poi `Setup.gs`, poi i servizi interessati.
