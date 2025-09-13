/*
  # Create cats table with demo data

  1. New Tables
    - `cats`
      - `id` (uuid, primary key)
      - `name` (text)
      - `age` (integer)
      - `owner_id` (uuid, foreign key to auth.users)
      - `breed` (text)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on `cats` table
    - Add policies for users to manage only their own cats

  3. Demo Data
    - Creates 5 demo users in auth.users
    - Inserts 30 cats distributed among these users
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

-- Enable RLS
ALTER TABLE cats ENABLE ROW LEVEL SECURITY;

-- Create policies
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

-- Insert demo users into auth.users (these are fake users for demo purposes)
INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES 
  (
    'd6bcac7a-25e1-42f2-bc67-39270d2ee0e3',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'alice@demo.com',
    '$2a$10$dummy.hash.for.demo.purposes.only',
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{}',
    false,
    '',
    '',
    '',
    ''
  ),
  (
    'f8e2c4b6-1a3d-4e5f-9c8b-7a6d5e4f3c2b',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'bob@demo.com',
    '$2a$10$dummy.hash.for.demo.purposes.only',
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{}',
    false,
    '',
    '',
    '',
    ''
  ),
  (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'charlie@demo.com',
    '$2a$10$dummy.hash.for.demo.purposes.only',
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{}',
    false,
    '',
    '',
    '',
    ''
  ),
  (
    '12345678-9abc-def0-1234-56789abcdef0',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'diana@demo.com',
    '$2a$10$dummy.hash.for.demo.purposes.only',
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{}',
    false,
    '',
    '',
    '',
    ''
  ),
  (
    'abcdef12-3456-7890-abcd-ef123456789a',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'eve@demo.com',
    '$2a$10$dummy.hash.for.demo.purposes.only',
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{}',
    false,
    '',
    '',
    '',
    ''
  )
ON CONFLICT (id) DO NOTHING;

-- Insert demo cats data
INSERT INTO cats (name, age, owner_id, breed) VALUES
  -- Alice's cats (6 cats)
  ('Whiskers', 3, 'd6bcac7a-25e1-42f2-bc67-39270d2ee0e3', 'Persian'),
  ('Shadow', 5, 'd6bcac7a-25e1-42f2-bc67-39270d2ee0e3', 'Maine Coon'),
  ('Luna', 2, 'd6bcac7a-25e1-42f2-bc67-39270d2ee0e3', 'Siamese'),
  ('Mittens', 4, 'd6bcac7a-25e1-42f2-bc67-39270d2ee0e3', 'British Shorthair'),
  ('Tiger', 6, 'd6bcac7a-25e1-42f2-bc67-39270d2ee0e3', 'Bengal'),
  ('Smokey', 1, 'd6bcac7a-25e1-42f2-bc67-39270d2ee0e3', 'Russian Blue'),
  
  -- Bob's cats (6 cats)
  ('Felix', 7, 'f8e2c4b6-1a3d-4e5f-9c8b-7a6d5e4f3c2b', 'Ragdoll'),
  ('Ginger', 3, 'f8e2c4b6-1a3d-4e5f-9c8b-7a6d5e4f3c2b', 'Orange Tabby'),
  ('Patches', 5, 'f8e2c4b6-1a3d-4e5f-9c8b-7a6d5e4f3c2b', 'Calico'),
  ('Oreo', 2, 'f8e2c4b6-1a3d-4e5f-9c8b-7a6d5e4f3c2b', 'Tuxedo'),
  ('Snowball', 4, 'f8e2c4b6-1a3d-4e5f-9c8b-7a6d5e4f3c2b', 'Turkish Angora'),
  ('Midnight', 8, 'f8e2c4b6-1a3d-4e5f-9c8b-7a6d5e4f3c2b', 'Bombay'),
  
  -- Charlie's cats (6 cats)
  ('Fluffy', 1, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Norwegian Forest'),
  ('Peanut', 3, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Abyssinian'),
  ('Coco', 5, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Burmese'),
  ('Jasper', 2, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Scottish Fold'),
  ('Muffin', 4, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Exotic Shorthair'),
  ('Storm', 6, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Chartreux'),
  
  -- Diana's cats (6 cats)
  ('Princess', 3, '12345678-9abc-def0-1234-56789abcdef0', 'Himalayan'),
  ('Bandit', 7, '12345678-9abc-def0-1234-56789abcdef0', 'American Shorthair'),
  ('Duchess', 2, '12345678-9abc-def0-1234-56789abcdef0', 'Birman'),
  ('Romeo', 5, '12345678-9abc-def0-1234-56789abcdef0', 'Somali'),
  ('Bella', 1, '12345678-9abc-def0-1234-56789abcdef0', 'Manx'),
  ('Max', 4, '12345678-9abc-def0-1234-56789abcdef0', 'Cornish Rex'),
  
  -- Eve's cats (6 cats)
  ('Angel', 6, 'abcdef12-3456-7890-abcd-ef123456789a', 'Sphynx'),
  ('Buddy', 3, 'abcdef12-3456-7890-abcd-ef123456789a', 'Devon Rex'),
  ('Chloe', 8, 'abcdef12-3456-7890-abcd-ef123456789a', 'Oriental Shorthair'),
  ('Oscar', 2, 'abcdef12-3456-7890-abcd-ef123456789a', 'Tonkinese'),
  ('Ruby', 5, 'abcdef12-3456-7890-abcd-ef123456789a', 'Ocicat'),
  ('Zeus', 1, 'abcdef12-3456-7890-abcd-ef123456789a', 'Selkirk Rex');