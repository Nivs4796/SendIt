import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright configuration for SendIt Admin Portal E2E tests
 * @see https://playwright.dev/docs/test-configuration
 */
export default defineConfig({
  testDir: './tests',

  /* Run tests in files in parallel */
  fullyParallel: true,

  /* Fail the build on CI if you accidentally left test.only in the source code */
  forbidOnly: !!process.env.CI,

  /* Retry on CI only */
  retries: process.env.CI ? 2 : 1,

  /* Opt out of parallel tests on CI */
  workers: process.env.CI ? 1 : undefined,

  /* Reporter to use */
  reporter: [
    ['html', { open: 'never' }],
    ['list'],
  ],

  /* Shared settings for all the projects below */
  use: {
    /* Base URL for all tests */
    baseURL: 'http://localhost:3001',

    /* Collect trace when retrying the failed test */
    trace: 'on-first-retry',

    /* Screenshot on failure */
    screenshot: 'only-on-failure',

    /* Video on first retry */
    video: 'on-first-retry',

    /* Maximum time each action can take */
    actionTimeout: 30000,

    /* Maximum time for navigation */
    navigationTimeout: 60000,
  },

  /* Configure projects for major browsers */
  projects: [
    /* Setup project for authentication */
    {
      name: 'setup',
      testMatch: /.*\.setup\.ts/,
      timeout: 60000,
    },

    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        /* Use prepared auth state */
        storageState: 'tests/.auth/admin.json',
      },
      dependencies: ['setup'],
    },
  ],

  /* Timeout for each test */
  timeout: 60000,

  /* Expect timeout */
  expect: {
    timeout: 15000,
  },

  /* Run local dev server before starting the tests */
  webServer: [
    {
      command: 'npm run dev -- -p 3001',
      url: 'http://localhost:3001',
      reuseExistingServer: !process.env.CI,
      timeout: 120000,
    },
  ],
});
