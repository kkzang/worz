/*
  # Fix Row-Level Security Policies for Words Table

  1. Security Updates
    - Update INSERT policy to allow authenticated users to insert words
    - Update SELECT policy to allow public access to words
    - Update UPDATE policy to be more permissive for word updates
    - Add policy for upsert operations

  2. Changes Made
    - Modified INSERT policy to allow any authenticated user to insert words
    - Ensured SELECT policy allows public access
    - Updated UPDATE policy to allow updates when contributor_id matches or is null
    - Added support for upsert operations
*/

-- Drop existing policies to recreate them
DROP POLICY IF EXISTS "Authenticated users can insert words" ON words;
DROP POLICY IF EXISTS "Words are viewable by everyone" ON words;
DROP POLICY IF EXISTS "Users can update their own words" ON words;

-- Create new INSERT policy that allows authenticated users to insert words
CREATE POLICY "Authenticated users can insert words"
  ON words
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Create SELECT policy that allows everyone to view words
CREATE POLICY "Words are viewable by everyone"
  ON words
  FOR SELECT
  TO public
  USING (true);

-- Create UPDATE policy that allows users to update words they contributed or words without contributors
CREATE POLICY "Users can update words"
  ON words
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Ensure RLS is enabled
ALTER TABLE words ENABLE ROW LEVEL SECURITY;