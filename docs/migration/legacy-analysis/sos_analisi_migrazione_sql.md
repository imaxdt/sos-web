# SOS Recuperi — Analisi di Migrazione a Infrastruttura Web + Database SQL

**Stato**: analisi futura, non roadmap corrente della versione Apps Script.
**Data**: 2026-06-10
**Versione**: 1.0
**Oggetto**: Analisi completa del progetto SOS Recuperi per riprogettazione da Google Apps Script + Google Sheets a web app con server applicativo e database MariaDB/MySQL.

---

## 1. Executive Summary

SOS Recuperi è una web app interna al dominio scolastico `liceoduca.it` che gestisce:

- La creazione di attività di recupero da parte dei docenti (tipologie SOS e Recupero Estivo)
- L'esplorazione e iscrizione da parte degli studenti
- La consultazione degli iscritti e la gestione amministrativa

Attualmente l'app è interamente costruita su **Google Apps Script** (backend serverless) con **Google Sheets** come database. Questo documento estrae tutte le specifiche funzionali e tecniche sviluppate, le organizza in un modello formale e propone una riprogettazione per architettura web tradizionale con **MariaDB/MySQL**.

---

## 2. Stato Attuale del Progetto (GAS)

### 2.1 Stack tecnologico

| Componente | Tecnologia attuale |
|---|---|
| Runtime backend | Google Apps Script (V8) |
| Database | Google Sheets (`SOS_RECUPERI_DB`, 14 fogli) |
| Frontend | HTML/CSS/JS servito via `HtmlService` |
| Autenticazione | Google Workspace (email + gruppi + AdminDirectory API) |
| Concorrenza | `LockService` (lock applicativo GAS) |
| Email | `MailApp` (disabilitato, solo log) |
| Testing E2E | Playwright (TypeScript) |
| Deploy | `clasp` CLI verso Apps Script |

### 2.2 Deployment attuale

- **Deployment ID stabile**: `AKfycbz6aw8P2qMJ_iAD7asEwYEJinYL0yG08-7kU8uwk_DkI9bZOfzp83r_Z_zuJT0NEFFtWg`
- **Versione**: `@33`
- **Esegui come**: `USER_DEPLOYING`
- **Accesso**: dominio `liceoduca.it`
- **URL base**: `https://script.google.com/macros/s/.../exec`
- **Repository GitHub**: `git@github.com:imaxdt/sos.git`

### 2.3 Moduli backend (file `.gs`)

| File | Responsabilità |
|---|---|
| `Code.gs` | Entry point `doGet()`, include HTML, diagnostica |
| `Config.gs` | Costanti, enumerazioni, schema tabelle, configurazioni test |
| `Auth.gs` | Risoluzione ruoli (admin via foglio, docente via gruppo Google+fallback, studente via dominio) |
| `Database.gs` | CRUD generico su Google Sheets (read/write/find/append/update) + setup fogli |
| `Setup.gs` | `setupDatabase()`, seed iniziale config/materie/profili test |
| `Utils.gs` | Helper: ID generation, date, normalizzazione, email dominio, booleani |
| `Router.gs` | Routing viste per ruolo, permessi, modalità test admin (`viewAs`, `runAs`) |
| `DocentiService.gs` | Dashboard, materie, attività di recupero (creazione/modifica/annullamento), iscrizioni, regole generazione |
| `StudentiService.gs` | Esplora recuperi, iscrizione/cancellazione, filtri |
| `AdminService.gs` | Configurazione parametri, log notifiche, modifica controllata `CONFIG` |
| `Notifications.gs` | Registrazione notifiche (log-only), invio email condizionato |

### 2.4 Frontend (HTML + CSS)

- **Viste HTML**: `Index.html` (shell SPA), `AccessoNegato.html`, `Error.html`
- **CSS**: `variables.css.html`, `layout.css.html`, `components.css.html`
- **Logica client**: JavaScript inline in `Index.html`, chiamate server via `google.script.run`
- **Pattern UI**: topbar fissa, sidebar sinistra, area contenuti centrale, card metriche, form laterali, split view docente/iscritti, griglia card studente, wizard iscrizione

---

## 3. Specifiche Funzionali Complete

### 3.1 Ruoli e autorizzazioni

| Ruolo | Come viene determinato |
|---|---|
| `ADMIN` | Email presente nel foglio `ADMIN` con `attivo = TRUE`. Campo `superadmin` distingue privilegi completi. |
| `DOCENTE` | Dominio `@liceoduca.it` + appartenenza al gruppo Google configurato in `CONFIG.gruppo_docenti` (default `docenti@liceoduca.it`). Fallback: presenza in foglio `DOCENTI` con `attivo = TRUE`. Cache 300s. |
| `STUDENTE` | Dominio `@studenti.liceoduca.it` (se `CONFIG.studenti_da_dominio = TRUE`). |
| `NON_AUTORIZZATO` | Qualsiasi altro account. |

**Permessi per ruolo**:

- **Admin**: dashboard test, configurazione parametri operativi, consultazione log notifiche, modalità `viewAs`/`runAs` per impersonare docente o studente.
- **Docente**: dashboard personale, gestione materie associate, creazione/modifica/annullamento attività di recupero, consultazione iscritti, rimozione iscrizioni.
- **Studente**: esplorazione attività pubblicate, iscrizione/cancellazione, visualizzazione proprie iscrizioni.

### 3.2 Entità e dominio dati

#### CONFIG
Configurazione applicativa globale come tabella chiave-valore.

| Chiave | Default |
|---|---|
| `app_name` | SOS Recuperi |
| `database_spreadsheet_id` | ID Google Sheet |
| `timezone` | Europe/Rome |
| `dominio_docenti` | liceoduca.it |
| `dominio_studenti` | studenti.liceoduca.it |
| `gruppo_docenti` | docenti@liceoduca.it |
| `studenti_da_dominio` | TRUE |
| `max_prenotazioni_per_studente` | 5 |
| `giorni_corsi_disponibili` | 1-6 |
| `notifiche_email_attive` | FALSE |
| `anno_scolastico` | (vuoto) |

Parametri modificabili da superadmin via UI: `gruppo_docenti`, `studenti_da_dominio`, `max_prenotazioni_per_studente`, `modifica_entro_ore`, `cancellazione_entro_ore`, `giorni_corsi_disponibili`, `notifiche_email_attive`, `anno_scolastico`.

#### DOCENTI
Ogni docente ha: ID, email, nome, cognome, telefono, soglie predefinite (min/max studenti per materia e laboratorio), limite prenotazioni studente, flag stessa classe, flag notifiche email, flag attivo.

#### STUDENTI
Ogni studente ha: ID, email, nome, cognome, classe (es. `3A`), sezione, flag attivo.

#### MATERIE
Materie globali: ID, nome, tipo (`MATERIA`/`LABORATORIO`), descrizione, flag attiva, ordine UI.

Materie seed: Matematica, Fisica, Informatica, Inglese, Filosofia, Diritto, English Lab.

#### DOCENTI_MATERIE
Collegamento docente-materia con descrizione personalizzata, note interne e flag attiva. La coppia `(docente_id, materia_id)` deve essere unica tra i record attivi.

#### PACCHETTI_RECUPERO (Attività di recupero)
L'entità centrale. Una attività di recupero è un pacchetto materia/docente a cui gli studenti si iscrivono.

| Campo | Descrizione |
|---|---|
| `tipo_corso` | `SOS` (singola lezione) o `RECUPERO_ESTIVO` (5 lezioni da 2h) |
| `modalita_generazione` | `SINGOLA`, `GIORNALIERA`, `SETTIMANALE` |
| `ripetizione_fino` | Data limite generazione automatica |
| `lezioni_previste` | 1 per SOS, 5 per Recupero Estivo |
| `ore_previste` | Monte ore previsto (per SOS = durata lezione, per Recupero Estivo = 10) |
| `ore_programmate` | Somma ore lezioni non annullate |
| `stato` | `BOZZA`, `PUBBLICATO`, `COMPLETO`, `ANNULLATO`, `CHIUSO` |
| `segnalazioni_generazione` | Warning lezioni mancanti |

Campi informativi: `titolo_corso`, `note_studenti`, `argomenti`, `principale`, `altri_dettagli`.

Vincoli: `min_studenti`, `max_studenti`, `solo_stessa_classe`, `generazione_gruppo_id`.

#### LEZIONI_PACCHETTO
Lezioni collegate a una attività.

| Campo | Descrizione |
|---|---|
| `data` | Data lezione |
| `ora_inizio` | HH:MM, step 15 min, range 08:00-18:00 |
| `ora_fine` | Calcolata automaticamente |
| `durata_minuti` | 60 o 120 |
| `stato` | `PROGRAMMATA` o `ANNULLATA` |

#### ISCRIZIONI_PACCHETTO
Iscrizioni degli studenti alle attività.

| Campo | Descrizione |
|---|---|
| `stato` | `ATTIVA`, `CANCELLATA_STUDENTE`, `CANCELLATA_DOCENTE`, `ANNULLATA` |

Dati ridondanti: `email_studente`, `classe_studente` (per lettura rapida).

#### DISPONIBILITA e PRENOTAZIONI
Tabelle legacy del modello a slot singoli, mantenute per retrocompatibilità ma non più usate nei nuovi flussi.

#### NOTIFICHE
Registro notifiche: tipo, destinatario, oggetto, esito (`INVIATA`, `LOG_ONLY`, `ERRORE`, `DISATTIVATA`), riferimento all'entità collegata.

#### LOG_AZIONI
Registro azioni: timestamp, utente, ruolo, azione, entità, ID record, dettaglio.

#### UTENTI_CACHE
Cache accessi utente: email, nome, cognome, ruolo, gruppi, ultimo accesso, attivo.

### 3.3 Relazioni

```text
DOCENTI 1 ─── N DOCENTI_MATERIE
MATERIE 1 ─── N DOCENTI_MATERIE
DOCENTI 1 ─── N PACCHETTI_RECUPERO
MATERIE 1 ─── N PACCHETTI_RECUPERO
PACCHETTI_RECUPERO 1 ─── N LEZIONI_PACCHETTO
PACCHETTI_RECUPERO 1 ─── N ISCRIZIONI_PACCHETTO
STUDENTI 1 ─── N ISCRIZIONI_PACCHETTO
```

### 3.4 Regole di business

1. Solo utenti autorizzati accedono all'app.
2. Un docente gestisce solo i propri corsi (verifica `docente_id` lato server).
3. Uno studente vede solo attività in stato `PUBBLICATO` o `COMPLETO`.
4. Uno studente non può iscriversi due volte alla stessa attività (vincolo di unicità).
5. Una attività non può superare `max_studenti` iscrizioni attive.
6. Se una attività raggiunge `max_studenti`, passa automaticamente a `COMPLETO`.
7. Se un'iscrizione viene rimossa e i posti scendono sotto `max_studenti`, l'attività torna `PUBBLICATO`.
8. L'iscrizione deve essere atomica (lock).
9. Una lezione annullata non cancella l'attività; il docente può aggiungere lezioni sostitutive.
10. Le attività in stato `BOZZA` non sono visibili agli studenti.
11. Le azioni rilevanti sono loggate in `LOG_AZIONI`.
12. Ora inizio lezione: range 08:00-18:00, step 15 minuti.
13. Durata lezione: 1h (60 min) o 2h (120 min).
14. I giorni disponibili per corsi sono configurati in `CONFIG.giorni_corsi_disponibili` (formato `1-5` o `1-6`, 1=lunedì).
15. **SOS**: una sola lezione. La ripetizione genera più attività SOS separate, ciascuna con una lezione.
16. **Recupero Estivo**: pacchetto unico da 5 lezioni di 2h (10h totali). La generazione automatica si ferma a 5 lezioni o alla data limite, segnalando le lezioni mancanti.
17. Non si possono aggiungere lezioni a un SOS (ha già la sua unica lezione).
18. A Recupero Estivo non si possono aggiungere più di 5 lezioni totali.
19. Le lezioni di Recupero Estivo sono sempre da 2h.
20. Una lezione non può sovrapporsi a un'altra lezione attiva della stessa attività (stessa data e ora inizio).

### 3.5 Flussi principali

#### Flusso docente
```
Accesso → Dashboard (metriche) → Gestione materie → Creazione attività di recupero
→ Scelta tipologia (SOS / Recupero Estivo) → Scelta modalità generazione
→ Prima lezione → Aggiunta eventuali lezioni → Consultazione iscritti
→ Rimozione iscrizione se necessario
```

#### Flusso studente
```
Accesso → Esplora recuperi → Filtri (materia/docente/giorno/fascia/posti/parola chiave)
→ Scegli attività → Riepilogo con calendario lezioni → Conferma iscrizione
→ Le mie iscrizioni → Cancellazione se consentito
```

### 3.6 Sistema di notifiche

Attualmente in modalità **log-only** (`notifiche_email_attive = FALSE`):

- **Nuova iscrizione**: notifica al docente (log) + conferma allo studente (log)
- **Cancellazione studente**: notifica al docente (log) + conferma allo studente (log)
- **Rimozione docente**: notifica allo studente (log) + conferma al docente (log)

Quando attivo, l'invio reale usa `MailApp.sendEmail()` di Google. Il docente può disattivare le proprie notifiche via flag `notifiche_email` sul profilo.

### 3.7 Funzionalità admin

- **Dashboard admin**: centro test con accesso rapido ai profili docente/studente
- **Configurazione** (`?page=configurazione`): tabella `CONFIG` leggibile da admin, modificabile da superadmin solo sui parametri operativi autorizzati
- **Log notifiche** (`?page=notifiche`): ultime 100 righe `NOTIFICHE`, statistiche per esito, switch `notifiche_email_attive`
- **Modalità test**: `viewAs` (docente/studente) + `runAs` (email specifica) per impersonare ruoli senza need di account reali
- **Azioni admin via URL**: `?adminAction=setupDatabase`, `?adminAction=ensureAuthTestProfiles`
- **Diagnostica**: `?debug=plain`

### 3.8 Test E2E (Playwright)

Suite Playwright con:
- Test autenticazione e smoke (7 test)
- Test write-flow su staging (5 test): creazione SOS, Recupero Estivo, iscrizione, overbooking, rimozione docente
- Test su giorni corsi, generazioni ripetute, casi incompleti
- Test multi-utente con secondo studente

---

## 4. Riprogettazione per Architettura Web + Database SQL

### 4.1 Stack proposto

| Componente | Tecnologia consigliata |
|---|---|
| Backend runtime | Node.js (Express/Fastify) o Python (FastAPI/Flask) |
| ORM / Query builder | Knex.js / Prisma (Node) o SQLAlchemy (Python) |
| Database | MariaDB 10.11+ o MySQL 8.0+ |
| Frontend | HTML/CSS/JS servito dal backend o SPA (React/Vue/Svelte) |
| Autenticazione | Google OAuth 2.0 + JWT session |
| Concorrenza | `SELECT ... FOR UPDATE` o lock applicativo via Redis |
| Email | SMTP (SendGrid, Amazon SES, o server SMTP istituzionale) |
| Deploy | Docker + reverse proxy (Nginx/Caddy) su VPS o container cloud |
| Testing E2E | Playwright (mantenuto) |

**Raccomandazione**: Node.js + Express + Prisma + MariaDB, frontend SPA semplice con Vanilla JS o Vue.js (coerente con l'attuale pattern SPA-like), JWT per sessioni, Redis per lock distribuiti.

### 4.2 Schema database MariaDB/MySQL

```sql
-- ============================================
-- Configurazione applicativa
-- ============================================
CREATE TABLE config (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    chiave      VARCHAR(100) NOT NULL UNIQUE,
    valore      TEXT NOT NULL,
    descrizione TEXT,
    aggiornato_il TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- Amministratori
-- ============================================
CREATE TABLE admin (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    email       VARCHAR(255) NOT NULL UNIQUE,
    superadmin  BOOLEAN NOT NULL DEFAULT FALSE,
    attivo      BOOLEAN NOT NULL DEFAULT TRUE,
    note        TEXT,
    aggiornato_il TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- Docenti
-- ============================================
CREATE TABLE docenti (
    id                          INT AUTO_INCREMENT PRIMARY KEY,
    docente_id                  VARCHAR(50) NOT NULL UNIQUE,
    email                       VARCHAR(255) NOT NULL UNIQUE,
    nome                        VARCHAR(100) NOT NULL,
    cognome                     VARCHAR(100) NOT NULL,
    telefono                    VARCHAR(20),
    min_studenti_materia        INT NOT NULL DEFAULT 1,
    max_studenti_materia        INT NOT NULL DEFAULT 8,
    min_studenti_laboratorio    INT NOT NULL DEFAULT 1,
    max_studenti_laboratorio    INT NOT NULL DEFAULT 12,
    max_prenotazioni_studente   INT NOT NULL DEFAULT 5,
    solo_stessa_classe_default  BOOLEAN NOT NULL DEFAULT FALSE,
    notifiche_email             BOOLEAN NOT NULL DEFAULT FALSE,
    attivo                      BOOLEAN NOT NULL DEFAULT TRUE,
    creato_il                   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aggiornato_il               TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- Studenti
-- ============================================
CREATE TABLE studenti (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    studente_id     VARCHAR(50) NOT NULL UNIQUE,
    email           VARCHAR(255) NOT NULL UNIQUE,
    nome            VARCHAR(100) NOT NULL,
    cognome         VARCHAR(100) NOT NULL,
    classe          VARCHAR(10) NOT NULL,
    sezione         VARCHAR(10),
    attivo          BOOLEAN NOT NULL DEFAULT TRUE,
    creato_il       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aggiornato_il   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- Materie
-- ============================================
CREATE TABLE materie (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    materia_id  VARCHAR(50) NOT NULL UNIQUE,
    nome        VARCHAR(200) NOT NULL,
    tipo        ENUM('MATERIA', 'LABORATORIO') NOT NULL DEFAULT 'MATERIA',
    descrizione TEXT,
    attiva      BOOLEAN NOT NULL DEFAULT TRUE,
    ordine      INT DEFAULT 0
);

-- ============================================
-- Collegamento Docenti-Materie
-- ============================================
CREATE TABLE docenti_materie (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    docente_materia_id  VARCHAR(50) NOT NULL UNIQUE,
    docente_id          VARCHAR(50) NOT NULL,
    materia_id          VARCHAR(50) NOT NULL,
    descrizione_docente VARCHAR(500),
    note_interne        TEXT,
    attiva              BOOLEAN NOT NULL DEFAULT TRUE,
    creato_il           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (docente_id) REFERENCES docenti(docente_id),
    FOREIGN KEY (materia_id) REFERENCES materie(materia_id),
    -- Una sola associazione attiva per coppia
    UNIQUE KEY uq_docente_materia_attiva (docente_id, materia_id, attiva)
);

-- ============================================
-- Attività di recupero (Pacchetti)
-- ============================================
CREATE TABLE pacchetti_recupero (
    id                      INT AUTO_INCREMENT PRIMARY KEY,
    pacchetto_id            VARCHAR(50) NOT NULL UNIQUE,
    docente_id              VARCHAR(50) NOT NULL,
    materia_id              VARCHAR(50) NOT NULL,
    tipo_corso              ENUM('SOS', 'RECUPERO_ESTIVO') NOT NULL,
    modalita_generazione    ENUM('SINGOLA', 'GIORNALIERA', 'SETTIMANALE') NOT NULL DEFAULT 'SINGOLA',
    ripetizione_fino        DATE,
    lezioni_previste        INT NOT NULL DEFAULT 1,
    generazione_gruppo_id   VARCHAR(100),
    titolo_corso            VARCHAR(500) NOT NULL,
    ore_previste            DECIMAL(5,1) NOT NULL DEFAULT 0,
    ore_programmate         DECIMAL(5,1) NOT NULL DEFAULT 0,
    note_studenti           TEXT,
    argomenti               TEXT,
    principale              VARCHAR(500),
    altri_dettagli          TEXT,
    min_studenti            INT NOT NULL DEFAULT 1,
    max_studenti            INT NOT NULL DEFAULT 8,
    solo_stessa_classe      BOOLEAN NOT NULL DEFAULT FALSE,
    stato                   ENUM('BOZZA', 'PUBBLICATO', 'COMPLETO', 'ANNULLATO', 'CHIUSO') NOT NULL DEFAULT 'BOZZA',
    segnalazioni_generazione TEXT,
    creato_da               VARCHAR(255) NOT NULL,
    creato_il               TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aggiornata_il           TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (docente_id) REFERENCES docenti(docente_id),
    FOREIGN KEY (materia_id) REFERENCES materie(materia_id),
    INDEX idx_pacchetti_stato (stato),
    INDEX idx_pacchetti_docente (docente_id),
    INDEX idx_pacchetti_materia (materia_id)
);

-- ============================================
-- Lezioni delle attività
-- ============================================
CREATE TABLE lezioni_pacchetto (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    lezione_id      VARCHAR(50) NOT NULL UNIQUE,
    pacchetto_id    VARCHAR(50) NOT NULL,
    data            DATE NOT NULL,
    ora_inizio      TIME NOT NULL,
    ora_fine        TIME NOT NULL,
    durata_minuti   INT NOT NULL,
    stato           ENUM('PROGRAMMATA', 'ANNULLATA') NOT NULL DEFAULT 'PROGRAMMATA',
    note_lezione    TEXT,
    creata_da       VARCHAR(255) NOT NULL,
    creato_il       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aggiornata_il   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pacchetto_id) REFERENCES pacchetti_recupero(pacchetto_id) ON DELETE CASCADE,
    INDEX idx_lezioni_pacchetto (pacchetto_id),
    INDEX idx_lezioni_data (data),
    -- No sovrapposizione stessa attività, stessa data/ora
    UNIQUE KEY uq_lezione_data_ora (pacchetto_id, data, ora_inizio, stato)
);

-- ============================================
-- Iscrizioni alle attività
-- ============================================
CREATE TABLE iscrizioni_pacchetto (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    iscrizione_id     VARCHAR(50) NOT NULL UNIQUE,
    pacchetto_id      VARCHAR(50) NOT NULL,
    studente_id       VARCHAR(50) NOT NULL,
    email_studente    VARCHAR(255) NOT NULL,
    classe_studente   VARCHAR(10) NOT NULL,
    stato             ENUM('ATTIVA', 'CANCELLATA_STUDENTE', 'CANCELLATA_DOCENTE', 'ANNULLATA') NOT NULL DEFAULT 'ATTIVA',
    nota_studente     TEXT,
    iscritta_il       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aggiornata_il     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pacchetto_id) REFERENCES pacchetti_recupero(pacchetto_id) ON DELETE CASCADE,
    FOREIGN KEY (studente_id) REFERENCES studenti(studente_id),
    INDEX idx_iscrizioni_pacchetto (pacchetto_id),
    INDEX idx_iscrizioni_studente (studente_id),
    INDEX idx_iscrizioni_stato (stato)
);

-- ============================================
-- Tabelle legacy (mantenute per compatibilità dati)
-- ============================================
CREATE TABLE disponibilita (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    disponibilita_id    VARCHAR(50) NOT NULL UNIQUE,
    docente_id          VARCHAR(50) NOT NULL,
    materia_id          VARCHAR(50) NOT NULL,
    titolo_slot         VARCHAR(500),
    data                DATE NOT NULL,
    ora_inizio          TIME NOT NULL,
    ora_fine            TIME NOT NULL,
    durata_minuti       INT NOT NULL,
    note_studenti       TEXT,
    argomenti           TEXT,
    principale          VARCHAR(500),
    altri_dettagli      TEXT,
    min_studenti        INT NOT NULL DEFAULT 1,
    max_studenti        INT NOT NULL DEFAULT 8,
    solo_stessa_classe  BOOLEAN NOT NULL DEFAULT FALSE,
    stato               ENUM('BOZZA', 'PUBBLICATA', 'COMPLETA', 'ANNULLATA', 'CHIUSA') NOT NULL DEFAULT 'BOZZA',
    ripetizione_gruppo_id VARCHAR(100),
    creata_da           VARCHAR(255) NOT NULL,
    creata_il           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aggiornata_il       TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (docente_id) REFERENCES docenti(docente_id),
    FOREIGN KEY (materia_id) REFERENCES materie(materia_id)
);

CREATE TABLE prenotazioni (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    prenotazione_id   VARCHAR(50) NOT NULL UNIQUE,
    disponibilita_id  VARCHAR(50) NOT NULL,
    studente_id       VARCHAR(50) NOT NULL,
    email_studente    VARCHAR(255) NOT NULL,
    classe_studente   VARCHAR(10) NOT NULL,
    stato             ENUM('ATTIVA', 'CANCELLATA_STUDENTE', 'CANCELLATA_DOCENTE', 'ANNULLATA') NOT NULL DEFAULT 'ATTIVA',
    nota_studente     TEXT,
    prenotata_il      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aggiornata_il     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (disponibilita_id) REFERENCES disponibilita(disponibilita_id),
    FOREIGN KEY (studente_id) REFERENCES studenti(studente_id)
);

-- ============================================
-- Notifiche
-- ============================================
CREATE TABLE notifiche (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    notifica_id     VARCHAR(50) NOT NULL UNIQUE,
    tipo            ENUM('PRENOTAZIONE_CONFERMATA_STUDENTE', 'NUOVA_PRENOTAZIONE_DOCENTE',
                         'PRENOTAZIONE_CANCELLATA_STUDENTE', 'CANCELLAZIONE_PRENOTAZIONE_DOCENTE',
                         'PRENOTAZIONE_RIMOSSA_DA_DOCENTE', 'RIMOZIONE_PRENOTAZIONE_DOCENTE',
                         'PROMEMORIA', 'MESSAGGIO_DOCENTE', 'ERRORE') NOT NULL,
    destinatario    VARCHAR(255) NOT NULL,
    oggetto         VARCHAR(500) NOT NULL,
    esito           VARCHAR(50) NOT NULL,
    riferimento_tipo VARCHAR(50),
    riferimento_id  VARCHAR(50),
    inviata_il      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Log azioni
-- ============================================
CREATE TABLE log_azioni (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    log_id          VARCHAR(50) NOT NULL UNIQUE,
    timestamp       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    email_utente    VARCHAR(255) NOT NULL,
    ruolo           ENUM('ADMIN', 'DOCENTE', 'STUDENTE', 'NON_AUTORIZZATO') NOT NULL,
    azione          VARCHAR(100) NOT NULL,
    entita          VARCHAR(50) NOT NULL,
    entita_id       VARCHAR(50),
    dettaglio       TEXT,
    ip_o_sessione   VARCHAR(100)
);

-- ============================================
-- Sessioni / cache utente
-- ============================================
CREATE TABLE utenti_cache (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    email           VARCHAR(255) NOT NULL,
    nome            VARCHAR(100),
    cognome         VARCHAR(100),
    ruolo           ENUM('ADMIN', 'DOCENTE', 'STUDENTE', 'NON_AUTORIZZATO') NOT NULL,
    ultimo_accesso  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    attivo          BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE KEY uq_utente_email (email)
);

-- ============================================
-- Refresh token / sessioni JWT (nuovo)
-- ============================================
CREATE TABLE sessions (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    session_id      VARCHAR(100) NOT NULL UNIQUE,
    email           VARCHAR(255) NOT NULL,
    ruolo           ENUM('ADMIN', 'DOCENTE', 'STUDENTE', 'NON_AUTORIZZATO') NOT NULL,
    token_hash      VARCHAR(255) NOT NULL,
    expires_at      TIMESTAMP NOT NULL,
    creato_il       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sessions_email (email),
    INDEX idx_sessions_expires (expires_at)
);
```

### 4.3 Vincoli di integrità aggiuntivi

Vincoli applicativi da implementare a livello backend (non tutti esprimibili in DDL):

1. **Iscrizione unica attiva**: `UNIQUE (pacchetto_id, studente_id) WHERE stato = 'ATTIVA'` — in MySQL 8 questa è una partial index, si può implementare con trigger o a livello applicativo.
2. **Docente-materia attiva unica**: `UNIQUE (docente_id, materia_id) WHERE attiva = TRUE`.
3. **Orario lezione valido**: CHECK su `ora_inizio` (MINUTE(ora_inizio) % 15 = 0, HOUR(ora_inizio) BETWEEN 8 AND 18).
4. **Durata lezione valida**: CHECK su `durata_minuti IN (60, 120)`.
5. **Ora fine calcolata**: `ora_fine = ADDTIME(ora_inizio, SEC_TO_TIME(durata_minuti * 60))` — computed column o trigger.

### 4.4 Architettura backend

```
src/
├── index.js                # Entry point, avvio server Express
├── config/
│   ├── database.js         # Connessione MariaDB/MySQL
│   ├── auth.js             # Config OAuth2 Google
│   └── app.js              # Costanti applicative
├── middleware/
│   ├── auth.js             # Middleware verifica JWT, ruoli
│   ├── admin.js            # Middleware superadmin
│   └── errorHandler.js     # Gestione errori centralizzata
├── routes/
│   ├── auth.js             # Login/logout Google
│   ├── admin.js            # Configurazione, notifiche
│   ├── docente.js          # Dashboard, materie, attività, iscrizioni
│   └── studente.js         # Esplora, iscrizioni, profilo
├── services/
│   ├── authService.js      # Risoluzione ruoli
│   ├── docenteService.js   # Logica docente
│   ├── studenteService.js  # Logica studente
│   ├── corsoService.js     # Gestione attività/lezioni
│   ├── iscrizioneService.js # Iscrizioni con lock
│   ├── notificaService.js  # Invio email e log
│   └── configService.js    # Configurazioni
├── models/
│   ├── docente.js          # Query/ORM docente
│   ├── studente.js         # Query/ORM studente
│   ├── pacchetto.js        # Query/ORM pacchetti
│   ├── lezione.js          # Query/ORM lezioni
│   └── iscrizione.js       # Query/ORM iscrizioni
└── utils/
    ├── idGenerator.js      # Generazione ID (sostituisce sosGenerateId)
    ├── dateUtils.js        # Formattazione date
    ├── timeUtils.js        # Validazione orari
    └── courseRules.js      # Regole generazione corsi
```

### 4.5 Autenticazione (riprogettata)

Nel nuovo stack, l'autenticazione Google Workspace viene gestita con **OAuth 2.0 + JWT**:

1. L'utente accede con Google OAuth (flusso Authorization Code)
2. Il backend riceve l'ID token Google, estrae email e dominio
3. Il sistema risolve il ruolo (admin, docente, studente) con la stessa logica attuale ma senza dipendere da `AdminDirectory` (che richiederebbe service account con delega dominio-wide)
4. Per la verifica del gruppo docenti: usare Google Workspace Admin SDK via service account con domain-wide delegation, oppure mantenere un fallback su tabella `docenti`
5. Viene emesso un JWT contenente: `sub` (email), `role`, `superadmin` (se admin)
6. Il JWT ha scadenza breve (15-60 min) e un refresh token opzionale
7. La modalità test admin (`viewAs`/`runAs`) può essere mantenuta come flag nel JWT payload, verificabile dal middleware admin

**Endpoint auth**:
- `GET /auth/google` — redirect a Google OAuth
- `GET /auth/google/callback` — callback OAuth, emissione JWT
- `POST /auth/refresh` — refresh token
- `GET /auth/me` — info utente corrente

### 4.6 API Design (REST)

Le attuali chiamate `google.script.run` diventano endpoint REST. Schema:

```
# Auth
POST   /api/auth/login
GET    /api/auth/me
POST   /api/auth/logout

# Admin
GET    /api/admin/config
PATCH  /api/admin/config          # body: { key, value }
GET    /api/admin/notifiche
POST   /api/admin/setup-database
POST   /api/admin/ensure-test-profiles

# Docente
GET    /api/docente/dashboard
GET    /api/docente/materie
POST   /api/docente/materie       # aggiungi
DELETE /api/docente/materie/:id   # disattiva
GET    /api/docente/attivita
POST   /api/docente/attivita      # crea
POST   /api/docente/attivita/:id/lezioni    # aggiungi lezione
DELETE /api/docente/lezioni/:id             # annulla lezione
GET    /api/docente/iscrizioni
DELETE /api/docente/iscrizioni/:id          # rimuovi iscrizione

# Studente
GET    /api/studente/esplora
GET    /api/studente/iscrizioni
POST   /api/studente/iscrizioni   # iscriviti
DELETE /api/studente/iscrizioni/:id  # cancella
GET    /api/studente/profilo
```

### 4.7 Gestione concorrenza iscrizioni

Nel modello GAS si usa `LockService`. Con MariaDB/MySQL si usano transazioni con lock:

```sql
START TRANSACTION;

-- Blocca la riga dell'attività per evitare race condition
SELECT * FROM pacchetti_recupero
WHERE pacchetto_id = ? AND stato IN ('PUBBLICATO', 'COMPLETO')
FOR UPDATE;

-- Conta iscrizioni attive (atomico dentro la transazione)
SELECT COUNT(*) FROM iscrizioni_pacchetto
WHERE pacchetto_id = ? AND stato = 'ATTIVA';

-- Verifica doppia iscrizione
SELECT COUNT(*) FROM iscrizioni_pacchetto
WHERE pacchetto_id = ? AND studente_id = ? AND stato = 'ATTIVA';

-- Se ok: INSERT iscrizione, eventuale UPDATE stato attività a COMPLETO

COMMIT;
```

Per scenari distribuiti (più istanze del backend), si può aggiungere un lock via Redis (`SET lock:iscrizione:<pacchetto_id> NX EX 10`) come ulteriore protezione.

### 4.8 Gestione invio email

Sostituire `MailApp.sendEmail()` con un servizio SMTP:

1. **Transazionale**: SendGrid, Amazon SES, Mailgun, Resend
2. **Istituzionale**: SMTP server della scuola (se disponibile)
3. Il sistema mantiene la stessa logica: se `notifiche_email_attive = FALSE`, solo log; se `TRUE`, invio reale + log con esito
4. Le email in errore vengono loggate con esito `ERRORE` e possono essere riprovate

### 4.9 Frontend

Si mantiene il modello SPA-like attuale, con possibilità di evoluzione:

**Opzione A — Server-rendered (coerente con l'attuale)**:
- Express + EJS/Pug template
- CSS vanilla modulare
- JavaScript client per chiamate fetch() alle API REST
- Stessa struttura viste: `index.ejs`, `accesso-negato.ejs`, `error.ejs`

**Opzione B — SPA moderna**:
- Vue.js 3 (leggero, adatto al contesto scolastico)
- Stesse viste come componenti
- Router client-side (Vue Router)
- State management leggero (Pinia o reattività nativa)

**Raccomandazione**: Opzione A per la prima iterazione (minore discontinuità), con migrazione graduale a Opzione B.

### 4.10 Modalità test admin

L'attuale sistema `viewAs`/`runAs` via query string è molto utile per debug e demo. Nel nuovo stack:

- L'admin autenticato ha un endpoint `POST /api/admin/impersonate` che restituisce un JWT temporaneo con `role=docente` o `studente` e `impersonated_email=...`
- Il frontend mostra una barra gialla di avviso quando si è in modalità impersonificazione
- L'admin può tornare al proprio ruolo con `POST /api/admin/unimpersonate`
- Il middleware di autorizzazione riconosce il JWT impersonato e logga l'operatore reale

### 4.11 Deploy

```text
┌─────────────────────────────────────────┐
│  Reverse Proxy (Nginx / Caddy)          │
│  - HTTPS (Let's Encrypt)                │
│  - Rate limiting                        │
│  - Static assets caching                │
├─────────────────────────────────────────┤
│  App Container (Docker)                 │
│  - Node.js / Express                    │
│  - Porta interna 3000                   │
├─────────────────────────────────────────┤
│  Database Container (Docker)            │
│  - MariaDB 10.11                        │
│  - Volume persistente per dati          │
│  - Backup automatico (mariabackup)      │
├─────────────────────────────────────────┤
│  (Opzionale) Redis Container            │
│  - Cache sessione                       │
│  - Lock distribuiti                     │
└─────────────────────────────────────────┘
```

Ambienti:
- **Sviluppo**: `docker compose` locale
- **Staging**: VPS dedicata con sottodominio `staging.sos.liceoduca.it`
- **Produzione**: VPS con dominio `sos.liceoduca.it`

---

## 5. Gap Analysis — Cosa Cambia

### 5.1 Vantaggi della migrazione

| Area | GAS + Sheets | Web + SQL |
|---|---|---|
| Performance query | Lente (scansione righe) | Veloci (indici, JOIN) |
| Concorrenza | `LockService` limitato | Transazioni ACID, lock a livello riga |
| Scalabilità | Limitata (quote GAS) | Virtualmente illimitata |
| Backup | Manuale (export Sheet) | Automatico (`mariabackup`, dump) |
| Integrazioni | Solo GAS ecosystem | Qualsiasi API esterna |
| Testabilità | Solo via Playwright su staging | Unit test, integration test locali |
| Versionamento | `clasp` push (fragile) | Git standard, CI/CD |
| UI | `HtmlService` (limitato) | HTML/CSS/JS nativo, SPA framework |
| Logging | `console.log` su Stackdriver | Log strutturati, monitoring |
| Manutenzione | Dipendente da Google | Indipendente, portabile |
| Accesso dati | Non strutturato (fogli) | Query SQL, report, analytics |

### 5.2 Complessità introdotte

| Area | Impatto |
|---|---|
| Infrastruttura | Server da gestire (VPS, Docker, backup, monitoring) |
| Autenticazione | OAuth2 più complesso da configurare rispetto a `Session.getActiveUser()` |
| Gruppi Google | Service account con domain-wide delegation (più complesso di `AdminDirectory` built-in) |
| Deploy | CI/CD da costruire (vs `clasp deploy` one-click) |
| HTTPS | Certificati da gestire (Let's Encrypt automatizza) |
| Manutenzione DB | Migration, indici, ottimizzazione query (assente con Sheets) |

### 5.3 Funzionalità da riadattare

- **Generazione ID**: `sosGenerateId()` usa `Utilities.getUuid()`. Sostituire con `crypto.randomUUID()` lato Node.js o `UUID()` lato MySQL.
- **Date e timezone**: `Utilities.formatDate()` va sostituito con `Intl.DateTimeFormat` o libreria (`dayjs`, `luxon`).
- **google.script.run**: Sostituire con `fetch()` verso API REST.
- **HtmlService templating**: Sostituire con EJS/Pug o SPA.
- **AdminDirectory API**: Sostituire con Google Admin SDK via service account.

### 5.4 Funzionalità da implementare ex-novo

- Sistema di migration database (es. `knex migrate` o `prisma migrate`)
- Rate limiting sugli endpoint
- Validazione input lato server (es. `zod` o `joi`)
- Sistema di logging strutturato (es. `winston` o `pino`)
- Health check endpoint per monitoring
- CI/CD pipeline (GitHub Actions)

### 5.5 Dati da migrare

Il foglio Google Sheet `SOS_RECUPERI_DB` contiene dati reali (docenti, studenti, attività, iscrizioni). La migrazione richiede:

1. Export di ogni foglio in CSV
2. Script di import con mappatura colonne (i nomi colonna corrispondono già al modello SQL)
3. Verifica integrità referenziale post-import
4. Correzione tipi di dato (date, booleani)
5. Ricalcolo `ore_programmate` da `lezioni_pacchetto`

---

## 6. Stima Effort

| Fase | Descrizione | Stima (giorni/uomo) |
|---|---|---|
| 1. Setup infrastruttura | Docker, MariaDB, Nginx, domini, certificati | 2-3 |
| 2. Schema database | Creazione tabelle, indici, migration | 2-3 |
| 3. Migrazione dati | Export Sheets → import SQL, validazione | 2-3 |
| 4. Backend auth | OAuth2 Google, JWT, middleware ruoli | 3-5 |
| 5. Backend API | REST endpoint per tutte le operazioni | 8-12 |
| 6. Frontend | Templating viste, sostituzione google.script.run con fetch() | 5-8 |
| 7. Notifiche email | Integrazione SMTP, template email | 2-3 |
| 8. Test | Unit test service, integration test API, E2E Playwright | 5-8 |
| 9. Deploy & CI/CD | GitHub Actions, docker compose, script deploy | 2-3 |
| 10. Documentazione | Aggiornamento docs, manuale amministratore | 2-3 |
| **Totale** | | **33-51 giorni/uomo** |

La stima presuppone uno sviluppatore esperto full-stack. Con un team di 2 persone, il progetto può essere completato in **4-6 settimane** working.

---

## 7. Raccomandazioni

1. **Prima iterazione**: backend REST API + frontend server-rendered (EJS), mantenendo il look & feel attuale. Questo minimizza la discontinuità e permette di avere un MVP funzionante in 3-4 settimane.

2. **Seconda iterazione**: migrazione frontend a SPA Vue.js, aggiunta di caching Redis, dashboard admin avanzato.

3. **Autenticazione**: se la configurazione del service account Google con domain-wide delegation risulta complessa, si può temporaneamente usare il fallback su tabella `docenti` per la verifica docenti (già implementato nel sistema attuale).

4. **Lock iscrizioni**: `SELECT ... FOR UPDATE` è sufficiente per carichi scolastici (decine/centinaia di utenti). Redis lock aggiuntivo solo se si prevede scaling orizzontale su più container.

5. **Backup**: configurare `mariabackup` giornaliero con retention 30 giorni + backup settimanale off-site.

6. **Test E2E Playwright**: la suite esistente può essere riutilizzata cambiando il target URL. La struttura dei test (auth, smoke, write-flow, multi-utente) rimane valida.

---

## 8. Riferimenti

- [ARCHITECTURE.md](/home/tecnico/dev/sos/ARCHITECTURE.md) — architettura attuale
- [PROJECT_SPEC.md](/home/tecnico/dev/sos/PROJECT_SPEC.md) — specifica funzionale
- [DATABASE.md](/home/tecnico/dev/sos/DATABASE.md) — schema dati Google Sheets
- [DEPLOYMENT.md](/home/tecnico/dev/sos/DEPLOYMENT.md) — procedure deploy GAS
- [TEST_PLAN.md](/home/tecnico/dev/sos/TEST_PLAN.md) — piano test
- [UI_GUIDELINES.md](/home/tecnico/dev/sos/UI_GUIDELINES.md) — linee guida UI
- [PROGRESS.md](/home/tecnico/dev/sos/PROGRESS.md) — stato progetto e storico
- [WORKFLOW.md](/home/tecnico/dev/sos/WORKFLOW.md) — workflow operativo Codex

---

*Documento generato dall'analisi completa del repository SOS Recuperi al 2026-06-10.*
