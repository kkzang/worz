/*
  # Word Database Schema

  1. New Tables
    - `words`: Stores word definitions and translations
      - `id` (uuid, primary key)
      - `word` (text, unique)
      - `category` (text)
      - `definition` (text)
      - `korean_translation` (text)
      - `japanese_translation` (text)
      - `bookmarks` (integer)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
      - `contributor_id` (uuid, references auth.users)
    
    - `word_relationships`: Stores relationships between words
      - `id` (uuid, primary key)
      - `source_word_id` (uuid, references words)
      - `target_word_id` (uuid, references words)
      - `relationship_type` (text: synonym, antonym, related)
      - `description` (text)
      - `created_at` (timestamptz)
      - `contributor_id` (uuid, references auth.users)

  2. Security
    - Enable RLS on both tables
    - Public read access
    - Authenticated users can insert
    - Contributors can update their own entries

  3. Performance
    - Indexes on frequently queried columns
    - Updated_at trigger for tracking modifications
*/

-- Create words table
CREATE TABLE IF NOT EXISTS words (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word text UNIQUE NOT NULL,
  category text,
  definition text,
  korean_translation text,
  japanese_translation text,
  bookmarks integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  contributor_id uuid REFERENCES auth.users(id)
);

-- Create word_relationships table
CREATE TABLE IF NOT EXISTS word_relationships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_word_id uuid REFERENCES words(id) ON DELETE CASCADE,
  target_word_id uuid REFERENCES words(id) ON DELETE CASCADE,
  relationship_type text NOT NULL CHECK (relationship_type IN ('synonym', 'antonym', 'related')),
  description text,
  created_at timestamptz DEFAULT now(),
  contributor_id uuid REFERENCES auth.users(id),
  UNIQUE(source_word_id, target_word_id, relationship_type)
);

-- Enable RLS
ALTER TABLE words ENABLE ROW LEVEL SECURITY;
ALTER TABLE word_relationships ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Allow public read access on words" ON words;
  DROP POLICY IF EXISTS "Allow authenticated users to insert words" ON words;
  DROP POLICY IF EXISTS "Allow contributors to update their words" ON words;
  DROP POLICY IF EXISTS "Allow public read access on word_relationships" ON word_relationships;
  DROP POLICY IF EXISTS "Allow authenticated users to insert relationships" ON word_relationships;
  DROP POLICY IF EXISTS "Allow contributors to update their relationships" ON word_relationships;
END $$;

-- Create policies for words table
CREATE POLICY "Allow public read access on words"
  ON words
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to insert words"
  ON words
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow contributors to update their words"
  ON words
  FOR UPDATE
  TO authenticated
  USING (contributor_id = auth.uid())
  WITH CHECK (contributor_id = auth.uid());

-- Create policies for word_relationships table
CREATE POLICY "Allow public read access on word_relationships"
  ON word_relationships
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to insert relationships"
  ON word_relationships
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow contributors to update their relationships"
  ON word_relationships
  FOR UPDATE
  TO authenticated
  USING (contributor_id = auth.uid())
  WITH CHECK (contributor_id = auth.uid());

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_words_word ON words(word);
CREATE INDEX IF NOT EXISTS idx_word_relationships_source ON word_relationships(source_word_id);
CREATE INDEX IF NOT EXISTS idx_word_relationships_target ON word_relationships(target_word_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for words table
DROP TRIGGER IF EXISTS update_words_updated_at ON words;
CREATE TRIGGER update_words_updated_at
  BEFORE UPDATE ON words
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();