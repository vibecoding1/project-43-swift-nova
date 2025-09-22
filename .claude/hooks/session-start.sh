#!/bin/bash
set -e
echo "🚀 Session start: Initializing environment..."

# Create necessary directories
mkdir -p daily-updates logs

# Git operations
echo "📥 Syncing with repository..."
git pull origin main --quiet 2>/dev/null || echo "⚠️ Git pull failed (no remote or conflicts)"

# Dependency management
if [ -f "package.json" ]; then
    echo "📦 Installing/updating dependencies..."
    npm install --silent
fi

# Initialize daily log
TODAY=$(date +"%Y-%m-%d")
DAILY_LOG="daily-updates/${TODAY}.md"

if [ ! -f "$DAILY_LOG" ]; then
    cat > "$DAILY_LOG" << EOF
# Daily Updates - ${TODAY}

## Session $(date +"%H:%M") - Session Started
**Action:** Claude Code session initialized
**Project:** ${PROJECT_NAME:-$(basename $(pwd))}
**Workspace:** $(pwd)
**Timestamp:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
---

EOF
fi

# Send session start notification
if [ ! -z "$WEBHOOK_URL" ]; then
    curl -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{\"type\": \"session_start\", \"projectId\": \"${PROJECT_NAME:-unknown}\", \"data\": {\"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}}" \
        --max-time 10 --silent || true
fi

echo "✅ Session initialization completed"
