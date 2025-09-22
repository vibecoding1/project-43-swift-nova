# Environment Setup Guide

## 🔒 Security First Approach

**CRITICAL**: All URLs, API keys, and secrets are **externalized per repository** and must **NEVER** be logged, displayed, or exposed by Claude.

## 📋 Required Environment Variables

### Frontend (.env.local)
```bash
# Never commit this file - add to .gitignore
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
VITE_APP_NAME=your-app-name
```

### Vercel Environment Variables
Set in Vercel Dashboard → Project Settings → Environment Variables:
- `VITE_SUPABASE_URL` (Production, Preview, Development)
- `VITE_SUPABASE_ANON_KEY` (Production, Preview, Development)
- `VITE_APP_NAME` (optional)

### GitHub Secrets
Set in GitHub Repository → Settings → Secrets and Variables → Actions:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`
- `VERCEL_TOKEN` (for deployments)
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`

### Supabase Edge Functions
Set in Supabase Dashboard → Project Settings → Edge Functions:
- `SUPABASE_SERVICE_ROLE_KEY` (for elevated permissions)
- Custom function-specific variables as needed

## 🚫 What Claude Must NEVER Do

- ❌ Log or display any API keys or URLs
- ❌ Show environment variable values
- ❌ Expose Supabase project IDs or secrets
- ❌ Print Vercel or GitHub tokens
- ❌ Include real secrets in code examples

## ✅ What Claude Should Do

- ✅ Reference environment variables by name only
- ✅ Use placeholder values in examples (`YOUR_PROJECT_ID`, `YOUR_KEY_HERE`)
- ✅ Guide users to set up their own externalized configs
- ✅ Remind users to never commit secrets

## 🔧 Development Workflow

### Remote-Only Supabase
```bash
# No local Supabase instance
# Always use the provided remote URL from environment variables

# Link to remote project
supabase link --project-ref your-project-ref

# Deploy functions to remote
supabase functions deploy

# Push database changes to remote
supabase db push

# Pull schema from remote
supabase db pull
```

### Environment File Template
Create `.env.example` for each repo:
```bash
# Copy this to .env.local and fill in your values
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
VITE_APP_NAME=your-app-name
```

## 📁 File Structure for Secrets

```
├── .env.local                    # Local secrets (NEVER commit)
├── .env.example                  # Template (safe to commit)
├── .gitignore                    # Must include .env.local
└── src/utils/supabase.ts         # Uses env vars, no hardcoded values
```

## 🛡️ Security Best Practices

### Repository Level
- Add `.env.local` to `.gitignore`
- Use `.env.example` as template
- Never commit actual secrets
- Use different values for different environments

### Platform Level
- **Vercel**: Set environment variables in dashboard
- **GitHub**: Use repository secrets for CI/CD
- **Supabase**: Manage secrets in project settings
- **Local**: Use `.env.local` file only

### Code Level
- Always use `import.meta.env.VITE_*` for frontend
- Always use `Deno.env.get()` for Edge Functions
- Include environment variable validation
- Provide helpful error messages for missing vars

## 🔄 Multi-Repository Setup

Since `.claude/` will be present in every repo:

### Per Repository
- Each repo has its own Supabase project
- Each repo has its own Vercel deployment
- Each repo has its own environment variables
- Each repo uses the same `.claude/` configuration structure

### Shared Configuration
- Same `.claude/` directory structure
- Same development patterns and standards
- Same deployment workflows
- Different secrets and URLs per repo

## 🚨 Claude Security Rules

When users ask about environment variables or secrets:
1. **Never show actual values**
2. **Refer to this guide**
3. **Use placeholder examples**
4. **Remind about security**
5. **Guide to proper setup**

Example response:
```
I can help you set up environment variables, but I won't display actual secrets. 
Please refer to .claude/environment-setup.md for the complete guide.
You'll need to set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY in your .env.local file.
```

## 📖 Quick Setup Checklist

For each new repository:
- [ ] Copy `.claude/` directory
- [ ] Create `.env.local` with your project's values
- [ ] Add environment variables to Vercel dashboard
- [ ] Set up GitHub secrets for CI/CD
- [ ] Configure Supabase Edge Functions secrets
- [ ] Test remote Supabase connection
- [ ] Verify deployment pipeline

Remember: **Security first, externalize everything, remote-only development!** 