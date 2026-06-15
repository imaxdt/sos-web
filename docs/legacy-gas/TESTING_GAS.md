# TESTING - SOS Recuperi

## Scopo

Questo file contiene i comandi correnti per verificare il progetto. `TEST_PLAN.md` resta il piano esteso e storico dei casi di accettazione.

## Prerequisiti

```bash
cp .env.example .env
npm install
npm run e2e:auth
```

`npm run e2e:auth` apre un browser headed per completare login Google admin. La sessione viene salvata in `.auth/admin.json`, esclusa da Git.

Variabili principali in `.env`:

- `SOS_WEBAPP_URL`
- `SOS_DOCENTE_TEST_EMAIL`
- `SOS_STUDENTE_TEST_EMAIL`
- `SOS_STUDENTE2_TEST_EMAIL`
- `SOS_E2E_PREFIX`

Non stampare o committare valori reali di `.env` o `.auth/`.

## Smoke

```bash
npm run e2e:smoke
```

Copre caricamento dashboard admin, configurazione, log notifiche, conferma protettiva email e viste `runAs` docente/studente.

## Write suite

```bash
npm run e2e:write
```

Scrive dati riconoscibili in staging con prefisso `E2E_`. Mantieni `CONFIG.notifiche_email_attive = FALSE`.

Copre:

- creazione `SOS` singolo;
- creazione `Recupero Estivo`;
- `SOS` ripetuto come attività separate;
- `Recupero Estivo` completo e incompleto con warning;
- controllo adattivo `CONFIG.giorni_corsi_disponibili`;
- iscrizione/cancellazione studente;
- doppia iscrizione e overbooking;
- modifica argomento iscrizione da parte del docente;
- blocco/sblocco studente SOS da admin;
- riepilogo studente per `SOS` e `Recupero Estivo`.

## Run mirati

```bash
npx playwright test tests/e2e/course-flows.spec.ts --grep "crea SOS singolo E2E" --reporter=line
npx playwright test tests/e2e/course-flows.spec.ts --grep "ripetuto" --reporter=line
npx playwright test tests/e2e/course-flows.spec.ts --grep "incompleto" --reporter=line
npx playwright test tests/e2e/course-flows.spec.ts --grep "giorni_corsi_disponibili" --reporter=line
npx playwright test tests/e2e/course-flows.spec.ts --grep "perfeziona argomento|blocca e sblocca|altri docenti" --reporter=line
```

## Controlli documentali

Per modifiche solo Markdown:

```bash
git diff --check
```

Non serve deploy Apps Script per modifiche solo documentali escluse da `.claspignore`.

## Note operative

- I test write sono lenti perché passano da Web App GAS e `google.script.run`.
- La suite puo' lasciare corsi `E2E_...` nel database staging.
- Se la sessione Google scade, riesegui `npm run e2e:auth`.
- Test manuali e deploy richiedono conferma esplicita dell'utente.
