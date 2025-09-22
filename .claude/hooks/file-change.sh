#!/bin/bash
set -e
CHANGED_FILE="$1"
echo "📁 File changed: $CHANGED_FILE"

# Auto-save if significant changes
if [ ! -z "$(git status --porcelain)" ]; then
    echo "💾 Auto-saving changes..."
    
    git add .
    
    if ! git diff --cached --quiet; then
        AUTO_MSG="auto-save: $(date '+%H:%M:%S')"
        git commit -m "$AUTO_MSG" --quiet || echo "⚠️ Auto-commit failed"
    fi
fi

# File-specific processing
case "$CHANGED_FILE" in
    *.js|*.jsx|*.ts|*.tsx)
        echo "🔧 Processing JavaScript/TypeScript file..."
        if command -v eslint >/dev/null 2>&1; then
            eslint "$CHANGED_FILE" --fix --quiet || true
        fi
        if command -v prettier >/dev/null 2>&1; then
            prettier --write "$CHANGED_FILE" --log-level=warn || true
        fi
        ;;
    package.json)
        echo "📦 Package.json changed, installing dependencies..."
        npm install --silent || echo "⚠️ npm install failed"
        ;;
esac

echo "✅ File change processed"
