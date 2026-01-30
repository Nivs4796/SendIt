import { test as setup, expect } from '@playwright/test';
import { TEST_CREDENTIALS } from './utils/auth';

const authFile = 'tests/.auth/admin.json';

setup('authenticate as admin', async ({ page }) => {
  // Navigate to login page
  await page.goto('/login');
  await page.waitForLoadState('domcontentloaded');

  // Wait for the form to be ready
  await expect(page.locator('#email')).toBeVisible({ timeout: 10000 });

  // Fill in credentials using ID selectors
  await page.locator('#email').fill(TEST_CREDENTIALS.email);
  await page.locator('#password').fill(TEST_CREDENTIALS.password);

  // Click login button
  await page.locator('button[type="submit"]').click();

  // Wait for successful login - redirect to dashboard or error
  try {
    await page.waitForURL(/dashboard/, { timeout: 30000 });
    // Verify login was successful
    await expect(page).toHaveURL(/dashboard/);
  } catch {
    // Check if there's an error message
    const errorVisible = await page.locator('.text-destructive').isVisible();
    if (errorVisible) {
      const errorText = await page.locator('.text-destructive').textContent();
      throw new Error(`Login failed with error: ${errorText}`);
    }
    throw new Error('Login failed - did not redirect to dashboard');
  }

  // Save storage state (cookies, localStorage, etc.)
  await page.context().storageState({ path: authFile });
});
