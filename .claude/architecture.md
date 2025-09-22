# Architecture Overview

## Deployment Strategy
- **Frontend**: React + Vite → Vercel (automatic from Git)
- **Backend**: Supabase Edge Functions (deployed via CLI)
- **Database**: Supabase PostgreSQL with Row Level Security
- **Storage**: Supabase Storage with CDN
- **Auth**: Supabase Auth with JWT tokens

## Development Flow with Claude Code
1. Claude Code manages development environment via MCP servers
2. Hooks automate testing, building, and quality checks  
3. Daily updates maintain context across sessions
4. Real-time notifications via webhooks
5. Multi-project isolation in separate workspaces

## Security Architecture
- Row Level Security (RLS) on database tables
- Environment variables externalized per project
- Git credentials managed securely
- Webhook signature verification
- Project workspace isolation

## MCP Integration
- Git operations via official MCP server
- File system operations via MCP server
- Extensible for additional MCP servers (Supabase, GitHub, etc.)
