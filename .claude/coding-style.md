# Coding Style Guide

## React + TypeScript Standards
- **Components**: PascalCase names, functional components with hooks
- **Files**: .tsx for components, .ts for utilities
- **Props**: TypeScript interfaces, destructured parameters
- **State**: useState/useReducer, proper dependency arrays
- **Effects**: useEffect with cleanup, proper dependencies

## Code Quality
- **Linting**: ESLint with React and TypeScript rules
- **Formatting**: Prettier with consistent config
- **Testing**: Jest + React Testing Library
- **Type Safety**: Strict TypeScript configuration

## File Organization
```
src/
├── components/     # Reusable UI components
├── pages/         # Route/page components  
├── hooks/         # Custom React hooks
├── utils/         # Utility functions
├── types/         # TypeScript type definitions
├── assets/        # Static assets
└── main.tsx       # Application entry point
```

## Git Workflow
- Conventional commits: feat:, fix:, docs:, etc.
- Atomic commits with clear messages
- Feature branches for major changes
- Automated hooks handle quality checks
