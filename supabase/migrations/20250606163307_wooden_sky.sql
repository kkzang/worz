/*
  # Add Real English Words for Trending

  1. New Data
    - Insert common English words with proper translations
    - Create relationships between related words
    - Add trending data for these words

  2. Purpose
    - Replace generated "word_X" entries with real English words
    - Provide meaningful trending words for the application
*/

-- Insert common English words with proper definitions and translations
INSERT INTO words (word, category, definition, bookmarks) VALUES
  ('water', 'Nature', 'A transparent, odorless, tasteless liquid', 50),
  ('fire', 'Nature', 'The rapid oxidation of a material in combustion', 45),
  ('earth', 'Nature', 'The planet on which we live', 60),
  ('wind', 'Nature', 'The natural movement of air', 40),
  ('light', 'Abstract', 'Natural agent that stimulates sight', 55),
  ('dark', 'Abstract', 'Absence of light', 35),
  ('hope', 'Abstract', 'A feeling of expectation and desire', 70),
  ('faith', 'Abstract', 'Complete trust or confidence', 65),
  ('truth', 'Abstract', 'The quality or state of being true', 80),
  ('beauty', 'Abstract', 'A combination of qualities that pleases the senses', 75),
  ('nature', 'Nature', 'The physical world collectively', 85),
  ('power', 'Abstract', 'The ability to do something or act', 90),
  ('space', 'Science', 'A continuous area or expanse', 55),
  ('heart', 'Abstract', 'The center of emotion and feeling', 95),
  ('mind', 'Abstract', 'The element of consciousness', 88),
  ('soul', 'Abstract', 'The spiritual essence of a person', 72),
  ('spirit', 'Abstract', 'The non-physical part of a person', 68),
  ('change', 'Abstract', 'The act of becoming different', 82),
  ('growth', 'Abstract', 'The process of increasing in size', 77),
  ('wisdom', 'Abstract', 'The quality of having experience and knowledge', 85),
  ('freedom', 'Abstract', 'The power to act, speak, or think freely', 92),
  ('justice', 'Abstract', 'Fair treatment in accordance with law', 78),
  ('courage', 'Abstract', 'The ability to do something frightening', 73),
  ('strength', 'Abstract', 'The quality of being physically strong', 69),
  ('knowledge', 'Abstract', 'Facts, information, and skills acquired', 87),
  ('learning', 'Abstract', 'The acquisition of knowledge or skills', 81),
  ('future', 'Abstract', 'The time that is to come', 76),
  ('past', 'Abstract', 'The time before the present', 64),
  ('present', 'Abstract', 'The time that is happening now', 71),
  ('success', 'Abstract', 'The accomplishment of an aim or purpose', 89)
ON CONFLICT (word) DO UPDATE SET
  definition = EXCLUDED.definition,
  category = EXCLUDED.category,
  bookmarks = EXCLUDED.bookmarks;

-- Insert Korean translations
INSERT INTO word_translations (word_id, language, translation) 
SELECT w.id, 'ko', 
  CASE w.word
    WHEN 'water' THEN '물'
    WHEN 'fire' THEN '불'
    WHEN 'earth' THEN '지구'
    WHEN 'wind' THEN '바람'
    WHEN 'light' THEN '빛'
    WHEN 'dark' THEN '어둠'
    WHEN 'hope' THEN '희망'
    WHEN 'faith' THEN '믿음'
    WHEN 'truth' THEN '진실'
    WHEN 'beauty' THEN '아름다움'
    WHEN 'nature' THEN '자연'
    WHEN 'power' THEN '힘'
    WHEN 'space' THEN '공간'
    WHEN 'heart' THEN '마음'
    WHEN 'mind' THEN '정신'
    WHEN 'soul' THEN '영혼'
    WHEN 'spirit' THEN '정신'
    WHEN 'change' THEN '변화'
    WHEN 'growth' THEN '성장'
    WHEN 'wisdom' THEN '지혜'
    WHEN 'freedom' THEN '자유'
    WHEN 'justice' THEN '정의'
    WHEN 'courage' THEN '용기'
    WHEN 'strength' THEN '힘'
    WHEN 'knowledge' THEN '지식'
    WHEN 'learning' THEN '학습'
    WHEN 'future' THEN '미래'
    WHEN 'past' THEN '과거'
    WHEN 'present' THEN '현재'
    WHEN 'success' THEN '성공'
  END
FROM words w
WHERE w.word IN ('water', 'fire', 'earth', 'wind', 'light', 'dark', 'hope', 'faith', 'truth', 'beauty', 'nature', 'power', 'space', 'heart', 'mind', 'soul', 'spirit', 'change', 'growth', 'wisdom', 'freedom', 'justice', 'courage', 'strength', 'knowledge', 'learning', 'future', 'past', 'present', 'success')
ON CONFLICT (word_id, language) DO UPDATE SET
  translation = EXCLUDED.translation;

-- Insert Japanese translations
INSERT INTO word_translations (word_id, language, translation) 
SELECT w.id, 'ja', 
  CASE w.word
    WHEN 'water' THEN '水 (みず)'
    WHEN 'fire' THEN '火 (ひ)'
    WHEN 'earth' THEN '地球 (ちきゅう)'
    WHEN 'wind' THEN '風 (かぜ)'
    WHEN 'light' THEN '光 (ひかり)'
    WHEN 'dark' THEN '暗闇 (くらやみ)'
    WHEN 'hope' THEN '希望 (きぼう)'
    WHEN 'faith' THEN '信仰 (しんこう)'
    WHEN 'truth' THEN '真実 (しんじつ)'
    WHEN 'beauty' THEN '美しさ (うつくしさ)'
    WHEN 'nature' THEN '自然 (しぜん)'
    WHEN 'power' THEN '力 (ちから)'
    WHEN 'space' THEN '空間 (くうかん)'
    WHEN 'heart' THEN '心 (こころ)'
    WHEN 'mind' THEN '心 (こころ)'
    WHEN 'soul' THEN '魂 (たましい)'
    WHEN 'spirit' THEN '精神 (せいしん)'
    WHEN 'change' THEN '変化 (へんか)'
    WHEN 'growth' THEN '成長 (せいちょう)'
    WHEN 'wisdom' THEN '知恵 (ちえ)'
    WHEN 'freedom' THEN '自由 (じゆう)'
    WHEN 'justice' THEN '正義 (せいぎ)'
    WHEN 'courage' THEN '勇気 (ゆうき)'
    WHEN 'strength' THEN '強さ (つよさ)'
    WHEN 'knowledge' THEN '知識 (ちしき)'
    WHEN 'learning' THEN '学習 (がくしゅう)'
    WHEN 'future' THEN '未来 (みらい)'
    WHEN 'past' THEN '過去 (かこ)'
    WHEN 'present' THEN '現在 (げんざい)'
    WHEN 'success' THEN '成功 (せいこう)'
  END
FROM words w
WHERE w.word IN ('water', 'fire', 'earth', 'wind', 'light', 'dark', 'hope', 'faith', 'truth', 'beauty', 'nature', 'power', 'space', 'heart', 'mind', 'soul', 'spirit', 'change', 'growth', 'wisdom', 'freedom', 'justice', 'courage', 'strength', 'knowledge', 'learning', 'future', 'past', 'present', 'success')
ON CONFLICT (word_id, language) DO UPDATE SET
  translation = EXCLUDED.translation;

-- Create some meaningful relationships between words
INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
SELECT 
  w1.id, w2.id, 'antonym', 'Opposite concepts'
FROM words w1, words w2
WHERE (w1.word = 'light' AND w2.word = 'dark')
   OR (w1.word = 'hope' AND w2.word = 'despair')
   OR (w1.word = 'future' AND w2.word = 'past')
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
SELECT 
  w1.id, w2.id, 'related', 'Related concepts'
FROM words w1, words w2
WHERE (w1.word = 'heart' AND w2.word = 'love')
   OR (w1.word = 'mind' AND w2.word = 'knowledge')
   OR (w1.word = 'nature' AND w2.word = 'earth')
   OR (w1.word = 'water' AND w2.word = 'life')
   OR (w1.word = 'fire' AND w2.word = 'power')
   OR (w1.word = 'wisdom' AND w2.word = 'knowledge')
   OR (w1.word = 'growth' AND w2.word = 'change')
   OR (w1.word = 'success' AND w2.word = 'work')
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
SELECT 
  w1.id, w2.id, 'synonym', 'Similar meaning'
FROM words w1, words w2
WHERE (w1.word = 'heart' AND w2.word = 'soul')
   OR (w1.word = 'mind' AND w2.word = 'spirit')
   OR (w1.word = 'strength' AND w2.word = 'power')
   OR (w1.word = 'learning' AND w2.word = 'knowledge')
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

-- Insert trending data for these words
INSERT INTO word_trends (word_id, views, last_viewed)
SELECT w.id, 
  CASE w.word
    WHEN 'love' THEN 250
    WHEN 'time' THEN 220
    WHEN 'life' THEN 200
    WHEN 'heart' THEN 180
    WHEN 'hope' THEN 170
    WHEN 'nature' THEN 160
    WHEN 'power' THEN 150
    WHEN 'truth' THEN 140
    WHEN 'beauty' THEN 130
    WHEN 'wisdom' THEN 120
    WHEN 'freedom' THEN 110
    WHEN 'success' THEN 100
    ELSE 50 + floor(random() * 50)
  END,
  now() - (random() * interval '7 days')
FROM words w
WHERE w.word IN ('water', 'fire', 'earth', 'wind', 'light', 'dark', 'hope', 'faith', 'truth', 'beauty', 'nature', 'power', 'space', 'heart', 'mind', 'soul', 'spirit', 'change', 'growth', 'wisdom', 'freedom', 'justice', 'courage', 'strength', 'knowledge', 'learning', 'future', 'past', 'present', 'success')
ON CONFLICT (word_id) DO UPDATE SET
  views = EXCLUDED.views,
  last_viewed = EXCLUDED.last_viewed;