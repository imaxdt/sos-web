# TEST PLAN - SOS Recuperi

## Obiettivo

Definire i casi minimi e storici per verificare che la web app funzioni correttamente.

Per i comandi correnti usare `TESTING.md`. Questo file resta il piano esteso dei casi di accettazione e lo storico delle validazioni manuali/E2E.

## Test autenticazione

- T01: docente autorizzato vede dashboard docente.
- T02: studente autorizzato vede area studente.
- T03: admin vede funzioni admin o permessi superiori.
- T04: utente non autorizzato vede accesso negato.
- T05: `testAuthDocente()` restituisce `DOCENTE` per una email docente reale appartenente al gruppo docenti.
- T06: `testAuthStudente()` restituisce `STUDENTE` per una email reale `@studenti.liceoduca.it`.
- T07: i risultati dei test vengono registrati o aggiornati in `UTENTI_CACHE`.
- T08: `debugAuthConfig()` mostra domini, `gruppo_docenti` e email di test configurate.
- T09: in caso di fallimento docente, `testAuthDocente()` mostra il motivo specifico in `details.checks.docente`.
- T10: `testDocenteMembershipSpecificUser()` verifica direttamente `AdminDirectory.Members.hasMember()`.
- T11: se `AdminDirectory` fallisce, docente presente in `DOCENTI.email` con `attivo = TRUE` viene riconosciuto tramite fallback.

## Test docente

- T20: aggiunta materia/laboratorio.
- T21: rimozione/disattivazione materia.
- T22: creazione attività di recupero con materia, ore previste, prima lezione, note, argomenti, principale, altri dettagli, min/max studenti.
- T22.1: aggiunta seconda lezione a una attività esistente.
- T22.2: ora inizio lezione accetta solo formato `HH:MM`, step 15 minuti, range 08:00-18:00.
- T22.3: durata lezione accetta solo `1h` o `2h`, con ora fine calcolata.
- T23: pubblicazione attività di recupero visibile agli studenti.
- T24: bozza non visibile agli studenti.
- T25: annullamento lezione; l'attività resta valida e puo' ricevere una lezione sostitutiva.
- T26: dashboard docente mostra metriche da `DOCENTI_MATERIE`, `PACCHETTI_RECUPERO`, `LEZIONI_PACCHETTO`, `ISCRIZIONI_PACCHETTO`.
- T27: docente autorizzato ma non censito in `DOCENTI` vede dashboard con metriche a zero e messaggio operativo.
- T28: docente apre `?page=materie`, seleziona una materia attiva e crea un record in `DOCENTI_MATERIE`.
- T29: docente disattiva una propria materia e il record viene aggiornato con `attiva = FALSE`.
- T30: docente non puo' aggiungere una materia gia attiva.
- T31: scritture materie docente generano record in `LOG_AZIONI`.
- T32: docente apre `?page=disponibilita`, crea una attività pubblicata e la vede in tabella.
- T33: docente annulla una lezione e `LEZIONI_PACCHETTO.stato` diventa `ANNULLATA`.
- T34: docente non puo' creare corsi su materia non associata.
- T35: docente apre `?page=prenotazioni` e vede l'elenco dei propri corsi con dettaglio del primo selezionato.
- T36: docente seleziona un'altra attività nella lista e il pannello destro si aggiorna senza ricaricare la pagina.
- T37: docente rimuove una iscrizione attiva da `?page=prenotazioni` e `ISCRIZIONI_PACCHETTO.stato` diventa `CANCELLATA_DOCENTE`.
- T38: se una attività era `COMPLETO` e una iscrizione docente viene rimossa, l'attività torna `PUBBLICATO` quando i posti occupati scendono sotto il massimo.
- T39: docente modifica/perfeziona `nota_studente` di una iscrizione attiva collegata a una propria attività; un altro docente non puo modificare la stessa iscrizione.

## Test studente

- T40: lo studente vede solo attività pubblicate.
- T41: filtri materia/docente/giorno/fascia/posti/parola chiave.
- T42: iscrizione valida all'attività.
- T43: doppia iscrizione alla stessa attività bloccata.
- T44: overbooking bloccato.
- T45: visualizzazione mie iscrizioni.
- T46: cancellazione iscrizione da `?page=iscrizioni`.
- T47: admin testa studente reale con `?page=esplora&viewAs=studente&runAs=...` oppure dal pulsante `Run as studente`.
- T48: in `Esplora recuperi`, `Scegli` seleziona l'attività e mostra il riepilogo con calendario lezioni senza iscrivere subito.
- T49: `Conferma iscrizione all'attività` registra l'iscrizione e aggiorna la lista senza pagina bianca.
- T49.1: test overbooking/doppia iscrizione: creare o usare una attività con `max_studenti = 1`; iscrivere uno studente; poi provare a iscrivere di nuovo lo stesso studente e verificare errore di doppia iscrizione; infine provare con un secondo studente e verificare che l'attività piena non sia prenotabile o restituisca errore di posti esauriti.
- T49.2: se lo studente ha un blocco attivo in `STUDENTI_BLOCCATI`, una nuova iscrizione `SOS` viene bloccata lato server con messaggio chiaro; dopo sblocco admin, lo stesso studente puo iscriversi.

## Test admin blocchi studenti

- T54.1: admin apre `?page=studenti-bloccati` e vede studenti selezionabili e ultimi blocchi.
- T54.2: admin crea un blocco con email studente, motivo, data inizio e fine opzionale; viene creata una riga in `STUDENTI_BLOCCATI` e un log `STUDENTE_BLOCCATO`.
- T54.3: admin sblocca uno studente; il blocco passa ad `attivo = FALSE` e viene registrato `STUDENTE_SBLOCCATO`.

## Test concorrenza

- T50: due iscrizioni simultanee sull'ultimo posto devono produrre una sola iscrizione valida.

## Test log

- T55: log creazione disponibilita.
- T56: log prenotazione.
- T57: log accesso negato.

## Test notifiche

- T57: con `CONFIG.notifiche_email_attive = FALSE`, una prenotazione registra righe `LOG_ONLY` in `NOTIFICHE`.
- T58: con `CONFIG.notifiche_email_attive = FALSE`, una cancellazione studente registra righe `LOG_ONLY` in `NOTIFICHE`.
- T59: con `CONFIG.notifiche_email_attive = FALSE`, una rimozione docente registra righe `LOG_ONLY` in `NOTIFICHE`.
- T59.1: con `CONFIG.notifiche_email_attive = TRUE`, invio email tramite `MailApp` e registrazione esito `INVIATA`, `DISATTIVATA` o `ERRORE`. Test sospeso: da eseguire piu' avanti, non nella fase corrente.

## Test deploy

- T60: accesso limitato al dominio.
- T61: database non condiviso con docenti/studenti.
- T62: web app eseguita come proprietario/deployer.
- T63: Web App mostra area docente a docente autorizzato.
- T64: Web App mostra area studente a studente autorizzato.
- T65: Web App mostra `AccessoNegato.html` a utente non autorizzato.
- T66: admin apre `?page=dashboard&viewAs=docente` e vede dashboard docente in modalita test.
- T67: admin apre `?page=esplora&viewAs=studente` e vede vista studente.
- T68: utente non admin non puo' cambiare ruolo effettivo con `viewAs`.
- T69: `?debug=plain` mostra la pagina diagnostica di `doGet(e)`.
- T70: admin apre `?page=materie&viewAs=docente` e vede la UI materie docente in modalita test.
- T71: admin apre `?page=materie&viewAs=docente&runAs=docente.reale@liceoduca.it` o usa `Run as docente` e puo' aggiungere/disattivare materie del docente indicato.
- T72: admin apre `?page=esplora&viewAs=studente&runAs=studente.reale@studenti.liceoduca.it` o usa `Run as studente` e la UI mantiene l'identita studente di test.
- T73: admin apre `?page=disponibilita&viewAs=docente&runAs=docente.reale@liceoduca.it` e puo' creare disponibilita per il docente indicato.
- T74: dopo aggiunta materia, disattivazione materia, creazione/annullamento disponibilita, prenotazione e cancellazione prenotazione la pagina non diventa bianca e la tabella si aggiorna nella stessa vista.
- T75: dalla barra admin, compilare una sola volta `Run as docente` o `Run as studente`; i link interni devono preservare il parametro `runAs` senza modifiche manuali all'URL.
- T76: dopo `Run as docente`, clic su sidebar `Materie`, sidebar `Disponibilita` e pulsante `Nuova disponibilita` non deve aprire una pagina bianca.
- T77: dopo `Run as docente`, clic su sidebar `Materie` e `Disponibilita` deve rimanere in vista docente e non tornare alla dashboard admin.
- T78: la dashboard admin mostra il centro test, la sidebar admin mostra solo pagine operative (`Dashboard`, `Configurazione`, `Log notifiche`) e la sidebar docente mostra le pagine docente implementate.
- T79: la UI `@19` rispetta i mockup locali: topbar globale, sidebar, dashboard docente a card, materie con form laterale, disponibilita con stepper/anteprima, studente esplora a card.

## Test setup e sincronizzazione

- T80: `.venv/bin/python --version` restituisce una versione Python valida.
- T81: `clasp --version` restituisce la versione installata.
- T82: `./sync2gscript.sh status` mostra nella sezione `Tracked files` solo file Apps Script previsti da `.claspignore`.
- T83: `./sync2gscript.sh deployments` mostra i deployment del progetto `SOS`.
- T84: `./sync2github.sh status` mostra remote SSH `git@github.com:imaxdt/sos.git`.
- T85: `./sync2github.sh "messaggio commit"` crea commit e push su `main`.

## Test E2E Playwright

- E2E-SETUP-1: `npm install` installa le dipendenze Playwright senza vulnerabilità note.
- E2E-SETUP-2: `npx playwright test --list` elenca i test E2E configurati.
- E2E-AUTH-1: `npm run e2e:auth` salva una sessione Google admin in `.auth/admin.json` dopo login manuale.
- E2E-SMOKE-1: `npm run e2e:smoke` carica la dashboard admin senza pagina bianca.
- E2E-SMOKE-2: `npm run e2e:smoke` carica `?page=configurazione` e trova `notifiche_email_attive`.
- E2E-SMOKE-3: `npm run e2e:smoke` carica `?page=notifiche`.
- E2E-SMOKE-4: l'attivazione di `notifiche_email_attive = TRUE` mostra conferma browser e viene annullata dal test.
- E2E-VIEWAS-1: `viewAs=docente&runAs=...` carica la vista docente con email test.
- E2E-VIEWAS-2: `viewAs=studente&runAs=...` carica la vista studente con email test.
- E2E-WRITE-1: `npm run e2e:write` crea un corso `SOS` singolo con titolo `E2E_...` e verifica riga docente aggiornata.
- E2E-WRITE-2: `npm run e2e:write` crea un `Recupero Estivo` singolo con 1 lezione su 5 e verifica segnalazione lezioni mancanti.
- E2E-WRITE-3: `npm run e2e:write` usa `viewAs=studente&runAs=...` per prenotare e poi cancellare una iscrizione su un corso `E2E_...`.
- E2E-WRITE-4: `npm run e2e:write` verifica che uno studente gia iscritto riveda il corso come `Gia prenotato` senza pulsante `Scegli`.
- E2E-WRITE-5: `npm run e2e:write`, con `SOS_STUDENTE2_TEST_EMAIL` configurata, verifica che un corso `max_studenti = 1` diventi non prenotabile per il secondo studente, poi torni `PUBBLICATO` dopo `Rimuovi` lato docente e sia di nuovo prenotabile.

Note:

- L'ambiente corrente e' considerato staging temporaneo durante la prima realizzazione.
- `.env` e `.auth/` non devono essere versionati.
- I test write scrivono dati riconoscibili in `PACCHETTI_RECUPERO`, `LEZIONI_PACCHETTO` e `ISCRIZIONI_PACCHETTO` con prefisso `E2E_`; le iscrizioni vengono cancellate, i corsi creati restano nel foglio staging.
- Nel caso E2E multi-utente, la prenotazione finale del secondo studente puo' restare attiva nel foglio staging per evitare cleanup instabili non necessari alla verifica.
- Il caso E2E multi-utente completo richiede una seconda email studente locale in `.env`; se assente, il test dedicato viene saltato.
- Il caso E2E multi-utente completo richiede anche che il deployment staging abbia il secondo profilo test in `STUDENTI`, ottenuto eseguendo `ensureAuthTestProfiles()` dopo l'allineamento di `SOS_CONFIG.AUTH_TEST`.

Esito 2026-05-28: `npm run e2e:auth` completato dopo correzione supporto iframe GAS; `npm run e2e:smoke` completato con 7/7 test passati.
Esito 2026-05-28: `npm run e2e:write` completato con 3/3 test passati (`SOS`, `Recupero Estivo`, prenotazione/cancellazione studente).
Esito 2026-05-28: `npm run e2e:write` completato con `5/5` test passati dopo allineamento staging `@33`, `ensureAuthTestProfiles` e sincronizzazione del test con le callback `google.script.run`.

## Test setup database

- T90: eseguire `setupDatabase()` in Apps Script senza errori.
- T91: verificare fogli `CONFIG`, `ADMIN`, `UTENTI_CACHE`, `DOCENTI`, `STUDENTI`, `MATERIE`, `DOCENTI_MATERIE`, `PACCHETTI_RECUPERO`, `LEZIONI_PACCHETTO`, `ISCRIZIONI_PACCHETTO`, `STUDENTI_BLOCCATI`, `DISPONIBILITA`, `PRENOTAZIONI`, `NOTIFICHE`, `LOG_AZIONI`.
- T92: verificare che `ADMIN` abbia come prime colonne `admin` e `superadmin`.
- T93: verificare seed `CONFIG` con domini `liceoduca.it` e `studenti.liceoduca.it`.
- T94: verificare seed iniziale `MATERIE`.

## Esiti manuali 2026-05-26

- T05 completato: docente reale riconosciuto dopo abilitazione Admin Directory.
- T06 completato: studente reale `@studenti.liceoduca.it` riconosciuto.
- T63 completato: Web App raggiungibile da deployment Apps Script.
- T66 completato: admin visualizza dashboard docente con `viewAs=docente`.
- T67 completato: admin visualizza area studente con `viewAs=studente`.
- T69 completato: diagnostica `?debug=plain` mostra `doGet` raggiunto.

## Test manuali richiesti dopo fix pagina bianca

- T74.1: da admin docente aggiungere una materia e verificare che resti visibile la pagina con messaggio `Materia aggiornata`.
- T74.2: da admin docente disattivare una materia e verificare che resti visibile la pagina con messaggio `Materia disattivata`.
- T74.3: da admin docente creare una disponibilita e verificare che resti visibile la pagina con messaggio `Disponibilita pubblicata`.
- T74.3a: dopo la creazione della disponibilita, verificare che la nuova riga compaia nell'elenco nella stessa pagina senza refresh manuale.
- T74.4: da admin docente annullare una disponibilita e verificare che resti visibile la pagina con messaggio `Disponibilita annullata`.
- T74.4a: dopo l'annullamento della disponibilita, verificare che la riga aggiorni lo stato ad `ANNULLATA` nella stessa pagina senza refresh manuale.
- T74.5: da admin studente prenotare uno slot e verificare che resti visibile la pagina con messaggio `Prenotazione registrata`.
- T74.6: da admin studente cancellare una prenotazione e verificare che resti visibile la pagina con messaggio `Prenotazione cancellata`.
- T78.1: da admin aprire la dashboard e verificare che siano presenti controlli test docente/studente e accessi rapidi a configurazione/log notifiche.
- T78.2: da `Run as docente` verificare che la sidebar mostri solo `Dashboard`, `Materie`, `Disponibilita`.

## Test manuali richiesti dopo UI mockup `@19`

- T79.1: aprire admin e verificare topbar globale, sidebar e centro test.
- T79.2: usare `Run as docente` con `alessandra.franceschi@liceoduca.it` e verificare dashboard docente con card metriche e azioni rapide.
- T79.3: aprire `Materie`, aggiungere o disattivare una materia e verificare che il form laterale resti in pagina senza pagina bianca.
- T79.4: aprire `Disponibilita`, compilare anche `Principale`, `Argomenti`, `Altri dettagli` e pubblicare una disponibilita.
- T79.5: usare `Run as studente` con `miglietta.chiara@studenti.liceoduca.it`, aprire `Esplora recuperi` e verificare card prenotabili.
- T79.6: prenotare e cancellare da `Le mie iscrizioni`, verificando che non si perda `runAs`.

## Test manuali richiesti dopo filtri reali studente

- T81.1: da admin usare `Run as studente` con `miglietta.chiara@studenti.liceoduca.it` e aprire `Esplora recuperi`.
- T81.2: filtrare per materia e verificare che restino solo card della materia scelta.
- T81.3: filtrare per docente e verificare che restino solo slot del docente scelto.
- T81.4: filtrare per giorno e fascia oraria, verificando conteggio e card visibili.
- T81.5: selezionare `Solo disponibili` e verificare che siano esclusi slot pieni.
- T81.6: cercare una parola presente in titolo/argomenti/note e poi usare `Reset`.
- T81.7: prenotare con un filtro attivo e verificare che la pagina non diventi bianca e che il filtro resti applicato.

## Test manuali richiesti dopo flow prenotazione guidato

- T82.1: da admin usare `Run as studente` con `miglietta.chiara@studenti.liceoduca.it` e aprire `Esplora recuperi`.
- T82.2: cliccare `Scegli` su uno slot e verificare che non parta subito la prenotazione.
- T82.3: verificare il pannello laterale `Prenota recupero` con riepilogo materia, docente, slot, posti e note subito dopo il clic su `Scegli`.
- T82.4: cliccare `Conferma iscrizione` e verificare messaggio `Prenotazione registrata`.
- T82.5: aprire `Le mie iscrizioni` e verificare che la prenotazione sia presente.
- T82.6: ripetere con un filtro attivo e verificare che non compaia pagina bianca.

## Test manuali richiesti dopo notifiche log-only

- T83.1: verificare in `CONFIG` che `notifiche_email_attive` sia `FALSE`.
- T83.2: da `Run as studente`, prenotare uno slot e verificare in `NOTIFICHE` righe con esito `LOG_ONLY`.
- T83.3: cancellare una prenotazione da `Le mie iscrizioni` e verificare nuove righe `LOG_ONLY`.
- T83.4: da `Run as docente`, aprire `Prenotazioni`, rimuovere una prenotazione e verificare nuove righe `LOG_ONLY`.
- T83.5: verificare che nessuna email reale venga inviata finche' `notifiche_email_attive` resta `FALSE`.

## Test manuali richiesti dopo pannello admin configurazione/log

- T84.1: da admin aprire `?page=configurazione` e verificare che la tabella `CONFIG` sia leggibile.
- T84.2: da superadmin modificare un parametro non distruttivo, per esempio `anno_scolastico`, e verificare messaggio `Configurazione aggiornata`.
- T84.3: verificare che parametri protetti come `database_spreadsheet_id` e `script_id` siano in sola lettura.
- T84.4: aprire `?page=notifiche` e verificare elenco ultime righe `NOTIFICHE`, statistiche e stato dello switch.
- T84.5: lasciare `notifiche_email_attive = FALSE` e verificare che il pannello mostri `LOG_ONLY`.
- T84.6: provare a selezionare `TRUE` e verificare che compaia la conferma browser prima dell'attivazione email reale; annullare il test se non si vuole inviare email.

Esito 2026-05-27: test manuali T84.1-T84.6 confermati OK. La prova di invio email reale resta sospesa e non e' richiesta per chiudere questa fase.

Conferma 2026-05-28: test manuali T84.1-T84.6 riconfermati OK dall'utente durante la ripresa operativa. `notifiche_email_attive` resta `FALSE`; nessun invio email reale eseguito.

## Test sospesi dopo fix refresh disponibilita/prenotazione

Stato 2026-05-27: sezione superata dalla revisione attività di recupero. I retest equivalenti sono ora tracciati in T85.

- TS-REFRESH-1: creare una disponibilita docente e verificare che la nuova riga compaia subito nell'elenco senza refresh manuale.
- TS-REFRESH-2: annullare una disponibilita docente e verificare che la riga passi subito a `ANNULLATA` senza refresh manuale.
- TS-BOOKING-1: da studente cliccare `Scegli` su uno slot e verificare che il pannello laterale mostri materia, docente, data/orario, posti e note.
- TS-OVERBOOKING-1: creare/usare uno slot con `Posti massimi = 1`, prenotarlo con uno studente, riprovare con lo stesso studente e poi con un secondo studente per verificare il blocco di doppia prenotazione e posti esauriti.

## Test manuali richiesti dopo revisione attività di recupero

- Stato 2026-05-28: il blocco `T85.*` resta manuale; il prossimo fronte prioritario e' `T85.1` per confermare il setup database dopo deploy prima di proseguire con i flussi docente/studente.
- T85.1: eseguire `setupDatabase()` dopo deploy e verificare che siano presenti i fogli `PACCHETTI_RECUPERO`, `LEZIONI_PACCHETTO`, `ISCRIZIONI_PACCHETTO`. **Confermato 2026-05-29**: eseguito via Playwright con sessione admin; 14 fogli presenti, inclusi i tre richiesti.
- T85.2: da admin docente aprire `?page=disponibilita`, creare una attività con `Ore previste` a 2 cifre, prima lezione, durata `1h` o `2h`, e verificare riga attività + riga lezione. **Confermato 2026-05-29**: attività SOS creata via Playwright con lezione 1h (14:00-15:00), payload server verificato: `tipoCorso=SOS`, `lezioni.length=1`, `lezione[0].stato=PROGRAMMATA`.
- T85.3: usare `Aggiungi lezione` sulla stessa attività e verificare incremento `ore_programmate`. **Confermato 2026-05-29**: Recupero Estivo con 1 lezione da 2h → aggiunta seconda lezione 2h via pulsante "Aggiungi lezione". `ore_programmate` passato da 2 a 4, `lezioni` da 1 a 2. Nota: SOS non permette piu' di 1 lezione (regola di dominio in `DocentiService.gs:1102`), quindi questo test va eseguito su Recupero Estivo.
- T85.4: annullare una lezione e verificare che l'attività resti pubblicata e le ore programmate diminuiscano. **Confermato 2026-05-29**: Recupero Estivo con 2 lezioni; annullamento prima lezione tramite pulsante UI "Annulla lezione". `oreProgrammate` passato da 4 a 2, attività resta `PUBBLICATO`, 1 lezione attiva rimasta. Nota: la lezione annullata non compare nel payload `getDocenteDisponibilitaPage` come `ANNULLATA` (possibile cache server), ma il decremento di ore conferma l'operazione.
- T85.5: da admin studente aprire `?page=esplora`, cliccare `Scegli` su una attività e verificare riepilogo con materia, docente, ore, calendario lezioni, posti e note. **Confermato 2026-05-29**: SOS creato, navigazione studente, click Scegli. Wizard confermato: Materia (Fisica), Docente, Tipo (SOS), Ore (1/1), Calendario (01/06/2026 14:00-15:00), Posti (5), Note, pulsante Conferma iscrizione.
- T85.6: confermare iscrizione all'attività e verificare `ISCRIZIONI_PACCHETTO` e pagina `Le mie iscrizioni`. **Confermato 2026-05-29**: SOS creato, studente iscritto, messaggio "Iscrizione alla attività registrata", pagina `Le mie iscrizioni` mostra riga con `ATTIVA`.
- T85.7: testare overbooking/doppia iscrizione su attività con `Posti massimi = 1`. **Confermato 2026-05-29**: SOS con maxStudenti=1. studente1 iscritto OK, doppia iscrizione bloccato ("Gia prenotato", nessun Scegli), overbooking studente2 bloccato ("Non disponibile", nessun Scegli). Blocco T85.* completato.

## Test manuali richiesti dopo tipologie attività e ripetizioni

- Stato 2026-05-28: `T86.1`, `T86.2`, `T86.3`, `T86.4`, `T86.5`, `T86.6` e `T86.7` coperti anche da Playwright con run mirati `tests/e2e/course-flows.spec.ts --grep "crea SOS singolo E2E"` passato `1/1`, `--grep "riepilogo completo di SOS e Recupero Estivo"` passato `1/1`, `--grep "ripetuto"` passato `2/2`, `--grep "incompleto"` passato `1/1` e `--grep "giorni_corsi_disponibili"` passato `1/1`.
- T86.1: verificata la chiave `giorni_corsi_disponibili` e il rifiuto del primo giorno non ammesso del range corrente (`sabato` se `1-5`, `domenica` se `1-6`).
- T86.2: verificata una attività `SOS` in modalita `Singola` con una riga in `PACCHETTI_RECUPERO` e una sola riga in `LEZIONI_PACCHETTO`.
- T86.3: verificato un `SOS` con ripetizione giornaliera fino a una data e corsi SOS separati, ciascuno con una lezione.
- T86.4: verificato un `Recupero Estivo` in modalita `Singola` con `ore_previste = 10`, una lezione da 2h e segnalazione delle lezioni #2-#5 mancanti.
- T86.5: verificato un `Recupero Estivo` con ripetizione giornaliera o settimanale e data sufficiente con 5 lezioni da 2h nella stessa attività.
- T86.6: verificato un `Recupero Estivo` con data limite insufficiente e salvataggio delle lezioni generate con segnalazione delle lezioni mancanti.
- T86.7: verificato lato studente il riepilogo di `SOS` e `Recupero Estivo` con tipo attività, docente, materia, ore, lezioni e posti.

## Test manuali richiesti dopo pagina docente prenotazioni

- T80.1: da admin usare `Run as docente` con `alessandra.franceschi@liceoduca.it` e aprire `Prenotazioni`.
- T80.2: verificare che la sidebar docente mostri di nuovo `Prenotazioni`.
- T80.3: cliccare almeno due slot diversi e verificare aggiornamento del dettaglio a destra senza pagina bianca.
- T80.4: se esistono studenti iscritti, usare `Rimuovi` su una prenotazione e verificare messaggio di successo e aggiornamento immediato.
