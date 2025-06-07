/*
  # Comprehensive Word Database Migration
  
  1. New Tables
    - `words`: Core word definitions and metadata
    - `word_translations`: Multi-language translations
    - `word_relationships`: Word connections (synonym, antonym, related)
    - `word_trends`: Popularity and trending data
    - `word_contributions`: User contributions tracking
    - `word_votes`: Community voting system
  
  2. Data Generation
    - Generate 10,000 words with Korean and Japanese translations
    - Create word relationships and trending data
    - Include predefined words with specific translations
  
  3. Security
    - Enable RLS on all tables
    - Create appropriate policies for public read and authenticated write access
*/

-- Create words table
CREATE TABLE IF NOT EXISTS words (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word text UNIQUE NOT NULL,
  category text DEFAULT 'General',
  definition text NOT NULL,
  bookmarks integer DEFAULT 0,
  contributor_id uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create word_translations table
CREATE TABLE IF NOT EXISTS word_translations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word_id uuid NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  language text NOT NULL,
  translation text NOT NULL,
  contributor_id uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(word_id, language)
);

-- Create word_relationships table
CREATE TABLE IF NOT EXISTS word_relationships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_word_id uuid NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  target_word_id uuid NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  relationship_type text NOT NULL CHECK (relationship_type IN ('synonym', 'antonym', 'related')),
  description text,
  strength float DEFAULT 1.0,
  contributor_id uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  UNIQUE(source_word_id, target_word_id, relationship_type)
);

-- Create word_trends table (note: no updated_at column to prevent trigger issues)
CREATE TABLE IF NOT EXISTS word_trends (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word_id uuid NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  views integer DEFAULT 0,
  trending_score double precision DEFAULT 0,
  last_viewed timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  UNIQUE(word_id)
);

-- Create word_contributions table
CREATE TABLE IF NOT EXISTS word_contributions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word_id uuid REFERENCES words(id) ON DELETE CASCADE,
  contributor_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  contribution_type text NOT NULL CHECK (contribution_type IN ('new_word', 'translation', 'relationship', 'example')),
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  content jsonb NOT NULL,
  created_at timestamptz DEFAULT now(),
  reviewed_at timestamptz,
  reviewer_id uuid REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Create word_votes table
CREATE TABLE IF NOT EXISTS word_votes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word_id uuid REFERENCES words(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  vote_type text NOT NULL CHECK (vote_type IN ('upvote', 'downvote')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(word_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_words_word ON words(word);
CREATE INDEX IF NOT EXISTS idx_words_category ON words(category);
CREATE INDEX IF NOT EXISTS idx_word_translations_word_id ON word_translations(word_id);
CREATE INDEX IF NOT EXISTS idx_word_translations_language ON word_translations(language);
CREATE INDEX IF NOT EXISTS idx_word_relationships_source ON word_relationships(source_word_id);
CREATE INDEX IF NOT EXISTS idx_word_relationships_target ON word_relationships(target_word_id);
CREATE INDEX IF NOT EXISTS idx_word_trends_word_id ON word_trends(word_id);
CREATE INDEX IF NOT EXISTS idx_word_trends_score ON word_trends(trending_score DESC);
CREATE INDEX IF NOT EXISTS idx_word_contributions_word_id ON word_contributions(word_id);
CREATE INDEX IF NOT EXISTS idx_word_contributions_contributor ON word_contributions(contributor_id);
CREATE INDEX IF NOT EXISTS idx_word_contributions_status ON word_contributions(status);
CREATE INDEX IF NOT EXISTS idx_word_votes_word_id ON word_votes(word_id);
CREATE INDEX IF NOT EXISTS idx_word_votes_user ON word_votes(user_id);

-- Enable Row Level Security
ALTER TABLE words ENABLE ROW LEVEL SECURITY;
ALTER TABLE word_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE word_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE word_trends ENABLE ROW LEVEL SECURITY;
ALTER TABLE word_contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE word_votes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist to avoid conflicts
DO $$ 
BEGIN
  -- Drop words table policies
  DROP POLICY IF EXISTS "Words are viewable by everyone" ON words;
  DROP POLICY IF EXISTS "Allow public read access on words" ON words;
  DROP POLICY IF EXISTS "Authenticated users can insert words" ON words;
  DROP POLICY IF EXISTS "Allow authenticated users to insert words" ON words;
  DROP POLICY IF EXISTS "Users can update their own words" ON words;
  DROP POLICY IF EXISTS "Allow contributors to update their words" ON words;
  
  -- Drop word_translations table policies
  DROP POLICY IF EXISTS "Word translations are viewable by everyone" ON word_translations;
  DROP POLICY IF EXISTS "Allow public read access on word_translations" ON word_translations;
  DROP POLICY IF EXISTS "Authenticated users can insert translations" ON word_translations;
  DROP POLICY IF EXISTS "Allow authenticated users to insert translations" ON word_translations;
  DROP POLICY IF EXISTS "Users can update their own translations" ON word_translations;
  DROP POLICY IF EXISTS "Allow contributors to update their translations" ON word_translations;
  
  -- Drop word_relationships table policies
  DROP POLICY IF EXISTS "Word relationships are viewable by everyone" ON word_relationships;
  DROP POLICY IF EXISTS "Allow public read access on word_relationships" ON word_relationships;
  DROP POLICY IF EXISTS "Authenticated users can insert relationships" ON word_relationships;
  DROP POLICY IF EXISTS "Allow authenticated users to insert relationships" ON word_relationships;
  DROP POLICY IF EXISTS "Users can update their own relationships" ON word_relationships;
  DROP POLICY IF EXISTS "Allow contributors to update their relationships" ON word_relationships;
  
  -- Drop word_trends table policies
  DROP POLICY IF EXISTS "Word trends are viewable by everyone" ON word_trends;
  DROP POLICY IF EXISTS "Allow public read access on word_trends" ON word_trends;
  DROP POLICY IF EXISTS "Anyone can update word trends" ON word_trends;
  DROP POLICY IF EXISTS "Allow system updates on word_trends" ON word_trends;
  DROP POLICY IF EXISTS "Anyone can insert word trends" ON word_trends;
  
  -- Drop word_contributions table policies
  DROP POLICY IF EXISTS "Users can view all contributions" ON word_contributions;
  DROP POLICY IF EXISTS "Allow public read access on word_contributions" ON word_contributions;
  DROP POLICY IF EXISTS "Users can insert their own contributions" ON word_contributions;
  DROP POLICY IF EXISTS "Allow authenticated users to contribute" ON word_contributions;
  DROP POLICY IF EXISTS "Users can update their own contributions" ON word_contributions;
  DROP POLICY IF EXISTS "Allow contributors to update their pending contributions" ON word_contributions;
  
  -- Drop word_votes table policies
  DROP POLICY IF EXISTS "Users can view all votes" ON word_votes;
  DROP POLICY IF EXISTS "Allow public read access on word_votes" ON word_votes;
  DROP POLICY IF EXISTS "Users can insert their own votes" ON word_votes;
  DROP POLICY IF EXISTS "Allow authenticated users to vote" ON word_votes;
  DROP POLICY IF EXISTS "Users can update their own votes" ON word_votes;
END $$;

-- Create RLS policies for words table
CREATE POLICY "Words are viewable by everyone"
  ON words
  FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert words"
  ON words
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update their own words"
  ON words
  FOR UPDATE
  TO authenticated
  USING (contributor_id = auth.uid() OR contributor_id IS NULL);

-- Create RLS policies for word_translations table
CREATE POLICY "Word translations are viewable by everyone"
  ON word_translations
  FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert translations"
  ON word_translations
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update their own translations"
  ON word_translations
  FOR UPDATE
  TO authenticated
  USING (contributor_id = auth.uid() OR contributor_id IS NULL);

-- Create RLS policies for word_relationships table
CREATE POLICY "Word relationships are viewable by everyone"
  ON word_relationships
  FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert relationships"
  ON word_relationships
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update their own relationships"
  ON word_relationships
  FOR UPDATE
  TO authenticated
  USING (contributor_id = auth.uid() OR contributor_id IS NULL);

-- Create RLS policies for word_trends table
CREATE POLICY "Word trends are viewable by everyone"
  ON word_trends
  FOR SELECT
  USING (true);

CREATE POLICY "Anyone can insert word trends"
  ON word_trends
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can update word trends"
  ON word_trends
  FOR UPDATE
  USING (true);

-- Create RLS policies for word_contributions table
CREATE POLICY "Users can view all contributions"
  ON word_contributions
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert their own contributions"
  ON word_contributions
  FOR INSERT
  TO authenticated
  WITH CHECK (contributor_id = auth.uid());

CREATE POLICY "Users can update their own contributions"
  ON word_contributions
  FOR UPDATE
  TO authenticated
  USING (contributor_id = auth.uid());

-- Create RLS policies for word_votes table
CREATE POLICY "Users can view all votes"
  ON word_votes
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert their own votes"
  ON word_votes
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own votes"
  ON word_votes
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid());

-- Drop existing triggers and functions in the correct order
DROP TRIGGER IF EXISTS update_word_trending_score ON word_trends;
DROP TRIGGER IF EXISTS update_words_updated_at ON words;
DROP TRIGGER IF EXISTS update_word_translations_updated_at ON word_translations;

-- Drop functions (now safe since triggers are dropped)
DROP FUNCTION IF EXISTS update_trending_score();
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP FUNCTION IF EXISTS calculate_trending_score(integer, timestamp with time zone);
DROP FUNCTION IF EXISTS calculate_trending_score(integer, timestamptz);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create function to update trending score (BEFORE trigger to prevent infinite loop)
CREATE OR REPLACE FUNCTION update_trending_score()
RETURNS TRIGGER AS $$
BEGIN
  -- Calculate trending score based on views and recency
  -- Higher score for more views and more recent activity
  NEW.trending_score = (NEW.views * 0.7) + (EXTRACT(EPOCH FROM (now() - NEW.last_viewed)) / 3600 * -0.1);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_words_updated_at
  BEFORE UPDATE ON words
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_word_translations_updated_at
  BEFORE UPDATE ON word_translations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create trigger to update trending score
CREATE TRIGGER update_word_trending_score
  BEFORE INSERT OR UPDATE ON word_trends
  FOR EACH ROW
  EXECUTE FUNCTION update_trending_score();

-- Helper functions for generating Korean and Japanese text
CREATE OR REPLACE FUNCTION random_korean() RETURNS text AS $$
DECLARE
  chars text[];
  result text;
  i integer;
BEGIN
  chars := ARRAY['가','나','다','라','마','바','사','아','자','차','카','타','파','하',
                 '강','명','성','영','운','진','현','혜','효','원','서','지','미','수',
                 '학','교','생','활','사','랑','시','간','자','유','평','화','진','실'];
  result := '';
  FOR i IN 1..2 LOOP
    result := result || chars[1 + floor(random() * array_length(chars, 1))];
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_japanese() RETURNS text AS $$
DECLARE
  chars text[];
  result text;
  i integer;
BEGIN
  chars := ARRAY['あ','い','う','え','お','か','き','く','け','こ','さ','し','す','せ','そ',
                 'た','ち','つ','て','と','な','に','ぬ','ね','の','は','ひ','ふ','へ','ほ',
                 'ま','み','む','め','も','や','ゆ','よ','ら','り','る','れ','ろ','わ','を','ん'];
  result := '';
  FOR i IN 1..3 LOOP
    result := result || chars[1 + floor(random() * array_length(chars, 1))];
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to generate comprehensive word dataset
CREATE OR REPLACE FUNCTION generate_comprehensive_word_data() RETURNS void AS $$
DECLARE
  word_count integer := 0;
  current_word_id uuid;
  i integer;
  word_text text;
  ko_translation text;
  ja_translation text;
  category_name text;
  categories text[] := ARRAY['Noun', 'Verb', 'Adjective', 'Abstract', 'Science', 'Technology', 'Nature', 'Society', 'Arts', 'Business'];
BEGIN
  -- Generate 10,000 words
  FOR i IN 1..10000 LOOP
    word_text := 'word_' || i;
    ko_translation := random_korean();
    ja_translation := random_japanese();
    category_name := categories[1 + (i % array_length(categories, 1))];
    
    -- Insert word
    INSERT INTO words (word, definition, category, bookmarks, contributor_id)
    VALUES (
      word_text,
      'Definition for ' || word_text,
      category_name,
      floor(random() * 1000),
      NULL  -- System-generated data
    )
    ON CONFLICT (word) DO UPDATE SET
      definition = EXCLUDED.definition,
      category = EXCLUDED.category
    RETURNING id INTO current_word_id;
    
    -- Insert Korean translation
    INSERT INTO word_translations (word_id, language, translation, contributor_id)
    VALUES (current_word_id, 'ko', ko_translation, NULL)
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    -- Insert Japanese translation
    INSERT INTO word_translations (word_id, language, translation, contributor_id)
    VALUES (current_word_id, 'ja', ja_translation, NULL)
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    -- Insert trending data
    INSERT INTO word_trends (word_id, views, last_viewed)
    VALUES (
      current_word_id,
      floor(random() * 1000),
      now() - (random() * interval '30 days')
    )
    ON CONFLICT (word_id) DO UPDATE SET
      views = EXCLUDED.views,
      last_viewed = EXCLUDED.last_viewed;
    
    word_count := word_count + 1;
    
    -- Create some relationships (every 10th word)
    IF word_count > 1 AND word_count % 10 = 0 THEN
      INSERT INTO word_relationships (
        source_word_id,
        target_word_id,
        relationship_type,
        description,
        contributor_id
      )
      SELECT 
        current_word_id,
        w.id,
        CASE 
          WHEN random() < 0.4 THEN 'synonym'
          WHEN random() < 0.7 THEN 'related'
          ELSE 'antonym'
        END,
        'Related to ' || word_text,
        NULL
      FROM words w
      WHERE w.id != current_word_id
      ORDER BY random()
      LIMIT 1
      ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;
    END IF;
    
    -- Log progress every 1000 words
    IF word_count % 1000 = 0 THEN
      RAISE NOTICE 'Generated % words', word_count;
    END IF;
  END LOOP;
  
  -- Insert predefined words with specific translations
  INSERT INTO words (word, category, definition) VALUES
    ('house', 'Noun', 'A building for human habitation'),
    ('love', 'Abstract', 'An intense feeling of deep affection'),
    ('time', 'Abstract', 'The indefinite continued progress of existence'),
    ('book', 'Noun', 'A written or printed work consisting of pages'),
    ('work', 'Noun', 'Activity involving mental or physical effort'),
    ('life', 'Abstract', 'The condition that distinguishes animals and plants'),
    ('food', 'Noun', 'Any nutritious substance that people or animals eat'),
    ('music', 'Arts', 'Vocal or instrumental sounds combined in harmony'),
    ('peace', 'Abstract', 'A state of tranquility or quiet'),
    ('dream', 'Abstract', 'A series of thoughts, images, and sensations')
  ON CONFLICT (word) DO UPDATE SET
    definition = EXCLUDED.definition,
    category = EXCLUDED.category;

  -- Insert specific translations for predefined words
  INSERT INTO word_translations (word_id, language, translation) 
  SELECT w.id, 'ko', 
    CASE w.word
      WHEN 'house' THEN '집'
      WHEN 'love' THEN '사랑'
      WHEN 'time' THEN '시간'
      WHEN 'book' THEN '책'
      WHEN 'work' THEN '일'
      WHEN 'life' THEN '생활'
      WHEN 'food' THEN '음식'
      WHEN 'music' THEN '음악'
      WHEN 'peace' THEN '평화'
      WHEN 'dream' THEN '꿈'
    END
  FROM words w
  WHERE w.word IN ('house', 'love', 'time', 'book', 'work', 'life', 'food', 'music', 'peace', 'dream')
  ON CONFLICT (word_id, language) DO UPDATE SET
    translation = EXCLUDED.translation;

  INSERT INTO word_translations (word_id, language, translation) 
  SELECT w.id, 'ja', 
    CASE w.word
      WHEN 'house' THEN '家 (いえ)'
      WHEN 'love' THEN '愛 (あい)'
      WHEN 'time' THEN '時間 (じかん)'
      WHEN 'book' THEN '本 (ほん)'
      WHEN 'work' THEN '仕事 (しごと)'
      WHEN 'life' THEN '生活 (せいかつ)'
      WHEN 'food' THEN '食べ物 (たべもの)'
      WHEN 'music' THEN '音楽 (おんがく)'
      WHEN 'peace' THEN '平和 (へいわ)'
      WHEN 'dream' THEN '夢 (ゆめ)'
    END
  FROM words w
  WHERE w.word IN ('house', 'love', 'time', 'book', 'work', 'life', 'food', 'music', 'peace', 'dream')
  ON CONFLICT (word_id, language) DO UPDATE SET
    translation = EXCLUDED.translation;

  -- Create relationships between predefined words
  INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
  SELECT 
    w1.id, w2.id, 'related', 'Related concept'
  FROM words w1, words w2
  WHERE w1.word = 'love' AND w2.word = 'life' AND w1.id != w2.id
  ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

  INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
  SELECT 
    w1.id, w2.id, 'related', 'Related concept'
  FROM words w1, words w2
  WHERE w1.word = 'house' AND w2.word = 'life' AND w1.id != w2.id
  ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

  -- Insert trending data for predefined words
  INSERT INTO word_trends (word_id, views, last_viewed)
  SELECT w.id, 
    CASE w.word
      WHEN 'house' THEN 150
      WHEN 'love' THEN 200
      WHEN 'time' THEN 180
      WHEN 'book' THEN 120
      WHEN 'work' THEN 160
      ELSE 100
    END,
    now() - (random() * interval '7 days')
  FROM words w
  WHERE w.word IN ('house', 'love', 'time', 'book', 'work', 'life', 'food', 'music', 'peace', 'dream')
  ON CONFLICT (word_id) DO UPDATE SET
    views = EXCLUDED.views,
    last_viewed = EXCLUDED.last_viewed;
  
  RAISE NOTICE 'Successfully generated comprehensive word dataset with % total words', word_count + 10;
END;
$$ LANGUAGE plpgsql;

-- Execute the function to generate comprehensive word data
SELECT generate_comprehensive_word_data();