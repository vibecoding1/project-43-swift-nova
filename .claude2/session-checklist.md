# Claude Session Start Checklist

## 🚀 MANDATORY Session Initialization

At the **START of EVERY session**, Claude must complete this checklist:

### ✅ 1. Load Recent Context (REQUIRED)
- [ ] Read `.claude/daily-updates/{today}.md` (today's file)
- [ ] Read previous 2 days of daily updates for context
- [ ] If daily update file >50 lines, load only first 50 lines
- [ ] Extract any outstanding TODOs from recent sessions

### ✅ 2. Tech Stack Confirmation (REQUIRED)
- [ ] **Frontend**: React 18 + Vite + TypeScript → Deployed to Vercel
- [ ] **API**: Supabase Edge Functions (Deno runtime) → Deployed via Supabase CLI  
- [ ] **Database**: Supabase PostgreSQL with RLS policies
- [ ] **Auth**: Supabase Auth with JWT tokens
- [ ] **Storage**: Supabase Storage for file uploads

### ✅ 3. Architecture Understanding (REQUIRED)
- [ ] Review `.claude/architecture.md` for current system design
- [ ] Understand deployment flow: Git→Vercel (frontend), CLI→Supabase (functions)
- [ ] Confirm file structure: `/src` (React), `/supabase/functions` (Edge Functions)
- [ ] Verify environment variables setup for both platforms

### ✅ 4. Coding Standards Awareness (REQUIRED)
- [ ] Review `.claude/coding-style.md` for current standards
- [ ] Confirm TypeScript usage for all new code (.tsx/.ts extensions)
- [ ] Understand Edge Function patterns (CORS, error handling, types)
- [ ] Apply React best practices (hooks, error boundaries, loading states)

### ✅ 5. Project Status Check (REQUIRED)
- [ ] Check for any pending TODOs from previous sessions
- [ ] Understand current development priorities
- [ ] Identify any blockers or issues to address
- [ ] Confirm user's immediate goals for this session

## 📋 Session Start Response Template

After completing the checklist, Claude should respond with:

```markdown
## 🎯 Session Initialized - React+Vite+Supabase+Vercel Stack

**Context Loaded**: ✅ Reviewed daily updates from {dates}
**Outstanding TODOs**: {list any pending tasks}
**Tech Stack Confirmed**: ✅ React→Vercel, Edge Functions→Supabase
**Ready to assist with**: {user's immediate goals}

**Recent Progress**: {brief summary from daily updates}
**Current Focus**: {based on recent TODOs and context}
```

## 🔄 During Session

### Code Generation Standards
- **Always use TypeScript** (.tsx/.ts extensions)
- **Include proper error handling** for all async operations
- **Add loading and error states** for React components
- **Follow Edge Function patterns** for API endpoints
- **Include type definitions** for all interfaces

### Deployment Awareness
- **Frontend changes** → Mention Vercel deployment
- **API changes** → Mention Supabase CLI deployment
- **Database changes** → Mention migration requirements
- **Environment variables** → Specify Vercel vs Supabase setup

## 📝 Session End Requirements

At session end, Claude must:
1. **Update daily log** with session summary
2. **List specific changes** made during session
3. **Identify future TODOs** for next session
4. **Confirm deployment steps** if code was changed

## 🚨 Critical Reminders

- **Never assume context** - always load daily updates first
- **Always use TypeScript** - no JavaScript files
- **Include error handling** - never skip try/catch blocks
- **Think full-stack** - consider both frontend and Edge Functions
- **Plan deployments** - mention both Vercel and Supabase CLI steps

## 📚 Quick Reference Files

When needed during session:
- **Architecture**: `.claude/architecture.md`
- **Coding Style**: `.claude/coding-style.md` 
- **Database Schema**: `.claude/supabase-schema.md`
- **Deploy Process**: `.claude/commands/deploy.md`
- **Auto-Fix**: `.claude/commands/auto-fix.md`
- **Testing**: `.claude/commands/test-and-commit.md` 