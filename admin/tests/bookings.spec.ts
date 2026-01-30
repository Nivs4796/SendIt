import { test, expect } from '@playwright/test';

test.describe('Bookings Management', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/bookings');
    await page.waitForLoadState('domcontentloaded');
    await page.waitForFunction(() => {
      const loading = document.body.textContent?.includes('Loading...');
      return !loading;
    }, { timeout: 30000 }).catch(() => {});
  });

  test.describe('Page Layout', () => {
    test('should display bookings page heading', async ({ page }) => {
      await expect(page.locator('h1')).toContainText(/bookings/i);
    });

    test('should display search input', async ({ page }) => {
      await expect(page.locator('input[placeholder*="Search"]')).toBeVisible();
    });

    test('should display status filter tabs', async ({ page }) => {
      await expect(page.locator('[role="tab"]').filter({ hasText: /all/i })).toBeVisible();
      await expect(page.locator('[role="tab"]').filter({ hasText: /pending/i })).toBeVisible();
      await expect(page.locator('[role="tab"]').filter({ hasText: /delivered/i })).toBeVisible();
    });

    test('should display bookings table', async ({ page }) => {
      await expect(page.locator('table')).toBeVisible();
    });
  });

  test.describe('Booking Listing', () => {
    test('should display list of bookings', async ({ page }) => {
      // Wait for a row with an action button (actual booking row, not "No bookings found")
      const bookingRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(bookingRow).toBeVisible({ timeout: 15000 });
    });

    test('should display booking status badges', async ({ page }) => {
      // Wait for actual booking data to load first
      const bookingRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(bookingRow).toBeVisible({ timeout: 15000 });

      const hasBadge = await page.locator('tbody').getByText(/pending|searching|confirmed|in.transit|delivered|cancelled/i).first().isVisible().catch(() => false);
      expect(hasBadge).toBeTruthy();
    });

    test('should display prices in rupee format', async ({ page }) => {
      // Wait for actual booking data to load first
      const bookingRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(bookingRow).toBeVisible({ timeout: 15000 });

      await expect(page.locator('tbody').getByText(/₹/).first()).toBeVisible();
    });
  });

  test.describe('Status Filter Tabs', () => {
    test('should filter by PENDING status', async ({ page }) => {
      await page.locator('[role="tab"]').filter({ hasText: /pending/i }).click();
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });

    test('should filter by DELIVERED status', async ({ page }) => {
      await page.locator('[role="tab"]').filter({ hasText: /delivered/i }).click();
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });

    test('should filter by CANCELLED status', async ({ page }) => {
      await page.locator('[role="tab"]').filter({ hasText: /cancelled/i }).click();
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });
  });

  test.describe('Search Functionality', () => {
    test('should show no results for non-matching search', async ({ page }) => {
      const searchInput = page.locator('input[placeholder*="Search"]');
      await searchInput.fill('nonexistentbookingxyz123');
      await page.waitForTimeout(1000);
      await expect(page.getByText(/no bookings found/i)).toBeVisible({ timeout: 10000 });
    });
  });

  test.describe('View Booking Details', () => {
    test('should open view details dialog', async ({ page }) => {
      // Wait for a row with an action button (actual booking row, not "No bookings found")
      const bookingRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(bookingRow).toBeVisible({ timeout: 15000 });

      const actionButton = bookingRow.locator('button');
      await actionButton.waitFor({ state: 'visible' });
      await actionButton.click();
      await page.locator('[role="menuitem"]').filter({ hasText: /view/i }).click();

      await expect(page.locator('[role="dialog"]')).toBeVisible();
    });

    test('should display booking information in dialog', async ({ page }) => {
      // Wait for a row with an action button (actual booking row, not "No bookings found")
      const bookingRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(bookingRow).toBeVisible({ timeout: 15000 });

      const actionButton = bookingRow.locator('button');
      await actionButton.waitFor({ state: 'visible' });
      await actionButton.click();
      await page.locator('[role="menuitem"]').filter({ hasText: /view/i }).click();

      await expect(page.locator('[role="dialog"]').getByText(/booking id/i)).toBeVisible();
    });
  });

  test.describe('Booking Actions', () => {
    test('should show action menu options', async ({ page }) => {
      // Wait for a row with an action button (actual booking row, not "No bookings found")
      const bookingRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(bookingRow).toBeVisible({ timeout: 15000 });

      const actionButton = bookingRow.locator('button');
      await actionButton.waitFor({ state: 'visible' });
      await actionButton.click();

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
