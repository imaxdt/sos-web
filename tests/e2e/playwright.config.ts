import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './specs',
  timeout: 30_000,
  expect: {
    timeout: 5_000
  },
  use: {
    baseURL: process.env.E2E_BASE_URL ?? 'http://localhost:5173',
    trace: 'on-first-retry'
  },
  webServer: [
    {
      command: 'cd ../.. && npm run dev -w backend',
      url: 'http://localhost:3000/health',
      reuseExistingServer: true,
      timeout: 120_000
    },
    {
      command: 'cd ../.. && npm run dev -w frontend',
      url: 'http://localhost:5173',
      reuseExistingServer: true,
      timeout: 120_000
    }
  ],
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] }
    }
  ]
});
