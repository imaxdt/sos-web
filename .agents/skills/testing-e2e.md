# Skill - Testing E2E

## Quando usarla

Usala per Playwright, `.env.example`, auth state, smoke/write suite, helper E2E, test su Web App GAS e verifica flussi staging.

## Contesto minimo

- `AGENTS.md`
- `SPEC_SUMMARY.md`
- `PROGRESS.md`
- `TESTING.md`
- `TEST_PLAN.md` solo per casi storici o codici test
- `playwright.config.ts`
- `tests/e2e/*.spec.ts`
- `tests/e2e/helpers/*.ts`

## Regole

- Non stampare credenziali, cookie o contenuto di `.auth/admin.json`.
- Per test write, verifica che `CONFIG.notifiche_email_attive = FALSE`.
- Segnala sempre se il test scrive dati `E2E_...` in staging.
- Preferisci run mirati prima della suite completa quando stai debug-gando un caso.
- Se la sessione Google scade, riesegui `npm run e2e:auth`.
- Non confermare test manuali al posto dell'utente.

## Chiusura

Aggiorna `PROGRESS.md`, `TESTING.md` se cambiano comandi correnti, `TEST_PLAN.md` se cambiano casi di accettazione, `CHANGELOG.md` se la copertura e' versionabile.
