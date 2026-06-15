# SOS Web

Nuovo progetto web + database SQL per SOS Recuperi.

Il vecchio progetto Google Apps Script resta separato in ~/dev/sos.

## Avvio rapido

Comandi:

    cp .env.example .env
    docker compose up -d
    npm install
    npm run db:migrate
    npm run dev

URL utili:

- Frontend: http://localhost:5173
- Backend health: http://localhost:3000/health
- Backend DB health: http://localhost:3000/health/db
- Adminer: http://localhost:8080
- Mailpit: http://localhost:8025

## Test

    npm run test:e2e

## Regole

I file in docs/legacy-gas/ sono riferimento funzionale storico.
Non modificarli salvo richiesta esplicita.
