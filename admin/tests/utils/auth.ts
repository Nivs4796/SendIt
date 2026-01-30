import { Page, expect } from '@playwright/test';

/**
 * Test credentials for admin login
 */
export const TEST_CREDENTIALS = {
  email: 'admin@sendit.co.in',
  password: 'admin123',
};

/**
 * Login as admin user
 * @param page - Playwright page object
 */
export async function loginAsAdmin(page: Page): Promise<void> {
  // Navigate to login page
  await page.goto('/login');

  // Fill in credentials
  await page.getByLabel(/email/i).fill(TEST_CREDENTIALS.email);
  await page.getByLabel(/password/i).fill(TEST_CREDENTIALS.password);

  // Click login button
  await page.getByRole('button', { name: /sign in|log in|login/i }).click();

  // Wait for navigation to dashboard
  await page.waitForURL(/dashboard/);

  // Verify we're logged in by checking for dashboard elements
  await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
}

/**
 * Logout from admin portal
 * @param page - Playwright page object
 */
export async function logout(page: Page): Promise<void> {
  // Look for logout button or menu
  const logoutButton = page.getByRole('button', { name: /logout|sign out/i });

  if (await logoutButton.isVisible()) {
    await logoutButton.click();
  } else {
    // Try dropdown menu
    const userMenu = page.getByRole('button', { name: /user|profile|account/i });
    if (await userMenu.isVisible()) {
      await userMenu.click();
      await page.getByRole('menuitem', { name: /logout|sign out/i }).click();
    }
  }

  // Wait for redirect to login
  await page.waitForURL(/login/);
}

/**
 * Check if user is logged in
 * @param page - Playwright page object
 */
export async function isLoggedIn(page: Page): Promise<boolean> {
  try {
    // Check for dashboard URL or logout button
    const url = page.url();
    return url.includes('/dashboard') || url.includes('/users') || url.includes('/pilots');
  } catch {
    return false;
  }
}

/**
 * Navigate to a protected route with auth check
 * @param page - Playwright page object
 * @param path - Route path to navigate to
 */
export async function navigateToProtectedRoute(page: Page, path: string): Promise<void> {
  await page.goto(path);

  // If redirected to login, perform login
  if (page.url().includes('/login')) {
    await loginAsAdmin(page);
    await page.goto(path);
  }

  await page.waitForLoadState('networkidle');
}
