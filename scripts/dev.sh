#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
cp --update=none .env.example .env 2>/dev/null || cp -n .env.example .env
docker compose up -d
npm run dev
