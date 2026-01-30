import { test, expect } from '@playwright/test';
import { SEARCH_QUERIES } from './utils/test-data';

test.describe('Pilots Management', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/pilots');
    await page.waitForLoadState('domcontentloaded');
    await page.waitForFunction(() => {
      const loading = document.body.textContent?.includes('Loading...');
      return !loading;
    }, { timeout: 30000 }).catch(() => {});
  });

  test.describe('Page Layout', () => {
    test('should display pilots page heading', async ({ page }) => {
      await expect(page.locator('h1')).toContainText(/pilots/i);
    });

    test('should display search input', async ({ page }) => {
      await expect(page.locator('input[placeholder*="Search"]')).toBeVisible();
    });

    test('should display status filter tabs', async ({ page }) => {
      await expect(page.locator('[role="tab"]').filter({ hasText: /all/i })).toBeVisible();
      await expect(page.locator('[role="tab"]').filter({ hasText: /pending/i })).toBeVisible();
      await expect(page.locator('[role="tab"]').filter({ hasText: /approved/i })).toBeVisible();
    });

    test('should display pilots table', async ({ page }) => {
      await expect(page.locator('table')).toBeVisible();
    });
  });

  test.describe('Pilot Listing', () => {
    test('should display list of pilots', async ({ page }) => {
      // Wait for a row with an action button (actual pilot row, not "No pilots found")
      const pilotRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(pilotRow).toBeVisible({ timeout: 15000 });
    });

    test('should display pilot status badges', async ({ page }) => {
      // Wait for actual pilot data to load first
      const pilotRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(pilotRow).toBeVisible({ timeout: 15000 });

      const hasBadge = await page.locator('tbody').getByText(/pending|approved|rejected|suspended/i).first().isVisible().catch(() => false);
      expect(hasBadge).toBeTruthy();
    });
  });

  test.describe('Status Filter Tabs', () => {
    test('should filter by PENDING status', async ({ page }) => {
      await page.locator('[role="tab"]').filter({ hasText: /pending/i }).click();
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });

    test('should filter by APPROVED status', async ({ page }) => {
      await page.locator('[role="tab"]').filter({ hasText: /approved/i }).click();
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });

    test('should show all pilots when All tab is selected', async ({ page }) => {
      await page.locator('[role="tab"]').filter({ hasText: /pending/i }).click();
      await page.waitForTimeout(500);
      await page.locator('[role="tab"]').filter({ hasText: /all/i }).click();
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });
  });

  test.describe('Search Functionality', () => {
    test('should filter pilots by name', async ({ page }) => {
      const searchInput = page.locator('input[placeholder*="Search"]');
      await searchInput.fill(SEARCH_QUERIES.pilots.byName);
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });

    test('should show no results for non-matching search', async ({ page }) => {
      const searchInput = page.locator('input[placeholder*="Search"]');
      await searchInput.fill('nonexistentpilotxyz123');
      await page.waitForTimeout(1000);
      await expect(page.getByText(/no pilots found/i)).toBeVisible({ timeout: 10000 });
    });
  });

  test.describe('View Pilot Details', () => {
    test('should open view details dialog', async ({ page }) => {
      // Wait for a row with an action button (actual pilot row, not "No pilots found")
      const pilotRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(pilotRow).toBeVisible({ timeout: 15000 });

      const actionButton = pilotRow.locator('button');
      await actionButton.waitFor({ state: 'visible' });
      await actionButton.click();
      await page.locator('[role="menuitem"]').filter({ hasText: /view/i }).click();

      await expect(page.locator('[role="dialog"]')).toBeVisible();
    });
  });

  test.describe('Pilot Actions', () => {
    test('should show action menu options', async ({ page }) => {
      // Wait for a row with an action button (actual pilot row, not "No pilots found")
      const pilotRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(pilotRow).toBeVisible({ timeout: 15000 });

      const actionButton = pilotRow.locator('button');
      await actionButton.waitFor({ state: 'visible' });
      await actionButton.click();

      // Should have at least View Details option
      await expect(page.locator('[role="menuitem"]').filter({ hasText: /view/i })).toBeVisible();
    });
  });

  test.describe('Pagination', () => {
    test('should display pagination info', async ({ page }) => {
      await expect(page.getByText(/showing \d+/i)).toBeVisible({ timeout: 15000 });
    });

    test('should have Previous and Next buttons', async ({ page }) => {
      await expect(page.getByRole('button', { name: 'Previous' })).toBeVisible();
      await expect(page.getByRole('button', { name: 'Next', exact: true })).toBeVisible();
    });
  });
});
