# Coding Style Guide

## General Principles
- Write clean, readable, and maintainable code
- Follow established conventions consistently
- Prioritize clarity over cleverness
- Use meaningful names for variables, functions, and components

## TypeScript Standards

### File Extensions
- **React Components**: `.tsx` for JSX components
- **TypeScript Files**: `.ts` for utilities and types
- **Edge Functions**: `.ts` for Deno runtime functions
- **Configuration**: `.ts` for config files when possible

### Naming Conventions
- **Components**: PascalCase (`UserProfile`, `NavBar`)
- **Variables/Functions**: camelCase (`userData`, `handleSubmit`)
- **Types/Interfaces**: PascalCase (`User`, `ApiResponse`)
- **Constants**: UPPER_SNAKE_CASE (`API_BASE_URL`, `MAX_RETRY_ATTEMPTS`)
- **Files**: kebab-case for utilities, PascalCase for components
  - Components: `UserProfile.tsx`
  - Utils: `api-helpers.ts`
  - Types: `user.types.ts`
  - Edge Functions: `function-name/index.ts`

### React Component Structure
```tsx
// 1. Imports (external libraries first, then internal)
import React, { useState, useEffect } from 'react'
import { supabase } from '../utils/supabase'
import type { User } from '../types/user.types'

// 2. Type definitions
interface UserProfileProps {
  userId: string
}

// 3. Component definition
const UserProfile: React.FC<UserProfileProps> = ({ userId }) => {
  // 4. State declarations with types
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState<boolean>(true)
  const [error, setError] = useState<string | null>(null)

  // 5. Effects
  useEffect(() => {
    fetchUser()
  }, [userId])

  // 6. Event handlers with proper typing
  const handleSubmit = async (data: FormData): Promise<void> => {
    try {
      // Implementation with error handling
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    }
  }

  // 7. Render with proper error/loading states
  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error}</div>

  return (
    <div className="user-profile">
      {/* JSX content */}
    </div>
  )
}

export default UserProfile
```

### Formatting Rules
- Use 2 spaces for indentation
- Use single quotes for strings
- Add trailing commas in objects/arrays
- Use semicolons consistently
- Maximum line length: 100 characters

### React Specific
- Use functional components with hooks
- Destructure props in function parameters when possible
- Use meaningful prop names and add PropTypes/TypeScript
- Keep components small and focused (< 200 lines)
- Extract custom hooks for reusable logic

## CSS Standards

### Class Naming
- Use BEM methodology: `block__element--modifier`
- Keep class names descriptive and semantic
- Use kebab-case: `user-profile__avatar--large`

### Organization
```css
/* Component styles should be organized as: */
/* 1. Layout properties */
/* 2. Visual properties */
/* 3. Typography */
/* 4. Interactions */

.user-profile {
  /* Layout */
  display: flex;
  flex-direction: column;
  padding: 1rem;
  
  /* Visual */
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  
  /* Typography */
  font-family: system-ui, sans-serif;
  
  /* Interactions */
  transition: box-shadow 0.2s ease;
}
```

## Supabase Integration

### Database Operations
```ts
// Use consistent error handling with TypeScript
const fetchUsers = async (): Promise<User[]> => {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('*')
    
    if (error) throw error
    return data as User[]
  } catch (error) {
    console.error('Error fetching users:', error)
    throw error
  }
}
```

## Edge Functions (Supabase)

### Function Structure
```ts
// supabase/functions/function-name/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Types
interface RequestBody {
  userId: string
  data: any
}

interface ResponseBody {
  success: boolean
  data?: any
  error?: string
}

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request): Promise<Response> => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Parse request body
    const body: RequestBody = await req.json()

    // Business logic here
    const result = await processRequest(body, supabase)

    // Return success response
    return new Response(
      JSON.stringify({ success: true, data: result } as ResponseBody),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    // Return error response
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message 
      } as ResponseBody),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})
```

### Edge Function Best Practices
- **Always handle CORS** for browser requests
- **Use TypeScript** for type safety
- **Validate inputs** before processing
- **Use service role key** for elevated permissions
- **Handle errors gracefully** with proper HTTP status codes
- **Keep functions focused** on single responsibilities

### Authentication
- Always check auth state before protected operations
- Handle loading and error states gracefully
- Use consistent auth patterns across components

## File Organization

### Directory Structure
```
src/
├── components/
│   ├── common/        # Reusable UI components
│   ├── forms/         # Form-specific components
│   └── layout/        # Layout components
├── pages/             # Route components
├── hooks/             # Custom React hooks
├── utils/             # Utility functions
├── services/          # API/external service integrations
└── constants/         # Application constants
```

### Import Organization
```js
// 1. React/External libraries
import React from 'react'
import { BrowserRouter } from 'react-router-dom'

// 2. Internal components
import Header from './components/Header'
import Footer from './components/Footer'

// 3. Utils/services
import { supabase } from './utils/supabase'
import { formatDate } from './utils/helpers'

// 4. Constants
import { ROUTES } from './constants/routes'
```

## Error Handling
- Use try-catch blocks for async operations
- Provide meaningful error messages
- Log errors appropriately (console.error for development)
- Show user-friendly error states in UI

## Performance Guidelines
- Use React.memo for expensive components
- Implement proper loading states
- Optimize images and assets
- Minimize bundle size with code splitting
- Use Supabase RLS for security and performance

## Testing Standards
- Write descriptive test names
- Test user interactions, not implementation details
- Mock external dependencies (Supabase calls)
- Aim for good coverage of critical paths

## Documentation
- Add JSDoc comments for complex functions
- Document component props and usage
- Keep README files updated
- Use meaningful commit messages 