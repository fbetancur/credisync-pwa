-- =====================================================
-- FIX RLS for Testing - Allow public read on tenants
-- Execute this ONLY for development/testing
-- =====================================================

-- Drop the restrictive policy
DROP POLICY IF EXISTS "Users can view their own tenant" ON tenants;

-- Create a more permissive policy for testing
CREATE POLICY "Allow public read on tenants"
  ON tenants FOR SELECT
  USING (true);  -- Allows anyone to read tenants

-- Note: This is ONLY for testing the connection
-- In production, you should use the original policy that checks auth.uid()

-- To revert to secure policy, run:
-- DROP POLICY IF EXISTS "Allow public read on tenants" ON tenants;
-- CREATE POLICY "Users can view their own tenant"
--   ON tenants FOR SELECT
--   USING (id = (SELECT tenant_id FROM users WHERE id = auth.uid()));
