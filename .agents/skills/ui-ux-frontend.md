# Skill - UI/UX Frontend

## Quando usarla

Usala per `html/Index.html`, CSS, JavaScript client inline, componenti UI, sidebar, topbar, dashboard, form, tabelle, wizard, modali, toast e stati vuoti.

## Contesto minimo

- `AGENTS.md`
- `SPEC_SUMMARY.md`
- `PROGRESS.md`
- `UI_GUIDELINES.md`
- `ARCHITECTURE.md`
- `TESTING.md`
- Mockup in `mockup/` solo se lo step riguarda layout o visual design

## Regole

- Segui il linguaggio visuale esistente del progetto.
- Non introdurre framework complessi non previsti.
- Non creare sezioni decorative non operative.
- Preserva `viewAs` e `runAs` nei flussi admin.
- Evita pagina bianca dopo azioni `google.script.run`.
- Verifica stati errore, stati vuoti, loading e feedback utente.
- Usa microcopy corrente: "attività di recupero", "lezione", "iscrizione", non "slot/prenotazione" salvo legacy.

## Chiusura

Aggiorna `PROGRESS.md`, `UI_GUIDELINES.md` se nasce un pattern riusabile, e `TESTING.md` o `TEST_PLAN.md` se cambiano scenari UI.
