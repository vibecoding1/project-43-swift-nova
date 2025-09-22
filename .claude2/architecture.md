# Architecture Documentation

## Technical Stack

### Frontend (Deployed to Vercel)
- **React 18**: UI library with modern hooks and concurrent features
- **Vite**: Fast build tool and dev server with HMR
- **TypeScript**: Type safety and better developer experience
- **CSS Modules**: Scoped styling with CSS modules/vanilla CSS

### API Layer (Supabase Edge Functions)
- **Supabase Edge Functions**: Serverless functions running on Deno runtime
- **Deno**: Modern runtime for TypeScript/JavaScript
- **Global Edge Network**: Low latency worldwide deployment

### Backend Services (Supabase)
- **PostgreSQL**: Managed database with extensions
- **Authentication**: Built-in auth with RLS policies
- **Real-time**: WebSocket subscriptions for live updates
- **Storage**: File storage with CDN
- **Row Level Security**: Database-level security policies

### Deployment & Infrastructure
- **Frontend**: Vercel (automatic deployments from Git)
- **API**: Supabase Edge Functions (deployed via Supabase CLI)
- **Database**: Supabase managed PostgreSQL
- **CDN**: Vercel Edge Network + Supabase CDN

### Development Tools
- **Vite**: Development server and bundler
- **TypeScript**: Static type checking
- **ESLint**: Code linting and formatting
- **Vitest**: Unit testing framework
- **Playwright**: End-to-end testing
- **Supabase CLI**: Database migrations and function deployment

## Architecture Decisions

### Why Vite?
- Faster development builds
- Better development experience
- Modern ES modules support
- Optimized production builds

### Why Supabase?
- **Rapid Development**: Built-in auth, database, and real-time features
- **Edge Functions**: Serverless API endpoints with global distribution
- **PostgreSQL**: Full-featured database with extensions and RLS
- **Real-time**: WebSocket subscriptions for live updates
- **No Infrastructure Management**: Fully managed backend services

### Why Vercel?
- **Edge Network**: Global CDN for fast content delivery
- **Zero Config**: Automatic builds and deployments from Git
- **Preview Deployments**: Branch-based preview environments
- **Analytics**: Built-in performance and usage analytics
- **Serverless**: Automatic scaling without server management

## Project Structure
```
├── src/                          # Frontend React application
│   ├── components/              # Reusable UI components
│   ├── pages/                   # Route-based page components
│   ├── hooks/                   # Custom React hooks
│   ├── utils/                   # Utility functions
│   ├── types/                   # TypeScript type definitions
│   ├── assets/                  # Static assets
│   └── main.tsx                 # Application entry point
├── supabase/                    # Supabase configuration
│   ├── functions/               # Edge Functions (Deno runtime)
│   │   ├── function-name/       # Individual function directories
│   │   │   └── index.ts         # Function implementation
│   ├── migrations/              # Database migrations
│   ├── seed.sql                 # Database seed data
│   └── config.toml              # Supabase configuration
├── public/                      # Static assets served by Vite
├── .env.local                   # Local environment variables
├── .env.example                 # Environment variables template
├── vite.config.ts               # Vite configuration
├── vercel.json                  # Vercel deployment configuration
└── supabase.config.ts           # Supabase client configuration (remote only)
```

## Data Flow

### Frontend → Backend
1. **React Components** call Supabase client or Edge Functions
2. **Authentication** handled by Supabase Auth with JWT tokens
3. **Database Operations** through Supabase client with RLS policies
4. **API Calls** to Supabase Edge Functions for server-side logic

### Real-time Updates
1. **Supabase Subscriptions** listen for database changes
2. **WebSocket Connections** provide live updates to React components
3. **State Management** through React hooks/context/Zustand

### Deployment Flow
1. **Git Push** triggers Vercel deployment for frontend
2. **Supabase CLI** deploys Edge Functions to remote Supabase
3. **Database Migrations** applied to remote instance via CLI
4. **Environment Variables** externalized per repo (Vercel, GitHub, Supabase)
5. **Remote Development**: No local Supabase - always use provided remote URL

## Security Considerations

### Database Security
- **Row Level Security (RLS)**: Database-level access control
- **JWT Authentication**: Secure token-based auth with Supabase
- **API Keys**: Separate anon and service role keys
- **Database Policies**: Fine-grained access control per table

### Application Security
- **Environment Variables**: Externalized per repo, never logged or committed
- **Secret Management**: Vercel, GitHub, and Supabase handle secrets separately
- **HTTPS Everywhere**: Vercel and Supabase enforce HTTPS
- **CORS Configuration**: Proper cross-origin request handling
- **Input Validation**: Client and server-side validation
- **🔒 Claude Security**: Never log, display, or expose any URLs or API keys

### Edge Function Security
- **Service Role**: Elevated permissions for server-side operations
- **Request Validation**: Input sanitization and validation
- **Rate Limiting**: Built-in protection against abuse
- **Secrets Management**: Environment variables for sensitive data 