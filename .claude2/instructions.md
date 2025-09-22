# Project Instructions

## Session Initialization (MANDATORY)
At the START of EVERY session, Claude MUST follow the complete checklist in `.claude/session-checklist.md`:

**REQUIRED STEPS:**
1. **Load Recent Context**: Read daily updates from today and previous 2 days
2. **Confirm Tech Stack**: React+Vite+TypeScript→Vercel, Edge Functions→Supabase CLI
3. **Review Architecture**: Understand deployment flow and file structure
4. **Apply Coding Standards**: TypeScript, error handling, proper patterns
5. **Check Project Status**: Outstanding TODOs and session goals

**Session Start Response Required**: Use template from session-checklist.md to confirm initialization

## Development Guidelines

### Code Style
- Use modern React with hooks
- Prefer functional components
- Use CSS modules for styling
- Follow ESLint configuration

### File Structure
- **Frontend**: `/src/components/`, `/src/pages/`, `/src/utils/`, `/src/assets/`
- **Edge Functions**: `/supabase/functions/` (Deno runtime)
- **Database**: `/supabase/migrations/` and `/supabase/seed.sql`
- **Config**: `vite.config.js`, `supabase/config.toml`, `vercel.json`

### Supabase Integration
- **Database**: Use Supabase client for database operations with proper error handling
- **Auth**: Implement Supabase Auth with RLS policies
- **Edge Functions**: Deploy API endpoints as Supabase Edge Functions (Deno runtime)
- **Real-time**: Use Supabase subscriptions for live updates
- **Storage**: Use Supabase Storage for file uploads
- **TypeScript**: Always use TypeScript for type safety

### Git Workflow
- Use conventional commits
- Create feature branches
- Keep commits atomic and descriptive

### Testing
- Write tests for critical functionality
- Use React Testing Library
- Maintain good test coverage

## Deployment Architecture
- **Frontend**: React + Vite → Deployed to Vercel
- **API**: Supabase Edge Functions → Deployed via Supabase CLI
- **Database**: Supabase PostgreSQL with RLS
- **Storage**: Supabase Storage for assets
- **Auth**: Supabase Auth with JWT tokens

## Project-Specific Notes
- This is a production-ready React + Vite + Supabase + Vercel stack
- Focus on clean, reusable components with TypeScript
- Prioritize developer experience and performance
- Use Edge Functions for server-side logic 


Development Instructions

## Coding Standards
- Use modern React patterns with hooks
- Implement TypeScript for type safety
- Follow component composition principles
- Add proper error handling and loading states

## React/Vite/Supabase Guidelines
- Leverage Vite's fast development experience
- Use Supabase best practices for data operations
- Implement real-time features where appropriate
- Maintain clean component architecture

## Available Development Tools
- **Frontend**: Vite dev server, TypeScript compiler (tsc), ESLint, Prettier
- **Backend**: Supabase CLI for database operations and Edge Functions deployment
- **Testing**: Vitest for unit tests, Playwright for E2E tests
- **Deployment**: Vercel CLI for frontend, Supabase CLI for Edge Functions
- **Database**: Supabase migrations, SQL editor, RLS policies

## Session Management & Daily Updates

### End-of-Session Requirements
At the end of EVERY session, Claude must create/update a daily log in `.claude/daily-updates/{YYYY-MM-DD}.md` with:

**Format (add to TOP of file like a stack):**
```markdown
## Session {time} - {brief_title}
**Issues Solved:** {1-2 line summary}
**Changes Made:** {bullet points of key changes}
**Future TODOs:** {action items for next session}
---
```

### Daily Update Guidelines
- **Concise**: Max 5-7 lines per session entry
- **Actionable**: Clear TODOs for next session
- **Stack format**: New entries at top, oldest at bottom
- **Load limit**: If file >100 lines, only load first 50 lines for context
- **Auto-create**: Create date file if it doesn't exist

### Daily Update Triggers
- After completing user requests
- After fixing bugs or issues
- After adding new features
- Before session ends (mandatory)