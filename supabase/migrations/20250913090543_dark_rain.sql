/*
  # Create cats table with user management

  1. New Tables
    - `cats`
      - `id` (uuid, primary key)
      - `name` (text, not null)
      - `age` (integer, not null)
      - `owner_id` (uuid, references auth.users)
      - `breed` (text, not null)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on `cats` table
    - Add policy for users to read only their own cats
    - Add policy for users to insert their own cats
    - Add policy for users to update their own cats
    - Add policy for users to delete their own cats

  3. Sample Data
    - Insert 30 sample cats with various breeds and ages
    - Distributed across multiple mock users
*/

-- Create cats table
CREATE TABLE IF NOT EXISTS cats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  age integer NOT NULL CHECK (age >= 0 AND age <= 30),
  owner_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  breed text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE cats ENABLE ROW LEVEL SECURITY;

-- RLS Policies
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

-- Create some mock user IDs for sample data
-- In a real application, these would be actual user IDs from auth.users
DO $$
DECLARE
  user1_id uuid := '11111111-1111-1111-1111-111111111111';
  user2_id uuid := '22222222-2222-2222-2222-222222222222';
  user3_id uuid := '33333333-3333-3333-3333-333333333333';
  user4_id uuid := '44444444-4444-4444-4444-444444444444';
  user5_id uuid := '55555555-5555-5555-5555-555555555555';
BEGIN
  -- Insert sample cats data
  INSERT INTO cats (name, age, owner_id, breed) VALUES
    -- User 1's cats
    ('Whiskers', 3, user1_id, 'Persian'),
    ('Shadow', 5, user1_id, 'Maine Coon'),
    ('Luna', 2, user1_id, 'Siamese'),
    ('Tiger', 7, user1_id, 'Bengal'),
    ('Mittens', 4, user1_id, 'British Shorthair'),
    ('Smokey', 6, user1_id, 'Russian Blue'),
    
    -- User 2's cats
    ('Felix', 1, user2_id, 'Ragdoll'),
    ('Ginger', 8, user2_id, 'Orange Tabby'),
    ('Patches', 3, user2_id, 'Calico'),
    ('Snowball', 2, user2_id, 'Turkish Angora'),
    ('Midnight', 5, user2_id, 'Bombay'),
    ('Cleo', 4, user2_id, 'Egyptian Mau'),
    
    -- User 3's cats
    ('Garfield', 6, user3_id, 'Exotic Shorthair'),
    ('Nala', 2, user3_id, 'Abyssinian'),
    ('Simba', 4, user3_id, 'Somali'),
    ('Duchess', 7, user3_id, 'Persian'),
    ('Oliver', 1, user3_id, 'Scottish Fold'),
    ('Bella', 3, user3_id, 'Birman'),
    
    -- User 4's cats
    ('Max', 5, user4_id, 'Norwegian Forest'),
    ('Chloe', 2, user4_id, 'Munchkin'),
    ('Leo', 8, user4_id, 'Savannah'),
    ('Zoe', 3, user4_id, 'Devon Rex'),
    ('Charlie', 6, user4_id, 'Sphynx'),
    ('Lily', 1, user4_id, 'Cornish Rex'),
    
    -- User 5's cats
    ('Milo', 4, user5_id, 'American Shorthair'),
    ('Ruby', 7, user5_id, 'Burmese'),
    ('Oscar', 2, user5_id, 'Manx'),
    ('Daisy', 5, user5_id, 'Tonkinese'),
    ('Jasper', 3, user5_id, 'Ocicat'),
    ('Rosie', 6, user5_id, 'Selkirk Rex');
END $$;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS cats_owner_id_idx ON cats(owner_id);
CREATE INDEX IF NOT EXISTS cats_breed_idx ON cats(breed);