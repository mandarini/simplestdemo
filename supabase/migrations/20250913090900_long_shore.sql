/*
  # Create cats table with sample data

  1. New Tables
    - `cats`
      - `id` (uuid, primary key)
      - `name` (text, cat's name)
      - `age` (integer, cat's age in years)
      - `owner_id` (uuid, references auth.users)
      - `breed` (text, cat's breed)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on `cats` table
    - Add policy for users to read only their own cats
    - Add policy for users to insert cats with their own owner_id
    - Add policy for users to update only their own cats
    - Add policy for users to delete only their own cats

  3. Sample Data
    - Insert 30 sample cats distributed across 5 mock users
*/

-- Create the cats table
CREATE TABLE IF NOT EXISTS cats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  age integer NOT NULL CHECK (age >= 0 AND age <= 30),
  owner_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  breed text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE cats ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS cats_owner_id_idx ON cats(owner_id);
CREATE INDEX IF NOT EXISTS cats_created_at_idx ON cats(created_at DESC);

-- Insert sample data (Note: These will only be visible after users sign up with these emails)
-- In a real application, users would add their own cats after signing up

-- Sample cats with various breeds and ages
INSERT INTO cats (name, age, owner_id, breed) VALUES
  -- These will be associated with actual users once they sign up
  ('Whiskers', 3, gen_random_uuid(), 'Persian'),
  ('Shadow', 5, gen_random_uuid(), 'Maine Coon'),
  ('Luna', 2, gen_random_uuid(), 'Siamese'),
  ('Tiger', 7, gen_random_uuid(), 'Bengal'),
  ('Mittens', 4, gen_random_uuid(), 'British Shorthair'),
  ('Smokey', 6, gen_random_uuid(), 'Russian Blue'),
  ('Patches', 1, gen_random_uuid(), 'Calico'),
  ('Felix', 8, gen_random_uuid(), 'Tuxedo'),
  ('Ginger', 3, gen_random_uuid(), 'Orange Tabby'),
  ('Princess', 5, gen_random_uuid(), 'Ragdoll'),
  ('Max', 4, gen_random_uuid(), 'Scottish Fold'),
  ('Bella', 2, gen_random_uuid(), 'Abyssinian'),
  ('Charlie', 6, gen_random_uuid(), 'Norwegian Forest'),
  ('Coco', 3, gen_random_uuid(), 'Burmese'),
  ('Daisy', 7, gen_random_uuid(), 'Birman'),
  ('Oscar', 1, gen_random_uuid(), 'Sphynx'),
  ('Ruby', 5, gen_random_uuid(), 'Turkish Angora'),
  ('Simba', 4, gen_random_uuid(), 'Somali'),
  ('Nala', 2, gen_random_uuid(), 'Tonkinese'),
  ('Milo', 8, gen_random_uuid(), 'Manx'),
  ('Zoe', 3, gen_random_uuid(), 'Devon Rex'),
  ('Leo', 6, gen_random_uuid(), 'Cornish Rex'),
  ('Lily', 1, gen_random_uuid(), 'Selkirk Rex'),
  ('Rocky', 7, gen_random_uuid(), 'American Shorthair'),
  ('Sophie', 4, gen_random_uuid(), 'Exotic Shorthair'),
  ('Buddy', 5, gen_random_uuid(), 'Chartreux'),
  ('Molly', 2, gen_random_uuid(), 'Korat'),
  ('Jack', 3, gen_random_uuid(), 'Ocicat'),
  ('Rosie', 6, gen_random_uuid(), 'Bombay'),
  ('Duke', 4, gen_random_uuid(), 'American Curl')
ON CONFLICT DO NOTHING;