/*
  # Add meaningful English words with Korean and Japanese translations

  1. New Tables
    - Removes any auto-generated numbered words (word_1, word_2, etc.)
    - Adds 200 meaningful English words with proper translations
    - Creates word relationships between related concepts

  2. Security
    - Uses existing RLS policies
    - Maintains data integrity with proper foreign key relationships

  3. Changes
    - Cleans up placeholder/generated words
    - Adds comprehensive vocabulary with translations
    - Creates semantic relationships between words
*/

-- First, remove any existing numbered words
DELETE FROM word_trends WHERE word_id IN (
  SELECT id FROM words WHERE word ~ '^word_\d+$'
);

DELETE FROM word_relationships WHERE 
  source_word_id IN (SELECT id FROM words WHERE word ~ '^word_\d+$') OR
  target_word_id IN (SELECT id FROM words WHERE word ~ '^word_\d+$');

DELETE FROM word_translations WHERE word_id IN (
  SELECT id FROM words WHERE word ~ '^word_\d+$'
);

DELETE FROM words WHERE word ~ '^word_\d+$';

-- Create a function to generate meaningful English words
CREATE OR REPLACE FUNCTION generate_meaningful_words()
RETURNS void AS $$
DECLARE
  word_list text[] := ARRAY[
    'ability', 'absence', 'academy', 'account', 'achieve', 'acquire', 'address', 'advance', 'adventure', 'advice',
    'balance', 'barrier', 'battery', 'benefit', 'bicycle', 'biology', 'brother', 'budget', 'building', 'business',
    'cabinet', 'camera', 'campus', 'cancer', 'capital', 'captain', 'career', 'carpet', 'castle', 'catalog',
    'danger', 'debate', 'decade', 'decide', 'defeat', 'defend', 'degree', 'deliver', 'demand', 'depend',
    'economy', 'educate', 'element', 'emotion', 'emperor', 'employee', 'energy', 'engine', 'enhance', 'enjoy',
    'fabric', 'factor', 'failure', 'family', 'famous', 'fantasy', 'farmer', 'fashion', 'father', 'feature',
    'galaxy', 'garage', 'garden', 'gather', 'gender', 'genius', 'gentle', 'gesture', 'global', 'golden',
    'habitat', 'handle', 'happen', 'harbor', 'hardly', 'header', 'health', 'heaven', 'height', 'helmet',
    'impact', 'import', 'income', 'indeed', 'indoor', 'infant', 'inform', 'injury', 'insect', 'inside',
    'jacket', 'jungle', 'junior', 'justice', 'kidney', 'kitchen', 'ladder', 'laptop', 'launch', 'lawyer',
    'machine', 'magazine', 'manager', 'manner', 'marble', 'market', 'master', 'matter', 'meadow', 'member',
    'nation', 'nature', 'nearby', 'needle', 'nephew', 'network', 'neural', 'normal', 'notice', 'number',
    'object', 'obtain', 'occupy', 'office', 'online', 'option', 'orange', 'origin', 'output', 'oxygen',
    'palace', 'parent', 'partly', 'patent', 'patrol', 'pattern', 'people', 'period', 'permit', 'person',
    'quality', 'quarter', 'question', 'rabbit', 'racing', 'random', 'rarely', 'rather', 'reason', 'recent',
    'safety', 'salary', 'sample', 'saving', 'school', 'screen', 'search', 'season', 'second', 'secret',
    'tablet', 'tackle', 'talent', 'target', 'temple', 'tennis', 'theory', 'thirty', 'thread', 'ticket',
    'unable', 'unique', 'update', 'upload', 'urgent', 'useful', 'valley', 'vendor', 'victim', 'vision',
    'wallet', 'wealth', 'weapon', 'weight', 'window', 'winter', 'wisdom', 'wonder', 'worker', 'yellow'
  ];
  korean_translations text[] := ARRAY[
    '능력', '부재', '학원', '계정', '달성하다', '획득하다', '주소', '발전', '모험', '조언',
    '균형', '장벽', '배터리', '혜택', '자전거', '생물학', '형제', '예산', '건물', '사업',
    '캐비닛', '카메라', '캠퍼스', '암', '자본', '선장', '경력', '카펫', '성', '카탈로그',
    '위험', '토론', '십년', '결정하다', '패배', '방어하다', '학위', '배달하다', '요구', '의존하다',
    '경제', '교육하다', '요소', '감정', '황제', '직원', '에너지', '엔진', '향상시키다', '즐기다',
    '직물', '요인', '실패', '가족', '유명한', '환상', '농부', '패션', '아버지', '특징',
    '은하', '차고', '정원', '모으다', '성별', '천재', '부드러운', '몸짓', '전세계의', '황금의',
    '서식지', '다루다', '일어나다', '항구', '거의 안', '헤더', '건강', '천국', '높이', '헬멧',
    '영향', '수입', '소득', '정말로', '실내의', '유아', '알리다', '부상', '곤충', '내부',
    '재킷', '정글', '후배', '정의', '신장', '부엌', '사다리', '노트북', '출시', '변호사',
    '기계', '잡지', '관리자', '방식', '대리석', '시장', '주인', '문제', '초원', '회원',
    '국가', '자연', '근처의', '바늘', '조카', '네트워크', '신경의', '정상적인', '알아차리다', '숫자',
    '물체', '얻다', '차지하다', '사무실', '온라인', '선택', '오렌지', '기원', '출력', '산소',
    '궁전', '부모', '부분적으로', '특허', '순찰', '패턴', '사람들', '기간', '허가', '사람',
    '품질', '분기', '질문', '토끼', '경주', '무작위', '드물게', '오히려', '이유', '최근의',
    '안전', '급여', '샘플', '저축', '학교', '화면', '검색', '계절', '두번째', '비밀',
    '태블릿', '다루다', '재능', '목표', '사원', '테니스', '이론', '서른', '실', '티켓',
    '할 수 없는', '독특한', '업데이트', '업로드', '긴급한', '유용한', '계곡', '공급업체', '피해자', '시야',
    '지갑', '부', '무기', '무게', '창문', '겨울', '지혜', '궁금하다', '노동자', '노란색'
  ];
  japanese_translations text[] := ARRAY[
    '能力 (のうりょく)', '不在 (ふざい)', '学院 (がくいん)', 'アカウント', '達成する (たっせいする)', '取得する (しゅとくする)', '住所 (じゅうしょ)', '進歩 (しんぽ)', '冒険 (ぼうけん)', '助言 (じょげん)',
    'バランス', '障壁 (しょうへき)', 'バッテリー', '利益 (りえき)', '自転車 (じてんしゃ)', '生物学 (せいぶつがく)', '兄弟 (きょうだい)', '予算 (よさん)', '建物 (たてもの)', 'ビジネス',
    'キャビネット', 'カメラ', 'キャンパス', 'がん', '資本 (しほん)', '船長 (せんちょう)', 'キャリア', 'カーペット', '城 (しろ)', 'カタログ',
    '危険 (きけん)', '討論 (とうろん)', '十年 (じゅうねん)', '決定する (けっていする)', '敗北 (はいぼく)', '守る (まもる)', '学位 (がくい)', '配達する (はいたつする)', '要求 (ようきゅう)', '依存する (いぞんする)',
    '経済 (けいざい)', '教育する (きょういくする)', '要素 (ようそ)', '感情 (かんじょう)', '皇帝 (こうてい)', '従業員 (じゅうぎょういん)', 'エネルギー', 'エンジン', '向上させる (こうじょうさせる)', '楽しむ (たのしむ)',
    '布 (ぬの)', '要因 (よういん)', '失敗 (しっぱい)', '家族 (かぞく)', '有名な (ゆうめいな)', 'ファンタジー', '農夫 (のうふ)', 'ファッション', '父 (ちち)', '特徴 (とくちょう)',
    '銀河 (ぎんが)', 'ガレージ', '庭 (にわ)', '集める (あつめる)', '性別 (せいべつ)', '天才 (てんさい)', '優しい (やさしい)', 'ジェスチャー', 'グローバル', '金の (きんの)',
    '生息地 (せいそくち)', '扱う (あつかう)', '起こる (おこる)', '港 (みなと)', 'ほとんど〜ない', 'ヘッダー', '健康 (けんこう)', '天国 (てんごく)', '高さ (たかさ)', 'ヘルメット',
    '影響 (えいきょう)', '輸入 (ゆにゅう)', '収入 (しゅうにゅう)', '確かに (たしかに)', '屋内の (おくないの)', '幼児 (ようじ)', '知らせる (しらせる)', '怪我 (けが)', '昆虫 (こんちゅう)', '内部 (ないぶ)',
    'ジャケット', 'ジャングル', '後輩 (こうはい)', '正義 (せいぎ)', '腎臓 (じんぞう)', '台所 (だいどころ)', 'はしご', 'ラップトップ', '発売 (はつばい)', '弁護士 (べんごし)',
    '機械 (きかい)', '雑誌 (ざっし)', 'マネージャー', '方法 (ほうほう)', '大理石 (だいりせき)', '市場 (しじょう)', 'マスター', '問題 (もんだい)', '草原 (そうげん)', 'メンバー',
    '国家 (こっか)', '自然 (しぜん)', '近くの (ちかくの)', '針 (はり)', '甥 (おい)', 'ネットワーク', '神経の (しんけいの)', '正常な (せいじょうな)', '気づく (きづく)', '数 (かず)',
    '物体 (ぶったい)', '得る (える)', '占める (しめる)', 'オフィス', 'オンライン', 'オプション', 'オレンジ', '起源 (きげん)', '出力 (しゅつりょく)', '酸素 (さんそ)',
    '宮殿 (きゅうでん)', '親 (おや)', '部分的に (ぶぶんてきに)', '特許 (とっきょ)', 'パトロール', 'パターン', '人々 (ひとびと)', '期間 (きかん)', '許可 (きょか)', '人 (ひと)',
    '品質 (ひんしつ)', '四半期 (しはんき)', '質問 (しつもん)', 'うさぎ', 'レース', 'ランダム', 'めったに〜ない', 'むしろ', '理由 (りゆう)', '最近の (さいきんの)',
    '安全 (あんぜん)', '給料 (きゅうりょう)', 'サンプル', '貯蓄 (ちょちく)', '学校 (がっこう)', 'スクリーン', '検索 (けんさく)', '季節 (きせつ)', '二番目 (にばんめ)', '秘密 (ひみつ)',
    'タブレット', '取り組む (とりくむ)', '才能 (さいのう)', '目標 (もくひょう)', '寺院 (じいん)', 'テニス', '理論 (りろん)', '三十 (さんじゅう)', '糸 (いと)', 'チケット',
    'できない', 'ユニーク', 'アップデート', 'アップロード', '緊急の (きんきゅうの)', '有用な (ゆうような)', '谷 (たに)', 'ベンダー', '被害者 (ひがいしゃ)', '視野 (しや)',
    '財布 (さいふ)', '富 (とみ)', '武器 (ぶき)', '重さ (おもさ)', '窓 (まど)', '冬 (ふゆ)', '知恵 (ちえ)', '不思議に思う (ふしぎにおもう)', '労働者 (ろうどうしゃ)', '黄色 (きいろ)'
  ];
  categories text[] := ARRAY[
    'General', 'General', 'Education', 'Technology', 'Action', 'Action', 'General', 'Abstract', 'Abstract', 'Abstract',
    'Abstract', 'General', 'Technology', 'Abstract', 'Transportation', 'Science', 'Family', 'Finance', 'Architecture', 'Business',
    'Furniture', 'Technology', 'Education', 'Health', 'Finance', 'Occupation', 'Work', 'Furniture', 'Architecture', 'General',
    'Abstract', 'Communication', 'Time', 'Action', 'Action', 'Action', 'Education', 'Action', 'Abstract', 'Action',
    'Finance', 'Education', 'Science', 'Abstract', 'Occupation', 'Occupation', 'Science', 'Technology', 'Action', 'Action',
    'Material', 'Abstract', 'Abstract', 'Family', 'Abstract', 'Abstract', 'Occupation', 'Abstract', 'Family', 'Abstract',
    'Science', 'Architecture', 'Nature', 'Action', 'Abstract', 'Abstract', 'Abstract', 'Action', 'Abstract', 'Abstract',
    'Nature', 'Action', 'Action', 'Transportation', 'Abstract', 'Technology', 'Health', 'Abstract', 'Abstract', 'Safety',
    'Abstract', 'Business', 'Finance', 'Abstract', 'Abstract', 'Family', 'Action', 'Health', 'Nature', 'Abstract',
    'Clothing', 'Nature', 'Education', 'Abstract', 'Health', 'Architecture', 'General', 'Technology', 'Business', 'Occupation',
    'Technology', 'Communication', 'Occupation', 'Abstract', 'Material', 'Business', 'Abstract', 'Abstract', 'Nature', 'Abstract',
    'Politics', 'Nature', 'Abstract', 'General', 'Family', 'Technology', 'Science', 'Abstract', 'Action', 'Abstract',
    'General', 'Action', 'Action', 'Architecture', 'Technology', 'Abstract', 'Food', 'Abstract', 'Technology', 'Science',
    'Architecture', 'Family', 'Abstract', 'Business', 'Action', 'Abstract', 'General', 'Time', 'Action', 'General',
    'Abstract', 'Time', 'Communication', 'Animal', 'Sports', 'Abstract', 'Abstract', 'Abstract', 'Abstract', 'Time',
    'Abstract', 'Finance', 'General', 'Finance', 'Education', 'Technology', 'Action', 'Time', 'Abstract', 'Abstract',
    'Technology', 'Action', 'Abstract', 'Abstract', 'Architecture', 'Sports', 'Abstract', 'Abstract', 'Material', 'General',
    'Abstract', 'Abstract', 'Action', 'Action', 'Abstract', 'Abstract', 'Nature', 'Business', 'General', 'Abstract',
    'General', 'Abstract', 'General', 'Abstract', 'Architecture', 'Time', 'Abstract', 'Action', 'Occupation', 'Color'
  ];
  i integer;
  v_word_id uuid; -- Renamed variable to avoid ambiguity with column name
BEGIN
  -- Insert meaningful English words with proper translations
  FOR i IN 1..array_length(word_list, 1) LOOP
    INSERT INTO words (word, category, definition, bookmarks)
    VALUES (
      word_list[i],
      categories[i],
      'Definition for ' || word_list[i],
      floor(random() * 100) + 1
    )
    ON CONFLICT (word) DO UPDATE SET
      category = EXCLUDED.category,
      definition = EXCLUDED.definition;
    
    -- Get the word ID
    SELECT id INTO v_word_id FROM words WHERE word = word_list[i];
    
    -- Insert Korean translation
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (v_word_id, 'ko', korean_translations[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    -- Insert Japanese translation
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (v_word_id, 'ja', japanese_translations[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    -- Insert trending data
    INSERT INTO word_trends (word_id, views, last_viewed)
    VALUES (
      v_word_id,
      floor(random() * 200) + 50,
      now() - (random() * interval '30 days')
    )
    ON CONFLICT (word_id) DO UPDATE SET
      views = EXCLUDED.views,
      last_viewed = EXCLUDED.last_viewed;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Execute the function to generate meaningful words
SELECT generate_meaningful_words();

-- Drop the function after use
DROP FUNCTION generate_meaningful_words();

-- Create some relationships between the new words
INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
SELECT 
  w1.id, w2.id, 'related', 'Related concepts'
FROM words w1, words w2
WHERE (w1.word = 'ability' AND w2.word = 'talent')
   OR (w1.word = 'academy' AND w2.word = 'school')
   OR (w1.word = 'business' AND w2.word = 'economy')
   OR (w1.word = 'camera' AND w2.word = 'technology')
   OR (w1.word = 'family' AND w2.word = 'parent')
   OR (w1.word = 'health' AND w2.word = 'medicine')
   OR (w1.word = 'nature' AND w2.word = 'environment')
   OR (w1.word = 'school' AND w2.word = 'education')
   OR (w1.word = 'technology' AND w2.word = 'computer')
   OR (w1.word = 'wisdom' AND w2.word = 'knowledge')
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
SELECT 
  w1.id, w2.id, 'synonym', 'Similar meaning'
FROM words w1, words w2
WHERE (w1.word = 'ability' AND w2.word = 'talent')
   OR (w1.word = 'obtain' AND w2.word = 'acquire')
   OR (w1.word = 'enhance' AND w2.word = 'improve')
   OR (w1.word = 'wealth' AND w2.word = 'money')
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;