# ARCHITECTURE - SOS Recuperi

## Obiettivo

Descrivere l’architettura tecnica della web app **SOS Recuperi**. L’app deve essere modulare, evitando file monolitici e separando backend Apps Script, accesso dati, autenticazione, servizi applicativi, viste HTML, JavaScript client, CSS e documentazione.

## Architettura generale

```text
Utente Google Workspace
        ↓
Apps Script Web App
        ↓
doGet / Router
        ↓
Autenticazione e ruolo
        ↓
Vista HTML corretta
        ↓
google.script.run
        ↓
Servizi Apps Script
        ↓
Google Sheet database
```

## Struttura backend attuale

```text
src/
├── Code.gs
├── Config.gs
├── Utils.gs
├── Database.gs
├── Router.gs
├── Auth.gs
├── Setup.gs
├── AdminService.gs
├── DocentiService.gs
├── StudentiService.gs
└── Notifications.gs
```

## Responsabilità file `.gs`

- `Code.gs`: entry point, `doGet(e)`, include, rendering iniziale.
- `Config.gs`: costanti, nomi fogli, ruoli, stati, chiavi config.
- `Auth.gs`: email utente, gruppi Google, ruoli, cache, assert permessi.
- `Database.gs`: accesso generico a Google Sheets, read/append/update/find.
- `Setup.gs`: creazione fogli, intestazioni, seed iniziali.
- `Utils.gs`: ID, date, normalizzazioni, helper.
- `Router.gs`: mapping viste e permessi.
- `AdminService.gs`: configurazione admin, log notifiche, blocchi temporanei studenti SOS e modifiche controllate a `CONFIG`.
- `DocentiService.gs`: dashboard docente, materie, creazione attività, aggiunta/annullamento lezioni, iscritti, perfezionamento argomento iscrizione.
- `StudentiService.gs`: esplora attività di recupero, iscrizioni, cancellazioni studente, blocco nuove iscrizioni SOS per studenti sospesi.
- `Notifications.gs`: registrazione notifiche e invio email condizionato.

File come `Logger.gs`, `Validation.gs`, `MaterieService.gs`, `DisponibilitaService.gs`, `PrenotazioniService.gs` e `NotificheService.gs` erano obiettivi di modularizzazione iniziale ma non esistono nella struttura corrente. Crearli solo dentro un refactor esplicito e approvato.

## Struttura frontend attuale

```text
html/
├── Index.html
├── AccessoNegato.html
└── Error.html

styles/
├── variables.css.html
├── layout.css.html
└── components.css.html
```

`html/Index.html` contiene la shell, il markup delle pagine operative e il JavaScript client inline. Il CSS e' separato in tre include. Una separazione in file HTML/client piu' granulari e' una possibile evoluzione, non lo stato attuale.

## Include HTML

Usare una funzione Apps Script:

```javascript
function include(filename) {
  return HtmlService.createHtmlOutputFromFile(filename).getContent();
}
```

## Web App minima

La prima base Web App include:

- `src/Code.gs`: `doGet(e)`, `include(filename)`, bootstrap dati client.
- `src/Router.gs`: routing minimo e scelta vista in base al ruolo.
- `src/DocentiService.gs`: dati iniziali dashboard docente.
- `src/StudentiService.gs`: dati e azioni studente MVP.
- `html/Index.html`: shell applicativa per utenti autorizzati.
- `html/AccessoNegato.html`: vista per utenti non autorizzati.
- `html/Error.html`: pagina errore tecnica per problemi di rendering server.
- `styles/variables.css.html`, `styles/layout.css.html`, `styles/components.css.html`: CSS modulare incluso via Apps Script.

`doGet(e)` espone anche `?debug=plain` per una diagnostica minima del deployment senza renderizzare la shell HTML completa.

## Gestione materie docente

La pagina `?page=materie` usa `DocentiService.gs` per leggere le materie globali attive da `MATERIE` e i collegamenti del docente da `DOCENTI_MATERIE`.

Funzioni server pubbliche usate dal frontend:

- `addDocenteMateria(payload)`: aggiunge o riattiva un collegamento docente-materia.
- `deactivateDocenteMateria(docenteMateriaId)`: disattiva il collegamento impostando `attiva = FALSE`.
- `getDocenteMaterieForCurrentUser()`: restituisce lo stato aggiornato della pagina materie.
- `addDocenteDisponibilita(payload)`: nome endpoint legacy usato dal frontend; crea un `PACCHETTI_RECUPERO` con tipologia `SOS` o `RECUPERO_ESTIVO`, genera lezioni singole/giornaliere/settimanali oppure aggiunge una riga in `LEZIONI_PACCHETTO` a una attività esistente.
- `cancelDocenteDisponibilita(payload)`: nome endpoint legacy usato dal frontend; annulla una lezione in `LEZIONI_PACCHETTO`.
- `updateIscrizioneArgomentoDocente(payload)`: aggiorna `ISCRIZIONI_PACCHETTO.nota_studente` solo per iscrizioni attive collegate ad attività del docente corrente.

Le funzioni ricontrollano il ruolo lato server tramite `getCurrentUserAuth()`. Le scritture sono permesse a docenti e admin. Un docente opera sul proprio profilo; un admin in modalita test opera sul profilo docente indicato da `runAs`/`asEmail` o da `SOS_CONFIG.AUTH_TEST.DOCENTE_EMAIL`. Il log conserva l'email admin come operatore e il docente testato nel dettaglio.

Le regole di generazione usano `CONFIG.giorni_corsi_disponibili` (`1-5` o `1-6`, default `1-6`). `SOS` genera attività separate, una per lezione. `RECUPERO_ESTIVO` genera una attività unica da 5 lezioni di 2h e registra in `segnalazioni_generazione` eventuali lezioni non create entro la data limite.

## Modalita test admin

Gli utenti `ADMIN` mantengono il ruolo reale `ADMIN`, ma possono usare un ruolo effettivo di test tramite parametro URL:

- `?page=dashboard&viewAs=docente`
- `?page=esplora&viewAs=studente`

Il parametro `viewAs` viene ignorato per utenti non admin. La UI mostra un banner di vista test quando il ruolo effettivo e' diverso dal ruolo reale.

Gli admin possono anche indicare una identita reale di test con la barra UI `Run as docente` / `Run as studente`, oppure con parametro URL `runAs`:

- `?page=materie&viewAs=docente&runAs=docente.reale@liceoduca.it`
- `?page=esplora&viewAs=studente&runAs=studente.reale@studenti.liceoduca.it`

Se `runAs` non e' presente, il router usa le email configurate in `SOS_CONFIG.AUTH_TEST`. Il vecchio parametro `asEmail` resta accettato come alias. Questo evita di dover inserire l'email admin nei fogli `DOCENTI` o `STUDENTI` solo per testare i profili.

## Area admin operativa

La route `?page=configurazione` usa `AdminService.gs` per leggere il foglio `CONFIG` e modificare solo un set esplicito di chiavi operative. Le scritture sono riservate ai superadmin e vengono registrate in `LOG_AZIONI`.

La route `?page=notifiche` legge le ultime righe del foglio `NOTIFICHE`, mostra statistiche per esito e consente di aggiornare `CONFIG.notifiche_email_attive`. L'attivazione dell'invio email reale richiede conferma lato browser.

La route `?page=studenti-bloccati` usa `AdminService.gs` per leggere e scrivere il foglio `STUDENTI_BLOCCATI`. Gli admin possono creare un blocco temporaneo con motivo, data inizio e fine opzionale, oppure sbloccare un blocco attivo. Ogni blocco/sblocco viene registrato in `LOG_AZIONI`.

## Area studente MVP

La pagina `?page=esplora` legge le attività pubblicate da `PACCHETTI_RECUPERO`, arricchite con lezioni da `LEZIONI_PACCHETTO` e dati da `MATERIE` e `DOCENTI`. Lo studente si iscrive all'attività intera tramite l'endpoint legacy `bookDisponibilitaStudente(payload)`.

La pagina `?page=iscrizioni` mostra le iscrizioni da `ISCRIZIONI_PACCHETTO` e consente la cancellazione tramite `cancelPrenotazioneStudente(payload)`. L'iscrizione usa `LockService` per rileggere l'attività, bloccare doppie iscrizioni e impedire overbooking sull'attività.

Prima di scrivere una nuova iscrizione `SOS`, `bookDisponibilitaStudente(payload)` verifica lato server se lo studente ha un blocco attivo in `STUDENTI_BLOCCATI`. Il blocco non impedisce accesso alla web app o consultazione delle iscrizioni.

## Autenticazione e ruoli

Il sistema legge l’email Google, verifica appartenenza a gruppi o tabelle applicative, assegna ruolo applicativo, blocca utenti non autorizzati e salva cache minima in `UTENTI_CACHE`.

Ruoli: `ADMIN`, `DOCENTE`, `STUDENTE`, `NON_AUTORIZZATO`.

Regole ruolo:

- `ADMIN`: email presente nel foglio `ADMIN` con `attivo = TRUE`.
- `DOCENTE`: email sul dominio `@liceoduca.it` e appartenenza al gruppo Google docenti indicato in `CONFIG.gruppo_docenti`; se `AdminDirectory` non e' disponibile, viene usato fallback sul foglio `DOCENTI`.
- `STUDENTE`: email sul dominio `@studenti.liceoduca.it`, se `CONFIG.studenti_da_dominio = TRUE`.
- `NON_AUTORIZZATO`: fallback per account non riconosciuti.

Il foglio `ADMIN` contiene anche `superadmin`, usato per distinguere privilegi amministrativi completi da funzioni admin ordinarie.

Funzioni principali:

- `getCurrentUserAuth()`: risolve il ruolo dell'utente corrente.
- `resolveAuthForEmail(email)`: risolve il ruolo di una email specifica.
- `testAuthDocente()`: test manuale con email docente configurata in `SOS_CONFIG.AUTH_TEST.DOCENTE_EMAIL`.
- `testAuthStudente()`: test manuale con email studente configurata in `SOS_CONFIG.AUTH_TEST.STUDENTE_EMAIL`.
- `testDocenteMembershipSpecificUser()`: test diretto `AdminDirectory.Members.hasMember()` sul gruppo docenti.

La verifica del gruppo docenti usa il servizio avanzato Apps Script `AdminDirectory` e cache `CacheService` per 300 secondi. Se il servizio non e' abilitato o l'utente esecutore non ha permessi adeguati, il sistema tenta il fallback sul foglio `DOCENTI` cercando `email` con `attivo = TRUE`.

## Sicurezza dati

- Docenti e studenti non devono accedere direttamente al Google Sheet.
- La web app deve essere distribuita internamente al dominio.
- Le funzioni server devono ricontrollare sempre il ruolo.
- Non fidarsi mai solo dei controlli frontend.
- Ogni azione sensibile deve essere loggata.

## Iscrizioni e concorrenza

La funzione di iscrizione deve usare `LockService`: acquisisci lock, rileggi attività, conta iscrizioni attive, verifica posti, verifica doppia iscrizione, scrivi, aggiorna stato, rilascia lock in `finally`.

## Deploy

La web app deve essere deployata come:

```text
Esegui come: proprietario/deployer
Accesso: utenti del dominio
```
