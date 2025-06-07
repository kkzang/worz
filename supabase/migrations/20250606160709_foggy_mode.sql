-- Create words table if it doesn't exist
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
  contributor_id uuid REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Create word_translations table if it doesn't exist
CREATE TABLE IF NOT EXISTS word_translations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word_id uuid REFERENCES words(id) ON DELETE CASCADE,
  language text NOT NULL CHECK (language IN ('en', 'ko', 'ja')),
  translation text NOT NULL,
  pronunciation text,
  notes text,
  contributor_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(word_id, language)
);

-- Create word_relationships table if it doesn't exist
CREATE TABLE IF NOT EXISTS word_relationships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_word_id uuid REFERENCES words(id) ON DELETE CASCADE,
  target_word_id uuid REFERENCES words(id) ON DELETE CASCADE,
  relationship_type text NOT NULL CHECK (relationship_type IN ('synonym', 'antonym', 'related')),
  description text,
  strength float DEFAULT 1.0,
  created_at timestamptz DEFAULT now(),
  contributor_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  UNIQUE(source_word_id, target_word_id, relationship_type)
);

-- Create word_trends table if it doesn't exist
CREATE TABLE IF NOT EXISTS word_trends (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word_id uuid REFERENCES words(id) ON DELETE CASCADE,
  views integer DEFAULT 0,
  last_viewed timestamptz DEFAULT now(),
  trending_score float DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  UNIQUE(word_id)
);

-- Create word_contributions table if it doesn't exist
CREATE TABLE IF NOT EXISTS word_contributions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word_id uuid REFERENCES words(id) ON DELETE CASCADE,
  contributor_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  contribution_type text NOT NULL CHECK (contribution_type IN ('new_word', 'translation', 'relationship', 'example')),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  content jsonb NOT NULL,
  created_at timestamptz DEFAULT now(),
  reviewed_at timestamptz,
  reviewer_id uuid REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Create word_votes table if it doesn't exist
CREATE TABLE IF NOT EXISTS word_votes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  word_id uuid REFERENCES words(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  vote_type text NOT NULL CHECK (vote_type IN ('upvote', 'downvote')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(word_id, user_id)
);

-- Enable RLS on all tables
ALTER TABLE words ENABLE ROW LEVEL SECURITY;
ALTER TABLE word_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE word_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE word_trends ENABLE ROW LEVEL SECURITY;
ALTER TABLE word_contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE word_votes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DO $$ 
BEGIN
  -- Words table policies
  DROP POLICY IF EXISTS "Allow public read access on words" ON words;
  DROP POLICY IF EXISTS "Allow authenticated users to insert words" ON words;
  DROP POLICY IF EXISTS "Allow contributors to update their words" ON words;
  
  -- Word translations policies
  DROP POLICY IF EXISTS "Allow public read access on word_translations" ON word_translations;
  DROP POLICY IF EXISTS "Allow authenticated users to insert translations" ON word_translations;
  DROP POLICY IF EXISTS "Allow contributors to update their translations" ON word_translations;
  
  -- Word relationships policies
  DROP POLICY IF EXISTS "Allow public read access on word_relationships" ON word_relationships;
  DROP POLICY IF EXISTS "Allow authenticated users to insert relationships" ON word_relationships;
  DROP POLICY IF EXISTS "Allow contributors to update their relationships" ON word_relationships;
  
  -- Word trends policies
  DROP POLICY IF EXISTS "Allow public read access on word_trends" ON word_trends;
  DROP POLICY IF EXISTS "Allow system updates on word_trends" ON word_trends;
  
  -- Word contributions policies
  DROP POLICY IF EXISTS "Allow public read access on word_contributions" ON word_contributions;
  DROP POLICY IF EXISTS "Allow authenticated users to contribute" ON word_contributions;
  DROP POLICY IF EXISTS "Allow contributors to update their pending contributions" ON word_contributions;
  
  -- Word votes policies
  DROP POLICY IF EXISTS "Allow public read access on word_votes" ON word_votes;
  DROP POLICY IF EXISTS "Allow authenticated users to vote" ON word_votes;
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
  USING (contributor_id = auth.uid() OR contributor_id IS NULL)
  WITH CHECK (contributor_id = auth.uid() OR contributor_id IS NULL);

-- Create policies for word_translations table
CREATE POLICY "Allow public read access on word_translations"
  ON word_translations
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to insert translations"
  ON word_translations
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow contributors to update their translations"
  ON word_translations
  FOR UPDATE
  TO authenticated
  USING (contributor_id = auth.uid() OR contributor_id IS NULL)
  WITH CHECK (contributor_id = auth.uid() OR contributor_id IS NULL);

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
  USING (contributor_id = auth.uid() OR contributor_id IS NULL)
  WITH CHECK (contributor_id = auth.uid() OR contributor_id IS NULL);

-- Create policies for word_trends table
CREATE POLICY "Allow public read access on word_trends"
  ON word_trends
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow system updates on word_trends"
  ON word_trends
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create policies for word_contributions table
CREATE POLICY "Allow public read access on word_contributions"
  ON word_contributions
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to contribute"
  ON word_contributions
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow contributors to update their pending contributions"
  ON word_contributions
  FOR UPDATE
  TO authenticated
  USING ((contributor_id = auth.uid() OR contributor_id IS NULL) AND status = 'pending')
  WITH CHECK ((contributor_id = auth.uid() OR contributor_id IS NULL) AND status = 'pending');

-- Create policies for word_votes table
CREATE POLICY "Allow public read access on word_votes"
  ON word_votes
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to vote"
  ON word_votes
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_words_word ON words(word);
CREATE INDEX IF NOT EXISTS idx_words_category ON words(category);
CREATE INDEX IF NOT EXISTS idx_word_translations_word ON word_translations(word_id);
CREATE INDEX IF NOT EXISTS idx_word_translations_language ON word_translations(language);
CREATE INDEX IF NOT EXISTS idx_word_relationships_source ON word_relationships(source_word_id);
CREATE INDEX IF NOT EXISTS idx_word_relationships_target ON word_relationships(target_word_id);
CREATE INDEX IF NOT EXISTS idx_word_trends_score ON word_trends(trending_score DESC);
CREATE INDEX IF NOT EXISTS idx_word_contributions_status ON word_contributions(status);
CREATE INDEX IF NOT EXISTS idx_word_contributions_contributor ON word_contributions(contributor_id);
CREATE INDEX IF NOT EXISTS idx_word_votes_word ON word_votes(word_id);
CREATE INDEX IF NOT EXISTS idx_word_votes_user ON word_votes(user_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
DROP TRIGGER IF EXISTS update_words_updated_at ON words;
CREATE TRIGGER update_words_updated_at
  BEFORE UPDATE ON words
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_word_translations_updated_at ON word_translations;
CREATE TRIGGER update_word_translations_updated_at
  BEFORE UPDATE ON word_translations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate trending score
CREATE OR REPLACE FUNCTION calculate_trending_score(
  views integer,
  last_viewed timestamptz
) RETURNS float AS $$
BEGIN
  RETURN (views::float * exp(-extract(epoch from (now() - last_viewed)) / 86400.0));
END;
$$ LANGUAGE plpgsql;

-- Function to update trending score
CREATE OR REPLACE FUNCTION update_trending_score()
RETURNS TRIGGER AS $$
BEGIN
  NEW.trending_score = calculate_trending_score(NEW.views, NEW.last_viewed);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update trending score
DROP TRIGGER IF EXISTS update_word_trending_score ON word_trends;
CREATE TRIGGER update_word_trending_score
  BEFORE INSERT OR UPDATE ON word_trends
  FOR EACH ROW
  EXECUTE FUNCTION update_trending_score();

-- Function to generate comprehensive word dataset
CREATE OR REPLACE FUNCTION generate_comprehensive_word_data() RETURNS void AS $$
DECLARE
  -- Abstract concepts (500 words)
  abstract_words text[] := ARRAY['love', 'time', 'freedom', 'peace', 'truth', 'beauty', 'justice', 'wisdom', 'infinity', 'eternity', 'destiny', 'fate', 'chaos', 'harmony', 'balance', 'unity', 'spirit', 'soul', 'mind', 'consciousness', 'reality', 'existence', 'purpose', 'meaning', 'hope', 'faith', 'trust', 'courage', 'strength', 'power', 'energy', 'force', 'motion', 'change', 'growth', 'progress', 'evolution', 'development', 'improvement', 'success', 'achievement', 'victory', 'triumph', 'glory', 'honor', 'dignity', 'respect', 'admiration', 'appreciation', 'gratitude', 'kindness', 'compassion', 'empathy', 'sympathy', 'understanding', 'patience', 'tolerance', 'acceptance', 'forgiveness', 'mercy', 'grace', 'blessing', 'miracle', 'wonder', 'mystery', 'secret', 'knowledge', 'intelligence', 'creativity', 'imagination', 'inspiration', 'motivation', 'determination', 'perseverance', 'resilience', 'endurance', 'stability', 'security', 'safety', 'protection', 'shelter', 'comfort', 'warmth', 'coolness', 'freshness', 'purity', 'clarity', 'transparency', 'honesty', 'integrity', 'loyalty', 'devotion', 'commitment', 'dedication', 'responsibility', 'duty', 'obligation', 'promise', 'vow', 'oath', 'contract', 'agreement', 'deal', 'bargain', 'exchange', 'trade', 'commerce', 'business', 'work', 'labor', 'effort', 'struggle', 'challenge', 'difficulty', 'problem', 'solution', 'answer', 'question', 'inquiry', 'investigation', 'research', 'study', 'analysis', 'examination', 'observation', 'discovery', 'invention', 'creation', 'innovation', 'revolution', 'transformation', 'metamorphosis', 'evolution', 'adaptation', 'adjustment', 'modification', 'alteration', 'variation', 'difference', 'similarity', 'comparison', 'contrast', 'distinction', 'separation', 'division', 'multiplication', 'addition', 'subtraction', 'calculation', 'computation', 'mathematics', 'science', 'technology', 'engineering', 'architecture', 'construction', 'building', 'structure', 'foundation', 'framework', 'system', 'organization', 'arrangement', 'order', 'sequence', 'pattern', 'design', 'plan', 'strategy', 'tactic', 'method', 'technique', 'approach', 'way', 'path', 'route', 'direction', 'destination', 'goal', 'objective', 'target', 'aim', 'intention', 'purpose', 'reason', 'cause', 'effect', 'result', 'consequence', 'outcome', 'conclusion', 'ending', 'finish', 'completion', 'accomplishment', 'fulfillment', 'satisfaction', 'contentment', 'happiness', 'joy', 'pleasure', 'delight', 'enjoyment', 'fun', 'entertainment', 'amusement', 'recreation', 'relaxation', 'rest', 'sleep', 'dream', 'nightmare', 'fantasy', 'illusion', 'reality', 'truth', 'fact', 'fiction', 'story', 'tale', 'legend', 'myth', 'folklore', 'tradition', 'custom', 'habit', 'routine', 'practice', 'exercise', 'training', 'education', 'learning', 'teaching', 'instruction', 'guidance', 'advice', 'suggestion', 'recommendation', 'proposal', 'offer', 'invitation', 'request', 'demand', 'requirement', 'necessity', 'need', 'want', 'desire', 'wish', 'hope', 'expectation', 'anticipation', 'prediction', 'forecast', 'prophecy', 'vision', 'sight', 'view', 'perspective', 'opinion', 'belief', 'thought', 'idea', 'concept', 'notion', 'theory', 'hypothesis', 'assumption', 'presumption', 'supposition', 'speculation', 'guess', 'estimate', 'calculation', 'measurement', 'evaluation', 'assessment', 'judgment', 'decision', 'choice', 'selection', 'option', 'alternative', 'possibility', 'probability', 'chance', 'opportunity', 'luck', 'fortune', 'fate', 'destiny', 'future', 'past', 'present', 'moment', 'instant', 'second', 'minute', 'hour', 'day', 'week', 'month', 'year', 'decade', 'century', 'millennium', 'age', 'era', 'period', 'phase', 'stage', 'step', 'level', 'degree', 'extent', 'amount', 'quantity', 'number', 'figure', 'statistic', 'data', 'information', 'knowledge', 'wisdom', 'understanding', 'comprehension', 'awareness', 'consciousness', 'recognition', 'acknowledgment', 'admission', 'confession', 'declaration', 'statement', 'announcement', 'proclamation', 'publication', 'release', 'disclosure', 'revelation', 'exposure', 'discovery', 'finding', 'detection', 'identification', 'recognition', 'realization', 'understanding', 'insight', 'enlightenment', 'awakening', 'awareness', 'consciousness', 'mindfulness', 'attention', 'focus', 'concentration', 'meditation', 'contemplation', 'reflection', 'consideration', 'thought', 'thinking', 'reasoning', 'logic', 'rationality', 'sensibility', 'practicality', 'realism', 'idealism', 'optimism', 'pessimism', 'cynicism', 'skepticism', 'doubt', 'uncertainty', 'confusion', 'clarity', 'understanding', 'knowledge', 'ignorance', 'stupidity', 'intelligence', 'brilliance', 'genius', 'talent', 'skill', 'ability', 'capability', 'capacity', 'potential', 'possibility', 'opportunity', 'chance', 'luck', 'fortune', 'blessing', 'gift', 'present', 'surprise', 'shock', 'amazement', 'wonder', 'awe', 'admiration', 'respect', 'reverence', 'worship', 'adoration', 'love', 'affection', 'fondness', 'liking', 'preference', 'choice', 'selection', 'decision', 'determination', 'resolution', 'commitment', 'dedication', 'devotion', 'loyalty', 'faithfulness', 'reliability', 'dependability', 'trustworthiness', 'honesty', 'sincerity', 'genuineness', 'authenticity', 'originality', 'uniqueness', 'individuality', 'personality', 'character', 'nature', 'essence', 'substance', 'material', 'matter', 'element', 'component', 'part', 'piece', 'fragment', 'portion', 'section', 'segment', 'division', 'category', 'class', 'group', 'team', 'crew', 'staff', 'personnel', 'workforce', 'employees', 'workers', 'laborers', 'professionals', 'experts', 'specialists', 'authorities', 'leaders', 'managers', 'supervisors', 'directors', 'executives', 'officials', 'representatives', 'delegates', 'ambassadors', 'messengers', 'communicators', 'speakers', 'presenters', 'performers', 'artists', 'creators', 'makers', 'builders', 'constructors', 'developers', 'designers', 'architects', 'engineers', 'scientists', 'researchers', 'investigators', 'explorers', 'discoverers', 'inventors', 'innovators', 'pioneers', 'leaders', 'followers', 'supporters', 'advocates', 'defenders', 'protectors', 'guardians', 'keepers', 'custodians', 'caretakers', 'providers', 'suppliers', 'vendors', 'sellers', 'merchants', 'traders', 'dealers', 'brokers', 'agents', 'representatives', 'intermediaries', 'mediators', 'negotiators', 'diplomats', 'peacemakers', 'reconcilers', 'healers', 'doctors', 'physicians', 'surgeons', 'nurses', 'therapists', 'counselors', 'advisors', 'consultants', 'coaches', 'trainers', 'instructors', 'teachers', 'educators', 'professors', 'scholars', 'students', 'learners', 'pupils', 'disciples', 'followers', 'admirers', 'fans', 'supporters', 'enthusiasts', 'lovers', 'devotees', 'believers', 'faithful', 'loyal', 'dedicated', 'committed', 'devoted', 'passionate', 'enthusiastic', 'excited', 'thrilled', 'delighted', 'pleased', 'satisfied', 'content', 'happy', 'joyful', 'cheerful', 'optimistic', 'positive', 'hopeful', 'confident', 'assured', 'certain', 'sure', 'definite', 'absolute', 'complete', 'total', 'entire', 'whole', 'full', 'maximum', 'ultimate', 'final', 'last', 'end'];
  
  abstract_ko text[] := ARRAY['사랑', '시간', '자유', '평화', '진실', '아름다움', '정의', '지혜', '무한', '영원', '운명', '숙명', '혼돈', '조화', '균형', '통일', '정신', '영혼', '마음', '의식', '현실', '존재', '목적', '의미', '희망', '믿음', '신뢰', '용기', '힘', '권력', '에너지', '힘', '움직임', '변화', '성장', '진보', '진화', '발전', '개선', '성공', '성취', '승리', '승리', '영광', '명예', '존엄', '존경', '감탄', '감사', '감사', '친절', '연민', '공감', '동정', '이해', '인내', '관용', '수용', '용서', '자비', '은혜', '축복', '기적', '경이', '신비', '비밀', '지식', '지능', '창의성', '상상력', '영감', '동기', '결심', '인내', '회복력', '지구력', '안정성', '보안', '안전', '보호', '피난처', '편안함', '따뜻함', '시원함', '신선함', '순수함', '명확성', '투명성', '정직', '성실', '충성', '헌신', '약속', '헌신', '책임', '의무', '의무', '약속', '맹세', '맹세', '계약', '합의', '거래', '교섭', '교환', '무역', '상업', '사업', '일', '노동', '노력', '투쟁', '도전', '어려움', '문제', '해결책', '답', '질문', '문의', '조사', '연구', '연구', '분석', '검사', '관찰', '발견', '발명', '창조', '혁신', '혁명', '변화', '변태', '진화', '적응', '조정', '수정', '변경', '변화', '차이', '유사성', '비교', '대조', '구별', '분리', '나눗셈', '곱셈', '덧셈', '뺄셈', '계산', '계산', '수학', '과학', '기술', '공학', '건축', '건설', '건물', '구조', '기초', '프레임워크', '시스템', '조직', '배치', '순서', '순서', '패턴', '디자인', '계획', '전략', '전술', '방법', '기술', '접근법', '방법', '경로', '경로', '방향', '목적지', '목표', '목적', '목표', '목표', '의도', '목적', '이유', '원인', '효과', '결과', '결과', '결과', '결론', '끝', '마침', '완료', '성취', '성취', '만족', '만족', '행복', '기쁨', '즐거움', '기쁨', '즐거움', '재미', '오락', '오락', '레크리에이션', '휴식', '휴식', '잠', '꿈', '악몽', '환상', '환상', '현실', '진실', '사실', '소설', '이야기', '이야기', '전설', '신화', '민속', '전통', '관습', '습관', '루틴', '연습', '운동', '훈련', '교육', '학습', '교육', '지시', '지도', '조언', '제안', '추천', '제안', '제안', '초대', '요청', '요구', '요구사항', '필요성', '필요', '원함', '욕망', '소원', '희망', '기대', '예상', '예측', '예보', '예언', '비전', '시야', '보기', '관점', '의견', '믿음', '생각', '아이디어', '개념', '개념', '이론', '가설', '가정', '추정', '추정', '추측', '추측', '추정', '계산', '측정', '평가', '평가', '판단', '결정', '선택', '선택', '옵션', '대안', '가능성', '확률', '기회', '기회', '운', '운', '운명', '운명', '미래', '과거', '현재', '순간', '즉시', '초', '분', '시간', '일', '주', '월', '년', '십년', '세기', '천년', '나이', '시대', '기간', '단계', '단계', '단계', '수준', '정도', '정도', '양', '수량', '번호', '그림', '통계', '데이터', '정보', '지식', '지혜', '이해', '이해', '인식', '의식', '인식', '인정', '입학', '고백', '선언', '성명', '발표', '선언', '출판', '릴리스', '공개', '계시', '노출', '발견', '찾기', '탐지', '식별', '인식', '실현', '이해', '통찰력', '깨달음', '각성', '인식', '의식', '마음챙김', '주의', '초점', '집중', '명상', '명상', '반사', '고려', '생각', '사고', '추론', '논리', '합리성', '감성', '실용성', '현실주의', '이상주의', '낙관주의', '비관주의', '냉소주의', '회의주의', '의심', '불확실성', '혼란', '명확성', '이해', '지식', '무지', '어리석음', '지능', '광채', '천재', '재능', '기술', '능력', '능력', '용량', '잠재력', '가능성', '기회', '기회', '운', '운', '축복', '선물', '현재', '놀라움', '충격', '놀라움', '경이', '경외', '감탄', '존경', '경외', '숭배', '숭배', '사랑', '애정', '애정', '좋아함', '선호', '선택', '선택', '결정', '결심', '해결', '약속', '헌신', '헌신', '충성', '충실함', '신뢰성', '의존성', '신뢰성', '정직', '성실', '진실성', '진정성', '독창성', '독특함', '개성', '성격', '성격', '자연', '본질', '물질', '물질', '물질', '요소', '구성 요소', '부분', '조각', '조각', '부분', '섹션', '세그먼트', '나눗셈', '카테고리', '클래스', '그룹', '팀', '승무원', '직원', '인사', '인력', '직원', '근로자', '노동자', '전문가', '전문가', '전문가', '당국', '지도자', '관리자', '감독자', '이사', '임원', '공무원', '대표', '대표', '대사', '메신저', '커뮤니케이터', '스피커', '발표자', '공연자', '예술가', '창작자', '제작자', '건축업자', '건설업자', '개발자', '디자이너', '건축가', '엔지니어', '과학자', '연구원', '수사관', '탐험가', '발견자', '발명가', '혁신가', '개척자', '지도자', '추종자', '지지자', '옹호자', '수비수', '보호자', '수호자', '키퍼', '관리인', '간병인', '제공자', '공급업체', '공급업체', '판매자', '상인', '상인', '딜러', '브로커', '에이전트', '대표', '중개자', '중재자', '협상가', '외교관', '평화 조성자', '화해자', '치료사', '의사', '의사', '외과의', '간호사', '치료사', '상담사', '고문', '컨설턴트', '코치', '트레이너', '강사', '교사', '교육자', '교수', '학자', '학생', '학습자', '학생', '제자', '추종자', '감탄자', '팬', '지지자', '애호가', '연인', '신도', '신자', '충실한', '충성스러운', '헌신적인', '헌신적인', '헌신적인', '열정적인', '열정적인', '흥분한', '스릴', '기쁜', '기쁜', '만족한', '만족한', '행복한', '기쁜', '쾌활한', '낙관적인', '긍정적인', '희망적인', '자신감 있는', '확신하는', '확실한', '확실한', '확실한', '절대적인', '완전한', '총', '전체', '전체', '가득한', '최대', '궁극적인', '최종', '마지막', '끝'];
  
  abstract_ja text[] := ARRAY['愛 (あい)', '時間 (じかん)', '自由 (じゆう)', '平和 (へいわ)', '真実 (しんじつ)', '美 (び)', '正義 (せいぎ)', '知恵 (ちえ)', '無限 (むげん)', '永遠 (えいえん)', '運命 (うんめい)', '宿命 (しゅくめい)', '混沌 (こんとん)', '調和 (ちょうわ)', 'バランス', '統一 (とういつ)', '精神 (せいしん)', '魂 (たましい)', '心 (こころ)', '意識 (いしき)', '現実 (げんじつ)', '存在 (そんざい)', '目的 (もくてき)', '意味 (いみ)', '希望 (きぼう)', '信仰 (しんこう)', '信頼 (しんらい)', '勇気 (ゆうき)', '力 (ちから)', '権力 (けんりょく)', 'エネルギー', '力 (ちから)', '運動 (うんどう)', '変化 (へんか)', '成長 (せいちょう)', '進歩 (しんぽ)', '進化 (しんか)', '発展 (はってん)', '改善 (かいぜん)', '成功 (せいこう)', '達成 (たっせい)', '勝利 (しょうり)', '勝利 (しょうり)', '栄光 (えいこう)', '名誉 (めいよ)', '尊厳 (そんげん)', '尊敬 (そんけい)', '感嘆 (かんたん)', '感謝 (かんしゃ)', '感謝 (かんしゃ)', '親切 (しんせつ)', '慈悲 (じひ)', '共感 (きょうかん)', '同情 (どうじょう)', '理解 (りかい)', '忍耐 (にんたい)', '寛容 (かんよう)', '受容 (じゅよう)', '許し (ゆるし)', '慈悲 (じひ)', '恵み (めぐみ)', '祝福 (しゅくふく)', '奇跡 (きせき)', '驚異 (きょうい)', '神秘 (しんぴ)', '秘密 (ひみつ)', '知識 (ちしき)', '知能 (ちのう)', '創造性 (そうぞうせい)', '想像力 (そうぞうりょく)', 'インスピレーション', '動機 (どうき)', '決意 (けつい)', '忍耐 (にんたい)', '回復力 (かいふくりょく)', '持久力 (じきゅうりょく)', '安定性 (あんていせい)', 'セキュリティ', '安全 (あんぜん)', '保護 (ほご)', '避難所 (ひなんじょ)', '快適 (かいてき)', '暖かさ (あたたかさ)', '涼しさ (すずしさ)', '新鮮さ (しんせんさ)', '純粋 (じゅんすい)', '明確性 (めいかくせい)', '透明性 (とうめいせい)', '正直 (しょうじき)', '誠実 (せいじつ)', '忠誠 (ちゅうせい)', '献身 (けんしん)', '約束 (やくそく)', '献身 (けんしん)', '責任 (せきにん)', '義務 (ぎむ)', '義務 (ぎむ)', '約束 (やくそく)', '誓い (ちかい)', '誓い (ちかい)', '契約 (けいやく)', '合意 (ごうい)', '取引 (とりひき)', '交渉 (こうしょう)', '交換 (こうかん)', '貿易 (ぼうえき)', '商業 (しょうぎょう)', 'ビジネス', '仕事 (しごと)', '労働 (ろうどう)', '努力 (どりょく)', '闘争 (とうそう)', '挑戦 (ちょうせん)', '困難 (こんなん)', '問題 (もんだい)', '解決策 (かいけつさく)', '答え (こたえ)', '質問 (しつもん)', '問い合わせ (といあわせ)', '調査 (ちょうさ)', '研究 (けんきゅう)', '研究 (けんきゅう)', '分析 (ぶんせき)', '検査 (けんさ)', '観察 (かんさつ)', '発見 (はっけん)', '発明 (はつめい)', '創造 (そうぞう)', '革新 (かくしん)', '革命 (かくめい)', '変化 (へんか)', '変態 (へんたい)', '進化 (しんか)', '適応 (てきおう)', '調整 (ちょうせい)', '修正 (しゅうせい)', '変更 (へんこう)', '変化 (へんか)', '違い (ちがい)', '類似性 (るいじせい)', '比較 (ひかく)', '対比 (たいひ)', '区別 (くべつ)', '分離 (ぶんり)', '除算 (じょざん)', '乗算 (じょうざん)', '加算 (かさん)', '減算 (げんざん)', '計算 (けいさん)', '計算 (けいさん)', '数学 (すうがく)', '科学 (かがく)', '技術 (ぎじゅつ)', '工学 (こうがく)', '建築 (けんちく)', '建設 (けんせつ)', '建物 (たてもの)', '構造 (こうぞう)', '基礎 (きそ)', 'フレームワーク', 'システム', '組織 (そしき)', '配置 (はいち)', '順序 (じゅんじょ)', '順序 (じゅんじょ)', 'パターン', 'デザイン', '計画 (けいかく)', '戦略 (せんりゃく)', '戦術 (せんじゅつ)', '方法 (ほうほう)', '技術 (ぎじゅつ)', 'アプローチ', '方法 (ほうほう)', '道 (みち)', 'ルート', '方向 (ほうこう)', '目的地 (もくてきち)', '目標 (もくひょう)', '目的 (もくてき)', 'ターゲット', '目標 (もくひょう)', '意図 (いと)', '目的 (もくてき)', '理由 (りゆう)', '原因 (げんいん)', '効果 (こうか)', '結果 (けっか)', '結果 (けっか)', '結果 (けっか)', '結論 (けつろん)', '終わり (おわり)', '終了 (しゅうりょう)', '完了 (かんりょう)', '達成 (たっせい)', '達成 (たっせい)', '満足 (まんぞく)', '満足 (まんぞく)', '幸福 (こうふく)', '喜び (よろこび)', '喜び (よろこび)', '喜び (よろこび)', '楽しみ (たのしみ)', '楽しさ (たのしさ)', '娯楽 (ごらく)', '娯楽 (ごらく)', 'レクリエーション', 'リラクゼーション', '休息 (きゅうそく)', '睡眠 (すいみん)', '夢 (ゆめ)', '悪夢 (あくむ)', 'ファンタジー', '幻想 (げんそう)', '現実 (げんじつ)', '真実 (しんじつ)', '事実 (じじつ)', 'フィクション', '物語 (ものがたり)', '物語 (ものがたり)', '伝説 (でんせつ)', '神話 (しんわ)', '民俗 (みんぞく)', '伝統 (でんとう)', '習慣 (しゅうかん)', '習慣 (しゅうかん)', 'ルーチン', '練習 (れんしゅう)', '運動 (うんどう)', '訓練 (くんれん)', '教育 (きょういく)', '学習 (がくしゅう)', '教育 (きょういく)', '指示 (しじ)', '指導 (しどう)', 'アドバイス', '提案 (ていあん)', '推薦 (すいせん)', '提案 (ていあん)', '申し出 (もうしで)', '招待 (しょうたい)', '要求 (ようきゅう)', '要求 (ようきゅう)', '要件 (ようけん)', '必要性 (ひつようせい)', '必要 (ひつよう)', '欲しい (ほしい)', '欲望 (よくぼう)', '願い (ねがい)', '希望 (きぼう)', '期待 (きたい)', '予想 (よそう)', '予測 (よそく)', '予報 (よほう)', '予言 (よげん)', 'ビジョン', '視力 (しりょく)', 'ビュー', '視点 (してん)', '意見 (いけん)', '信念 (しんねん)', '思考 (しこう)', 'アイデア', '概念 (がいねん)', '概念 (がいねん)', '理論 (りろん)', '仮説 (かせつ)', '仮定 (かてい)', '推定 (すいてい)', '推定 (すいてい)', '推測 (すいそく)', '推測 (すいそく)', '推定 (すいてい)', '計算 (けいさん)', '測定 (そくてい)', '評価 (ひょうか)', '評価 (ひょうか)', '判断 (はんだん)', '決定 (けってい)', '選択 (せんたく)', '選択 (せんたく)', 'オプション', '代替 (だいたい)', '可能性 (かのうせい)', '確率 (かくりつ)', 'チャンス', '機会 (きかい)', '運 (うん)', '運 (うん)', '運命 (うんめい)', '運命 (うんめい)', '未来 (みらい)', '過去 (かこ)', '現在 (げんざい)', '瞬間 (しゅんかん)', '瞬間 (しゅんかん)', '秒 (びょう)', '分 (ふん)', '時間 (じかん)', '日 (ひ)', '週 (しゅう)', '月 (つき)', '年 (ねん)', '十年 (じゅうねん)', '世紀 (せいき)', '千年 (せんねん)', '年齢 (ねんれい)', '時代 (じだい)', '期間 (きかん)', '段階 (だんかい)', '段階 (だんかい)', 'ステップ', 'レベル', '度 (ど)', '程度 (ていど)', '量 (りょう)', '数量 (すうりょう)', '番号 (ばんごう)', '図 (ず)', '統計 (とうけい)', 'データ', '情報 (じょうほう)', '知識 (ちしき)', '知恵 (ちえ)', '理解 (りかい)', '理解 (りかい)', '認識 (にんしき)', '意識 (いしき)', '認識 (にんしき)', '承認 (しょうにん)', '入学 (にゅうがく)', '告白 (こくはく)', '宣言 (せんげん)', '声明 (せいめい)', '発表 (はっぴょう)', '宣言 (せんげん)', '出版 (しゅっぱん)', 'リリース', '開示 (かいじ)', '啓示 (けいじ)', '露出 (ろしゅつ)', '発見 (はっけん)', '発見 (はっけん)', '検出 (けんしゅつ)', '識別 (しきべつ)', '認識 (にんしき)', '実現 (じつげん)', '理解 (りかい)', '洞察 (どうさつ)', '悟り (さとり)', '覚醒 (かくせい)', '認識 (にんしき)', '意識 (いしき)', 'マインドフルネス', '注意 (ちゅうい)', 'フォーカス', '集中 (しゅうちゅう)', '瞑想 (めいそう)', '瞑想 (めいそう)', '反射 (はんしゃ)', '考慮 (こうりょ)', '思考 (しこう)', '思考 (しこう)', '推論 (すいろん)', '論理 (ろんり)', '合理性 (ごうりせい)', '感性 (かんせい)', '実用性 (じつようせい)', '現実主義 (げんじつしゅぎ)', '理想主義 (りそうしゅぎ)', '楽観主義 (らっかんしゅぎ)', '悲観主義 (ひかんしゅぎ)', '皮肉主義 (ひにくしゅぎ)', '懐疑主義 (かいぎしゅぎ)', '疑い (うたがい)', '不確実性 (ふかくじつせい)', '混乱 (こんらん)', '明確性 (めいかくせい)', '理解 (りかい)', '知識 (ちしき)', '無知 (むち)', '愚かさ (おろかさ)', '知能 (ちのう)', '輝き (かがやき)', '天才 (てんさい)', '才能 (さいのう)', 'スキル', '能力 (のうりょく)', '能力 (のうりょく)', '容量 (ようりょう)', '潜在能力 (せんざいのうりょく)', '可能性 (かのうせい)', '機会 (きかい)', 'チャンス', '運 (うん)', '運 (うん)', '祝福 (しゅくふく)', '贈り物 (おくりもの)', 'プレゼント', '驚き (おどろき)', 'ショック', '驚き (おどろき)', '驚異 (きょうい)', '畏敬 (いけい)', '感嘆 (かんたん)', '尊敬 (そんけい)', '畏敬 (いけい)', '崇拝 (すうはい)', '崇拝 (すうはい)', '愛 (あい)', '愛情 (あいじょう)', '愛情 (あいじょう)', '好み (このみ)', '好み (このみ)', '選択 (せんたく)', '選択 (せんたく)', '決定 (けってい)', '決意 (けつい)', '解決 (かいけつ)', '約束 (やくそく)', '献身 (けんしん)', '献身 (けんしん)', '忠誠 (ちゅうせい)', '忠実 (ちゅうじつ)', '信頼性 (しんらいせい)', '依存性 (いぞんせい)', '信頼性 (しんらいせい)', '正直 (しょうじき)', '誠実 (せいじつ)', '真正性 (しんせいせい)', '真正性 (しんせいせい)', '独創性 (どくそうせい)', '独自性 (どくじせい)', '個性 (こせい)', '性格 (せいかく)', '性格 (せいかく)', '自然 (しぜん)', '本質 (ほんしつ)', '物質 (ぶっしつ)', '物質 (ぶっしつ)', '物質 (ぶっしつ)', '要素 (ようそ)', 'コンポーネント', '部分 (ぶぶん)', 'ピース', '断片 (だんぺん)', '部分 (ぶぶん)', 'セクション', 'セグメント', '除算 (じょざん)', 'カテゴリ', 'クラス', 'グループ', 'チーム', 'クルー', 'スタッフ', '人事 (じんじ)', '労働力 (ろうどうりょく)', '従業員 (じゅうぎょういん)', '労働者 (ろうどうしゃ)', '労働者 (ろうどうしゃ)', '専門家 (せんもんか)', '専門家 (せんもんか)', '専門家 (せんもんか)', '当局 (とうきょく)', 'リーダー', 'マネージャー', '監督者 (かんとくしゃ)', 'ディレクター', '幹部 (かんぶ)', '役人 (やくにん)', '代表 (だいひょう)', '代表 (だいひょう)', '大使 (たいし)', 'メッセンジャー', 'コミュニケーター', 'スピーカー', 'プレゼンター', 'パフォーマー', 'アーティスト', 'クリエイター', 'メーカー', 'ビルダー', 'コンストラクター', '開発者 (かいはつしゃ)', 'デザイナー', '建築家 (けんちくか)', 'エンジニア', '科学者 (かがくしゃ)', '研究者 (けんきゅうしゃ)', '調査員 (ちょうさいん)', '探検家 (たんけんか)', '発見者 (はっけんしゃ)', '発明者 (はつめいしゃ)', '革新者 (かくしんしゃ)', '開拓者 (かいたくしゃ)', 'リーダー', 'フォロワー', 'サポーター', '支持者 (しじしゃ)', '擁護者 (ようごしゃ)', '守備者 (しゅびしゃ)', '保護者 (ほごしゃ)', '守護者 (しゅごしゃ)', 'キーパー', '管理人 (かんりにん)', '介護者 (かいごしゃ)', 'プロバイダー', 'サプライヤー', 'ベンダー', '売り手 (うりて)', '商人 (しょうにん)', '商人 (しょうにん)', 'ディーラー', 'ブローカー', 'エージェント', '代表 (だいひょう)', '仲介者 (ちゅうかいしゃ)', '調停者 (ちょうていしゃ)', '交渉者 (こうしょうしゃ)', '外交官 (がいこうかん)', '平和構築者 (へいわこうちくしゃ)', '和解者 (わかいしゃ)', 'ヒーラー', '医師 (いし)', '医師 (いし)', '外科医 (げかい)', '看護師 (かんごし)', 'セラピスト', 'カウンセラー', 'アドバイザー', 'コンサルタント', 'コーチ', 'トレーナー', 'インストラクター', '教師 (きょうし)', '教育者 (きょういくしゃ)', '教授 (きょうじゅ)', '学者 (がくしゃ)', '学生 (がくせい)', '学習者 (がくしゅうしゃ)', '生徒 (せいと)', '弟子 (でし)', 'フォロワー', '崇拝者 (すうはいしゃ)', 'ファン', 'サポーター', '愛好家 (あいこうか)', '恋人 (こいびと)', '信者 (しんじゃ)', '信者 (しんじゃ)', '忠実 (ちゅうじつ)', '忠実 (ちゅうじつ)', '献身的 (けんしんてき)', '献身的 (けんしんてき)', '献身的 (けんしんてき)', '情熱的 (じょうねつてき)', '熱狂的 (ねっきょうてき)', '興奮した (こうふんした)', 'スリル', '喜んだ (よろこんだ)', '喜んだ (よろこんだ)', '満足した (まんぞくした)', '満足した (まんぞくした)', '幸せ (しあわせ)', '喜ばしい (よろこばしい)', '陽気 (ようき)', '楽観的 (らっかんてき)', 'ポジティブ', '希望に満ちた (きぼうにみちた)', '自信に満ちた (じしんにみちた)', '確信した (かくしんした)', '確実 (かくじつ)', '確実 (かくじつ)', '確実 (かくじつ)', '絶対 (ぜったい)', '完全 (かんぜん)', '合計 (ごうけい)', '全体 (ぜんたい)', '全体 (ぜんたい)', '満杯 (まんぱい)', '最大 (さいだい)', '究極 (きゅうきょく)', '最終 (さいしゅう)', '最後 (さいご)', '終わり (おわり)'];

  word_count integer := 0;
  current_word_id uuid;
  i integer;
BEGIN
  -- Insert abstract words (system-generated data with NULL contributor_id)
  FOR i IN 1..array_upper(abstract_words, 1) LOOP
    INSERT INTO words (word, definition, category, bookmarks, contributor_id)
    VALUES (
      abstract_words[i],
      'Definition for ' || abstract_words[i],
      'Abstract',
      floor(random() * 1000),
      NULL  -- System-generated data has NULL contributor_id
    )
    ON CONFLICT (word) DO UPDATE SET
      definition = EXCLUDED.definition,
      category = EXCLUDED.category
    RETURNING id INTO current_word_id;
    
    -- Insert translations using qualified variable name
    INSERT INTO word_translations (word_id, language, translation, contributor_id)
    VALUES 
      (current_word_id, 'ko', abstract_ko[i], NULL),
      (current_word_id, 'ja', abstract_ja[i], NULL)
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
    
    -- Create some relationships
    IF word_count > 1 AND random() < 0.3 THEN
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
        'Related to ' || abstract_words[i],
        NULL  -- System-generated relationships
      FROM words w
      WHERE w.id != current_word_id
      ORDER BY random()
      LIMIT 1
      ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;
    END IF;
    
    -- Exit if we've reached 10,000 words
    IF word_count >= 10000 THEN
      EXIT;
    END IF;
  END LOOP;
  
  RAISE NOTICE 'Generated % words with translations and relationships', word_count;
END;
$$ LANGUAGE plpgsql;

-- Execute the function to generate comprehensive word data
SELECT generate_comprehensive_word_data();