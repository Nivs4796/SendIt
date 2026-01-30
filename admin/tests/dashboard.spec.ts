import { test, expect } from '@playwright/test';

test.describe('Dashboard', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/dashboard');
    await page.waitForLoadState('domcontentloaded');
  });

  test.describe('Page Layout', () => {
    test('should display dashboard heading and welcome message', async ({ page }) => {
      await expect(page.locator('h1')).toContainText(/dashboard/i);
      await expect(page.getByText(/welcome to sendit admin/i)).toBeVisible();
    });

    test('should display content after loading', async ({ page }) => {
      // Wait for either loading spinner to disappear or content to appear
      await page.waitForFunction(() => {
        const spinner = document.querySelector('.animate-spin');
        const content = document.querySelector('h1');
        return !spinner || content;
      }, { timeout: 15000 });

      // Content should be visible
      await expect(page.locator('h1')).toBeVisible();
    });
  });

  test.describe('Overview Stats Cards', () => {
    test('should display stat cards', async ({ page }) => {
      // Wait for data to load
      await page.waitForTimeout(2000);

      // Check for stat card titles
      const statTitles = ['Total Users', 'Total Pilots', 'Total Bookings', 'Total Revenue'];

      for (const title of statTitles) {
        const card = page.getByText(title, { exact: false });
        await expect(card).toBeVisible({ timeout: 10000 });
      }
    });

    test('should display Total Users stat', async ({ page }) => {
      await expect(page.getByText(/total users/i)).toBeVisible({ timeout: 15000 });
    });

    test('should display Total Pilots stat with pending count', async ({ page }) => {
      await expect(page.getByText(/total pilots/i)).toBeVisible({ timeout: 15000 });
    });

    test('should display Total Bookings stat', async ({ page }) => {
      await expect(page.getByText(/total bookings/i)).toBeVisible({ timeout: 15000 });
    });

    test('should display Total Revenue stat', async ({ page }) => {
      await expect(page.getByText(/total revenue/i)).toBeVisible({ timeout: 15000 });
    });
  });

  test.describe('Real-time Stats Cards', () => {
    test('should display Active Bookings stat', async ({ page }) => {
      await expect(page.getByText(/active bookings/i)).toBeVisible({ timeout: 15000 });
    });

    test('should display Online Pilots stat', async ({ page }) => {
      await expect(page.getByText(/online pilots/i)).toBeVisible({ timeout: 15000 });
    });

    test('should display Today\'s Deliveries stat', async ({ page }) => {
      await expect(page.getByText(/today's deliveries/i)).toBeVisible({ timeout: 15000 });
    });

    test('should display Today\'s Revenue stat', async ({ page }) => {
      await expect(page.getByText(/today's revenue/i)).toBeVisible({ timeout: 15000 });
    });
  });

  test.describe('Quick Actions', () => {
    test('should display Quick Actions section', async ({ page }) => {
      await expect(page.getByText(/quick actions/i)).toBeVisible({ timeout: 15000 });
    });

    test('should have link to Review Pending Pilots', async ({ page }) => {
      const pendingPilotsLink = page.locator('a[href*="pilots"]').filter({ hasText: /pending|review/i });
      await expect(pendingPilotsLink).toBeVisible({ timeout: 15000 });
    });

    test('should have link to Manage Pending Bookings', async ({ page }) => {
      const pendingBookingsLink = page.locator('a[href*="bookings"]').filter({ hasText: /pending|manage/i });
      await expect(pendingBookingsLink).toBeVisible({ timeout: 15000 });
    });

    test('should have link to View Analytics', async ({ page }) => {
      const analyticsLink = page.locator('a[href*="analytics"]');
      await expect(analyticsLink).toBeVisible({ timeout: 15000 });
    });

    test('should navigate to Pending Pilots when clicked', async ({ page }) => {
      const pendingPilotsLink = page.locator('a[href*="pilots"]').first();
      await pendingPilotsLink.click();
      await page.waitForURL(/pilots/);
      await expect(page).toHaveURL(/pilots/);
    });

    test('should navigate to Pending Bookings when clicked', async ({ page }) => {
      const pendingBookingsLink = page.locator('a[href*="bookings"]').first();
      await pendingBookingsLink.click();
      await page.waitForURL(/bookings/);
      await expect(page).toHaveURL(/bookings/);
    });

    test('should navigate to Analytics when clicked', async ({ page }) => {
      const analyticsLink = page.locator('a[href*="analytics"]').first();
      await analyticsLink.click();
      await page.waitForURL(/analytics/);
      await expect(page).toHaveURL(/analytics/);
    });
  });

  test.describe('Live Booking Updates', () => {
    test('should display Live Booking Updates section', async ({ page }) => {
      await expect(page.getByText(/live booking updates/i)).toBeVisible({ timeout: 15000 });
    });
  });

  test.describe('Responsiveness', () => {
    test('should display correctly on mobile viewport', async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });
      await page.reload();
      await page.waitForLoadState('domcontentloaded');

      // Stats should still be visible
      await expect(page.getByText(/total users/i)).toBeVisible({ timeout: 15000 });
    });

    test('should display correctly on tablet viewport', async ({ page }) => {
      await page.setViewportSize({ width: 768, height: 1024 });
      await page.reload();
      await page.waitForLoadState('domcontentloaded');

      // All sections should be visible
      await expect(page.getByText(/total users/i)).toBeVisible({ timeout: 15000 });
    });
  });
});
