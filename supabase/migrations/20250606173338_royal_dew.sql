/*
  # Add category column to words table

  1. Changes
    - Add `category` column to `words` table if it doesn't exist
    - Set default value to 'General'
    - Update existing records without category to have 'General' as default

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
    ALTER TABLE words ADD COLUMN category text DEFAULT 'General';
  END IF;
END $$;

-- Update any existing records that might have NULL category
UPDATE words SET category = 'General' WHERE category IS NULL;