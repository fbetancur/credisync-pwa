-- =====================================================
-- FIX: Infinite Recursion in RLS Policies
-- Execute this in Supabase SQL Editor
-- =====================================================

-- The problem: The users table policy tries to query itself, creating infinite recursion
-- Solution: Use auth.uid() directly instead of querying the users table

-- Drop the problematic policies
DROP POLICY IF EXISTS "Users can view their own tenant" ON tenants;
DROP POLICY IF EXISTS "Users can view users in their tenant" ON users;

-- Create fixed policies

-- Tenants: Allow users to see their tenant directly by checking if they exist in users table
CREATE POLICY "Users can view their own tenant"
  ON tenants FOR SELECT
  USING (
    id IN (
      SELECT tenant_id 
      FROM users 
      WHERE id = auth.uid()
    )
  );

-- Users: Allow users to see other users in their tenant
-- We use a security definer function to break the recursion
CREATE OR REPLACE FUNCTION get_user_tenant_id()
RETURNS UUID
LANGUAGE SQL
SECURITY DEFINER
STABLE
AS $$
  SELECT tenant_id FROM users WHERE id = auth.uid() LIMIT 1;
$$;

CREATE POLICY "Users can view users in their tenant"
  ON users FOR SELECT
  USING (tenant_id = get_user_tenant_id());

-- Also allow users to see their own record
CREATE POLICY "Users can view their own record"
  ON users FOR SELECT
  USING (id = auth.uid());

