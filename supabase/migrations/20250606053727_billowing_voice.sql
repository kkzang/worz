-- Create word_metadata table
CREATE TABLE IF NOT EXISTS word_metadata (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word_id uuid REFERENCES words(id) ON DELETE CASCADE,
  usage_frequency integer DEFAULT 0,
  etymology text,
  notes text,
  last_updated timestamptz DEFAULT now(),
  contributor_id uuid REFERENCES auth.users(id),
  UNIQUE(word_id)
);

-- Create word_examples table
CREATE TABLE IF NOT EXISTS word_examples (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word_id uuid REFERENCES words(id) ON DELETE CASCADE,
  example_text text NOT NULL,
  created_at timestamptz DEFAULT now(),
  contributor_id uuid REFERENCES auth.users(id)
);

-- Enable RLS
ALTER TABLE word_metadata ENABLE ROW LEVEL SECURITY;
ALTER TABLE word_examples ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DO $$ 
BEGIN
  -- Drop word_metadata policies
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'word_metadata' AND policyname = 'Allow public read access on word_metadata'
  ) THEN
    DROP POLICY "Allow public read access on word_metadata" ON word_metadata;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'word_metadata' AND policyname = 'Allow authenticated users to insert metadata'
  ) THEN
    DROP POLICY "Allow authenticated users to insert metadata" ON word_metadata;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'word_metadata' AND policyname = 'Allow contributors to update their metadata'
  ) THEN
    DROP POLICY "Allow contributors to update their metadata" ON word_metadata;
  END IF;

  -- Drop word_examples policies
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'word_examples' AND policyname = 'Allow public read access on word_examples'
  ) THEN
    DROP POLICY "Allow public read access on word_examples" ON word_examples;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'word_examples' AND policyname = 'Allow authenticated users to insert examples'
  ) THEN
    DROP POLICY "Allow authenticated users to insert examples" ON word_examples;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'word_examples' AND policyname = 'Allow contributors to update their examples'
  ) THEN
    DROP POLICY "Allow contributors to update their examples" ON word_examples;
  END IF;
END $$;

-- Create policies for word_metadata
CREATE POLICY "Allow public read access on word_metadata"
  ON word_metadata
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to insert metadata"
  ON word_metadata
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow contributors to update their metadata"
  ON word_metadata
  FOR UPDATE
  TO authenticated
  USING (contributor_id = auth.uid())
  WITH CHECK (contributor_id = auth.uid());

-- Create policies for word_examples
CREATE POLICY "Allow public read access on word_examples"
  ON word_examples
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to insert examples"
  ON word_examples
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow contributors to update their examples"
  ON word_examples
  FOR UPDATE
  TO authenticated
  USING (contributor_id = auth.uid())
  WITH CHECK (contributor_id = auth.uid());

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_word_examples_word ON word_examples(word_id);

-- Add some example data
INSERT INTO word_metadata (word_id, usage_frequency, etymology, notes)
SELECT 
  id,
  floor(random() * 100),
  'Etymology for ' || word,
  'Additional notes for ' || word
FROM words
WHERE word IN ('hello', 'world', 'love', 'time', 'life')
ON CONFLICT (word_id) DO NOTHING;

INSERT INTO word_examples (word_id, example_text)
SELECT 
  id,
  'Example sentence using the word ' || word
FROM words
WHERE word IN ('hello', 'world', 'love', 'time', 'life');