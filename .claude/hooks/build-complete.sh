#!/bin/bash
# .claude/hooks/build-complete.sh
set -e

echo "🏗️ Build completed hook..."

BUILD_STATUS="$1"  # success or failure
BUILD_OUTPUT="$2"  # build output/error message

# Update daily logs
TODAY=$(date +"%Y-%m-%d")
DAILY_LOG=".claude/daily-updates/${TODAY}.md"

if [ "$BUILD_STATUS" = "success" ]; then
    EMOJI="✅"
    STATUS_TEXT="successful"
else
    EMOJI="❌"  
    STATUS_TEXT="failed"
fi

cat >> "$DAILY_LOG" << EOF
## Build $(date +"%H:%M") - Build ${STATUS_TEXT}
**Status:** ${EMOJI} ${STATUS_TEXT}
**Output:** ${BUILD_OUTPUT:0:200}...
**Timestamp:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
---

EOF

# Send webhook notification
if [ ! -z "$WEBHOOK_URL" ]; then
    echo "🔔 Sending build status notification..."
    
    curl -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"type\": \"build_complete\",
            \"projectId\": \"${PROJECT_NAME:-unknown}\",
            \"data\": {
                \"status\": \"$BUILD_STATUS\",
                \"output\": \"$BUILD_OUTPUT\",
                \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"
            }
        }" || echo "⚠️ Webhook failed"
fi

echo "✅ Build complete hook finished"