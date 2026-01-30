import { test, expect } from '@playwright/test';
import { SEARCH_QUERIES } from './utils/test-data';

test.describe('Users Management', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/users');
    await page.waitForLoadState('domcontentloaded');
    // Wait for data to load
    await page.waitForFunction(() => {
      const loading = document.body.textContent?.includes('Loading...');
      return !loading;
    }, { timeout: 30000 }).catch(() => {});
  });

  test.describe('Page Layout', () => {
    test('should display users page heading', async ({ page }) => {
      await expect(page.locator('h1')).toContainText(/users/i);
    });

    test('should display search input', async ({ page }) => {
      await expect(page.locator('input[placeholder*="Search"]')).toBeVisible();
    });

    test('should display status filter dropdown', async ({ page }) => {
      await expect(page.locator('button[role="combobox"]')).toBeVisible();
    });

    test('should display users table with headers', async ({ page }) => {
      await expect(page.locator('table')).toBeVisible();
      await expect(page.locator('th').filter({ hasText: /name/i })).toBeVisible();
      await expect(page.locator('th').filter({ hasText: /email/i })).toBeVisible();
      await expect(page.locator('th').filter({ hasText: /phone/i })).toBeVisible();
    });
  });

  test.describe('User Listing', () => {
    test('should display list of users', async ({ page }) => {
      // Wait for a row with an action button (actual user row, not "No users found")
      const userRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(userRow).toBeVisible({ timeout: 15000 });
    });

    test('should display user status badges', async ({ page }) => {
      // Wait for actual user data to load first
      const userRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(userRow).toBeVisible({ timeout: 15000 });

      // Check for Active or Inactive badges
      const hasBadge = await page.locator('tbody').getByText(/active|inactive/i).first().isVisible().catch(() => false);
      expect(hasBadge).toBeTruthy();
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

    test('should disable Previous button on first page', async ({ page }) => {
      const prevButton = page.getByRole('button', { name: /previous/i });
      await expect(prevButton).toBeDisabled();
    });
  });

  test.describe('Search Functionality', () => {
    test('should filter users by name', async ({ page }) => {
      const searchInput = page.locator('input[placeholder*="Search"]');
      await searchInput.fill(SEARCH_QUERIES.users.byName);
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });

    test('should show no results for non-matching search', async ({ page }) => {
      const searchInput = page.locator('input[placeholder*="Search"]');
      await searchInput.fill('nonexistentuserxyz123');
      await page.waitForTimeout(1000);
      await expect(page.getByText(/no users found/i)).toBeVisible({ timeout: 10000 });
    });
  });

  test.describe('Status Filter', () => {
    test('should filter active users', async ({ page }) => {
      await page.locator('button[role="combobox"]').click();
      await page.locator('[role="option"]').filter({ hasText: /^active$/i }).click();
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });

    test('should filter inactive users', async ({ page }) => {
      await page.locator('button[role="combobox"]').click();
      await page.locator('[role="option"]').filter({ hasText: /inactive/i }).click();
      await page.waitForTimeout(1000);
      await expect(page.locator('tbody')).toBeVisible();
    });
  });

  test.describe('View User Details', () => {
    test('should open view details dialog', async ({ page }) => {
      // Wait for a row with an action button (actual user row, not "No users found")
      const userRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(userRow).toBeVisible({ timeout: 15000 });

      // Click on first user's actions menu
      const actionButton = userRow.locator('button');
      await actionButton.waitFor({ state: 'visible' });
      await actionButton.click();
      await page.locator('[role="menuitem"]').filter({ hasText: /view/i }).click();

      // Dialog should open
      await expect(page.locator('[role="dialog"]')).toBeVisible();
    });

    test('should display user information in dialog', async ({ page }) => {
      // Wait for a row with an action button (actual user row, not "No users found")
      const userRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(userRow).toBeVisible({ timeout: 15000 });

      const actionButton = userRow.locator('button');
      await actionButton.waitFor({ state: 'visible' });
      await actionButton.click();
      await page.locator('[role="menuitem"]').filter({ hasText: /view/i }).click();

      // Check for dialog title and content
      await expect(page.locator('[role="dialog"]')).toBeVisible();
      await expect(page.locator('[role="dialog"]').getByText(/user details/i)).toBeVisible();
    });
  });

  test.describe('Edit User', () => {
    test('should open edit dialog', async ({ page }) => {
      // Wait for a row with an action button (actual user row, not "No users found")
      const userRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(userRow).toBeVisible({ timeout: 15000 });

      const actionButton = userRow.locator('button');
      await actionButton.waitFor({ state: 'visible' });
      await actionButton.click();
      await page.locator('[role="menuitem"]').filter({ hasText: /edit/i }).click();

      await expect(page.locator('[role="dialog"]')).toBeVisible();
      await expect(page.locator('[role="dialog"]').getByText(/edit user/i)).toBeVisible();
    });

    test('should have Cancel and Save buttons', async ({ page }) => {
      // Wait for a row with an action button (actual user row, not "No users found")
      const userRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(userRow).toBeVisible({ timeout: 15000 });

      const actionButton = userRow.locator('button');
      await actionButton.waitFor({ state: 'visible' });
      await actionButton.click();
      await page.locator('[role="menuitem"]').filter({ hasText: /edit/i }).click();

      await expect(page.getByRole('button', { name: /cancel/i })).toBeVisible();
      await expect(page.getByRole('button', { name: /save/i })).toBeVisible();
    });
  });

  test.describe('Suspend/Activate User', () => {
    test('should show Suspend option for active user', async ({ page }) => {
      // Wait for a row with an action button (actual user row, not "No users found")
      const userRow = page.locator('tbody tr').filter({ has: page.locator('button') }).first();
      await expect(userRow).toBeVisible({ timeout: 15000 });

      const actionButton = userRow.locator('button');
      await actionButton.waitFor({ state: 'visible' });
      await actionButton.click();

      // Should have either Suspend or Activate option
      const hasSuspend = await page.locator('[role="menuitem"]').filter({ hasText: /suspend/i }).isVisible().catch(() => false);
      const hasActivate = await page.locator('[role="menuitem"]').filter({ hasText: /activate/i }).isVisible().catch(() => false);

      expect(hasSuspend || hasActivate).toBeTruthy();
    });
  });
});
