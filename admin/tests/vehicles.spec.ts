import { test, expect } from '@playwright/test';
import { SEARCH_QUERIES } from './utils/test-data';

test.describe('Vehicles Management', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/vehicles');
    await page.waitForLoadState('domcontentloaded');
    await page.waitForFunction(() => {
      const loading = document.body.textContent?.includes('Loading...');
      return !loading;
    }, { timeout: 30000 }).catch(() => {});
  });

  test.describe('Page Layout', () => {
    test('should display vehicles page heading', async ({ page }) => {
      await expect(page.locator('h1')).toContainText(/vehicles/i);
    });

    test('should display search input', async ({ page }) => {
      await expect(page.locator('input[placeholder*="Search"]')).toBeVisible();
    });

    test('should display verification filter dropdown', async ({ page }) => {
      await expect(page.locator('button[role="combobox"]')).toBeVisible();
    });

    test('should display vehicles table', async ({ page }) => {
      await expect(page.locator('table')).toBeVisible();
    });
  });

  test.describe('Vehicle Listing', () => {
    test('should display list of vehicles', async ({ page }) => {
      await expect(page.locator('tbody tr').first()).toBeVisible({ timeout: 15000 });
    });

    test('should display verification status badges', async ({ page }) => {
      const hasBadge = await page.locator('tbody').getByText(/verified|pending/i).first().isVisible({ timeout: 15000 }).catch(() => false);
      expect(hasBadge).toBeTruthy();
    });
  });

  test.describe('Verification Filter', () => {
    test('should filter verified vehicles', async ({ page }) => {
      await page.locator('button[role="combobox"]').click();
      await page.locator('[role="option"]').filter({ hasText: /^verified$/i }).click();
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });

    test('should filter pending vehicles', async ({ page }) => {
      await page.locator('button[role="combobox"]').click();
      await page.locator('[role="option"]').filter({ hasText: /pending/i }).click();
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });
  });

  test.describe('Search Functionality', () => {
    test('should filter vehicles by plate number', async ({ page }) => {
      const searchInput = page.locator('input[placeholder*="Search"]');
      await searchInput.fill(SEARCH_QUERIES.vehicles.byPlate);
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });

    test('should show no results for non-matching search', async ({ page }) => {
      const searchInput = page.locator('input[placeholder*="Search"]');
      await searchInput.fill('nonexistentvehiclexyz123');
      await page.waitForTimeout(1000);
      await expect(page.getByText(/no vehicles found/i)).toBeVisible({ timeout: 10000 });
    });
  });

  test.describe('View Vehicle Details', () => {
    test('should open view details dialog', async ({ page }) => {
      await expect(page.locator('tbody tr').first()).toBeVisible({ timeout: 15000 });
      await page.locator('tbody tr').first().locator('button').click();
      await page.locator('[role="menuitem"]').filter({ hasText: /view/i }).click();

      await expect(page.locator('[role="dialog"]')).toBeVisible();
    });
  });

  test.describe('Vehicle Actions', () => {
    test('should show action menu options', async ({ page }) => {
      await expect(page.locator('tbody tr').first()).toBeVisible({ timeout: 15000 });
      await page.locator('tbody tr').first().locator('button').click();

      await expect(page.locator('[role="menuitem"]').filter({ hasText: /view/i })).toBeVisible();
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
  });
});
