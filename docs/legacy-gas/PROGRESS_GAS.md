# PROGRESS - SOS Recuperi

## Uso operativo

`PROGRESS.md` e' la fonte primaria per stato corrente, decisioni recenti e prossimo step. La cronologia lunga precedente e' archiviata in `docs/archive/cronologia.md`.

Per riprendere il lavoro:

1. leggere `AGENTS.md`, `SPEC_SUMMARY.md`, `PROGRESS.md`, `CONTEXT_MAP.md`;
2. leggere i documenti indicati dalla mappa contesto;
3. usare la skill locale pertinente in `.agents/skills/`;
4. aggiornare questo file a fine step con decisioni, file modificati, test, rischi e prossimo step.

## NEXT_STEP

- ID: `STEP-VERIFY-2026-06-14-006`
- Titolo: Validazione finale post deploy GAS
- Stato: `TODO`
- Priorità: Media
- Obiettivo: eseguire una verifica di stabilita' post deploy su staging, partendo dal flusso docente e poi dalla smoke suite se serve.
- Skill da usare: `deployment-release`, `testing-e2e`
- Documenti da leggere prima: `PROGRESS.md`, `TESTING.md`, `DEPLOYMENT.md`.
- Modifiche consentite: solo correzioni puntuali emerse dai test mirati.
- Modifiche da evitare: deploy Apps Script, push GitHub, migrazioni o test write senza conferma esplicita.
- Criteri di successo: deployment `@41` valido su staging; flusso docente argomento completato; cancellazione studente completata; nessuna email reale inviata.
- Test richiesti: `npx playwright test tests/e2e/course-flows.spec.ts --grep "perfeziona argomento" --reporter=line`; smoke suite solo se serve.

## Registro attività recente

### STEP-DOCS-2026-06-12-001 - Hardening documentazione e skill locali

- Stato: `DONE`
- Priorità: Media
- Obiettivo: applicare `nuovo_prompt_generico_progetto.md` come miglioramento del progetto esistente, senza creare un nuovo progetto.
- Skill usate: `skill-creator`, `documentation-maintainer`
- Documenti letti: documentazione root, skill locali, test E2E, sorgenti principali, mockup, prompt generico.
- File modificati: `AGENTS.md`, `SPEC_SUMMARY.md`, `CONTEXT_MAP.md`, `TESTING.md`, `README.md`, `ARCHITECTURE.md`, `UI_GUIDELINES.md`, `DEPLOYMENT.md`, `TEST_PLAN.md`, `WORKFLOW.md`, `CHANGELOG.md`, `PROGRESS.md`, `.agents/agent.md`, `.agents/README.md`, `.agents/skills/*.md`, `docs/archive/cronologia.md`, `docs/archive/prompts/*`, `docs/migration/*`.
- Test eseguiti: `git diff --check`; controllo whitespace Markdown con `rg -n '[ \t]+$'`.
- Decisioni: mantenuto formato skill `.agents/skills/*.md`; prompt storici archiviati; analisi SQL spostata in `docs/migration/` come analisi futura.
- Rischi / dubbi: nessun test E2E eseguito perché la patch e' solo documentale; verificare deployment con `./sync2gscript.sh deployments` prima di dichiarare versione corrente.
- Esito: documentazione resa piu' compatta e orientata ad agenti, con mappa contesto e direttive di stop/profilo aggiornate.
- Prossimo step: seguire `NEXT_STEP`.

### STEP-NEXT-2026-06-14-001 - Definizione fronte post T85

- Stato: `DONE`
- Priorità: Media
- Obiettivo: controllare dove e' arrivato il progetto e trasformare il next step generico in un fronte operativo concreto.
- Skill usate: `documentation-maintainer`
- Documenti letti: `AGENTS.md`, `SPEC_SUMMARY.md`, `PROGRESS.md`, `CONTEXT_MAP.md`, `README.md`, `.agents/agent.md`, `.agents/skills/documentation-maintainer.md`, `CHANGELOG.md`.
- File modificati: `PROGRESS.md`.
- Test eseguiti: `git status --short`, `git log -1 --oneline`, `git diff --stat`, `git diff --name-status`; validazioni finali rimandate a `NEXT_STEP`.
- Decisioni: il prossimo fronte non e' un nuovo sviluppo applicativo, ma la validazione/consolidamento della patch documentale `0.1.44` gia presente in working tree. Deploy, push, migrazioni e test write restano esclusi senza conferma esplicita.
- Rischi / dubbi: working tree non pulita; le modifiche documentali risultano ampie e includono nuovi documenti, archivi e cancellazione dei prompt root storici dopo archiviazione.
- Esito: `NEXT_STEP` aggiornato con obiettivo, file, controlli e limiti.
- Prossimo step: seguire `NEXT_STEP`.

### STEP-DOCS-2026-06-14-002 - Validazione patch documentale 0.1.44

- Stato: `DONE`
- Priorità: Media
- Obiettivo: validare la patch documentale gia presente in working tree dopo hardening e completamento T85.*.
- Skill usate: `documentation-maintainer`
- Documenti letti: `PROGRESS.md`, `CHANGELOG.md`, `docs/archive/prompts/README.md`.
- File modificati: `PROGRESS.md`.
- Test eseguiti: `git diff --check`; `rg -n '[ \t]+$' AGENTS.md SPEC_SUMMARY.md CONTEXT_MAP.md TESTING.md README.md ARCHITECTURE.md UI_GUIDELINES.md DEPLOYMENT.md TEST_PLAN.md WORKFLOW.md CHANGELOG.md PROGRESS.md .agents docs`; controllo che non ci siano diff in `src`, `html`, `styles`, `tests`, `package.json`, `package-lock.json`, `appsscript.json`; verifica presenza archivi `docs/archive/prompts/*` e `docs/archive/cronologia.md`.
- Decisioni: la patch e' solo documentale; i prompt root cancellati risultano archiviati in `docs/archive/prompts/`; nessun test E2E necessario per questa validazione.
- Rischi / dubbi: working tree resta non committata; serve conferma esplicita prima di pushare.
- Esito: patch documentale validata a livello di diff/whitespace e pronta per commit locale.
- Prossimo step: seguire `NEXT_STEP`.

### STEP-GIT-2026-06-14-003 - Commit e push patch documentale 0.1.44

- Stato: `DONE`
- Priorità: Media
- Obiettivo: registrare in Git e pubblicare la patch documentale `0.1.44`.
- Skill usate: `documentation-maintainer`
- Documenti letti: `PROGRESS.md`.
- File modificati: documentazione e archivi gia elencati nello step `STEP-DOCS-2026-06-12-001`; in questa chiusura aggiornato anche `PROGRESS.md`.
- Test eseguiti: `git status --short`, `git diff --check`, `git branch --show-current`, `git diff --cached --stat`, `git commit -m "documenta stato progetto e skill agenti"`, `git push`, `git remote -v`, `ssh -vT git@github.com`.
- Decisioni: creato commit locale documentale `992da4d` su `main`; non eseguiti deploy, migrazioni o test write.
- Rischi / dubbi: `git push` era bloccato da passphrase SSH nell'ambiente Codex; l'utente ha poi eseguito l'operazione da terminale remoto.
- Esito: commit documentali pubblicati; `git status --branch --short` risultava allineato a `origin/main` prima dello step GAS successivo.
- Prossimo step: completamento GAS essenziale.

### STEP-GAS-2026-06-14-004 - Completamento GAS argomento e blocchi studenti

- Stato: `DONE`
- Priorità: Alta
- Obiettivo: completare nel progetto Google Apps Script esistente le funzioni minime richieste da `completamento_sos_gas.md`, senza SQL e senza nuova architettura.
- Skill usate: `apps-script-backend`, `google-sheets-database`, `booking-concurrency`, `ui-ux-frontend`, `testing-e2e`, `documentation-maintainer`.
- Documenti letti: `AGENTS.md`, `SPEC_SUMMARY.md`, `PROGRESS.md`, `CONTEXT_MAP.md`, `PROJECT_SPEC.md`, `DATABASE.md`, `ARCHITECTURE.md`, `completamento_sos_gas.md`, `TESTING.md`, `TEST_PLAN.md`, `UI_GUIDELINES.md`, skill locali pertinenti.
- File modificati: `src/Config.gs`, `src/Database.gs`, `src/AdminService.gs`, `src/StudentiService.gs`, `src/DocentiService.gs`, `src/Notifications.gs`, `src/Router.gs`, `html/Index.html`, `styles/components.css.html`, `tests/e2e/course-flows.spec.ts`, `tests/e2e/helpers/env.ts`, `.env.example`, `PROJECT_SPEC.md`, `DATABASE.md`, `ARCHITECTURE.md`, `TESTING.md`, `TEST_PLAN.md`, `CHANGELOG.md`, `PROGRESS.md`.
- Test eseguiti: `git diff --check`; `npx playwright test --list`; parsing GAS tramite copie `/tmp/*.js` con `node --check` per `AdminService`, `StudentiService`, `DocentiService`, `Notifications`, `Config`, `Database`.
- Decisioni: aggiunto nuovo foglio `STUDENTI_BLOCCATI`; il blocco impedisce solo nuove iscrizioni `SOS`; lo studente resta autorizzato e puo consultare iscrizioni; `nota_studente` viene aggiornata direttamente e il valore precedente e' tracciato in `LOG_AZIONI`; notifiche nuove forzate log-only con `allowSend: false`.
- Rischi / dubbi: non eseguiti deploy Apps Script, `setupDatabase()` o test write E2E perché richiedono conferma; i test Playwright nuovi validano codice che sara disponibile solo dopo push/deploy GAS; `SOS_DOCENTE2_TEST_EMAIL` e' opzionale e il test permessi docente viene saltato se manca.
- Esito: implementazione locale completata con test statici/economici passati.
- Prossimo step: seguire `NEXT_STEP`.

### STEP-GAS-2026-06-14-005 - Stabilizzazione runtime docente e cancellazione studente

- Stato: `DONE`
- Priorita: Alta
- Obiettivo: eliminare i colli di bottiglia del flusso docente argomento e della cancellazione studente su staging Apps Script.
- Skill usate: `deployment-release`, `testing-e2e`
- Documenti letti: `PROGRESS.md`, `DEPLOYMENT.md`, `TESTING.md`.
- File modificati: `src/DocentiService.gs`, `src/StudentiService.gs`, `html/Index.html`, `tests/e2e/course-flows.spec.ts`, `PROGRESS.md`.
- Test eseguiti: `git diff --check`; `node --check /tmp/DocentiService.js`; `clasp push --force`; `clasp deploy --deploymentId AKfycbz6aw8P2qMJ_iAD7asEwYEJinYL0yG08-7kU8uwk_DkI9bZOfzp83r_Z_zuJT0NEFFtWg --description "...";` `npx playwright test tests/e2e/course-flows.spec.ts --grep "perfeziona argomento" --reporter=line` con esito finale `1 passed`.
- Decisioni: il backend per l'argomento non ritorna piu' una pagina completa; il client aggiorna solo il DOM della riga iscrizione e il dettaglio corrente; la cancellazione studente usa lo stesso pattern leggero; rimosse le notifiche secondarie non richieste dallo step.
- Rischi / dubbi: il test write resta lungo e dipende dai dati accumulati in staging; il timeout del helper di creazione e' stato portato a 90s per ridurre falsi negativi.
- Esito: flusso docente argomento completato su deployment `@41`; cleanup studente completato nello stesso test.
- Prossimo step: seguire `NEXT_STEP`.

## Stato corrente

- Blocco manuale `T85.*` completato e pushato su GitHub nel commit `149435a`.
- Suite E2E documentata: smoke `7/7`, run mirati su SOS/Recupero/giorni disponibili, write suite validata su staging `@33` nella chiusura precedente.
- Email reali non abilitate: mantenere `CONFIG.notifiche_email_attive = FALSE` salvo conferma esplicita.
- La migrazione SQL e' solo analisi futura in `docs/migration/`, non roadmap corrente.

## Rischi aperti

- Verificare con `./sync2gscript.sh deployments` prima di dichiarare una versione Apps Script come ultima stabile operativa.
- Alcuni documenti storici restano lunghi per tracciabilità; usare `CONTEXT_MAP.md` per non caricarli sempre.
- I test write lasciano dati `E2E_...` in staging.

## Template step

```md
### STEP-YYYY-MM-DD-NNN - Titolo

- Stato: TODO | IN_PROGRESS | BLOCKED | DONE
- Priorità: Alta | Media | Bassa
- Obiettivo:
- Skill usate:
- Documenti letti:
- File modificati:
- Test eseguiti:
- Decisioni:
- Rischi / dubbi:
- Esito:
- Prossimo step:
```
