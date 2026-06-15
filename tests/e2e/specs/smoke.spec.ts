import { test, expect } from '@playwright/test';

test('homepage smoke', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: 'SOS Web' })).toBeVisible();
  await expect(page.getByText('Nuova web app + DB')).toBeVisible();
});
