# Deploy Command

## Overview
The deploy command handles the complete deployment process for React-Vite-Supabase applications, including building, testing, and deploying to various platforms with proper environment configuration.

## Usage
```bash
# Deploy frontend to Vercel
npm run deploy:frontend
npm run deploy:frontend:staging

# Deploy Edge Functions to Supabase
npm run deploy:functions
npm run deploy:functions:staging

# Deploy both (full deployment)
npm run deploy
npm run deploy:staging

# Deploy specific function
npm run deploy:function -- function-name
```

## Deployment Architecture

### Frontend Deployment (Vercel)
**Setup:**
```bash
# Install Vercel CLI
npm i -g vercel

# Login and setup
vercel login
vercel --prod
```

**Configuration (vercel.json):**
```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "installCommand": "npm install",
  "framework": "vite",
  "env": {
    "VITE_SUPABASE_URL": "@supabase-url",
    "VITE_SUPABASE_ANON_KEY": "@supabase-anon-key"
  },
  "build": {
    "env": {
      "VITE_SUPABASE_URL": "@supabase-url",
      "VITE_SUPABASE_ANON_KEY": "@supabase-anon-key"
    }
  }
}
```

### Edge Functions Deployment (Supabase)
**Setup:**
```bash
# Install Supabase CLI
npm i -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Deploy all functions
supabase functions deploy

# Deploy specific function
supabase functions deploy function-name
```

**Function Development (Remote Only):**
```bash
# Create new function
supabase functions new function-name

# Deploy and test on remote
supabase functions deploy function-name

# Test function on remote Supabase
curl -i --location --request POST 'https://YOUR_PROJECT.supabase.co/functions/v1/function-name' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"key":"value"}'

# Note: No local Supabase - always develop against remote instance
```

## Environment Configuration

### Environment Variables
```bash
# .env.local (development)
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_APP_ENV=development

# .env.production
VITE_SUPABASE_URL=https://your-production-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-production-anon-key
VITE_APP_ENV=production
```

### Supabase Configuration
```javascript
// src/utils/supabase.js
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true
  }
})
```

## Deployment Script

### Main Deploy Script
```javascript
// scripts/deploy.js
const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')

class Deployer {
  constructor(environment = 'production') {
    this.env = environment
    this.platform = process.env.DEPLOY_PLATFORM || 'vercel'
  }

  async deploy() {
    console.log(`🚀 Starting deployment to ${this.env}...`)
    
    try {
      await this.preDeployChecks()
      await this.buildProject()
      await this.runTests()
      await this.deployToPlatform()
      await this.postDeployTasks()
      
      console.log('✅ Deployment successful!')
    } catch (error) {
      console.error('❌ Deployment failed:', error.message)
      process.exit(1)
    }
  }

  async preDeployChecks() {
    console.log('🔍 Running pre-deployment checks...')
    
    // Check environment variables
    this.checkEnvironmentVariables()
    
    // Check git status
    this.checkGitStatus()
    
    // Run linting
    execSync('npm run lint', { stdio: 'inherit' })
    
    console.log('✅ Pre-deployment checks passed')
  }

  checkEnvironmentVariables() {
    const required = [
      'VITE_SUPABASE_URL',
      'VITE_SUPABASE_ANON_KEY'
    ]
    
    const missing = required.filter(env => !process.env[env])
    
    if (missing.length > 0) {
      throw new Error(`Missing environment variables: ${missing.join(', ')}`)
    }
  }

  checkGitStatus() {
    try {
      const status = execSync('git status --porcelain', { encoding: 'utf8' })
      if (status.trim() && this.env === 'production') {
        throw new Error('Uncommitted changes detected. Commit or stash changes before deploying to production.')
      }
    } catch (error) {
      console.warn('Warning: Could not check git status')
    }
  }

  async buildProject() {
    console.log('🏗️  Building project...')
    execSync('npm run build', { stdio: 'inherit' })
    console.log('✅ Build completed')
  }

  async runTests() {
    console.log('🧪 Running tests...')
    try {
      execSync('npm test -- --run', { stdio: 'inherit' })
      console.log('✅ Tests passed')
    } catch (error) {
      if (this.env === 'production') {
        throw new Error('Tests failed. Cannot deploy to production with failing tests.')
      } else {
        console.warn('⚠️  Tests failed, but continuing deployment to non-production environment')
      }
    }
  }

  async deployToPlatform() {
    console.log(`📦 Deploying to ${this.platform}...`)
    
    switch (this.platform) {
      case 'vercel':
        await this.deployToVercel()
        break
      case 'netlify':
        await this.deployToNetlify()
        break
      case 'github-pages':
        await this.deployToGitHubPages()
        break
      default:
        throw new Error(`Unsupported platform: ${this.platform}`)
    }
  }

  async deployToVercel() {
    const prodFlag = this.env === 'production' ? '--prod' : ''
    execSync(`vercel ${prodFlag} --yes`, { stdio: 'inherit' })
  }

  async deployToNetlify() {
    const prodFlag = this.env === 'production' ? '--prod' : ''
    execSync(`netlify deploy --dir=dist ${prodFlag}`, { stdio: 'inherit' })
  }

  async deployToGitHubPages() {
    execSync('npm run deploy:gh-pages', { stdio: 'inherit' })
  }

  async postDeployTasks() {
    console.log('🔧 Running post-deployment tasks...')
    
    // Update deployment record
    this.updateDeploymentRecord()
    
    // Send notifications (if configured)
    // await this.sendNotifications()
    
    console.log('✅ Post-deployment tasks completed')
  }

  updateDeploymentRecord() {
    const deployment = {
      timestamp: new Date().toISOString(),
      environment: this.env,
      platform: this.platform,
      commit: this.getCommitHash(),
      version: this.getPackageVersion()
    }
    
    const deploymentsFile = 'deployments.json'
    let deployments = []
    
    if (fs.existsSync(deploymentsFile)) {
      deployments = JSON.parse(fs.readFileSync(deploymentsFile, 'utf8'))
    }
    
    deployments.unshift(deployment)
    deployments = deployments.slice(0, 10) // Keep last 10 deployments
    
    fs.writeFileSync(deploymentsFile, JSON.stringify(deployments, null, 2))
  }

  getCommitHash() {
    try {
      return execSync('git rev-parse HEAD', { encoding: 'utf8' }).trim()
    } catch {
      return 'unknown'
    }
  }

  getPackageVersion() {
    try {
      const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'))
      return pkg.version
    } catch {
      return 'unknown'
    }
  }
}

// Run deployment
const environment = process.argv[2] || 'production'
new Deployer(environment).deploy()
```

### Package.json Scripts
```json
{
  "scripts": {
    "build": "vite build",
    "preview": "vite preview",
    "deploy": "node scripts/deploy.js production",
    "deploy:staging": "node scripts/deploy.js staging",
    "deploy:dev": "node scripts/deploy.js development",
    "deploy:vercel": "DEPLOY_PLATFORM=vercel npm run deploy",
    "deploy:netlify": "DEPLOY_PLATFORM=netlify npm run deploy",
    "deploy:gh-pages": "DEPLOY_PLATFORM=github-pages npm run deploy"
  }
}
```

## CI/CD Integration

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests
        run: npm test
        
      - name: Build
        run: npm run build
        env:
          VITE_SUPABASE_URL: ${{ secrets.VITE_SUPABASE_URL }}
          VITE_SUPABASE_ANON_KEY: ${{ secrets.VITE_SUPABASE_ANON_KEY }}
          
      - name: Deploy to Vercel
        uses: vercel/action@v1
        if: github.ref == 'refs/heads/main'
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

## Security Considerations

### Environment Variables
```bash
# Never commit these to version control
VITE_SUPABASE_URL=your-url
VITE_SUPABASE_ANON_KEY=your-key

# Use secrets management in CI/CD
# GitHub Secrets, Vercel Environment Variables, etc.
```

### Build Security
```javascript
// vite.config.js
export default defineConfig({
  // Remove console logs in production
  esbuild: {
    drop: process.env.NODE_ENV === 'production' ? ['console', 'debugger'] : []
  },
  
  // Environment variable validation
  define: {
    __SUPABASE_URL__: JSON.stringify(process.env.VITE_SUPABASE_URL),
    __SUPABASE_KEY__: JSON.stringify(process.env.VITE_SUPABASE_ANON_KEY)
  }
})
```

## Monitoring and Rollback

### Deployment Monitoring
```javascript
// src/utils/monitoring.js
export const reportDeployment = (status, error = null) => {
  // Send to monitoring service
  console.log('Deployment status:', status)
  if (error) {
    console.error('Deployment error:', error)
  }
}
```

### Rollback Strategy
```bash
# Quick rollback commands
vercel rollback  # Rollback to previous Vercel deployment
netlify rollback # Rollback to previous Netlify deployment

# Git-based rollback
git revert HEAD
git push origin main
```

## Best Practices

### 1. Environment Separation
- Use different Supabase projects for different environments
- Separate environment variable files
- Different domain names for staging/production

### 2. Automated Testing
- Run full test suite before deployment
- Include E2E tests for critical paths
- Test database migrations

### 3. Gradual Deployment
- Use feature flags for new features
- Deploy to staging first
- Monitor metrics after deployment

### 4. Documentation
- Document deployment process
- Keep deployment logs
- Maintain rollback procedures 