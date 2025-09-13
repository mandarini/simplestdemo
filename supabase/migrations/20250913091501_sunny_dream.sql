/*
  # Create cats table

  1. New Tables
    - `cats`
      - `id` (uuid, primary key)
      - `name` (text)
      - `age` (integer)
      - `owner_id` (uuid, foreign key to users)
      - `breed` (text)
      - `created_at` (timestamp)
  2. Security
    - Enable RLS on `cats` table
    - Add policies for authenticated users to manage their own cats
*/

-- Create cats table if it doesn't exist
CREATE TABLE IF NOT EXISTS cats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  age integer NOT NULL CHECK (age >= 0 AND age <= 30),
  owner_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  breed text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE cats ENABLE ROW LEVEL SECURITY;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS cats_owner_id_idx ON cats(owner_id);
CREATE INDEX IF NOT EXISTS cats_created_at_idx ON cats(created_at DESC);

-- Drop existing policies if they exist and recreate them
DROP POLICY IF EXISTS "Users can read own cats" ON cats;
DROP POLICY IF EXISTS "Users can insert own cats" ON cats;
DROP POLICY IF EXISTS "Users can update own cats" ON cats;
DROP POLICY IF EXISTS "Users can delete own cats" ON cats;

-- Create policies for authenticated users
CREATE POLICY "Users can read own cats"
  ON cats
  FOR SELECT
  TO authenticated
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert own cats"
  ON cats
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update own cats"
  ON cats
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can delete own cats"
  ON cats
  FOR DELETE
  TO authenticated
  USING (auth.uid() = owner_id);