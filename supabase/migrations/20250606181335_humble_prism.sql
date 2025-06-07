/*
  # Add New Word Relationship Types

  1. Changes
    - Update relationship_type check constraint to include new types
    - Add comprehensive relationship types for semantic analysis
    - Maintain backward compatibility with existing data

  2. New Relationship Types
    - antonym: 반의어 (opposite meaning)
    - synonym: 유의어 (similar meaning)
    - hypernym: 상위어 (broader category)
    - hyponym: 하위어 (narrower category)
    - meronym: 부분어 (part of)
    - holonym: 전체어 (whole of)
    - derivative: 파생어 (derived word)
    - polysemy: 다의어 (multiple meanings)
    - semantic_field: 의미장 (semantic field)
    - related: 관련어 (general relation)
*/

-- Drop the existing check constraint
ALTER TABLE word_relationships DROP CONSTRAINT IF EXISTS word_relationships_relationship_type_check;

-- Add the new check constraint with all relationship types
ALTER TABLE word_relationships ADD CONSTRAINT word_relationships_relationship_type_check 
CHECK (relationship_type IN (
  'antonym',        -- 반의어
  'synonym',        -- 유의어  
  'hypernym',       -- 상위어
  'hyponym',        -- 하위어
  'meronym',        -- 부분어
  'holonym',        -- 전체어
  'derivative',     -- 파생어
  'polysemy',       -- 다의어
  'semantic_field', -- 의미장
  'related'         -- 관련어
));

-- Create function to generate diverse relationships for existing words
CREATE OR REPLACE FUNCTION generate_diverse_relationships() RETURNS void AS $$
DECLARE
  word_record RECORD;
  target_word_record RECORD;
  relationship_types text[] := ARRAY['antonym', 'synonym', 'hypernym', 'hyponym', 'meronym', 'holonym', 'derivative', 'polysemy', 'semantic_field', 'related'];
  selected_type text;
  relationship_count integer;
BEGIN
  -- Loop through all words to create diverse relationships
  FOR word_record IN 
    SELECT id, word, category FROM words 
    WHERE word NOT LIKE 'word_%' 
    ORDER BY word 
    LIMIT 100 -- Process first 100 words to avoid timeout
  LOOP
    -- Count existing relationships for this word
    SELECT COUNT(*) INTO relationship_count
    FROM word_relationships 
    WHERE source_word_id = word_record.id;
    
    -- If word has fewer than 8 relationships, add more
    IF relationship_count < 8 THEN
      -- Find target words from same or related categories
      FOR target_word_record IN
        SELECT id, word, category FROM words 
        WHERE id != word_record.id 
        AND word NOT LIKE 'word_%'
        AND (
          category = word_record.category OR 
          category IN ('General', 'Abstract', 'Science', 'Technology', 'Business', 'Education', 'Health')
        )
        ORDER BY random()
        LIMIT (8 - relationship_count)
      LOOP
        -- Select relationship type based on word characteristics
        selected_type := CASE 
          WHEN word_record.category = target_word_record.category THEN
            relationship_types[1 + (abs(hashtext(word_record.word || target_word_record.word)) % 10)]
          ELSE
            'semantic_field'
        END;
        
        -- Insert relationship if it doesn't exist
        INSERT INTO word_relationships (
          source_word_id,
          target_word_id,
          relationship_type,
          description,
          strength,
          contributor_id
        )
        SELECT 
          word_record.id,
          target_word_record.id,
          selected_type,
          CASE selected_type
            WHEN 'antonym' THEN word_record.word || '의 반의어'
            WHEN 'synonym' THEN word_record.word || '의 유의어'
            WHEN 'hypernym' THEN word_record.word || '의 상위어'
            WHEN 'hyponym' THEN word_record.word || '의 하위어'
            WHEN 'meronym' THEN word_record.word || '의 부분어'
            WHEN 'holonym' THEN word_record.word || '의 전체어'
            WHEN 'derivative' THEN word_record.word || '의 파생어'
            WHEN 'polysemy' THEN word_record.word || '의 다의어'
            WHEN 'semantic_field' THEN word_record.word || '의 의미장'
            ELSE word_record.word || '의 관련어'
          END,
          random() * 0.5 + 0.5, -- Random strength between 0.5 and 1.0
          NULL -- System generated
        WHERE NOT EXISTS (
          SELECT 1 FROM word_relationships 
          WHERE source_word_id = word_record.id 
          AND target_word_id = target_word_record.id 
          AND relationship_type = selected_type
        );
      END LOOP;
    END IF;
  END LOOP;
  
  RAISE NOTICE 'Generated diverse relationships for words';
END;
$$ LANGUAGE plpgsql;

-- Execute the function to generate diverse relationships
SELECT generate_diverse_relationships();

-- Drop the function after use
DROP FUNCTION generate_diverse_relationships();

-- Create some specific meaningful relationships for common words
INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description, strength)
SELECT 
  w1.id, w2.id, 'antonym', '반의어 관계', 1.0
FROM words w1, words w2
WHERE (w1.word = 'light' AND w2.word = 'dark')
   OR (w1.word = 'hot' AND w2.word = 'cold')
   OR (w1.word = 'big' AND w2.word = 'small')
   OR (w1.word = 'good' AND w2.word = 'bad')
   OR (w1.word = 'happy' AND w2.word = 'sad')
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description, strength)
SELECT 
  w1.id, w2.id, 'hypernym', '상위어 관계', 0.9
FROM words w1, words w2
WHERE (w1.word = 'animal' AND w2.word = 'dog')
   OR (w1.word = 'vehicle' AND w2.word = 'car')
   OR (w1.word = 'building' AND w2.word = 'house')
   OR (w1.word = 'food' AND w2.word = 'fruit')
   OR (w1.word = 'color' AND w2.word = 'red')
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description, strength)
SELECT 
  w1.id, w2.id, 'meronym', '부분어 관계', 0.8
FROM words w1, words w2
WHERE (w1.word = 'hand' AND w2.word = 'finger')
   OR (w1.word = 'house' AND w2.word = 'room')
   OR (w1.word = 'car' AND w2.word = 'wheel')
   OR (w1.word = 'book' AND w2.word = 'page')
   OR (w1.word = 'tree' AND w2.word = 'leaf')
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;