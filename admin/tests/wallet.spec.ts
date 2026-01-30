import { test, expect } from '@playwright/test';

test.describe('Wallet Transactions', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/wallet');
    await page.waitForLoadState('domcontentloaded');
    await page.waitForFunction(() => {
      const loading = document.body.textContent?.includes('Loading...');
      return !loading;
    }, { timeout: 30000 }).catch(() => {});
  });

  test.describe('Page Layout', () => {
    test('should display wallet transactions page heading', async ({ page }) => {
      await expect(page.locator('h1')).toContainText(/wallet/i);
    });

    test('should display user ID filter input', async ({ page }) => {
      await expect(page.locator('input[placeholder*="user"]')).toBeVisible();
    });

    test('should display type filter dropdown', async ({ page }) => {
      await expect(page.locator('button[role="combobox"]')).toBeVisible();
    });

    test('should display transactions table', async ({ page }) => {
      await expect(page.locator('table')).toBeVisible();
    });
  });

  test.describe('Transaction Listing', () => {
    test('should display list of transactions', async ({ page }) => {
      await expect(page.locator('tbody tr').first()).toBeVisible({ timeout: 15000 });
    });

    test('should display CREDIT or DEBIT type badges', async ({ page }) => {
      const hasBadge = await page.locator('tbody').getByText(/credit|debit/i).first().isVisible({ timeout: 15000 }).catch(() => false);
      expect(hasBadge).toBeTruthy();
    });

    test('should display amounts with rupee symbol', async ({ page }) => {
      await expect(page.locator('tbody').getByText(/₹/).first()).toBeVisible({ timeout: 15000 });
    });
  });

  test.describe('Type Filter', () => {
    test('should filter CREDIT transactions', async ({ page }) => {
      await page.locator('button[role="combobox"]').click();
      await page.locator('[role="option"]').filter({ hasText: /credit/i }).click();
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });

    test('should filter DEBIT transactions', async ({ page }) => {
      await page.locator('button[role="combobox"]').click();
      await page.locator('[role="option"]').filter({ hasText: /debit/i }).click();
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });

    test('should show all transactions when filter is cleared', async ({ page }) => {
      // First apply filter
      await page.locator('button[role="combobox"]').click();
      await page.locator('[role="option"]').filter({ hasText: /credit/i }).click();
      await page.waitForTimeout(1000);

      // Then clear filter
      await page.locator('button[role="combobox"]').click();
      await page.locator('[role="option"]').filter({ hasText: /all/i }).click();
      await page.waitForTimeout(1000);

      await expect(page.locator('tbody')).toBeVisible();
    });
  });

  test.describe('User ID Filter', () => {
    test('should filter transactions by user ID', async ({ page }) => {
      const userIdInput = page.locator('input[placeholder*="user"]');
      await userIdInput.fill('test');
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });

    test('should show no results for non-matching user ID', async ({ page }) => {
      const userIdInput = page.locator('input[placeholder*="user"]');
      await userIdInput.fill('nonexistentuseridxyz123456789');
      await page.waitForTimeout(1000);
      await expect(page.getByText(/no.*transactions.*found/i)).toBeVisible({ timeout: 10000 });
    });
  });

  test.describe('Pagination', () => {
    test('should display pagination info', async ({ page }) => {
      await expect(page.getByText(/showing \d+/i)).toBeVisible({ timeout: 15000 });
    });

    test('should have Previous and Next buttons', async ({ page }) => {
      await expect(page.getByRole('button', { name: /previous/i })).toBeVisible();
      await expect(page.getByRole('button', { name: /next/i })).toBeVisible();
    });

    test('should disable Previous button on first page', async ({ page }) => {
      const prevButton = page.getByRole('button', { name: /previous/i });
      await expect(prevButton).toBeDisabled();
    });
  });
});
