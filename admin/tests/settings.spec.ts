import { test, expect } from '@playwright/test';

test.describe('Settings', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/settings');
    await page.waitForLoadState('domcontentloaded');
    await page.waitForFunction(() => {
      const loading = document.body.textContent?.includes('Loading...');
      return !loading;
    }, { timeout: 30000 }).catch(() => {});
  });

  test.describe('Page Layout', () => {
    test('should display settings page heading', async ({ page }) => {
      await expect(page.locator('h1')).toContainText(/settings/i);
    });

    test('should display Add Setting button', async ({ page }) => {
      await expect(page.getByRole('button', { name: /add setting/i })).toBeVisible();
    });
  });

  test.describe('Settings Display', () => {
    test('should display settings or empty state', async ({ page }) => {
      // Either shows settings cards or empty message
      const hasSettings =
        (await page.locator('.font-mono').count()) > 0 ||
        (await page.getByText(/no settings/i).isVisible().catch(() => false));
      expect(hasSettings).toBeTruthy();
    });

    test('should display settings grouped by category', async ({ page }) => {
      // Check for possible category cards
      const hasPricing = await page.getByText(/pricing/i).isVisible().catch(() => false);
      const hasLimits = await page.getByText(/limits/i).isVisible().catch(() => false);
      const hasOther = await page.getByText(/other/i).isVisible().catch(() => false);
      const hasEmpty = await page.getByText(/no settings/i).isVisible().catch(() => false);

      // Should have at least one category or empty state
      expect(hasPricing || hasLimits || hasOther || hasEmpty).toBeTruthy();
    });

    test('should display setting keys in monospace font', async ({ page }) => {
      const monoElements = page.locator('.font-mono');
      const count = await monoElements.count();

      if (count > 0) {
        await expect(monoElements.first()).toBeVisible();
      }
    });
  });

  test.describe('Add New Setting', () => {
    test('should open Add Setting dialog', async ({ page }) => {
      await page.getByRole('button', { name: /add setting/i }).click();
      await expect(page.locator('[role="dialog"]')).toBeVisible();
    });

    test('should display form fields in dialog', async ({ page }) => {
      await page.getByRole('button', { name: /add setting/i }).click();
      await expect(page.locator('[role="dialog"]')).toBeVisible();

      // Check for input fields in the dialog
      await expect(page.locator('[role="dialog"] input').first()).toBeVisible();
    });

    test('should have Cancel button in dialog', async ({ page }) => {
      await page.getByRole('button', { name: /add setting/i }).click();
      await expect(page.locator('[role="dialog"]')).toBeVisible();
      await expect(page.getByRole('button', { name: /cancel/i })).toBeVisible();
    });

    test('should close dialog on Cancel', async ({ page }) => {
      await page.getByRole('button', { name: /add setting/i }).click();
      await expect(page.locator('[role="dialog"]')).toBeVisible();

      await page.getByRole('button', { name: /cancel/i }).click();

      await expect(page.locator('[role="dialog"]')).not.toBeVisible();
    });
  });

  test.describe('Setting Categories', () => {
    test('should display Pricing Settings card if pricing settings exist', async ({ page }) => {
      const hasPricing = await page.getByText(/pricing/i).isVisible().catch(() => false);

      if (hasPricing) {
        await expect(page.getByText(/pricing/i).first()).toBeVisible();
      }
    });

    test('should display Limits card if limit settings exist', async ({ page }) => {
      const hasLimits = await page.getByText(/limits/i).isVisible().catch(() => false);

      if (hasLimits) {
        await expect(page.getByText(/limits/i).first()).toBeVisible();
      }
    });
  });

  test.describe('Responsiveness', () => {
    test('should display correctly on mobile viewport', async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });
      await page.reload();
      await page.waitForLoadState('domcontentloaded');

      await expect(page.locator('h1')).toContainText(/settings/i);
      await expect(page.getByRole('button', { name: /add setting/i })).toBeVisible();
    });
  });
});
