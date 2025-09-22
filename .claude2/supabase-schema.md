# Supabase Database Schema

## Overview
This document defines the database schema for the React-Vite-Supabase application. All tables use Supabase's built-in Row Level Security (RLS) and include standard audit fields.

## Core Tables

### users (extends auth.users)
Extends Supabase's built-in authentication with additional profile information.

```sql
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  full_name VARCHAR(255),
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- RLS Policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### profiles (alternative user extension)
If you prefer a separate profiles table instead of extending users:

```sql
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  username VARCHAR(50) UNIQUE,
  full_name VARCHAR(255),
  avatar_url TEXT,
  bio TEXT,
  website TEXT,
  location VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX profiles_user_id_idx ON public.profiles(user_id);
CREATE INDEX profiles_username_idx ON public.profiles(username);

-- RLS Policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles are viewable by everyone" ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

## Application-Specific Tables

### posts (example content table)
```sql
CREATE TABLE public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  slug VARCHAR(255) UNIQUE,
  published BOOLEAN DEFAULT false,
  featured_image TEXT,
  tags TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX posts_user_id_idx ON public.posts(user_id);
CREATE INDEX posts_published_idx ON public.posts(published);
CREATE INDEX posts_created_at_idx ON public.posts(created_at DESC);
CREATE INDEX posts_tags_idx ON public.posts USING gin(tags);

-- RLS Policies
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Published posts are viewable by everyone" ON public.posts
  FOR SELECT USING (published = true OR auth.uid() = user_id);

CREATE POLICY "Users can create own posts" ON public.posts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts" ON public.posts
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts" ON public.posts
  FOR DELETE USING (auth.uid() = user_id);
```

### comments (example relationship table)
```sql
CREATE TABLE public.comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX comments_post_id_idx ON public.comments(post_id);
CREATE INDEX comments_user_id_idx ON public.comments(user_id);
CREATE INDEX comments_parent_id_idx ON public.comments(parent_id);

-- RLS Policies
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Comments are viewable by everyone" ON public.comments
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create comments" ON public.comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments" ON public.comments
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments" ON public.comments
  FOR DELETE USING (auth.uid() = user_id);
```

## Utility Tables

### app_settings
```sql
CREATE TABLE public.app_settings (
  key VARCHAR(100) PRIMARY KEY,
  value JSONB,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- RLS Policies
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Settings are viewable by everyone" ON public.app_settings
  FOR SELECT USING (true);

-- Only allow updates through functions/admin
```

## Storage Buckets

### avatars
```sql
-- Create storage bucket for user avatars
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);

-- Storage policies
CREATE POLICY "Avatar images are publicly accessible" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload own avatar" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update own avatar" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
```

### uploads
```sql
-- Create storage bucket for general file uploads
INSERT INTO storage.buckets (id, name, public) VALUES ('uploads', 'uploads', false);

-- Storage policies
CREATE POLICY "Users can view own uploads" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'uploads' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can upload files" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'uploads' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
```

## Functions

### get_user_profile
```sql
CREATE OR REPLACE FUNCTION get_user_profile(user_uuid UUID)
RETURNS TABLE (
  id UUID,
  email VARCHAR,
  full_name VARCHAR,
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMPTZ
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.email,
    u.full_name,
    u.avatar_url,
    u.bio,
    u.created_at
  FROM public.users u
  WHERE u.id = user_uuid;
END;
$$;
```

## Triggers

### Auto-update timestamps
```sql
-- Function to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to all tables with updated_at
CREATE TRIGGER update_posts_updated_at
  BEFORE UPDATE ON public.posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at
  BEFORE UPDATE ON public.comments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## Security Considerations

### Row Level Security (RLS)
- All tables have RLS enabled
- Policies ensure users can only access/modify their own data
- Public data is explicitly marked as viewable by everyone

### Authentication
- Uses Supabase Auth with JWT tokens
- Email confirmation required for new accounts
- Password reset functionality built-in

### Data Validation
- Use database constraints for data integrity
- Implement client-side validation in React components
- Server-side validation through database functions

## Migrations

### Initial Setup
1. Run the schema creation scripts in order
2. Set up storage buckets and policies
3. Configure authentication settings in Supabase dashboard
4. Test RLS policies with different user roles

### Version Control
- Keep migration files in `supabase/migrations/`
- Use descriptive names: `20231201_create_posts_table.sql`
- Always include rollback instructions in comments

## Performance Optimization

### Indexes
- Add indexes on frequently queried columns
- Use composite indexes for multi-column queries
- Monitor query performance with `EXPLAIN ANALYZE`

### Real-time Subscriptions
- Use Supabase real-time for live updates
- Subscribe only to necessary changes
- Clean up subscriptions on component unmount

## Backup and Recovery
- Supabase handles automated backups
- Consider exporting critical data regularly
- Test restore procedures periodically 