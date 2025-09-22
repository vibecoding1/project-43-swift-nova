# Test and Commit Workflow

## Overview
The test-and-commit workflow ensures code quality by running comprehensive tests, linting, and formatting before committing changes. It includes pre-commit hooks, automated testing, and commit message validation.

## Usage
```bash
# Run full test and commit workflow
npm run test-and-commit

# Run individual components
npm run test:all        # Run all tests
npm run test:unit       # Unit tests only
npm run test:integration # Integration tests only
npm run test:e2e        # End-to-end tests
npm run commit          # Interactive commit with validation
```

## Pre-commit Hooks Setup

### Husky Configuration
```bash
# Install husky and lint-staged
npm install -D husky lint-staged @commitlint/cli @commitlint/config-conventional

# Initialize husky
npx husky install

# Add pre-commit hook
npx husky add .husky/pre-commit "npm run pre-commit"

# Add commit-msg hook
npx husky add .husky/commit-msg "npx commitlint --edit $1"
```

### Package.json Configuration
```json
{
  "scripts": {
    "prepare": "husky install",
    "pre-commit": "lint-staged && npm run test:changed",
    "test-and-commit": "npm run test:all && npm run lint && npm run format:check",
    "test:all": "vitest run",
    "test:watch": "vitest",
    "test:changed": "vitest run --changed",
    "test:unit": "vitest run src/**/*.test.{js,jsx}",
    "test:integration": "vitest run src/**/*.integration.test.{js,jsx}",
    "test:e2e": "playwright test",
    "lint": "eslint src/ --ext .js,.jsx",
    "lint:fix": "eslint src/ --ext .js,.jsx --fix",
    "format": "prettier --write src/",
    "format:check": "prettier --check src/",
    "commit": "git-cz"
  },
  "lint-staged": {
    "src/**/*.{js,jsx}": [
      "eslint --fix",
      "prettier --write",
      "vitest run --related --passWithNoTests"
    ],
    "src/**/*.{css,md,json}": [
      "prettier --write"
    ]
  },
  "commitlint": {
    "extends": ["@commitlint/config-conventional"]
  }
}
```

## Testing Strategy

### 1. Unit Tests (Vitest + React Testing Library)
```javascript
// src/components/__tests__/UserProfile.test.jsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { vi } from 'vitest'
import UserProfile from '../UserProfile'
import { supabase } from '../../utils/supabase'

// Mock Supabase
vi.mock('../../utils/supabase', () => ({
  supabase: {
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        eq: vi.fn(() => ({
          single: vi.fn()
        }))
      }))
    }))
  }
}))

describe('UserProfile', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  test('renders user profile correctly', async () => {
    const mockUser = {
      id: '1',
      full_name: 'John Doe',
      email: 'john@example.com'
    }

    supabase.from().select().eq().single.mockResolvedValue({
      data: mockUser,
      error: null
    })

    render(<UserProfile userId="1" />)

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument()
      expect(screen.getByText('john@example.com')).toBeInTheDocument()
    })
  })

  test('handles loading state', () => {
    supabase.from().select().eq().single.mockImplementation(() => 
      new Promise(() => {}) // Never resolves
    )

    render(<UserProfile userId="1" />)
    
    expect(screen.getByText('Loading...')).toBeInTheDocument()
  })

  test('handles error state', async () => {
    supabase.from().select().eq().single.mockResolvedValue({
      data: null,
      error: { message: 'User not found' }
    })

    render(<UserProfile userId="1" />)

    await waitFor(() => {
      expect(screen.getByText('Error: User not found')).toBeInTheDocument()
    })
  })
})
```

### 2. Integration Tests
```javascript
// src/__tests__/auth.integration.test.js
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { vi } from 'vitest'
import App from '../App'
import { supabase } from '../utils/supabase'

describe('Authentication Integration', () => {
  test('complete login flow', async () => {
    // Mock successful login
    supabase.auth.signInWithPassword = vi.fn().mockResolvedValue({
      data: { user: { id: '1', email: 'test@example.com' } },
      error: null
    })

    render(<App />)

    // Click login button
    fireEvent.click(screen.getByText('Login'))

    // Fill in form
    fireEvent.change(screen.getByLabelText('Email'), {
      target: { value: 'test@example.com' }
    })
    fireEvent.change(screen.getByLabelText('Password'), {
      target: { value: 'password123' }
    })

    // Submit form
    fireEvent.click(screen.getByRole('button', { name: 'Sign In' }))

    // Verify login success
    await waitFor(() => {
      expect(screen.getByText('Welcome back!')).toBeInTheDocument()
    })
  })
})
```

### 3. E2E Tests (Playwright)
```javascript
// tests/auth.spec.js
import { test, expect } from '@playwright/test'

test.describe('Authentication', () => {
  test('user can sign up and login', async ({ page }) => {
    await page.goto('/')

    // Navigate to signup
    await page.click('text=Sign Up')

    // Fill signup form
    await page.fill('[data-testid=email]', 'test@example.com')
    await page.fill('[data-testid=password]', 'password123')
    await page.click('[data-testid=signup-button]')

    // Verify signup success
    await expect(page.locator('text=Check your email')).toBeVisible()

    // Navigate to login
    await page.click('text=Login')

    // Fill login form
    await page.fill('[data-testid=email]', 'test@example.com')
    await page.fill('[data-testid=password]', 'password123')
    await page.click('[data-testid=login-button]')

    // Verify login success
    await expect(page.locator('text=Dashboard')).toBeVisible()
  })
})
```

## Test Configuration

### Vitest Configuration
```javascript
// vitest.config.js
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.js'],
    coverage: {
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/test/',
        '**/*.test.{js,jsx}',
        '**/*.spec.{js,jsx}'
      ]
    }
  }
})
```

### Test Setup
```javascript
// src/test/setup.js
import '@testing-library/jest-dom'
import { vi } from 'vitest'

// Mock Supabase
vi.mock('../utils/supabase', () => ({
  supabase: {
    auth: {
      getSession: vi.fn(),
      signInWithPassword: vi.fn(),
      signUp: vi.fn(),
      signOut: vi.fn()
    },
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        eq: vi.fn(() => ({
          single: vi.fn()
        }))
      })),
      insert: vi.fn(),
      update: vi.fn(),
      delete: vi.fn()
    }))
  }
}))

// Global test utilities
global.ResizeObserver = vi.fn().mockImplementation(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn()
}))
```

### Playwright Configuration
```javascript
// playwright.config.js
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:5173',
    trace: 'on-first-retry'
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] }
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] }
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] }
    }
  ],
  webServer: {
    command: 'npm run dev',
    port: 5173
  }
})
```

## Commit Message Validation

### Commitlint Configuration
```javascript
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // New feature
        'fix',      // Bug fix
        'docs',     // Documentation
        'style',    // Code style changes
        'refactor', // Code refactoring
        'perf',     // Performance improvements
        'test',     // Adding tests
        'build',    // Build system changes
        'ci',       // CI configuration changes
        'chore',    // Other changes
        'revert'    // Revert previous commit
      ]
    ],
    'subject-case': [2, 'never', ['sentence-case', 'start-case', 'pascal-case', 'upper-case']],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 72]
  }
}
```

### Conventional Commit Examples
```bash
# Feature commits
git commit -m "feat: add user profile component"
git commit -m "feat(auth): implement password reset functionality"

# Bug fixes
git commit -m "fix: resolve login form validation issue"
git commit -m "fix(ui): correct button alignment on mobile"

# Documentation
git commit -m "docs: update API documentation"
git commit -m "docs(readme): add installation instructions"

# Refactoring
git commit -m "refactor: extract common validation logic"
git commit -m "refactor(hooks): simplify useAuth implementation"
```

## Test and Commit Script

### Main Script
```javascript
// scripts/test-and-commit.js
const { execSync } = require('child_process')
const inquirer = require('inquirer')

class TestAndCommit {
  async run() {
    console.log('🧪 Starting test and commit workflow...')
    
    try {
      await this.runTests()
      await this.runLinting()
      await this.runFormatting()
      await this.checkGitStatus()
      await this.interactiveCommit()
      
      console.log('✅ Test and commit workflow completed!')
    } catch (error) {
      console.error('❌ Workflow failed:', error.message)
      process.exit(1)
    }
  }

  async runTests() {
    console.log('🧪 Running tests...')
    
    try {
      execSync('npm run test:all', { stdio: 'inherit' })
      console.log('✅ All tests passed')
    } catch (error) {
      throw new Error('Tests failed. Please fix failing tests before committing.')
    }
  }

  async runLinting() {
    console.log('🔍 Running linter...')
    
    try {
      execSync('npm run lint', { stdio: 'inherit' })
      console.log('✅ Linting passed')
    } catch (error) {
      console.log('🔧 Attempting to fix linting issues...')
      execSync('npm run lint:fix', { stdio: 'inherit' })
      console.log('✅ Linting issues fixed')
    }
  }

  async runFormatting() {
    console.log('🎨 Checking code formatting...')
    
    try {
      execSync('npm run format:check', { stdio: 'inherit' })
      console.log('✅ Code formatting is correct')
    } catch (error) {
      console.log('🔧 Formatting code...')
      execSync('npm run format', { stdio: 'inherit' })
      console.log('✅ Code formatted')
    }
  }

  async checkGitStatus() {
    const status = execSync('git status --porcelain', { encoding: 'utf8' })
    
    if (!status.trim()) {
      throw new Error('No changes to commit')
    }
    
    console.log('📝 Changes detected:')
    console.log(status)
  }

  async interactiveCommit() {
    const answers = await inquirer.prompt([
      {
        type: 'list',
        name: 'type',
        message: 'Select the type of change:',
        choices: [
          { name: 'feat: A new feature', value: 'feat' },
          { name: 'fix: A bug fix', value: 'fix' },
          { name: 'docs: Documentation only changes', value: 'docs' },
          { name: 'style: Code style changes', value: 'style' },
          { name: 'refactor: Code refactoring', value: 'refactor' },
          { name: 'perf: Performance improvements', value: 'perf' },
          { name: 'test: Adding tests', value: 'test' },
          { name: 'chore: Other changes', value: 'chore' }
        ]
      },
      {
        type: 'input',
        name: 'scope',
        message: 'Enter the scope (optional):',
        validate: (input) => input.length <= 20 || 'Scope should be 20 characters or less'
      },
      {
        type: 'input',
        name: 'subject',
        message: 'Enter a short description:',
        validate: (input) => {
          if (input.length === 0) return 'Subject is required'
          if (input.length > 50) return 'Subject should be 50 characters or less'
          if (input.endsWith('.')) return 'Subject should not end with a period'
          return true
        }
      },
      {
        type: 'input',
        name: 'body',
        message: 'Enter a longer description (optional):'
      }
    ])

    const scope = answers.scope ? `(${answers.scope})` : ''
    const commitMessage = `${answers.type}${scope}: ${answers.subject}`
    
    if (answers.body) {
      commitMessage += `\n\n${answers.body}`
    }

    console.log('\n📝 Commit message:')
    console.log(commitMessage)

    const { confirm } = await inquirer.prompt([
      {
        type: 'confirm',
        name: 'confirm',
        message: 'Commit with this message?',
        default: true
      }
    ])

    if (confirm) {
      execSync(`git add .`, { stdio: 'inherit' })
      execSync(`git commit -m "${commitMessage}"`, { stdio: 'inherit' })
      console.log('✅ Changes committed successfully')
    } else {
      console.log('❌ Commit cancelled')
    }
  }
}

new TestAndCommit().run()
```

## CI/CD Integration

### GitHub Actions
```yaml
# .github/workflows/test.yml
name: Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run linting
        run: npm run lint
        
      - name: Check formatting
        run: npm run format:check
        
      - name: Run unit tests
        run: npm run test:unit
        
      - name: Run integration tests
        run: npm run test:integration
        
      - name: Run E2E tests
        run: npm run test:e2e
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## Best Practices

### 1. Test Organization
- Group related tests in describe blocks
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Mock external dependencies

### 2. Commit Hygiene
- Make atomic commits
- Write clear commit messages
- Use conventional commit format
- Keep commits focused on single changes

### 3. Pre-commit Checks
- Run tests on changed files only for speed
- Fix auto-fixable issues automatically
- Prevent commits with failing tests
- Validate commit message format

### 4. Continuous Integration
- Run full test suite on CI
- Block merges with failing tests
- Generate and track coverage reports
- Test on multiple environments 