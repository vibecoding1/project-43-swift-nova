#!/bin/bash
set -e
echo "🔚 Session end: Performing cleanup..."

# Auto-commit any pending changes
if [ ! -z "$(git status --porcelain)" ]; then
    echo "💾 Final commit of session changes..."
    
    git add .
    
    if ! git diff --cached --quiet; then
        FINAL_MSG="session-end: final commit $(date '+%Y-%m-%d %H:%M:%S')"
        git commit -m "$FINAL_MSG" --quiet || echo "⚠️ Final commit failed"
    fi
fi

# Update daily log
TODAY=$(date +"%Y-%m-%d")
DAILY_LOG="daily-updates/${TODAY}.md"

cat >> "$DAILY_LOG" << EOF
## Session $(date +"%H:%M") - Session Ended  
**Action:** Claude Code session completed
**Final Status:** $(git status --porcelain | wc -l | tr -d ' ') pending changes
**Timestamp:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
---

EOF

# Send session end notification
if [ ! -z "$WEBHOOK_URL" ]; then
    curl -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{\"type\": \"session_end\", \"projectId\": \"${PROJECT_NAME:-unknown}\", \"data\": {\"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\", \"pending_changes\": $(git status --porcelain | wc -l)}}" \
        --max-time 10 --silent || true
fi

echo "✅ Session cleanup completed"
