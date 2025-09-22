#!/bin/bash
set -e
echo "📝 Post-commit: Processing commit..."

# Get commit information
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_MSG=$(git log -1 --pretty=format:"%s")
AUTHOR_NAME=$(git log -1 --pretty=format:"%an")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Update daily logs in root directory
echo "📊 Updating daily logs..."
TODAY=$(date +"%Y-%m-%d")
DAILY_LOG="daily-updates/${TODAY}.md"

# Create daily-updates directory if it doesn't exist
mkdir -p daily-updates

# Add entry to daily log
cat >> "$DAILY_LOG" << EOF
## Commit $(date +"%H:%M") - ${COMMIT_MSG}
**Hash:** ${COMMIT_HASH:0:8}
**Author:** ${AUTHOR_NAME}
**Files:** $(git diff --name-only HEAD~1 HEAD | tr '\n' ', ' | sed 's/,$//')
**Timestamp:** ${TIMESTAMP}
---

EOF

# Send webhook notification if configured
if [ ! -z "$WEBHOOK_URL" ]; then
    echo "🔔 Sending webhook notification..."
    curl -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{\"type\": \"commit\", \"projectId\": \"${PROJECT_NAME:-unknown}\", \"data\": {\"hash\": \"$COMMIT_HASH\", \"message\": \"$COMMIT_MSG\", \"author\": \"$AUTHOR_NAME\", \"timestamp\": \"$TIMESTAMP\"}}" \
        --max-time 10 --silent || echo "⚠️ Webhook failed"
fi

echo "✅ Post-commit processing completed"
