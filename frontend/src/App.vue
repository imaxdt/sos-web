<script setup lang="ts">
const appName = 'SOS Web'
</script>

<template>
  <main class="app-shell">
    <section class="hero-card">
      <p class="eyebrow">Nuova web app + DB</p>
      <h1>{{ appName }}</h1>
      <p>
        Ambiente iniziale pronto: frontend Vue, backend Fastify, MariaDB, Prisma e Playwright.
      </p>
      <a href="http://localhost:3000/health" target="_blank" rel="noreferrer">
        Verifica backend health
      </a>
    </section>
  </main>
</template>

<style scoped>
.app-shell {
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 2rem;
  background: #f5f7fb;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

.hero-card {
  max-width: 720px;
  padding: 2rem;
  border-radius: 24px;
  background: white;
  box-shadow: 0 20px 60px rgba(15, 23, 42, 0.12);
}

.eyebrow {
  text-transform: uppercase;
  letter-spacing: .12em;
  font-weight: 700;
  color: #2563eb;
}

h1 {
  margin: 0 0 1rem;
  font-size: clamp(2rem, 5vw, 4rem);
}

p {
  color: #475569;
  line-height: 1.6;
}

a {
  display: inline-flex;
  margin-top: 1rem;
  color: #2563eb;
  font-weight: 700;
}
</style>
