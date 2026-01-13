-- Initialize database
CREATE DATABASE IF NOT EXISTS cloudnative;

-- Connect to cloudnative
\c cloudnative;

-- Create extension for UUID support (if needed in future)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE cloudnative TO postgres;

-- Insert some initial test data (optional)
-- This will be executed only if the users table exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
        -- Table doesn't exist yet (will be created by Hibernate)
        RAISE NOTICE 'Users table will be created by application';
    END IF;
END
$$;
