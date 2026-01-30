import { test, expect } from '@playwright/test';

test.describe('Analytics', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/analytics');
    await page.waitForLoadState('domcontentloaded');
    // Wait for loading to complete
    await page.waitForFunction(() => {
      const spinner = document.querySelector('.animate-spin');
      return !spinner;
    }, { timeout: 30000 }).catch(() => {});
  });

  test.describe('Page Layout', () => {
    test('should display analytics page heading', async ({ page }) => {
      await expect(page.locator('h1')).toContainText(/analytics/i);
    });

    test('should display business insights text', async ({ page }) => {
      await expect(page.getByText(/business insights/i)).toBeVisible({ timeout: 15000 });
    });

    test('should display date range selector', async ({ page }) => {
      // Look for the select trigger button
      const selector = page.locator('button[role="combobox"], [data-radix-collection-item]').first();
      await expect(selector).toBeVisible({ timeout: 15000 });
    });

    test('should display Bookings and Revenue tabs', async ({ page }) => {
      await expect(page.locator('[role="tab"]').filter({ hasText: /bookings/i })).toBeVisible({ timeout: 15000 });
      await expect(page.locator('[role="tab"]').filter({ hasText: /revenue/i })).toBeVisible({ timeout: 15000 });
    });
  });

  test.describe('Date Range Selection', () => {
    test('should change date range when selecting 7 days', async ({ page }) => {
      const combobox = page.locator('button[role="combobox"]').first();
      await combobox.click();
      await page.locator('[role="option"]').filter({ hasText: /7 days/i }).click();
      await page.waitForLoadState('networkidle');
      // Verify selection changed
      await expect(combobox).toContainText(/7/);
    });

    test('should change date range when selecting 90 days', async ({ page }) => {
      const combobox = page.locator('button[role="combobox"]').first();
      await combobox.click();
      await page.locator('[role="option"]').filter({ hasText: /90 days/i }).click();
      await page.waitForLoadState('networkidle');
      await expect(combobox).toContainText(/90/);
    });
  });

  test.describe('Bookings Tab', () => {
    test('should display Total Bookings card', async ({ page }) => {
      await expect(page.getByText(/total bookings/i).first()).toBeVisible({ timeout: 20000 });
    });

    test('should display Completion Rate card', async ({ page }) => {
      await expect(page.getByText(/completion rate/i)).toBeVisible({ timeout: 20000 });
    });

    test('should display Cancellation Rate card', async ({ page }) => {
      await expect(page.getByText(/cancellation rate/i)).toBeVisible({ timeout: 20000 });
    });

    test('should display Daily Bookings chart section', async ({ page }) => {
      await expect(page.getByText(/daily bookings/i).first()).toBeVisible({ timeout: 20000 });
    });

    test('should display Bookings by Status chart section', async ({ page }) => {
      await expect(page.getByText(/bookings by status/i)).toBeVisible({ timeout: 20000 });
    });
  });

  test.describe('Revenue Tab', () => {
    test.beforeEach(async ({ page }) => {
      // Click on Revenue tab
      await page.locator('[role="tab"]').filter({ hasText: /revenue/i }).click();
      await page.waitForTimeout(1000);
    });

    test('should switch to Revenue tab', async ({ page }) => {
      const revenueTab = page.locator('[role="tab"]').filter({ hasText: /revenue/i });
      await expect(revenueTab).toHaveAttribute('data-state', 'active');
    });

    test('should display Total Revenue card', async ({ page }) => {
      await expect(page.getByText(/total revenue/i).first()).toBeVisible({ timeout: 20000 });
    });

    test('should display Avg Booking Value card', async ({ page }) => {
      await expect(page.getByText(/avg booking value/i)).toBeVisible({ timeout: 20000 });
    });

    test('should display Daily Revenue chart section', async ({ page }) => {
      await expect(page.getByText(/daily revenue/i).first()).toBeVisible({ timeout: 20000 });
    });

    test('should display rupee symbol in revenue values', async ({ page }) => {
      await expect(page.getByText(/₹/).first()).toBeVisible({ timeout: 20000 });
    });
  });

  test.describe('Tab Switching', () => {
    test('should maintain date range when switching tabs', async ({ page }) => {
      // Change to 90 days
      const combobox = page.locator('button[role="combobox"]').first();
      await combobox.click();
      await page.locator('[role="option"]').filter({ hasText: /90 days/i }).click();
      await page.waitForTimeout(1000);

      // Switch to Revenue tab
      await page.locator('[role="tab"]').filter({ hasText: /revenue/i }).click();
      await page.waitForTimeout(1000);

      // Date range should still be 90 days
      await expect(combobox).toContainText(/90/);

      // Switch back to Bookings tab
      await page.locator('[role="tab"]').filter({ hasText: /bookings/i }).click();
      await page.waitForTimeout(1000);

      // Date range should still be 90 days
      await expect(combobox).toContainText(/90/);
    });
  });

  test.describe('Responsiveness', () => {
    test('should display correctly on tablet viewport', async ({ page }) => {
      await page.setViewportSize({ width: 768, height: 1024 });
      await page.reload();
      await page.waitForLoadState('domcontentloaded');

      await expect(page.locator('h1')).toContainText(/analytics/i);
    });

    test('should display correctly on mobile viewport', async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });
      await page.reload();
      await page.waitForLoadState('domcontentloaded');

      await expect(page.locator('h1')).toContainText(/analytics/i);
    });
  });
});
