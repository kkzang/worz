/*
  # Add category column to words table

  1. Changes
    - Add category column to words table if it doesn't exist
    - Set default value to 'General'
    - Add index for better query performance

  2. Safety
    - Uses IF NOT EXISTS pattern to avoid errors if column already exists
    - Preserves existing data
*/

-- Add category column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'words' AND column_name = 'category'
  ) THEN
    ALTER TABLE words ADD COLUMN category TEXT DEFAULT 'General';
  END IF;
END $$;

-- Ensure we have an index on category for better performance
CREATE INDEX IF NOT EXISTS idx_words_category ON words(category);

-- Update any existing words that might have NULL category values
UPDATE words SET category = 'General' WHERE category IS NULL;