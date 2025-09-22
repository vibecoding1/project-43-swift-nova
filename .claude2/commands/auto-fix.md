# Auto-Fix Command

## Overview
The auto-fix command automatically detects and resolves common issues in React-Vite-Supabase projects. It performs automated code fixes, dependency updates, and configuration corrections.

## Usage
```bash
# Run auto-fix for all detected issues
npm run auto-fix

# Run specific auto-fix categories
npm run auto-fix:lint     # ESLint fixes
npm run auto-fix:deps     # Dependency issues
npm run auto-fix:security # Security vulnerabilities
npm run auto-fix:format   # Code formatting
```

## Detectable Issues

### 1. Linting Errors
- **ESLint rule violations**
  - Unused imports/variables
  - Missing semicolons
  - Incorrect indentation
  - React hooks dependency issues

- **Auto-fixes:**
  ```bash
  npx eslint --fix src/
  ```

### 2. Dependency Issues
- **Outdated packages**
- **Security vulnerabilities**
- **Peer dependency warnings**
- **Unused dependencies**

- **Auto-fixes:**
  ```bash
  npm audit fix
  npm update
  npx depcheck --json | jq '.dependencies[]' # Remove unused deps
  ```

### 3. Import/Export Issues
- **Missing imports**
- **Circular dependencies**
- **Incorrect import paths**
- **Unused exports**

- **Auto-fixes:**
  - Add missing React imports
  - Fix relative import paths
  - Remove unused imports
  - Organize imports by type

### 4. React-Specific Issues
- **Missing key props in lists**
- **Incorrect hook usage**
- **State mutation**
- **Missing cleanup in useEffect**

- **Auto-fixes:**
  ```jsx
  // Before
  items.map(item => <div>{item.name}</div>)
  
  // After
  items.map(item => <div key={item.id}>{item.name}</div>)
  ```

### 5. Supabase Integration Issues
- **Missing error handling**
- **Incorrect RLS policies**
- **Unoptimized queries**
- **Missing auth checks**

- **Auto-fixes:**
  ```js
  // Before
  const { data } = await supabase.from('users').select('*')
  
  // After
  const { data, error } = await supabase.from('users').select('*')
  if (error) throw error
  ```

### 6. Performance Issues
- **Large bundle size**
- **Unoptimized images**
- **Missing lazy loading**
- **Inefficient re-renders**

- **Auto-fixes:**
  - Add React.memo where appropriate
  - Implement code splitting
  - Optimize image formats
  - Add loading="lazy" to images

### 7. Security Issues
- **Exposed API keys**
- **Missing CSRF protection**
- **Insecure dependencies**
- **Hardcoded secrets**

- **Auto-fixes:**
  - Move secrets to environment variables
  - Add security headers
  - Update vulnerable dependencies

### 8. Configuration Issues
- **Missing environment variables**
- **Incorrect Vite config**
- **ESLint configuration errors**
- **Missing build optimizations**

## Implementation

### Auto-Fix Script
```javascript
// scripts/auto-fix.js
const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')

class AutoFixer {
  constructor() {
    this.fixes = []
    this.errors = []
  }

  async run() {
    console.log('🔧 Starting auto-fix...')
    
    await this.fixLinting()
    await this.fixDependencies()
    await this.fixImports()
    await this.fixReactIssues()
    await this.fixSupabaseIssues()
    await this.fixSecurity()
    
    this.reportResults()
  }

  async fixLinting() {
    try {
      console.log('📝 Fixing linting issues...')
      execSync('npx eslint --fix src/', { stdio: 'inherit' })
      this.fixes.push('Fixed ESLint issues')
    } catch (error) {
      this.errors.push('ESLint fixes failed: ' + error.message)
    }
  }

  async fixDependencies() {
    try {
      console.log('📦 Fixing dependencies...')
      execSync('npm audit fix', { stdio: 'inherit' })
      this.fixes.push('Fixed dependency vulnerabilities')
    } catch (error) {
      this.errors.push('Dependency fixes failed: ' + error.message)
    }
  }

  reportResults() {
    console.log('\n✅ Auto-fix Results:')
    this.fixes.forEach(fix => console.log(`  ✓ ${fix}`))
    
    if (this.errors.length > 0) {
      console.log('\n❌ Issues that need manual attention:')
      this.errors.forEach(error => console.log(`  ✗ ${error}`))
    }
  }
}

new AutoFixer().run()
```

### Package.json Scripts
```json
{
  "scripts": {
    "auto-fix": "node scripts/auto-fix.js",
    "auto-fix:lint": "eslint --fix src/",
    "auto-fix:deps": "npm audit fix && npm update",
    "auto-fix:security": "npm audit fix --force",
    "auto-fix:format": "prettier --write src/",
    "auto-fix:imports": "npx organize-imports-cli src/**/*.{js,jsx,ts,tsx}"
  }
}
```

## Configuration

### .eslintrc.js Auto-Fix Rules
```javascript
module.exports = {
  extends: [
    'eslint:recommended',
    '@eslint/js/recommended',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended'
  ],
  rules: {
    // Auto-fixable rules
    'semi': ['error', 'never'],
    'quotes': ['error', 'single'],
    'indent': ['error', 2],
    'comma-dangle': ['error', 'never'],
    'no-unused-vars': 'error',
    'no-console': 'warn',
    
    // React specific
    'react/prop-types': 'off', // Using TypeScript instead
    'react-hooks/exhaustive-deps': 'warn'
  },
  settings: {
    react: {
      version: 'detect'
    }
  }
}
```

### Auto-Fix Patterns

#### Missing React Imports
```javascript
// Detection pattern
const missingReactImport = /^(?!.*import.*React).*jsx?$/m

// Fix
function addReactImport(content) {
  if (content.includes('React') && !content.includes('import React')) {
    return `import React from 'react'\n${content}`
  }
  return content
}
```

#### Supabase Error Handling
```javascript
// Detection pattern
const missingErrorHandling = /supabase\.from\([^)]+\)\.[^;]+(?!.*error)/g

// Fix
function addErrorHandling(content) {
  return content.replace(
    /const { data } = await (supabase\.from\([^)]+\)\.[^;]+)/g,
    `const { data, error } = await $1
    if (error) throw error`
  )
}
```

## Integration with CI/CD

### GitHub Actions
```yaml
name: Auto-Fix
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  auto-fix:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run auto-fix
        run: npm run auto-fix
        
      - name: Commit fixes
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add -A
          git diff --staged --quiet || git commit -m "Auto-fix: Apply automated fixes"
          git push
```

## Best Practices

### 1. Run Before Commits
- Set up pre-commit hooks
- Integrate with husky
- Include in development workflow

### 2. Safe Fixes Only
- Only apply fixes that are guaranteed safe
- Require manual review for complex changes
- Maintain backup of original files

### 3. Incremental Fixes
- Fix one category at a time
- Test after each fix category
- Rollback if issues are introduced

### 4. Documentation
- Log all applied fixes
- Provide explanations for changes
- Include fix suggestions for manual issues

## Troubleshooting

### Common Issues
1. **ESLint fixes break functionality**
   - Review .eslintrc.js configuration
   - Test application after fixes
   - Disable problematic rules

2. **Dependency conflicts after updates**
   - Use `npm ls` to check conflicts
   - Pin specific versions if needed
   - Test thoroughly after updates

3. **Import fixes cause circular dependencies**
   - Review import structure
   - Refactor shared dependencies
   - Use dependency graphs to visualize

### Manual Review Required
- Complex state management changes
- Authentication flow modifications  
- Database schema alterations
- Performance optimizations with trade-offs 