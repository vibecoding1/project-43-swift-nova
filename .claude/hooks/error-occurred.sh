
#!/bin/bash
# .claude/hooks/error-occurred.sh
set -e

echo "🚨 Error occurred hook..."

ERROR_TYPE="$1"     # Type of error
ERROR_MESSAGE="$2"  # Error message
ERROR_FILE="$3"     # File where error occurred (if applicable)

# Update daily logs
TODAY=$(date +"%Y-%m-%d")
DAILY_LOG=".claude/daily-updates/${TODAY}.md"

cat >> "$DAILY_LOG" << EOF
## Error $(date +"%H:%M") - ${ERROR_TYPE}
**Type:** ${ERROR_TYPE}
**Message:** ${ERROR_MESSAGE:0:200}...
**File:** ${ERROR_FILE:-N/A}
**Timestamp:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
---

EOF

# Attempt auto-fix for common errors
case "$ERROR_TYPE" in
    "lint_error"|"eslint_error")
        echo "🔧 Attempting auto-fix for linting error..."
        if [ ! -z "$ERROR_FILE" ] && [ -f "$ERROR_FILE" ]; then
            eslint "$ERROR_FILE" --fix || echo "⚠️ Auto-fix failed"
        else
            npm run lint -- --fix || echo "⚠️ Global auto-fix failed"
        fi
        ;;
    "build_error")
        echo "🏗️ Attempting build error resolution..."
        # Try installing dependencies
        npm install || echo "⚠️ npm install failed"
        ;;
    "type_error"|"typescript_error")
        echo "📋 TypeScript error detected..."
        if command -v tsc > /dev/null; then
            tsc --noEmit || echo "⚠️ Type checking failed"
        fi
        ;;
esac

# Send error notification
if [ ! -z "$WEBHOOK_URL" ]; then
    echo "🔔 Sending error notification..."
    
    curl -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"type\": \"error\",
            \"projectId\": \"${PROJECT_NAME:-unknown}\",
            \"data\": {
                \"error_type\": \"$ERROR_TYPE\",
                \"message\": \"$ERROR_MESSAGE\",
                \"file\": \"$ERROR_FILE\",
                \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"
            }
        }" || echo "⚠️ Webhook failed"
fi

echo "✅ Error handling completed"