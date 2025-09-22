# Claude AI Assistant Configuration

## 🚀 Session Initialization Protocol

**MANDATORY**: At the start of EVERY session, Claude must:

1. **Load Context**: Read `.claude/daily-updates/{today}.md` and previous 2 days
2. **Confirm Stack**: React 18 + Vite + TypeScript → Vercel, Edge Functions → Supabase CLI
3. **Review Standards**: Apply TypeScript-first development with proper error handling
4. **Check TODOs**: Load outstanding tasks from recent sessions

**Response Template**: Use session template from `.claude/session-checklist.md`

## 🏗️ Tech Stack (Production Ready)

### Frontend → Vercel Deployment
- **React 18**: Modern hooks, concurrent features, TypeScript
- **Vite**: Fast dev server, HMR, optimized builds
- **TypeScript**: Mandatory for all new code (.tsx/.ts)
- **CSS Modules**: Scoped styling approach

### API → Supabase Edge Functions
- **Deno Runtime**: TypeScript-native serverless functions
- **Global Edge**: Low-latency worldwide deployment
- **CORS Handling**: Required for all browser requests
- **Error Handling**: Proper HTTP status codes and responses

### Backend Services → Supabase (Remote Only)
- **PostgreSQL**: Remote managed database with RLS policies
- **Authentication**: JWT tokens with row-level security via remote instance
- **Real-time**: WebSocket subscriptions for live updates
- **Storage**: CDN-backed file storage
- **Edge Functions**: Remote development and testing
- **No Local Supabase**: Always use provided remote URL for simplicity

## 📁 Project Structure

```
├── src/                          # React frontend (TypeScript)
│   ├── components/              # Reusable UI components (.tsx)
│   ├── pages/                   # Route components (.tsx)
│   ├── hooks/                   # Custom React hooks (.ts)
│   ├── utils/                   # Utility functions (.ts)
│   ├── types/                   # TypeScript definitions (.ts)
│   └── main.tsx                 # App entry point
├── supabase/                    # Backend configuration
│   ├── functions/               # Edge Functions (Deno/TypeScript)
│   ├── migrations/              # Database schema changes
│   └── config.toml              # Supabase settings
├── .claude/                     # AI assistant configuration
│   ├── settings.json            # Project permissions & config
│   ├── architecture.md          # System design documentation
│   ├── coding-style.md          # TypeScript & React standards
│   ├── supabase-schema.md       # Database schema & RLS policies
│   ├── session-checklist.md     # Session initialization guide
│   ├── daily-updates/           # Session logs & context
│   ├── commands/                # Workflow documentation
│   └── agents/                  # Specialized AI behaviors
└── CLAUDE.md                    # This file (main entry point)
```

## 🎯 Development Standards

### Code Quality Requirements
- **TypeScript Only**: No .js/.jsx files allowed
- **Error Handling**: All async operations in try/catch blocks
- **Loading States**: React components must handle loading/error states
- **Type Safety**: Proper interfaces for all data structures
- **CORS Support**: All Edge Functions must handle CORS

### React Component Pattern
```tsx
interface ComponentProps {
  userId: string
}

const Component: React.FC<ComponentProps> = ({ userId }) => {
  const [data, setData] = useState<DataType | null>(null)
  const [loading, setLoading] = useState<boolean>(true)
  const [error, setError] = useState<string | null>(null)

  // Proper error handling
  const fetchData = async (): Promise<void> => {
    try {
      setLoading(true)
      const result = await supabaseCall()
      setData(result)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setLoading(false)
    }
  }

  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error}</div>
  return <div>{/* Component JSX */}</div>
}
```

### Edge Function Pattern
```ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Business logic with proper typing
    const result = await processRequest()
    
    return new Response(JSON.stringify({ success: true, data: result }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
```

## 🚢 Deployment Workflow

### Frontend Deployment (Automatic)
```bash
# Vercel auto-deploys on git push to main
git push origin main  # Triggers Vercel build & deploy
```

### Edge Functions Deployment (Manual)
```bash
# Deploy all functions
supabase functions deploy

# Deploy specific function
supabase functions deploy function-name

# Test locally first
supabase functions serve
```

### Environment Variables (Externalized)
- **Frontend (.env.local)**: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`
- **Vercel Secrets**: Same variables set in Vercel dashboard
- **GitHub Secrets**: For CI/CD workflows
- **Supabase Secrets**: `SUPABASE_SERVICE_ROLE_KEY`, function-specific vars
- **🔒 Security**: All URLs/keys are externalized per repo, never logged or exposed

## 📝 Session Management

### Daily Updates System
- **Location**: `.claude/daily-updates/{YYYY-MM-DD}.md`
- **Format**: Stack format (newest entries at top)
- **Limit**: Max 7 lines per session entry
- **Loading**: First 50 lines if file is long

### Session Entry Template
```markdown
## Session {HH:MM} - {Brief Title}
**Issues Solved:** {1-2 line summary}
**Changes Made:** 
- {Key change 1}
- {Key change 2}
**Future TODOs:** {Action items for next session}
---
```

## 🔧 Available Commands

### Development
```bash
npm run dev          # Start Vite dev server
npm run build        # Build for production
npm run preview      # Preview production build
```

### Supabase (Remote Development)
```bash
supabase functions deploy  # Deploy to remote Supabase
supabase functions deploy function-name  # Deploy specific function
supabase db push     # Push schema changes to remote
supabase db pull     # Pull schema from remote
# Note: No local Supabase - always use remote for development
```

### Deployment
```bash
npm run deploy:frontend   # Deploy to Vercel
npm run deploy:functions  # Deploy Edge Functions
npm run deploy           # Deploy both
```

## 🔒 Security & Environment

**CRITICAL SECURITY RULE**: Claude must **NEVER** log, display, or expose:
- Supabase URLs or API keys
- Vercel tokens or project IDs  
- GitHub secrets or tokens
- Any environment variable values

**Always use placeholders** in examples and refer users to `.claude/environment-setup.md`

## 📚 Configuration References

For detailed information, refer to:
- **🔒 Environment Setup**: `.claude/environment-setup.md` (security & secrets)
- **Architecture**: `.claude/architecture.md`
- **Coding Standards**: `.claude/coding-style.md`
- **Database Schema**: `.claude/supabase-schema.md`
- **Deployment Guide**: `.claude/commands/deploy.md`
- **Testing Workflow**: `.claude/commands/test-and-commit.md`
- **Auto-Fix System**: `.claude/commands/auto-fix.md`
- **Session Checklist**: `.claude/session-checklist.md`

## 🎯 Current Session Goals

**Outstanding TODOs**: (Will be populated from daily updates)
- Create example Edge Function
- Implement TypeScript setup
- Test deployment workflows
- Add authentication components

---

**Last Updated**: 2025-09-17 | **Stack**: React+Vite+Supabase+Vercel+Edge Functions 