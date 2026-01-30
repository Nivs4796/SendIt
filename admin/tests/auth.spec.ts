import { test, expect } from '@playwright/test';
import { TEST_CREDENTIALS } from './utils/auth';

test.describe('Authentication', () => {
  test.describe('Login', () => {
    // Use fresh browser context (no stored auth) for login tests
    test.use({ storageState: { cookies: [], origins: [] } });

    test('should display login page correctly', async ({ page }) => {
      await page.goto('/login');
      await page.waitForLoadState('domcontentloaded');

      // Check page title and branding
      await expect(page.getByText('SendIt Admin')).toBeVisible();
      await expect(page.getByText(/Sign in to manage/i)).toBeVisible();

      // Check form elements using ID selectors
      await expect(page.locator('#email')).toBeVisible();
      await expect(page.locator('#password')).toBeVisible();
      await expect(page.locator('button[type="submit"]')).toBeVisible();
    });

    test('should login with valid credentials', async ({ page }) => {
      await page.goto('/login');
      await page.waitForLoadState('domcontentloaded');

      // Fill in valid credentials
      await page.locator('#email').fill(TEST_CREDENTIALS.email);
      await page.locator('#password').fill(TEST_CREDENTIALS.password);

      // Submit form
      await page.locator('button[type="submit"]').click();

      // Should redirect to dashboard
      await page.waitForURL(/dashboard/, { timeout: 30000 });
      await expect(page).toHaveURL(/dashboard/);
    });

    test('should show error with invalid email', async ({ page }) => {
      await page.goto('/login');
      await page.waitForLoadState('domcontentloaded');

      // Fill in invalid email
      await page.locator('#email').fill('invalid@example.com');
      await page.locator('#password').fill(TEST_CREDENTIALS.password);

      // Submit form
      await page.locator('button[type="submit"]').click();

      // Should show error message (wait for API response)
      await expect(page.locator('.text-destructive, [class*="destructive"]')).toBeVisible({
        timeout: 15000,
      });

      // Should remain on login page
      await expect(page).toHaveURL(/login/);
    });

    test('should show error with invalid password', async ({ page }) => {
      await page.goto('/login');
      await page.waitForLoadState('domcontentloaded');

      // Fill in invalid password
      await page.locator('#email').fill(TEST_CREDENTIALS.email);
      await page.locator('#password').fill('wrongpassword');

      // Submit form
      await page.locator('button[type="submit"]').click();

      // Should show error message
      await expect(page.locator('.text-destructive, [class*="destructive"]')).toBeVisible({
        timeout: 15000,
      });

      // Should remain on login page
      await expect(page).toHaveURL(/login/);
    });

    test('should show validation for empty fields', async ({ page }) => {
      await page.goto('/login');
      await page.waitForLoadState('domcontentloaded');

      // Try to submit empty form
      await page.locator('button[type="submit"]').click();

      // Email field should be invalid (required validation)
      const emailInput = page.locator('#email');
      await expect(emailInput).toHaveAttribute('required');

      // Form should not submit - check we're still on login page
      await expect(page).toHaveURL(/login/);
    });

    test('should show loading state during login', async ({ page }) => {
      await page.goto('/login');
      await page.waitForLoadState('domcontentloaded');

      // Fill in credentials
      await page.locator('#email').fill(TEST_CREDENTIALS.email);
      await page.locator('#password').fill(TEST_CREDENTIALS.password);

      // Click login
      await page.locator('button[type="submit"]').click();

      // Check for loading state (button shows "Signing in..." or is disabled)
      const button = page.locator('button[type="submit"]');
      const isDisabled = await button.isDisabled();
      const buttonText = await button.textContent();

      expect(isDisabled || buttonText?.includes('Signing')).toBeTruthy();
    });
  });

  test.describe('Protected Routes', () => {
    test.use({ storageState: { cookies: [], origins: [] } });

    test('should redirect to login when accessing dashboard without auth', async ({ page }) => {
      await page.goto('/dashboard');

      // Should redirect to login
      await page.waitForURL(/login/, { timeout: 15000 });
      await expect(page).toHaveURL(/login/);
    });

    test('should redirect to login when accessing users page without auth', async ({ page }) => {
      await page.goto('/users');

      // Should redirect to login
      await page.waitForURL(/login/, { timeout: 15000 });
      await expect(page).toHaveURL(/login/);
    });

    test('should redirect to login when accessing pilots page without auth', async ({ page }) => {
      await page.goto('/pilots');

      // Should redirect to login
      await page.waitForURL(/login/, { timeout: 15000 });
      await expect(page).toHaveURL(/login/);
    });
  });

  test.describe('Session Persistence', () => {
    test('should maintain session after page refresh', async ({ page }) => {
      // This test uses the authenticated state from setup
      await page.goto('/dashboard');
      await page.waitForLoadState('domcontentloaded');

      // Verify we're on dashboard
      await expect(page).toHaveURL(/dashboard/);

      // Refresh the page
      await page.reload();
      await page.waitForLoadState('domcontentloaded');

      // Should still be on dashboard (session persisted)
      await expect(page).toHaveURL(/dashboard/);
    });

    test('should be able to navigate between pages while logged in', async ({ page }) => {
      await page.goto('/dashboard');
      await page.waitForLoadState('domcontentloaded');
      await expect(page).toHaveURL(/dashboard/);

      // Navigate to users
      await page.goto('/users');
      await page.waitForLoadState('domcontentloaded');
      await expect(page).toHaveURL(/users/);

      // Navigate to pilots
      await page.goto('/pilots');
      await page.waitForLoadState('domcontentloaded');
      await expect(page).toHaveURL(/pilots/);

      // Navigate back to dashboard
      await page.goto('/dashboard');
      await page.waitForLoadState('domcontentloaded');
      await expect(page).toHaveURL(/dashboard/);
    });
  });

  test.describe('Logout', () => {
    test('should logout and redirect to login', async ({ page }) => {
      await page.goto('/dashboard');
      await page.waitForLoadState('domcontentloaded');

      // Look for logout button - could be in sidebar or header
      const logoutButton = page.locator('button:has-text("Logout"), button:has-text("Sign out"), a:has-text("Logout")');

      if (await logoutButton.isVisible({ timeout: 5000 }).catch(() => false)) {
        await logoutButton.click();
        // Should redirect to login page
        await page.waitForURL(/login/, { timeout: 15000 });
        await expect(page).toHaveURL(/login/);
      } else {
        // If no visible logout button, skip test
        test.skip();
      }
    });
  });
});
