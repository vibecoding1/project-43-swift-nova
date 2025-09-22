#!/bin/bash
set -e
echo "🔍 Pre-commit: Running quality checks..."

# Check if in git repository
if [ ! -d .git ]; then
    echo "Not in git repository, skipping git hooks"
    exit 0
fi

# Install dependencies if package.json changed
if git diff --cached --name-only | grep -q "package.json"; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Run linting with auto-fix
if [ -f "package.json" ] && npm run lint --silent 2>/dev/null; then
    echo "🔧 Running ESLint..."
    npm run lint -- --fix || npm run lint
fi

# Run tests
if [ -f "package.json" ] && npm run test --silent 2>/dev/null; then  
    echo "🧪 Running tests..."
    npm run test -- --passWithNoTests --watchAll=false
fi

# TypeScript type checking
if [ -f "tsconfig.json" ]; then
    echo "📋 TypeScript type checking..."
    npx tsc --noEmit
fi

# Build check
if [ -f "package.json" ] && npm run build --silent 2>/dev/null; then
    echo "🏗️ Build verification..."
    npm run build
fi

echo "✅ Pre-commit checks passed"
