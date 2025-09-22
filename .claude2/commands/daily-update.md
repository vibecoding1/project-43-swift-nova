# Daily Update Command

## Overview
Automated system for Claude to log session summaries and maintain context across conversations.

## Usage
Claude will automatically:
1. Create/update daily files at session end
2. Add entries in stack format (newest at top)
3. Load previous entries for context

## File Structure
```
.claude/daily-updates/
├── README.md              # System documentation
├── 2025-09-17.md         # Today's updates
├── 2025-09-16.md         # Yesterday's updates
└── ...                   # Historical updates
```

## Entry Format
```markdown
## Session {HH:MM} - {Brief Title}
**Issues Solved:** {1-2 line summary}
**Changes Made:** 
- {Key change 1}
- {Key change 2}  
**Future TODOs:** {Action items}
---
```

## Implementation

### Auto-Update Function
```javascript
// Helper function for Claude to create daily updates
const createDailyUpdate = (sessionData) => {
  const date = new Date().toISOString().split('T')[0] // YYYY-MM-DD
  const time = new Date().toLocaleTimeString('en-US', { 
    hour12: false, 
    hour: '2-digit', 
    minute: '2-digit' 
  })
  
  const entry = `## Session ${time} - ${sessionData.title}
**Issues Solved:** ${sessionData.issues}
**Changes Made:** 
${sessionData.changes.map(c => `- ${c}`).join('\n')}
**Future TODOs:** ${sessionData.todos}
---

`
  
  const filePath = `.claude/daily-updates/${date}.md`
  
  // Prepend to file (stack format)
  const existingContent = fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf8') : ''
  fs.writeFileSync(filePath, entry + existingContent)
}
```

### Context Loading
```javascript
// Load recent daily updates for context
const loadRecentUpdates = (days = 3) => {
  const updates = []
  for (let i = 0; i < days; i++) {
    const date = new Date()
    date.setDate(date.getDate() - i)
    const dateStr = date.toISOString().split('T')[0]
    const filePath = `.claude/daily-updates/${dateStr}.md`
    
    if (fs.existsSync(filePath)) {
      const content = fs.readFileSync(filePath, 'utf8')
      const lines = content.split('\n')
      // Load only first 50 lines if file is long
      const limitedContent = lines.slice(0, 50).join('\n')
      updates.push({ date: dateStr, content: limitedContent })
    }
  }
  return updates
}
```

## Configuration (settings.json)
```json
{
  "ai_assistant": {
    "daily_updates": {
      "enabled": true,
      "format": "concise",
      "max_lines_per_session": 7,
      "load_limit": 50,
      "auto_create_date_files": true
    }
  }
}
```

## Benefits

### For Claude
- **Context continuity** across sessions
- **Progress tracking** for complex tasks
- **TODO management** for multi-session projects

### For Users
- **Session history** to understand what was accomplished
- **Quick catch-up** when resuming work after breaks
- **Progress visibility** for long-term projects

## Best Practices

### Writing Updates
- **Be concise**: Max 7 lines per session
- **Be specific**: Mention file names, features, fixes
- **Be actionable**: Clear TODOs for next session
- **Be honest**: Include both successes and blockers

### Managing Files
- **Daily rotation**: New file each day
- **Size limits**: Load only first 50 lines of long files
- **Stack format**: Newest entries always at top
- **Cleanup**: Archive old files monthly (optional)

## Examples

### Good Entry
```markdown
## Session 14:30 - User Authentication Implementation
**Issues Solved:** Fixed login form validation and Supabase auth integration
**Changes Made:** 
- Created LoginForm.jsx with proper error handling
- Added useAuth hook for session management
- Updated routing to protect authenticated pages
**Future TODOs:** Add password reset functionality, implement user profile page
---
```

### Bad Entry (too verbose)
```markdown
## Session 14:30 - Working on Various Things
**Issues Solved:** We worked on multiple different components and fixed some bugs and added features and also did some refactoring of the codebase to make it better and more maintainable...
[continues for 20+ lines]
```

## Troubleshooting

### File Not Found
- Claude will auto-create date files when needed
- Check `.claude/daily-updates/` directory exists

### Long Files
- Only first 50 lines loaded for context
- Consider archiving old entries monthly

### Missing Context
- Review previous day's TODOs
- Check recent session summaries
- Load multiple days if needed 