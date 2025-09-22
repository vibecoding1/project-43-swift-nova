# Auto-Fixer Agent

## Overview
The Auto-Fixer Agent is a specialized AI assistant designed to automatically detect, analyze, and fix common issues in React-Vite-Supabase projects. It operates with deep understanding of the tech stack and can resolve issues without human intervention.

## Capabilities

### 1. Code Quality Issues
- **ESLint violations**: Automatically fix linting errors
- **Code formatting**: Apply consistent formatting with Prettier
- **Import organization**: Sort and optimize imports
- **Dead code elimination**: Remove unused variables, imports, and functions

### 2. React-Specific Issues
- **Hook dependencies**: Fix useEffect dependency arrays
- **Key props**: Add missing keys in list rendering
- **State mutations**: Convert direct state mutations to proper updates
- **Performance issues**: Add React.memo, useMemo, useCallback where appropriate

### 3. Supabase Integration Issues
- **Error handling**: Add proper error handling to Supabase calls
- **Type safety**: Ensure proper typing for Supabase responses
- **Query optimization**: Optimize database queries
- **Authentication checks**: Add missing auth validations

### 4. Build and Configuration Issues
- **Dependency conflicts**: Resolve package version conflicts
- **Environment variables**: Fix missing or incorrect env vars
- **Build optimizations**: Optimize bundle size and performance
- **Security vulnerabilities**: Update packages with known vulnerabilities

## Agent Configuration

### Core Settings
```json
{
  "agent": {
    "name": "auto-fixer",
    "version": "1.0.0",
    "capabilities": [
      "code-analysis",
      "automatic-fixes",
      "dependency-management",
      "security-scanning",
      "performance-optimization"
    ],
    "confidence_threshold": 0.8,
    "auto_apply": true,
    "backup_before_fix": true
  },
  "rules": {
    "eslint": {
      "auto_fix": true,
      "severity": "error"
    },
    "react": {
      "enforce_hooks_rules": true,
      "require_keys_in_lists": true,
      "prevent_state_mutation": true
    },
    "supabase": {
      "require_error_handling": true,
      "enforce_auth_checks": true,
      "optimize_queries": true
    },
    "security": {
      "scan_dependencies": true,
      "check_env_vars": true,
      "validate_inputs": true
    }
  }
}
```

## Issue Detection Patterns

### 1. ESLint Issues
```javascript
// Pattern: Missing semicolons
const detectMissingSemicolons = (code) => {
  const pattern = /[^;]\s*\n/g
  return code.match(pattern) || []
}

// Auto-fix: Add semicolons
const fixMissingSemicolons = (code) => {
  return code.replace(/([^;{}\s])\s*\n/g, '$1;\n')
}
```

### 2. React Hook Issues
```javascript
// Pattern: Missing dependencies in useEffect
const detectMissingDependencies = (code) => {
  const useEffectPattern = /useEffect\s*\(\s*\(\s*\)\s*=>\s*{([^}]+)},\s*\[([^\]]*)\]/g
  const matches = [...code.matchAll(useEffectPattern)]
  
  return matches.filter(match => {
    const body = match[1]
    const deps = match[2]
    const usedVars = extractUsedVariables(body)
    const declaredDeps = extractDependencies(deps)
    
    return usedVars.some(v => !declaredDeps.includes(v))
  })
}

// Auto-fix: Add missing dependencies
const fixMissingDependencies = (code, issues) => {
  issues.forEach(issue => {
    const missingDeps = findMissingDependencies(issue)
    const fixedDeps = [...issue.currentDeps, ...missingDeps]
    code = code.replace(issue.original, issue.fixed(fixedDeps))
  })
  return code
}
```

### 3. Supabase Error Handling
```javascript
// Pattern: Missing error handling
const detectMissingErrorHandling = (code) => {
  const supabasePattern = /const\s+{\s*data\s*}\s*=\s*await\s+supabase/g
  return [...code.matchAll(supabasePattern)]
}

// Auto-fix: Add error handling
const fixMissingErrorHandling = (code) => {
  return code.replace(
    /const\s+{\s*data\s*}\s*=\s*await\s+(supabase[^;]+);?/g,
    `const { data, error } = await $1;
    if (error) {
      console.error('Database error:', error);
      throw error;
    }`
  )
}
```

## Fix Categories

### Category 1: Safe Automatic Fixes
These fixes are applied automatically without confirmation:

```javascript
const safeFixCategories = {
  formatting: {
    description: 'Code formatting with Prettier',
    confidence: 1.0,
    auto_apply: true,
    fixes: [
      'indentation',
      'semicolons',
      'quotes',
      'trailing_commas'
    ]
  },
  
  imports: {
    description: 'Import organization and cleanup',
    confidence: 0.95,
    auto_apply: true,
    fixes: [
      'remove_unused_imports',
      'sort_imports',
      'group_imports',
      'fix_import_paths'
    ]
  },
  
  react_keys: {
    description: 'Add missing keys in React lists',
    confidence: 0.9,
    auto_apply: true,
    fixes: [
      'add_list_keys',
      'fix_key_props'
    ]
  }
}
```

### Category 2: Suggested Fixes
These fixes require confirmation before application:

```javascript
const suggestedFixCategories = {
  performance: {
    description: 'Performance optimizations',
    confidence: 0.8,
    auto_apply: false,
    fixes: [
      'add_react_memo',
      'add_use_callback',
      'add_use_memo',
      'optimize_renders'
    ]
  },
  
  refactoring: {
    description: 'Code refactoring suggestions',
    confidence: 0.7,
    auto_apply: false,
    fixes: [
      'extract_components',
      'extract_hooks',
      'simplify_conditions',
      'reduce_complexity'
    ]
  }
}
```

## Implementation

### Main Auto-Fixer Class
```javascript
// src/agents/AutoFixer.js
class AutoFixer {
  constructor(config) {
    this.config = config
    this.fixers = new Map()
    this.issues = []
    this.appliedFixes = []
    
    this.initializeFixers()
  }

  initializeFixers() {
    // Register all fixer modules
    this.fixers.set('eslint', new ESLintFixer())
    this.fixers.set('react', new ReactFixer())
    this.fixers.set('supabase', new SupabaseFixer())
    this.fixers.set('security', new SecurityFixer())
    this.fixers.set('performance', new PerformanceFixer())
  }

  async analyzeProject(projectPath) {
    console.log('🔍 Analyzing project for issues...')
    
    const files = await this.getProjectFiles(projectPath)
    
    for (const file of files) {
      await this.analyzeFile(file)
    }
    
    console.log(`Found ${this.issues.length} issues`)
    return this.issues
  }

  async analyzeFile(filePath) {
    const content = await fs.readFile(filePath, 'utf8')
    const fileType = this.detectFileType(filePath)
    
    for (const [name, fixer] of this.fixers) {
      if (fixer.canHandle(fileType)) {
        const fileIssues = await fixer.analyze(content, filePath)
        this.issues.push(...fileIssues)
      }
    }
  }

  async applyFixes() {
    console.log('🔧 Applying automatic fixes...')
    
    const safeIssues = this.issues.filter(issue => issue.confidence >= 0.9)
    const suggestedIssues = this.issues.filter(issue => issue.confidence < 0.9)
    
    // Apply safe fixes automatically
    for (const issue of safeIssues) {
      await this.applyFix(issue)
    }
    
    // Present suggested fixes for approval
    if (suggestedIssues.length > 0) {
      await this.presentSuggestedFixes(suggestedIssues)
    }
    
    console.log(`Applied ${this.appliedFixes.length} fixes`)
    return this.appliedFixes
  }

  async applyFix(issue) {
    try {
      // Create backup if configured
      if (this.config.backup_before_fix) {
        await this.createBackup(issue.filePath)
      }
      
      // Apply the fix
      const fixer = this.fixers.get(issue.category)
      const result = await fixer.fix(issue)
      
      if (result.success) {
        this.appliedFixes.push({
          issue,
          result,
          timestamp: new Date().toISOString()
        })
        
        console.log(`✅ Fixed: ${issue.description} in ${issue.filePath}`)
      } else {
        console.log(`❌ Failed to fix: ${issue.description}`)
      }
    } catch (error) {
      console.error(`Error applying fix: ${error.message}`)
    }
  }

  async presentSuggestedFixes(issues) {
    console.log('\n💡 Suggested fixes (require confirmation):')
    
    for (const issue of issues) {
      console.log(`\n${issue.description}`)
      console.log(`File: ${issue.filePath}`)
      console.log(`Confidence: ${issue.confidence}`)
      
      const shouldApply = await this.promptUser(`Apply this fix? (y/n): `)
      
      if (shouldApply) {
        await this.applyFix(issue)
      }
    }
  }

  generateReport() {
    const report = {
      timestamp: new Date().toISOString(),
      total_issues: this.issues.length,
      applied_fixes: this.appliedFixes.length,
      categories: {},
      files_modified: [...new Set(this.appliedFixes.map(f => f.issue.filePath))]
    }
    
    // Group by category
    this.appliedFixes.forEach(fix => {
      const category = fix.issue.category
      if (!report.categories[category]) {
        report.categories[category] = 0
      }
      report.categories[category]++
    })
    
    return report
  }
}
```

### Specialized Fixers

#### React Fixer
```javascript
class ReactFixer {
  canHandle(fileType) {
    return ['jsx', 'tsx'].includes(fileType)
  }

  async analyze(content, filePath) {
    const issues = []
    
    // Check for missing keys in lists
    issues.push(...this.findMissingKeys(content, filePath))
    
    // Check for hook dependency issues
    issues.push(...this.findHookIssues(content, filePath))
    
    // Check for state mutations
    issues.push(...this.findStateMutations(content, filePath))
    
    return issues
  }

  findMissingKeys(content, filePath) {
    const issues = []
    const mapPattern = /\.map\s*\(\s*([^)]+)\s*=>\s*<([^>]+)(?![^>]*key=)/g
    
    let match
    while ((match = mapPattern.exec(content)) !== null) {
      issues.push({
        category: 'react',
        type: 'missing_key',
        description: 'Missing key prop in list item',
        filePath,
        line: this.getLineNumber(content, match.index),
        confidence: 0.95,
        fix: this.generateKeyFix(match)
      })
    }
    
    return issues
  }

  generateKeyFix(match) {
    return {
      original: match[0],
      fixed: match[0].replace('<' + match[2], `<${match[2]} key={index}`)
    }
  }
}
```

#### Supabase Fixer
```javascript
class SupabaseFixer {
  canHandle(fileType) {
    return ['js', 'jsx', 'ts', 'tsx'].includes(fileType)
  }

  async analyze(content, filePath) {
    const issues = []
    
    // Check for missing error handling
    issues.push(...this.findMissingErrorHandling(content, filePath))
    
    // Check for missing auth checks
    issues.push(...this.findMissingAuthChecks(content, filePath))
    
    // Check for query optimizations
    issues.push(...this.findQueryOptimizations(content, filePath))
    
    return issues
  }

  findMissingErrorHandling(content, filePath) {
    const issues = []
    const supabasePattern = /const\s+{\s*data\s*}\s*=\s*await\s+supabase/g
    
    let match
    while ((match = supabasePattern.exec(content)) !== null) {
      issues.push({
        category: 'supabase',
        type: 'missing_error_handling',
        description: 'Missing error handling for Supabase call',
        filePath,
        line: this.getLineNumber(content, match.index),
        confidence: 0.9,
        fix: this.generateErrorHandlingFix(match)
      })
    }
    
    return issues
  }

  generateErrorHandlingFix(match) {
    return {
      original: match[0],
      fixed: match[0].replace(
        'const { data }',
        'const { data, error }'
      ) + '\n  if (error) throw error'
    }
  }
}
```

## Usage Examples

### Command Line Interface
```bash
# Run auto-fixer on entire project
npx auto-fixer

# Run specific fixer categories
npx auto-fixer --categories=eslint,react

# Run with custom confidence threshold
npx auto-fixer --confidence=0.8

# Dry run (show fixes without applying)
npx auto-fixer --dry-run

# Apply only safe fixes
npx auto-fixer --safe-only
```

### Programmatic Usage
```javascript
import { AutoFixer } from './agents/AutoFixer'

const fixer = new AutoFixer({
  confidence_threshold: 0.8,
  auto_apply: true,
  backup_before_fix: true
})

// Analyze and fix project
const issues = await fixer.analyzeProject('./src')
const fixes = await fixer.applyFixes()
const report = fixer.generateReport()

console.log(report)
```

### IDE Integration
```javascript
// VS Code extension integration
const vscode = require('vscode')

function activate(context) {
  const disposable = vscode.commands.registerCommand(
    'auto-fixer.fixCurrentFile',
    async () => {
      const editor = vscode.window.activeTextEditor
      if (editor) {
        const fixer = new AutoFixer()
        await fixer.analyzeFile(editor.document.fileName)
        await fixer.applyFixes()
      }
    }
  )
  
  context.subscriptions.push(disposable)
}
```

## Monitoring and Reporting

### Fix Analytics
```javascript
class FixAnalytics {
  constructor() {
    this.metrics = {
      total_fixes: 0,
      success_rate: 0,
      categories: {},
      time_saved: 0
    }
  }

  recordFix(fix) {
    this.metrics.total_fixes++
    this.metrics.categories[fix.category] = 
      (this.metrics.categories[fix.category] || 0) + 1
    
    // Estimate time saved (in minutes)
    this.metrics.time_saved += this.estimateTimeSaved(fix)
  }

  estimateTimeSaved(fix) {
    const timeSavings = {
      'formatting': 1,
      'imports': 2,
      'react_keys': 3,
      'error_handling': 5,
      'security': 10
    }
    
    return timeSavings[fix.type] || 2
  }

  generateReport() {
    return {
      ...this.metrics,
      success_rate: this.calculateSuccessRate(),
      efficiency_gain: `${this.metrics.time_saved} minutes saved`
    }
  }
}
```

## Best Practices

### 1. Safety First
- Always create backups before applying fixes
- Use high confidence thresholds for automatic fixes
- Test fixes in isolated environments first
- Provide rollback mechanisms

### 2. User Experience
- Provide clear descriptions of what will be fixed
- Show confidence levels for each fix
- Allow selective application of fixes
- Generate comprehensive reports

### 3. Continuous Learning
- Track fix success rates
- Learn from failed fixes
- Update patterns based on new issues
- Integrate user feedback

### 4. Integration
- Work with existing development tools
- Integrate with CI/CD pipelines
- Support multiple IDEs and editors
- Provide API for custom integrations 