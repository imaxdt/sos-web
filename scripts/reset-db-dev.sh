#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo "ATTENZIONE: questo comando elimina il volume database locale."
read -r -p "Continuare? Scrivi SI: " confirm
if [ "$confirm" != "SI" ]; then
  echo "Annullato."
  exit 1
fi
docker compose down -v
docker compose up -d db
npm run db:migrate
