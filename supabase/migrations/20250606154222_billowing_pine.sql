/*
  # Remove duplicate translation columns from words table
  
  1. Changes
    - Remove korean_translation and japanese_translation columns from words table
    - These translations are now managed exclusively through word_translations table
    
  2. Data Migration
    - Ensure all existing translation data is preserved in word_translations table
    - Clean up any duplicate or inconsistent data
*/

-- First, ensure all existing translations are in word_translations table
INSERT INTO word_translations (word_id, language, translation)
SELECT 
  id,
  'ko',
  korean_translation
FROM words 
WHERE korean_translation IS NOT NULL 
  AND korean_translation != ''
  AND korean_translation != '번역 필요'
ON CONFLICT (word_id, language) DO NOTHING;

INSERT INTO word_translations (word_id, language, translation)
SELECT 
  id,
  'ja',
  japanese_translation
FROM words 
WHERE japanese_translation IS NOT NULL 
  AND japanese_translation != ''
  AND japanese_translation != '翻訳필요'
ON CONFLICT (word_id, language) DO NOTHING;

-- Remove the duplicate columns from words table
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'words' AND column_name = 'korean_translation'
  ) THEN
    ALTER TABLE words DROP COLUMN korean_translation;
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'words' AND column_name = 'japanese_translation'
  ) THEN
    ALTER TABLE words DROP COLUMN japanese_translation;
  END IF;
END $$;