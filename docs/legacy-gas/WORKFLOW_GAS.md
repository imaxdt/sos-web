# WORKFLOW - SOS Recuperi

## Protocollo operativo Codex

`PROGRESS.md` e' la fonte primaria per stato operativo, priorità e prossimo step.

Prima di iniziare una fase ampia, invasiva, ambigua o che richiede test manuali/deploy/push, Codex deve mostrare un prompt sintetico e attendere conferma esplicita.

Per piccoli fix locali già documentati in `NEXT_STEP`, già dentro una fase confermata e senza test manuali/deploy/push/migrazioni, Codex può procedere direttamente rispettando `AGENTS.md`, `.agents/agent.md`, skill locali e documentazione di progetto.

Codex lavora per step completi. Deve fermarsi solo a fine fase logica, dopo modifiche importanti, quando serve una decisione dell'utente, quando `/compact` e' davvero utile o quando conviene cambiare modello/profilo. Non deve fermarsi solo per micro-risparmio token.

Il prompt deve includere:

- fase che si sta per intraprendere;
- modello consigliato, specificando la versione numerica del modello, es. `GPT-5.5` o `GPT-5.4`;
- profilo consigliato tra `low`, `medium`, `high`, `xhigh`, scegliendo il minimo adeguato;
- skill o direttive locali che verranno usate;
- valutazione del contesto: continuare, compattare o riavviare Codex per risparmiare token;
- modifiche previste;
- test automatici o controlli locali;
- test manuali richiesti all'utente;
- eventuali rischi o dati mancanti.

## Modello e profilo consigliati

- Modello: indicare sempre la versione numerica consigliata, es. `GPT-5.5`, `GPT-5.4`, `GPT-5.3`.
- Profilo: `low`, `medium`, `high` o `xhigh`.

Codex può raccomandare modello e profilo, ma non li cambia autonomamente. Se tra uno step e l'altro conviene cambiare modello, profilo, compattare o riavviare, Codex deve proporlo e attendere che l'utente applichi manualmente la scelta.

Scegliere il profilo in base alla fase:

- `low`: fix semplici, rename, documentazione breve, test minori.
- `medium`: modifiche normali di codice, documentazione strutturata, script semplici, test ordinari.
- `high`: analisi architetturale, bug difficile, refactoring delicato, test articolati.
- `xhigh`: architettura complessa, concorrenza, sicurezza, migrazioni dati, integrazioni critiche.

## Direttive locali

Le direttive operative del progetto sono in:

- `AGENTS.md`;
- `.agents/agent.md`;
- `.agents/skills/apps-script-backend.md`;
- `.agents/skills/google-sheets-database.md`;
- `.agents/skills/workspace-auth-groups.md`;
- `.agents/skills/ui-ux-frontend.md`;
- `.agents/skills/booking-concurrency.md`;
- `.agents/skills/documentation-maintainer.md`;
- `.agents/skills/testing-e2e.md`;
- `.agents/skills/deployment-release.md`.

## Gestione contesto

Continuare nella sessione corrente se il contesto e' ancora leggibile e coerente.

Proporre compattazione o riavvio Codex quando conviene risparmiare token o ridurre rumore operativo.

Compattare quando:

- la conversazione contiene troppe informazioni obsolete;
- cambia una fase ampia del progetto;
- bisogna passare da audit/setup a implementazione estesa;
- i dettagli tecnici precedenti rischiano di confondere il lavoro successivo.

Riavviare Codex quando:

- la sessione contiene troppe decisioni superate;
- si apre una fase indipendente e lunga;
- il contesto residuo non giustifica il costo token;
- serve ripartire da documentazione e repository aggiornati.

## Test e conferme

A fine step Codex deve indicare:

- cosa ha fatto;
- file creati o modificati;
- controlli eseguiti;
- test manuali richiesti;
- errori o limiti rilevati;
- prossimo step consigliato;
- rischi residui;
- se conviene davvero fare `/compact`;
- se conviene fare commit e push su GitHub.

Codex deve chiedere conferma prima di modifiche invasive: schema database, architettura, autenticazione/ruoli, sicurezza, deploy, push, rollback, invio email reale, eliminazione file o rimozione funzionalità.

Richiedono sempre conferma o esito esplicito dell'utente:

- test manuali, perché Codex può guidarli ma non confermarli al posto dell'utente;
- commit/push GitHub, perché `sync2github.sh` può richiedere conferma o passphrase della chiave SSH;
- cambio modello o profilo `medium`/`high`/`xhigh`;
- compattazione o riavvio della sessione;
- deploy Apps Script o migrazioni su dati reali.

## Sincronizzazione Google Apps Script

Usare:

```bash
./sync2gscript.sh status
./sync2gscript.sh push
```

Nel comando `status`, la sezione `Tracked files` mostra i file che `clasp` gestira' nel push. La sezione `Untracked files` puo' elencare documentazione e asset locali che restano fuori dal progetto Apps Script.

## Sincronizzazione GitHub

Il repository GitHub usa SSH:

```text
git@github.com:imaxdt/sos.git
```

Usare:

```bash
./sync2github.sh status
./sync2github.sh "messaggio commit"
```
