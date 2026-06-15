# AGENTS - SOS Web

## Obiettivo

Sviluppare la nuova versione web + database SQL di SOS Recuperi in una root separata dal vecchio progetto GAS.

## Confini

- Non modificare ~/dev/sos.
- Non importare codice GAS come runtime applicativo.
- I file in docs/legacy-gas/ sono solo riferimento funzionale.
- La nuova app vive in backend/, frontend/, db/, tests/e2e/.

## Stack iniziale

- Backend: Node.js + Fastify + TypeScript.
- Database: MariaDB/MySQL.
- ORM: Prisma.
- Frontend: Vue 3 + TypeScript + Vite.
- Test E2E: Playwright.
- Ambiente locale: Docker Compose.

## Modalità Codex

- Leggere prima SPEC_SUMMARY.md, PROJECT_SPEC.md, DATABASE.md, ARCHITECTURE.md, CONTEXT_MAP.md, PROGRESS.md.
- Usare docs/legacy-gas/ solo quando serve confrontare comportamento storico.
- Procedere in step piccoli.
- Non fare refactor ampi senza richiesta.
- Non eseguire deploy o cancellazioni dati senza conferma.
- Aggiornare PROGRESS.md a fine step.
