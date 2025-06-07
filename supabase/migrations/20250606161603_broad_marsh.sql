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
  UNIQUE(word_id, language)
);

-- Create word_relationships table
CREATE TABLE IF NOT EXISTS word_relationships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_word_id uuid NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  target_word_id uuid NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  relationship_type text NOT NULL CHECK (relationship_type IN ('synonym', 'antonym', 'related')),
  description text,
  contributor_id uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  UNIQUE(source_word_id, target_word_id, relationship_type)
);

-- Create word_trends table
CREATE TABLE IF NOT EXISTS word_trends (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word_id uuid NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  views integer DEFAULT 0,
  trending_score numeric DEFAULT 0,
  last_viewed timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  UNIQUE(word_id)
);

-- Create word_contributions table
CREATE TABLE IF NOT EXISTS word_contributions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word_id uuid NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  contributor_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  contribution_type text NOT NULL,
  content jsonb NOT NULL,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at timestamptz DEFAULT now()
);

-- Create word_votes table
CREATE TABLE IF NOT EXISTS word_votes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word_id uuid NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vote_type text NOT NULL CHECK (vote_type IN ('up', 'down')),
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
CREATE INDEX IF NOT EXISTS idx_word_votes_word_id ON word_votes(word_id);

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
  DROP POLICY IF EXISTS "Authenticated users can insert words" ON words;
  DROP POLICY IF EXISTS "Users can update their own words" ON words;
  
  -- Drop word_translations table policies
  DROP POLICY IF EXISTS "Word translations are viewable by everyone" ON word_translations;
  DROP POLICY IF EXISTS "Authenticated users can insert translations" ON word_translations;
  DROP POLICY IF EXISTS "Users can update their own translations" ON word_translations;
  
  -- Drop word_relationships table policies
  DROP POLICY IF EXISTS "Word relationships are viewable by everyone" ON word_relationships;
  DROP POLICY IF EXISTS "Authenticated users can insert relationships" ON word_relationships;
  DROP POLICY IF EXISTS "Users can update their own relationships" ON word_relationships;
  
  -- Drop word_trends table policies
  DROP POLICY IF EXISTS "Word trends are viewable by everyone" ON word_trends;
  DROP POLICY IF EXISTS "Anyone can update word trends" ON word_trends;
  DROP POLICY IF EXISTS "Anyone can insert word trends" ON word_trends;
  
  -- Drop word_contributions table policies
  DROP POLICY IF EXISTS "Users can view all contributions" ON word_contributions;
  DROP POLICY IF EXISTS "Users can insert their own contributions" ON word_contributions;
  DROP POLICY IF EXISTS "Users can update their own contributions" ON word_contributions;
  
  -- Drop word_votes table policies
  DROP POLICY IF EXISTS "Users can view all votes" ON word_votes;
  DROP POLICY IF EXISTS "Users can insert their own votes" ON word_votes;
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
  USING (contributor_id = auth.uid());

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
  USING (contributor_id = auth.uid());

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
  USING (contributor_id = auth.uid());

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

-- Drop existing function if it exists and create new one with correct signature
DROP FUNCTION IF EXISTS calculate_trending_score(integer, timestamp with time zone);
DROP FUNCTION IF EXISTS calculate_trending_score(integer, timestamptz);

-- Create function to calculate trending score (without trigger to avoid infinite loop)
CREATE OR REPLACE FUNCTION calculate_trending_score(
  p_views integer,
  p_last_viewed timestamptz
) RETURNS numeric AS $$
BEGIN
  -- Calculate trending score based on views and recency
  -- Higher score for more views and more recent activity
  RETURN (p_views * 0.7) + (EXTRACT(EPOCH FROM (now() - p_last_viewed)) / 3600 * -0.1);
END;
$$ LANGUAGE plpgsql;

-- Insert some sample data
INSERT INTO words (word, category, definition) VALUES
  ('house', 'Noun', 'A building for human habitation'),
  ('love', 'Noun', 'An intense feeling of deep affection'),
  ('time', 'Noun', 'The indefinite continued progress of existence'),
  ('book', 'Noun', 'A written or printed work consisting of pages'),
  ('work', 'Noun', 'Activity involving mental or physical effort'),
  ('life', 'Noun', 'The condition that distinguishes animals and plants'),
  ('food', 'Noun', 'Any nutritious substance that people or animals eat'),
  ('music', 'Noun', 'Vocal or instrumental sounds combined in harmony'),
  ('peace', 'Noun', 'A state of tranquility or quiet'),
  ('dream', 'Noun', 'A series of thoughts, images, and sensations')
ON CONFLICT (word) DO NOTHING;

-- Insert sample translations
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
ON CONFLICT (word_id, language) DO NOTHING;

INSERT INTO word_translations (word_id, language, translation) 
SELECT w.id, 'ja', 
  CASE w.word
    WHEN 'house' THEN '家'
    WHEN 'love' THEN '愛'
    WHEN 'time' THEN '時間'
    WHEN 'book' THEN '本'
    WHEN 'work' THEN '仕事'
    WHEN 'life' THEN '生活'
    WHEN 'food' THEN '食べ物'
    WHEN 'music' THEN '音楽'
    WHEN 'peace' THEN '平和'
    WHEN 'dream' THEN '夢'
  END
FROM words w
WHERE w.word IN ('house', 'love', 'time', 'book', 'work', 'life', 'food', 'music', 'peace', 'dream')
ON CONFLICT (word_id, language) DO NOTHING;

-- Insert sample relationships (only for words that exist)
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

INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
SELECT 
  w1.id, w2.id, 'related', 'Related concept'
FROM words w1, words w2
WHERE w1.word = 'time' AND w2.word = 'life' AND w1.id != w2.id
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

-- Insert sample trending data with calculated scores
INSERT INTO word_trends (word_id, views, trending_score, last_viewed)
SELECT w.id, 
  CASE w.word
    WHEN 'house' THEN 150
    WHEN 'love' THEN 200
    WHEN 'time' THEN 180
    WHEN 'book' THEN 120
    WHEN 'work' THEN 160
    ELSE 100
  END as view_count,
  calculate_trending_score(
    CASE w.word
      WHEN 'house' THEN 150
      WHEN 'love' THEN 200
      WHEN 'time' THEN 180
      WHEN 'book' THEN 120
      WHEN 'work' THEN 160
      ELSE 100
    END,
    now() - (random() * interval '7 days')
  ),
  now() - (random() * interval '7 days')
FROM words w
ON CONFLICT (word_id) DO NOTHING;