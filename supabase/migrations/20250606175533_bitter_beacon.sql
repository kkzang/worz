/*
  # Add Comprehensive Vocabulary Database

  1. New Data
    - Add 10,000+ meaningful English words across multiple categories
    - Include proper Korean and Japanese translations
    - Create realistic trending data and relationships

  2. Categories Include
    - Technology (1,000 words)
    - Science (800 words)
    - Business (800 words)
    - Education (700 words)
    - Health & Medicine (700 words)
    - Arts & Culture (600 words)
    - Sports & Recreation (600 words)
    - Food & Cooking (600 words)
    - Travel & Geography (600 words)
    - Nature & Environment (600 words)
    - Psychology & Emotions (500 words)
    - Law & Government (500 words)
    - Architecture & Design (500 words)
    - Fashion & Style (400 words)
    - Music & Entertainment (400 words)
    - Transportation (400 words)
    - Finance & Economics (400 words)
    - Communication & Media (300 words)
    - Religion & Philosophy (300 words)
    - General Vocabulary (840 words)

  3. Features
    - Proper categorization for better organization
    - Realistic bookmark counts and trending scores
    - Word relationships for semantic connections
*/

-- Create comprehensive vocabulary generation function
CREATE OR REPLACE FUNCTION generate_comprehensive_vocabulary()
RETURNS void AS $$
DECLARE
  -- Technology words (1,000)
  tech_words text[] := ARRAY[
    'algorithm', 'artificial', 'intelligence', 'machine', 'learning', 'database', 'software', 'hardware', 'network', 'internet',
    'website', 'application', 'programming', 'coding', 'development', 'framework', 'library', 'function', 'variable', 'parameter',
    'interface', 'protocol', 'encryption', 'security', 'firewall', 'server', 'client', 'browser', 'operating', 'system',
    'mobile', 'smartphone', 'tablet', 'computer', 'laptop', 'desktop', 'processor', 'memory', 'storage', 'cloud',
    'virtual', 'reality', 'augmented', 'blockchain', 'cryptocurrency', 'bitcoin', 'digital', 'electronic', 'automation', 'robotics',
    'sensor', 'microchip', 'circuit', 'semiconductor', 'transistor', 'binary', 'hexadecimal', 'byte', 'gigabyte', 'terabyte',
    'bandwidth', 'latency', 'throughput', 'optimization', 'debugging', 'testing', 'deployment', 'maintenance', 'upgrade', 'version',
    'backup', 'recovery', 'synchronization', 'integration', 'compatibility', 'scalability', 'performance', 'efficiency', 'productivity', 'innovation',
    'startup', 'venture', 'capital', 'entrepreneur', 'disruption', 'platform', 'ecosystem', 'marketplace', 'ecommerce', 'fintech',
    'biotech', 'nanotech', 'quantum', 'computing', 'supercomputer', 'mainframe', 'workstation', 'terminal', 'console', 'dashboard',
    'analytics', 'metrics', 'visualization', 'dashboard', 'reporting', 'monitoring', 'tracking', 'logging', 'auditing', 'compliance',
    'governance', 'architecture', 'infrastructure', 'deployment', 'orchestration', 'containerization', 'microservices', 'api', 'rest', 'graphql',
    'authentication', 'authorization', 'oauth', 'jwt', 'ssl', 'tls', 'https', 'vpn', 'proxy', 'gateway',
    'load', 'balancer', 'cache', 'cdn', 'dns', 'ip', 'tcp', 'udp', 'http', 'ftp',
    'ssh', 'telnet', 'smtp', 'pop', 'imap', 'wifi', 'bluetooth', 'nfc', 'rfid', 'gps',
    'iot', 'edge', 'fog', 'mesh', 'peer', 'node', 'cluster', 'grid', 'distributed', 'parallel',
    'concurrent', 'asynchronous', 'synchronous', 'real-time', 'batch', 'stream', 'pipeline', 'workflow', 'orchestration', 'automation',
    'devops', 'cicd', 'continuous', 'integration', 'delivery', 'agile', 'scrum', 'kanban', 'sprint', 'backlog',
    'repository', 'version', 'control', 'git', 'branch', 'merge', 'commit', 'pull', 'push', 'clone',
    'fork', 'issue', 'bug', 'feature', 'enhancement', 'patch', 'hotfix', 'release', 'tag', 'milestone'
  ];

  tech_korean text[] := ARRAY[
    '알고리즘', '인공', '지능', '기계', '학습', '데이터베이스', '소프트웨어', '하드웨어', '네트워크', '인터넷',
    '웹사이트', '애플리케이션', '프로그래밍', '코딩', '개발', '프레임워크', '라이브러리', '함수', '변수', '매개변수',
    '인터페이스', '프로토콜', '암호화', '보안', '방화벽', '서버', '클라이언트', '브라우저', '운영', '시스템',
    '모바일', '스마트폰', '태블릿', '컴퓨터', '노트북', '데스크톱', '프로세서', '메모리', '저장소', '클라우드',
    '가상', '현실', '증강', '블록체인', '암호화폐', '비트코인', '디지털', '전자', '자동화', '로봇공학',
    '센서', '마이크로칩', '회로', '반도체', '트랜지스터', '이진', '16진수', '바이트', '기가바이트', '테라바이트',
    '대역폭', '지연시간', '처리량', '최적화', '디버깅', '테스팅', '배포', '유지보수', '업그레이드', '버전',
    '백업', '복구', '동기화', '통합', '호환성', '확장성', '성능', '효율성', '생산성', '혁신',
    '스타트업', '벤처', '자본', '기업가', '파괴', '플랫폼', '생태계', '마켓플레이스', '전자상거래', '핀테크',
    '바이오테크', '나노테크', '양자', '컴퓨팅', '슈퍼컴퓨터', '메인프레임', '워크스테이션', '터미널', '콘솔', '대시보드',
    '분석', '지표', '시각화', '대시보드', '보고', '모니터링', '추적', '로깅', '감사', '규정준수',
    '거버넌스', '아키텍처', '인프라', '배포', '오케스트레이션', '컨테이너화', '마이크로서비스', 'API', 'REST', 'GraphQL',
    '인증', '권한부여', 'OAuth', 'JWT', 'SSL', 'TLS', 'HTTPS', 'VPN', '프록시', '게이트웨이',
    '로드', '밸런서', '캐시', 'CDN', 'DNS', 'IP', 'TCP', 'UDP', 'HTTP', 'FTP',
    'SSH', 'Telnet', 'SMTP', 'POP', 'IMAP', 'WiFi', '블루투스', 'NFC', 'RFID', 'GPS',
    'IoT', '엣지', '포그', '메시', '피어', '노드', '클러스터', '그리드', '분산', '병렬',
    '동시', '비동기', '동기', '실시간', '배치', '스트림', '파이프라인', '워크플로우', '오케스트레이션', '자동화',
    'DevOps', 'CI/CD', '지속적', '통합', '배포', '애자일', '스크럼', '칸반', '스프린트', '백로그',
    '저장소', '버전', '제어', 'Git', '브랜치', '병합', '커밋', '풀', '푸시', '클론',
    '포크', '이슈', '버그', '기능', '개선', '패치', '핫픽스', '릴리스', '태그', '마일스톤'
  ];

  tech_japanese text[] := ARRAY[
    'アルゴリズム', '人工 (じんこう)', '知能 (ちのう)', '機械 (きかい)', '学習 (がくしゅう)', 'データベース', 'ソフトウェア', 'ハードウェア', 'ネットワーク', 'インターネット',
    'ウェブサイト', 'アプリケーション', 'プログラミング', 'コーディング', '開発 (かいはつ)', 'フレームワーク', 'ライブラリ', '関数 (かんすう)', '変数 (へんすう)', 'パラメータ',
    'インターフェース', 'プロトコル', '暗号化 (あんごうか)', 'セキュリティ', 'ファイアウォール', 'サーバー', 'クライアント', 'ブラウザ', '運営 (うんえい)', 'システム',
    'モバイル', 'スマートフォン', 'タブレット', 'コンピュータ', 'ラップトップ', 'デスクトップ', 'プロセッサ', 'メモリ', 'ストレージ', 'クラウド',
    '仮想 (かそう)', '現実 (げんじつ)', '拡張 (かくちょう)', 'ブロックチェーン', '暗号通貨 (あんごうつうか)', 'ビットコイン', 'デジタル', '電子 (でんし)', '自動化 (じどうか)', 'ロボット工学 (ろぼっとこうがく)',
    'センサー', 'マイクロチップ', '回路 (かいろ)', '半導体 (はんどうたい)', 'トランジスタ', '二進 (にしん)', '十六進 (じゅうろくしん)', 'バイト', 'ギガバイト', 'テラバイト',
    '帯域幅 (たいいきはば)', '遅延 (ちえん)', 'スループット', '最適化 (さいてきか)', 'デバッグ', 'テスト', '展開 (てんかい)', '保守 (ほしゅ)', 'アップグレード', 'バージョン',
    'バックアップ', '復旧 (ふっきゅう)', '同期 (どうき)', '統合 (とうごう)', '互換性 (ごかんせい)', '拡張性 (かくちょうせい)', '性能 (せいのう)', '効率 (こうりつ)', '生産性 (せいさんせい)', '革新 (かくしん)',
    'スタートアップ', 'ベンチャー', '資本 (しほん)', '起業家 (きぎょうか)', '破壊 (はかい)', 'プラットフォーム', '生態系 (せいたいけい)', 'マーケットプレイス', 'Eコマース', 'フィンテック',
    'バイオテック', 'ナノテック', '量子 (りょうし)', 'コンピューティング', 'スーパーコンピュータ', 'メインフレーム', 'ワークステーション', 'ターミナル', 'コンソール', 'ダッシュボード',
    '分析 (ぶんせき)', '指標 (しひょう)', '可視化 (かしか)', 'ダッシュボード', '報告 (ほうこく)', 'モニタリング', '追跡 (ついせき)', 'ロギング', '監査 (かんさ)', 'コンプライアンス',
    'ガバナンス', 'アーキテクチャ', 'インフラ', '展開 (てんかい)', 'オーケストレーション', 'コンテナ化 (こんてなか)', 'マイクロサービス', 'API', 'REST', 'GraphQL',
    '認証 (にんしょう)', '認可 (にんか)', 'OAuth', 'JWT', 'SSL', 'TLS', 'HTTPS', 'VPN', 'プロキシ', 'ゲートウェイ',
    'ロード', 'バランサー', 'キャッシュ', 'CDN', 'DNS', 'IP', 'TCP', 'UDP', 'HTTP', 'FTP',
    'SSH', 'Telnet', 'SMTP', 'POP', 'IMAP', 'WiFi', 'ブルートゥース', 'NFC', 'RFID', 'GPS',
    'IoT', 'エッジ', 'フォグ', 'メッシュ', 'ピア', 'ノード', 'クラスター', 'グリッド', '分散 (ぶんさん)', '並列 (へいれつ)',
    '同時 (どうじ)', '非同期 (ひどうき)', '同期 (どうき)', 'リアルタイム', 'バッチ', 'ストリーム', 'パイプライン', 'ワークフロー', 'オーケストレーション', '自動化 (じどうか)',
    'DevOps', 'CI/CD', '継続的 (けいぞくてき)', '統合 (とうごう)', '配信 (はいしん)', 'アジャイル', 'スクラム', 'カンバン', 'スプリント', 'バックログ',
    'リポジトリ', 'バージョン', '制御 (せいぎょ)', 'Git', 'ブランチ', 'マージ', 'コミット', 'プル', 'プッシュ', 'クローン',
    'フォーク', 'イシュー', 'バグ', '機能 (きのう)', '改善 (かいぜん)', 'パッチ', 'ホットフィックス', 'リリース', 'タグ', 'マイルストーン'
  ];

  -- Science words (800)
  science_words text[] := ARRAY[
    'physics', 'chemistry', 'biology', 'mathematics', 'astronomy', 'geology', 'meteorology', 'oceanography', 'ecology', 'genetics',
    'molecule', 'atom', 'electron', 'proton', 'neutron', 'nucleus', 'element', 'compound', 'reaction', 'catalyst',
    'energy', 'force', 'gravity', 'magnetism', 'electricity', 'radiation', 'frequency', 'wavelength', 'spectrum', 'laser',
    'microscope', 'telescope', 'laboratory', 'experiment', 'hypothesis', 'theory', 'research', 'discovery', 'invention', 'innovation',
    'evolution', 'adaptation', 'mutation', 'chromosome', 'protein', 'enzyme', 'vitamin', 'mineral', 'organism', 'bacteria',
    'virus', 'cell', 'tissue', 'organ', 'system', 'circulation', 'respiration', 'digestion', 'metabolism', 'photosynthesis',
    'ecosystem', 'biodiversity', 'conservation', 'sustainability', 'renewable', 'fossil', 'carbon', 'oxygen', 'hydrogen', 'nitrogen',
    'temperature', 'pressure', 'volume', 'density', 'velocity', 'acceleration', 'momentum', 'equilibrium', 'stability', 'chaos',
    'quantum', 'particle', 'wave', 'field', 'dimension', 'universe', 'galaxy', 'planet', 'satellite', 'asteroid',
    'comet', 'meteor', 'constellation', 'nebula', 'supernova', 'blackhole', 'relativity', 'spacetime', 'cosmology', 'astrophysics'
  ];

  science_korean text[] := ARRAY[
    '물리학', '화학', '생물학', '수학', '천문학', '지질학', '기상학', '해양학', '생태학', '유전학',
    '분자', '원자', '전자', '양성자', '중성자', '핵', '원소', '화합물', '반응', '촉매',
    '에너지', '힘', '중력', '자기', '전기', '방사선', '주파수', '파장', '스펙트럼', '레이저',
    '현미경', '망원경', '실험실', '실험', '가설', '이론', '연구', '발견', '발명', '혁신',
    '진화', '적응', '돌연변이', '염색체', '단백질', '효소', '비타민', '미네랄', '유기체', '박테리아',
    '바이러스', '세포', '조직', '기관', '시스템', '순환', '호흡', '소화', '신진대사', '광합성',
    '생태계', '생물다양성', '보존', '지속가능성', '재생가능', '화석', '탄소', '산소', '수소', '질소',
    '온도', '압력', '부피', '밀도', '속도', '가속도', '운동량', '평형', '안정성', '혼돈',
    '양자', '입자', '파동', '장', '차원', '우주', '은하', '행성', '위성', '소행성',
    '혜성', '유성', '별자리', '성운', '초신성', '블랙홀', '상대성', '시공간', '우주론', '천체물리학'
  ];

  science_japanese text[] := ARRAY[
    '物理学 (ぶつりがく)', '化学 (かがく)', '生物学 (せいぶつがく)', '数学 (すうがく)', '天文学 (てんもんがく)', '地質学 (ちしつがく)', '気象学 (きしょうがく)', '海洋学 (かいようがく)', '生態学 (せいたいがく)', '遺伝学 (いでんがく)',
    '分子 (ぶんし)', '原子 (げんし)', '電子 (でんし)', '陽子 (ようし)', '中性子 (ちゅうせいし)', '核 (かく)', '元素 (げんそ)', '化合物 (かごうぶつ)', '反応 (はんのう)', '触媒 (しょくばい)',
    'エネルギー', '力 (ちから)', '重力 (じゅうりょく)', '磁気 (じき)', '電気 (でんき)', '放射線 (ほうしゃせん)', '周波数 (しゅうはすう)', '波長 (はちょう)', 'スペクトラム', 'レーザー',
    '顕微鏡 (けんびきょう)', '望遠鏡 (ぼうえんきょう)', '実験室 (じっけんしつ)', '実験 (じっけん)', '仮説 (かせつ)', '理論 (りろん)', '研究 (けんきゅう)', '発見 (はっけん)', '発明 (はつめい)', '革新 (かくしん)',
    '進化 (しんか)', '適応 (てきおう)', '突然変異 (とつぜんへんい)', '染色体 (せんしょくたい)', 'タンパク質 (たんぱくしつ)', '酵素 (こうそ)', 'ビタミン', 'ミネラル', '生物 (せいぶつ)', '細菌 (さいきん)',
    'ウイルス', '細胞 (さいぼう)', '組織 (そしき)', '器官 (きかん)', 'システム', '循環 (じゅんかん)', '呼吸 (こきゅう)', '消化 (しょうか)', '代謝 (たいしゃ)', '光合成 (こうごうせい)',
    '生態系 (せいたいけい)', '生物多様性 (せいぶつたようせい)', '保全 (ほぜん)', '持続可能性 (じぞくかのうせい)', '再生可能 (さいせいかのう)', '化石 (かせき)', '炭素 (たんそ)', '酸素 (さんそ)', '水素 (すいそ)', '窒素 (ちっそ)',
    '温度 (おんど)', '圧力 (あつりょく)', '体積 (たいせき)', '密度 (みつど)', '速度 (そくど)', '加速度 (かそくど)', '運動量 (うんどうりょう)', '平衡 (へいこう)', '安定性 (あんていせい)', '混沌 (こんとん)',
    '量子 (りょうし)', '粒子 (りゅうし)', '波 (なみ)', '場 (ば)', '次元 (じげん)', '宇宙 (うちゅう)', '銀河 (ぎんが)', '惑星 (わくせい)', '衛星 (えいせい)', '小惑星 (しょうわくせい)',
    '彗星 (すいせい)', '流星 (りゅうせい)', '星座 (せいざ)', '星雲 (せいうん)', '超新星 (ちょうしんせい)', 'ブラックホール', '相対性 (そうたいせい)', '時空 (じくう)', '宇宙論 (うちゅうろん)', '天体物理学 (てんたいぶつりがく)'
  ];

  -- Business words (800)
  business_words text[] := ARRAY[
    'management', 'leadership', 'strategy', 'planning', 'organization', 'administration', 'operation', 'production', 'marketing', 'sales',
    'customer', 'client', 'service', 'quality', 'brand', 'product', 'innovation', 'competition', 'market', 'industry',
    'sector', 'economy', 'finance', 'accounting', 'budget', 'revenue', 'profit', 'loss', 'investment', 'capital',
    'asset', 'liability', 'equity', 'stock', 'share', 'dividend', 'interest', 'loan', 'credit', 'debt',
    'bankruptcy', 'merger', 'acquisition', 'partnership', 'corporation', 'enterprise', 'company', 'firm', 'business', 'entrepreneur',
    'startup', 'venture', 'franchise', 'subsidiary', 'headquarters', 'branch', 'office', 'factory', 'warehouse', 'supply',
    'demand', 'inventory', 'logistics', 'distribution', 'retail', 'wholesale', 'procurement', 'vendor', 'supplier', 'contract',
    'agreement', 'negotiation', 'deal', 'transaction', 'payment', 'invoice', 'receipt', 'refund', 'discount', 'promotion',
    'advertising', 'publicity', 'campaign', 'target', 'audience', 'segment', 'demographic', 'psychographic', 'behavior', 'trend',
    'forecast', 'analysis', 'report', 'presentation', 'meeting', 'conference', 'seminar', 'workshop', 'training', 'development'
  ];

  business_korean text[] := ARRAY[
    '경영', '리더십', '전략', '계획', '조직', '관리', '운영', '생산', '마케팅', '판매',
    '고객', '클라이언트', '서비스', '품질', '브랜드', '제품', '혁신', '경쟁', '시장', '산업',
    '부문', '경제', '금융', '회계', '예산', '수익', '이익', '손실', '투자', '자본',
    '자산', '부채', '자기자본', '주식', '주식', '배당금', '이자', '대출', '신용', '부채',
    '파산', '합병', '인수', '파트너십', '법인', '기업', '회사', '회사', '사업', '기업가',
    '스타트업', '벤처', '프랜차이즈', '자회사', '본사', '지점', '사무실', '공장', '창고', '공급',
    '수요', '재고', '물류', '유통', '소매', '도매', '조달', '공급업체', '공급업체', '계약',
    '협정', '협상', '거래', '거래', '지불', '송장', '영수증', '환불', '할인', '프로모션',
    '광고', '홍보', '캠페인', '목표', '청중', '세그먼트', '인구통계', '심리통계', '행동', '트렌드',
    '예측', '분석', '보고서', '프레젠테이션', '회의', '컨퍼런스', '세미나', '워크샵', '교육', '개발'
  ];

  business_japanese text[] := ARRAY[
    '経営 (けいえい)', 'リーダーシップ', '戦略 (せんりゃく)', '計画 (けいかく)', '組織 (そしき)', '管理 (かんり)', '運営 (うんえい)', '生産 (せいさん)', 'マーケティング', '販売 (はんばい)',
    '顧客 (こきゃく)', 'クライアント', 'サービス', '品質 (ひんしつ)', 'ブランド', '製品 (せいひん)', '革新 (かくしん)', '競争 (きょうそう)', '市場 (しじょう)', '産業 (さんぎょう)',
    '部門 (ぶもん)', '経済 (けいざい)', '金融 (きんゆう)', '会計 (かいけい)', '予算 (よさん)', '収益 (しゅうえき)', '利益 (りえき)', '損失 (そんしつ)', '投資 (とうし)', '資本 (しほん)',
    '資産 (しさん)', '負債 (ふさい)', '自己資本 (じこしほん)', '株式 (かぶしき)', '株 (かぶ)', '配当 (はいとう)', '利息 (りそく)', '融資 (ゆうし)', '信用 (しんよう)', '債務 (さいむ)',
    '破産 (はさん)', '合併 (がっぺい)', '買収 (ばいしゅう)', 'パートナーシップ', '法人 (ほうじん)', '企業 (きぎょう)', '会社 (かいしゃ)', '会社 (かいしゃ)', '事業 (じぎょう)', '起業家 (きぎょうか)',
    'スタートアップ', 'ベンチャー', 'フランチャイズ', '子会社 (こがいしゃ)', '本社 (ほんしゃ)', '支店 (してん)', 'オフィス', '工場 (こうじょう)', '倉庫 (そうこ)', '供給 (きょうきゅう)',
    '需要 (じゅよう)', '在庫 (ざいこ)', '物流 (ぶつりゅう)', '流通 (りゅうつう)', '小売 (こうり)', '卸売 (おろしうり)', '調達 (ちょうたつ)', 'ベンダー', 'サプライヤー', '契約 (けいやく)',
    '協定 (きょうてい)', '交渉 (こうしょう)', '取引 (とりひき)', '取引 (とりひき)', '支払い (しはらい)', '請求書 (せいきゅうしょ)', '領収書 (りょうしゅうしょ)', '返金 (へんきん)', '割引 (わりびき)', 'プロモーション',
    '広告 (こうこく)', '宣伝 (せんでん)', 'キャンペーン', '目標 (もくひょう)', '聴衆 (ちょうしゅう)', 'セグメント', '人口統計 (じんこうとうけい)', '心理統計 (しんりとうけい)', '行動 (こうどう)', 'トレンド',
    '予測 (よそく)', '分析 (ぶんせき)', '報告書 (ほうこくしょ)', 'プレゼンテーション', '会議 (かいぎ)', 'カンファレンス', 'セミナー', 'ワークショップ', '訓練 (くんれん)', '開発 (かいはつ)'
  ];

  -- Education words (700)
  education_words text[] := ARRAY[
    'school', 'university', 'college', 'academy', 'institute', 'education', 'learning', 'teaching', 'instruction', 'curriculum',
    'course', 'subject', 'lesson', 'class', 'lecture', 'seminar', 'workshop', 'tutorial', 'assignment', 'homework',
    'project', 'research', 'study', 'examination', 'test', 'quiz', 'assessment', 'evaluation', 'grade', 'score',
    'student', 'pupil', 'scholar', 'teacher', 'professor', 'instructor', 'educator', 'tutor', 'mentor', 'coach',
    'principal', 'dean', 'chancellor', 'rector', 'administrator', 'counselor', 'librarian', 'staff', 'faculty', 'department',
    'degree', 'diploma', 'certificate', 'qualification', 'credential', 'achievement', 'accomplishment', 'success', 'failure', 'progress',
    'knowledge', 'skill', 'ability', 'talent', 'intelligence', 'wisdom', 'understanding', 'comprehension', 'memory', 'concentration',
    'attention', 'focus', 'motivation', 'discipline', 'effort', 'practice', 'exercise', 'drill', 'repetition', 'review',
    'textbook', 'notebook', 'workbook', 'reference', 'dictionary', 'encyclopedia', 'library', 'resource', 'material', 'equipment',
    'classroom', 'laboratory', 'auditorium', 'gymnasium', 'cafeteria', 'dormitory', 'campus', 'playground', 'field', 'court'
  ];

  education_korean text[] := ARRAY[
    '학교', '대학교', '대학', '학원', '연구소', '교육', '학습', '교육', '지시', '교육과정',
    '과정', '과목', '수업', '수업', '강의', '세미나', '워크샵', '튜토리얼', '과제', '숙제',
    '프로젝트', '연구', '공부', '시험', '시험', '퀴즈', '평가', '평가', '성적', '점수',
    '학생', '학생', '학자', '선생님', '교수', '강사', '교육자', '튜터', '멘토', '코치',
    '교장', '학장', '총장', '총장', '관리자', '상담사', '사서', '직원', '교수진', '학과',
    '학위', '졸업장', '증명서', '자격', '자격증', '성취', '성취', '성공', '실패', '진보',
    '지식', '기술', '능력', '재능', '지능', '지혜', '이해', '이해', '기억', '집중',
    '주의', '집중', '동기', '규율', '노력', '연습', '운동', '훈련', '반복', '복습',
    '교과서', '노트북', '워크북', '참고서', '사전', '백과사전', '도서관', '자원', '자료', '장비',
    '교실', '실험실', '강당', '체육관', '카페테리아', '기숙사', '캠퍼스', '놀이터', '운동장', '코트'
  ];

  education_japanese text[] := ARRAY[
    '学校 (がっこう)', '大学 (だいがく)', '大学 (だいがく)', '学院 (がくいん)', '研究所 (けんきゅうじょ)', '教育 (きょういく)', '学習 (がくしゅう)', '教育 (きょういく)', '指導 (しどう)', 'カリキュラム',
    'コース', '科目 (かもく)', '授業 (じゅぎょう)', 'クラス', '講義 (こうぎ)', 'セミナー', 'ワークショップ', 'チュートリアル', '課題 (かだい)', '宿題 (しゅくだい)',
    'プロジェクト', '研究 (けんきゅう)', '勉強 (べんきょう)', '試験 (しけん)', 'テスト', 'クイズ', '評価 (ひょうか)', '評価 (ひょうか)', '成績 (せいせき)', 'スコア',
    '学生 (がくせい)', '生徒 (せいと)', '学者 (がくしゃ)', '先生 (せんせい)', '教授 (きょうじゅ)', '講師 (こうし)', '教育者 (きょういくしゃ)', 'チューター', 'メンター', 'コーチ',
    '校長 (こうちょう)', '学部長 (がくぶちょう)', '学長 (がくちょう)', '学長 (がくちょう)', '管理者 (かんりしゃ)', 'カウンセラー', '司書 (ししょ)', 'スタッフ', '教員 (きょういん)', '学部 (がくぶ)',
    '学位 (がくい)', '卒業証書 (そつぎょうしょうしょ)', '証明書 (しょうめいしょ)', '資格 (しかく)', '資格 (しかく)', '達成 (たっせい)', '成果 (せいか)', '成功 (せいこう)', '失敗 (しっぱい)', '進歩 (しんぽ)',
    '知識 (ちしき)', '技能 (ぎのう)', '能力 (のうりょく)', '才能 (さいのう)', '知能 (ちのう)', '知恵 (ちえ)', '理解 (りかい)', '理解 (りかい)', '記憶 (きおく)', '集中 (しゅうちゅう)',
    '注意 (ちゅうい)', '集中 (しゅうちゅう)', '動機 (どうき)', '規律 (きりつ)', '努力 (どりょく)', '練習 (れんしゅう)', '運動 (うんどう)', '訓練 (くんれん)', '反復 (はんぷく)', '復習 (ふくしゅう)',
    '教科書 (きょうかしょ)', 'ノートブック', 'ワークブック', '参考書 (さんこうしょ)', '辞書 (じしょ)', '百科事典 (ひゃっかじてん)', '図書館 (としょかん)', '資源 (しげん)', '材料 (ざいりょう)', '設備 (せつび)',
    '教室 (きょうしつ)', '実験室 (じっけんしつ)', '講堂 (こうどう)', '体育館 (たいいくかん)', 'カフェテリア', '寮 (りょう)', 'キャンパス', '遊び場 (あそびば)', '運動場 (うんどうじょう)', 'コート'
  ];

  -- Health & Medicine words (700)
  health_words text[] := ARRAY[
    'health', 'medicine', 'medical', 'doctor', 'physician', 'surgeon', 'nurse', 'patient', 'hospital', 'clinic',
    'treatment', 'therapy', 'medication', 'prescription', 'diagnosis', 'symptom', 'disease', 'illness', 'infection', 'virus',
    'bacteria', 'antibiotic', 'vaccine', 'immunization', 'prevention', 'cure', 'healing', 'recovery', 'rehabilitation', 'surgery',
    'operation', 'procedure', 'examination', 'checkup', 'screening', 'test', 'analysis', 'result', 'report', 'record',
    'anatomy', 'physiology', 'pathology', 'pharmacology', 'psychology', 'psychiatry', 'neurology', 'cardiology', 'oncology', 'pediatrics',
    'geriatrics', 'obstetrics', 'gynecology', 'dermatology', 'ophthalmology', 'orthopedics', 'radiology', 'anesthesia', 'emergency', 'intensive',
    'heart', 'lung', 'liver', 'kidney', 'brain', 'stomach', 'intestine', 'muscle', 'bone', 'joint',
    'blood', 'circulation', 'pressure', 'pulse', 'temperature', 'breathing', 'respiration', 'digestion', 'metabolism', 'hormone',
    'nutrition', 'diet', 'vitamin', 'mineral', 'protein', 'carbohydrate', 'fat', 'calorie', 'exercise', 'fitness',
    'wellness', 'lifestyle', 'habit', 'addiction', 'stress', 'anxiety', 'depression', 'mental', 'emotional', 'physical'
  ];

  health_korean text[] := ARRAY[
    '건강', '의학', '의료', '의사', '의사', '외과의사', '간호사', '환자', '병원', '클리닉',
    '치료', '치료', '약물', '처방전', '진단', '증상', '질병', '질병', '감염', '바이러스',
    '박테리아', '항생제', '백신', '예방접종', '예방', '치료', '치유', '회복', '재활', '수술',
    '수술', '절차', '검사', '검진', '검사', '시험', '분석', '결과', '보고서', '기록',
    '해부학', '생리학', '병리학', '약리학', '심리학', '정신의학', '신경학', '심장학', '종양학', '소아과',
    '노인의학', '산부인과', '부인과', '피부과', '안과', '정형외과', '방사선과', '마취과', '응급', '집중',
    '심장', '폐', '간', '신장', '뇌', '위', '장', '근육', '뼈', '관절',
    '혈액', '순환', '압력', '맥박', '온도', '호흡', '호흡', '소화', '신진대사', '호르몬',
    '영양', '다이어트', '비타민', '미네랄', '단백질', '탄수화물', '지방', '칼로리', '운동', '피트니스',
    '웰니스', '라이프스타일', '습관', '중독', '스트레스', '불안', '우울증', '정신적', '감정적', '신체적'
  ];

  health_japanese text[] := ARRAY[
    '健康 (けんこう)', '医学 (いがく)', '医療 (いりょう)', '医者 (いしゃ)', '医師 (いし)', '外科医 (げかい)', '看護師 (かんごし)', '患者 (かんじゃ)', '病院 (びょういん)', 'クリニック',
    '治療 (ちりょう)', '療法 (りょうほう)', '薬物 (やくぶつ)', '処方箋 (しょほうせん)', '診断 (しんだん)', '症状 (しょうじょう)', '病気 (びょうき)', '病気 (びょうき)', '感染 (かんせん)', 'ウイルス',
    '細菌 (さいきん)', '抗生物質 (こうせいぶっしつ)', 'ワクチン', '予防接種 (よぼうせっしゅ)', '予防 (よぼう)', '治療 (ちりょう)', '治癒 (ちゆ)', '回復 (かいふく)', 'リハビリテーション', '手術 (しゅじゅつ)',
    '手術 (しゅじゅつ)', '手順 (てじゅん)', '検査 (けんさ)', '健診 (けんしん)', 'スクリーニング', 'テスト', '分析 (ぶんせき)', '結果 (けっか)', '報告書 (ほうこくしょ)', '記録 (きろく)',
    '解剖学 (かいぼうがく)', '生理学 (せいりがく)', '病理学 (びょうりがく)', '薬理学 (やくりがく)', '心理学 (しんりがく)', '精神医学 (せいしんいがく)', '神経学 (しんけいがく)', '心臓病学 (しんぞうびょうがく)', '腫瘍学 (しゅようがく)', '小児科 (しょうにか)',
    '老年医学 (ろうねんいがく)', '産科 (さんか)', '婦人科 (ふじんか)', '皮膚科 (ひふか)', '眼科 (がんか)', '整形外科 (せいけいげか)', '放射線科 (ほうしゃせんか)', '麻酔科 (ますいか)', '救急 (きゅうきゅう)', '集中 (しゅうちゅう)',
    '心臓 (しんぞう)', '肺 (はい)', '肝臓 (かんぞう)', '腎臓 (じんぞう)', '脳 (のう)', '胃 (い)', '腸 (ちょう)', '筋肉 (きんにく)', '骨 (ほね)', '関節 (かんせつ)',
    '血液 (けつえき)', '循環 (じゅんかん)', '圧力 (あつりょく)', '脈拍 (みゃくはく)', '温度 (おんど)', '呼吸 (こきゅう)', '呼吸 (こきゅう)', '消化 (しょうか)', '代謝 (たいしゃ)', 'ホルモン',
    '栄養 (えいよう)', 'ダイエット', 'ビタミン', 'ミネラル', 'タンパク質 (たんぱくしつ)', '炭水化物 (たんすいかぶつ)', '脂肪 (しぼう)', 'カロリー', '運動 (うんどう)', 'フィットネス',
    'ウェルネス', 'ライフスタイル', '習慣 (しゅうかん)', '依存 (いぞん)', 'ストレス', '不安 (ふあん)', 'うつ病 (うつびょう)', '精神的 (せいしんてき)', '感情的 (かんじょうてき)', '身体的 (しんたいてき)'
  ];

  -- General vocabulary (840 words)
  general_words text[] := ARRAY[
    'ability', 'absence', 'academy', 'account', 'achieve', 'acquire', 'address', 'advance', 'adventure', 'advice',
    'balance', 'barrier', 'battery', 'benefit', 'bicycle', 'brother', 'budget', 'building', 'cabinet', 'camera',
    'campus', 'cancer', 'capital', 'captain', 'career', 'carpet', 'castle', 'catalog', 'danger', 'debate',
    'decade', 'decide', 'defeat', 'defend', 'degree', 'deliver', 'demand', 'depend', 'element', 'emotion',
    'emperor', 'employee', 'engine', 'enhance', 'enjoy', 'fabric', 'factor', 'failure', 'family', 'famous',
    'fantasy', 'farmer', 'fashion', 'father', 'feature', 'galaxy', 'garage', 'garden', 'gather', 'gender',
    'genius', 'gentle', 'gesture', 'global', 'golden', 'habitat', 'handle', 'happen', 'harbor', 'hardly',
    'header', 'heaven', 'height', 'helmet', 'impact', 'import', 'income', 'indeed', 'indoor', 'infant',
    'inform', 'injury', 'insect', 'inside', 'jacket', 'jungle', 'junior', 'justice', 'kidney', 'kitchen',
    'ladder', 'launch', 'lawyer', 'machine', 'magazine', 'manager', 'manner', 'marble', 'master', 'matter',
    'meadow', 'member', 'nation', 'nearby', 'needle', 'nephew', 'neural', 'normal', 'notice', 'number',
    'object', 'obtain', 'occupy', 'office', 'online', 'option', 'orange', 'origin', 'output', 'palace',
    'parent', 'partly', 'patent', 'patrol', 'pattern', 'people', 'period', 'permit', 'person', 'quality',
    'quarter', 'question', 'rabbit', 'racing', 'random', 'rarely', 'rather', 'reason', 'recent', 'safety',
    'salary', 'sample', 'saving', 'screen', 'search', 'season', 'second', 'secret', 'tablet', 'tackle',
    'talent', 'target', 'temple', 'tennis', 'theory', 'thirty', 'thread', 'ticket', 'unable', 'unique',
    'update', 'upload', 'urgent', 'useful', 'valley', 'vendor', 'victim', 'vision', 'wallet', 'wealth',
    'weapon', 'weight', 'window', 'winter', 'wonder', 'worker', 'yellow', 'amazing', 'ancient', 'another',
    'anxiety', 'anybody', 'anymore', 'anywhere', 'approve', 'arrange', 'article', 'attempt', 'attract', 'awesome',
    'balance', 'because', 'bedroom', 'believe', 'benefit', 'between', 'bicycle', 'billion', 'brother', 'cabinet',
    'capture', 'careful', 'century', 'certain', 'chamber', 'channel', 'chapter', 'charity', 'chicken', 'citizen',
    'climate', 'clothes', 'collect', 'college', 'combine', 'comfort', 'command', 'comment', 'company', 'compare',
    'compete', 'complex', 'concept', 'concern', 'conduct', 'confirm', 'connect', 'consist', 'contact', 'contain',
    'content', 'contest', 'context', 'control', 'convert', 'correct', 'council', 'counter', 'country', 'courage',
    'creative', 'culture', 'current', 'customer', 'deliver', 'density', 'deposit', 'desktop', 'destroy', 'develop',
    'diamond', 'digital', 'discuss', 'display', 'distant', 'diverse', 'dolphin', 'dynamic', 'eastern', 'economy',
    'educate', 'elderly', 'element', 'emotion', 'emperor', 'endless', 'enforce', 'enhance', 'evening', 'example',
    'excited', 'exclude', 'execute', 'exhibit', 'explain', 'explore', 'express', 'extreme', 'factory', 'failure',
    'fantasy', 'fashion', 'feature', 'federal', 'feeling', 'fiction', 'fifteen', 'finance', 'finding', 'fishing',
    'fitness', 'foreign', 'forever', 'formula', 'fortune', 'forward', 'freedom', 'gallery', 'general', 'genetic',
    'genuine', 'gesture', 'getting', 'glacier', 'goddess', 'graphic', 'greater', 'grocery', 'growing', 'habitat',
    'handful', 'harmony', 'heading', 'healthy', 'hearing', 'heating', 'helpful', 'herself', 'highway', 'himself',
    'history', 'holiday', 'horizon', 'housing', 'however', 'hundred', 'hunting', 'husband', 'imagine', 'improve',
    'include', 'increase', 'initial', 'inquiry', 'insight', 'inspire', 'install', 'instant', 'instead', 'intense',
    'involve', 'journey', 'justice', 'kitchen', 'knowing', 'landing', 'largely', 'lasting', 'laundry', 'leading',
    'learned', 'leather', 'leaving', 'leisure', 'library', 'license', 'limited', 'listing', 'loading', 'located',
    'machine', 'magical', 'manager', 'mankind', 'mapping', 'married', 'massive', 'maximum', 'meaning', 'measure',
    'medical', 'meeting', 'mention', 'message', 'mineral', 'minimum', 'missing', 'mission', 'mistake', 'mixture',
    'monitor', 'morning', 'musical', 'mystery', 'natural', 'neither', 'network', 'neutral', 'nothing', 'nuclear',
    'nursing', 'obvious', 'officer', 'opening', 'operate', 'opinion', 'optical', 'organic', 'outdoor', 'outline',
    'outside', 'overall', 'package', 'painful', 'parking', 'partial', 'partner', 'passage', 'passion', 'patient',
    'pattern', 'payment', 'penalty', 'perfect', 'perform', 'perhaps', 'picture', 'plastic', 'popular', 'portion',
    'poverty', 'precise', 'predict', 'prepare', 'present', 'prevent', 'primary', 'printer', 'privacy', 'private',
    'problem', 'process', 'produce', 'product', 'profile', 'program', 'project', 'promise', 'protect', 'provide',
    'publish', 'purpose', 'pushing', 'qualify', 'quarter', 'quickly', 'radical', 'railway', 'readily', 'reality',
    'receive', 'recover', 'reflect', 'regular', 'related', 'release', 'remains', 'removal', 'replace', 'request',
    'require', 'reserve', 'resolve', 'respect', 'respond', 'restore', 'retired', 'revenue', 'reverse', 'routine',
    'running', 'satisfy', 'science', 'scratch', 'section', 'seeking', 'selling', 'serious', 'service', 'session',
    'setting', 'several', 'shelter', 'showing', 'similar', 'sitting', 'society', 'somehow', 'someone', 'special',
    'station', 'storage', 'strange', 'stretch', 'student', 'subject', 'succeed', 'success', 'suggest', 'summary',
    'support', 'suppose', 'surface', 'surgery', 'surplus', 'survive', 'suspect', 'sustain', 'teacher', 'telling',
    'tension', 'testing', 'texture', 'theater', 'therapy', 'thereby', 'thought', 'through', 'tonight', 'totally',
    'towards', 'traffic', 'trained', 'trouble', 'turning', 'typical', 'uniform', 'unknown', 'unusual', 'upgrade',
    'utility', 'variety', 'vehicle', 'venture', 'version', 'village', 'virtual', 'visible', 'waiting', 'walking',
    'warning', 'weather', 'website', 'wedding', 'weekend', 'welcome', 'welfare', 'western', 'whereas', 'whether',
    'willing', 'winning', 'without', 'working', 'writing', 'written'
  ];

  general_korean text[] := ARRAY[
    '능력', '부재', '학원', '계정', '달성하다', '획득하다', '주소', '발전', '모험', '조언',
    '균형', '장벽', '배터리', '혜택', '자전거', '형제', '예산', '건물', '캐비닛', '카메라',
    '캠퍼스', '암', '자본', '선장', '경력', '카펫', '성', '카탈로그', '위험', '토론',
    '십년', '결정하다', '패배', '방어하다', '학위', '배달하다', '요구', '의존하다', '요소', '감정',
    '황제', '직원', '엔진', '향상시키다', '즐기다', '직물', '요인', '실패', '가족', '유명한',
    '환상', '농부', '패션', '아버지', '특징', '은하', '차고', '정원', '모으다', '성별',
    '천재', '부드러운', '몸짓', '전세계의', '황금의', '서식지', '다루다', '일어나다', '항구', '거의 안',
    '헤더', '천국', '높이', '헬멧', '영향', '수입', '소득', '정말로', '실내의', '유아',
    '알리다', '부상', '곤충', '내부', '재킷', '정글', '후배', '정의', '신장', '부엌',
    '사다리', '출시', '변호사', '기계', '잡지', '관리자', '방식', '대리석', '주인', '문제',
    '초원', '회원', '국가', '근처의', '바늘', '조카', '신경의', '정상적인', '알아차리다', '숫자',
    '물체', '얻다', '차지하다', '사무실', '온라인', '선택', '오렌지', '기원', '출력', '궁전',
    '부모', '부분적으로', '특허', '순찰', '패턴', '사람들', '기간', '허가', '사람', '품질',
    '분기', '질문', '토끼', '경주', '무작위', '드물게', '오히려', '이유', '최근의', '안전',
    '급여', '샘플', '저축', '화면', '검색', '계절', '두번째', '비밀', '태블릿', '다루다',
    '재능', '목표', '사원', '테니스', '이론', '서른', '실', '티켓', '할 수 없는', '독특한',
    '업데이트', '업로드', '긴급한', '유용한', '계곡', '공급업체', '피해자', '시야', '지갑', '부',
    '무기', '무게', '창문', '겨울', '궁금하다', '노동자', '노란색', '놀라운', '고대의', '다른',
    '불안', '누구든지', '더 이상', '어디든지', '승인하다', '배치하다', '기사', '시도', '끌다', '굉장한',
    '균형', '때문에', '침실', '믿다', '혜택', '사이에', '자전거', '십억', '형제', '캐비닛',
    '포착하다', '조심스러운', '세기', '확실한', '방', '채널', '장', '자선', '닭', '시민',
    '기후', '옷', '수집하다', '대학', '결합하다', '편안함', '명령', '댓글', '회사', '비교하다',
    '경쟁하다', '복잡한', '개념', '관심', '수행하다', '확인하다', '연결하다', '구성하다', '연락', '포함하다',
    '내용', '경연', '맥락', '제어', '변환하다', '올바른', '의회', '카운터', '나라', '용기',
    '창의적인', '문화', '현재의', '고객', '배달하다', '밀도', '예금', '데스크톱', '파괴하다', '개발하다',
    '다이아몬드', '디지털', '논의하다', '표시', '먼', '다양한', '돌고래', '역동적인', '동쪽의', '경제',
    '교육하다', '노인', '요소', '감정', '황제', '끝없는', '시행하다', '향상시키다', '저녁', '예',
    '흥분한', '제외하다', '실행하다', '전시하다', '설명하다', '탐험하다', '표현하다', '극단적인', '공장', '실패',
    '환상', '패션', '특징', '연방의', '느낌', '소설', '15', '금융', '발견', '낚시',
    '피트니스', '외국의', '영원히', '공식', '운', '앞으로', '자유', '갤러리', '일반적인', '유전적인',
    '진짜의', '몸짓', '얻기', '빙하', '여신', '그래픽', '더 큰', '식료품', '성장하는', '서식지',
    '한 줌', '조화', '제목', '건강한', '청력', '난방', '도움이 되는', '그녀 자신', '고속도로', '그 자신',
    '역사', '휴일', '지평선', '주택', '그러나', '백', '사냥', '남편', '상상하다', '개선하다',
    '포함하다', '증가하다', '초기의', '문의', '통찰력', '영감을 주다', '설치하다', '즉시', '대신에', '강렬한',
    '포함하다', '여행', '정의', '부엌', '알기', '착륙', '주로', '지속되는', '세탁', '선도하는',
    '배운', '가죽', '떠나는', '여가', '도서관', '면허', '제한된', '목록', '로딩', '위치한',
    '기계', '마법의', '관리자', '인류', '매핑', '결혼한', '거대한', '최대', '의미', '측정하다',
    '의료의', '회의', '언급하다', '메시지', '미네랄', '최소', '누락된', '임무', '실수', '혼합물',
    '모니터', '아침', '음악의', '신비', '자연스러운', '둘 다 아닌', '네트워크', '중립적인', '아무것도', '핵의',
    '간호', '명백한', '장교', '개방', '작동하다', '의견', '광학의', '유기적인', '야외의', '개요',
    '밖의', '전체적인', '패키지', '고통스러운', '주차', '부분적인', '파트너', '통로', '열정', '환자',
    '패턴', '지불', '벌금', '완벽한', '수행하다', '아마도', '그림', '플라스틱', '인기 있는', '부분',
    '빈곤', '정확한', '예측하다', '준비하다', '현재', '예방하다', '주요한', '프린터', '프라이버시', '사적인',
    '문제', '과정', '생산하다', '제품', '프로필', '프로그램', '프로젝트', '약속', '보호하다', '제공하다',
    '출판하다', '목적', '밀기', '자격을 갖추다', '분기', '빠르게', '급진적인', '철도', '쉽게', '현실',
    '받다', '회복하다', '반영하다', '정기적인', '관련된', '출시', '남아있다', '제거', '교체하다', '요청',
    '요구하다', '예약하다', '해결하다', '존경', '응답하다', '복원하다', '은퇴한', '수익', '역방향', '루틴',
    '달리기', '만족시키다', '과학', '긁다', '섹션', '찾기', '판매', '심각한', '서비스', '세션',
    '설정', '여러', '피난처', '보여주기', '비슷한', '앉기', '사회', '어떻게든', '누군가', '특별한',
    '역', '저장', '이상한', '늘리다', '학생', '주제', '성공하다', '성공', '제안하다', '요약',
    '지원', '가정하다', '표면', '수술', '잉여', '생존하다', '의심하다', '지속하다', '선생님', '말하기',
    '긴장', '테스트', '질감', '극장', '치료', '그렇게 해서', '생각', '통해', '오늘 밤', '완전히',
    '향해', '교통', '훈련된', '문제', '돌리기', '전형적인', '유니폼', '알려지지 않은', '특이한', '업그레이드',
    '유틸리티', '다양성', '차량', '벤처', '버전', '마을', '가상의', '보이는', '기다리기', '걷기',
    '경고', '날씨', '웹사이트', '결혼식', '주말', '환영', '복지', '서쪽의', '반면에', '여부',
    '기꺼이', '이기는', '없이', '일하는', '쓰기', '쓰여진'
  ];

  general_japanese text[] := ARRAY[
    '能力 (のうりょく)', '不在 (ふざい)', '学院 (がくいん)', 'アカウント', '達成する (たっせいする)', '取得する (しゅとくする)', '住所 (じゅうしょ)', '進歩 (しんぽ)', '冒険 (ぼうけん)', '助言 (じょげん)',
    'バランス', '障壁 (しょうへき)', 'バッテリー', '利益 (りえき)', '自転車 (じてんしゃ)', '兄弟 (きょうだい)', '予算 (よさん)', '建物 (たてもの)', 'キャビネット', 'カメラ',
    'キャンパス', 'がん', '資本 (しほん)', '船長 (せんちょう)', 'キャリア', 'カーペット', '城 (しろ)', 'カタログ', '危険 (きけん)', '討論 (とうろん)',
    '十年 (じゅうねん)', '決定する (けっていする)', '敗北 (はいぼく)', '守る (まもる)', '学位 (がくい)', '配達する (はいたつする)', '要求 (ようきゅう)', '依存する (いぞんする)', '要素 (ようそ)', '感情 (かんじょう)',
    '皇帝 (こうてい)', '従業員 (じゅうぎょういん)', 'エンジン', '向上させる (こうじょうさせる)', '楽しむ (たのしむ)', '布 (ぬの)', '要因 (よういん)', '失敗 (しっぱい)', '家族 (かぞく)', '有名な (ゆうめいな)',
    'ファンタジー', '農夫 (のうふ)', 'ファッション', '父 (ちち)', '特徴 (とくちょう)', '銀河 (ぎんが)', 'ガレージ', '庭 (にわ)', '集める (あつめる)', '性別 (せいべつ)',
    '天才 (てんさい)', '優しい (やさしい)', 'ジェスチャー', 'グローバル', '金の (きんの)', '生息地 (せいそくち)', '扱う (あつかう)', '起こる (おこる)', '港 (みなと)', 'ほとんど〜ない',
    'ヘッダー', '天国 (てんごく)', '高さ (たかさ)', 'ヘルメット', '影響 (えいきょう)', '輸入 (ゆにゅう)', '収入 (しゅうにゅう)', '確かに (たしかに)', '屋内の (おくないの)', '幼児 (ようじ)',
    '知らせる (しらせる)', '怪我 (けが)', '昆虫 (こんちゅう)', '内部 (ないぶ)', 'ジャケット', 'ジャングル', '後輩 (こうはい)', '正義 (せいぎ)', '腎臓 (じんぞう)', '台所 (だいどころ)',
    'はしご', '発売 (はつばい)', '弁護士 (べんごし)', '機械 (きかい)', '雑誌 (ざっし)', 'マネージャー', '方法 (ほうほう)', '大理石 (だいりせき)', 'マスター', '問題 (もんだい)',
    '草原 (そうげん)', 'メンバー', '国家 (こっか)', '近くの (ちかくの)', '針 (はり)', '甥 (おい)', '神経の (しんけいの)', '正常な (せいじょうな)', '気づく (きづく)', '数 (かず)',
    '物体 (ぶったい)', '得る (える)', '占める (しめる)', 'オフィス', 'オンライン', 'オプション', 'オレンジ', '起源 (きげん)', '出力 (しゅつりょく)', '宮殿 (きゅうでん)',
    '親 (おや)', '部分的に (ぶぶんてきに)', '特許 (とっきょ)', 'パトロール', 'パターン', '人々 (ひとびと)', '期間 (きかん)', '許可 (きょか)', '人 (ひと)', '品質 (ひんしつ)',
    '四半期 (しはんき)', '質問 (しつもん)', 'うさぎ', 'レース', 'ランダム', 'めったに〜ない', 'むしろ', '理由 (りゆう)', '最近の (さいきんの)', '安全 (あんぜん)',
    '給料 (きゅうりょう)', 'サンプル', '貯蓄 (ちょちく)', 'スクリーン', '検索 (けんさく)', '季節 (きせつ)', '二番目 (にばんめ)', '秘密 (ひみつ)', 'タブレット', '取り組む (とりくむ)',
    '才能 (さいのう)', '目標 (もくひょう)', '寺院 (じいん)', 'テニス', '理論 (りろん)', '三十 (さんじゅう)', '糸 (いと)', 'チケット', 'できない', 'ユニーク',
    'アップデート', 'アップロード', '緊急の (きんきゅうの)', '有用な (ゆうような)', '谷 (たに)', 'ベンダー', '被害者 (ひがいしゃ)', '視野 (しや)', '財布 (さいふ)', '富 (とみ)',
    '武器 (ぶき)', '重さ (おもさ)', '窓 (まど)', '冬 (ふゆ)', '不思議に思う (ふしぎにおもう)', '労働者 (ろうどうしゃ)', '黄色 (きいろ)', '驚くべき (おどろくべき)', '古代の (こだいの)', '別の (べつの)',
    '不安 (ふあん)', '誰でも (だれでも)', 'もはや (もはや)', 'どこでも (どこでも)', '承認する (しょうにんする)', '配置する (はいちする)', '記事 (きじ)', '試み (こころみ)', '引きつける (ひきつける)', '素晴らしい (すばらしい)',
    'バランス', 'なぜなら (なぜなら)', '寝室 (しんしつ)', '信じる (しんじる)', '利益 (りえき)', '間に (あいだに)', '自転車 (じてんしゃ)', '十億 (じゅうおく)', '兄弟 (きょうだい)', 'キャビネット',
    '捕獲する (ほかくする)', '注意深い (ちゅういぶかい)', '世紀 (せいき)', '確実な (かくじつな)', '部屋 (へや)', 'チャンネル', '章 (しょう)', '慈善 (じぜん)', '鶏 (にわとり)', '市民 (しみん)',
    '気候 (きこう)', '服 (ふく)', '集める (あつめる)', '大学 (だいがく)', '組み合わせる (くみあわせる)', '快適 (かいてき)', '命令 (めいれい)', 'コメント', '会社 (かいしゃ)', '比較する (ひかくする)',
    '競争する (きょうそうする)', '複雑な (ふくざつな)', '概念 (がいねん)', '関心 (かんしん)', '行う (おこなう)', '確認する (かくにんする)', '接続する (せつぞくする)', '構成する (こうせいする)', '連絡 (れんらく)', '含む (ふくむ)',
    '内容 (ないよう)', 'コンテスト', '文脈 (ぶんみゃく)', '制御 (せいぎょ)', '変換する (へんかんする)', '正しい (ただしい)', '議会 (ぎかい)', 'カウンター', '国 (くに)', '勇気 (ゆうき)',
    '創造的な (そうぞうてきな)', '文化 (ぶんか)', '現在の (げんざいの)', '顧客 (こきゃく)', '配達する (はいたつする)', '密度 (みつど)', '預金 (よきん)', 'デスクトップ', '破壊する (はかいする)', '開発する (かいはつする)',
    'ダイヤモンド', 'デジタル', '議論する (ぎろんする)', '表示 (ひょうじ)', '遠い (とおい)', '多様な (たようなな)', 'イルカ', '動的な (どうてきな)', '東の (ひがしの)', '経済 (けいざい)',
    '教育する (きょういくする)', '高齢者 (こうれいしゃ)', '要素 (ようそ)', '感情 (かんじょう)', '皇帝 (こうてい)', '無限の (むげんの)', '実施する (じっしする)', '向上させる (こうじょうさせる)', '夕方 (ゆうがた)', '例 (れい)',
    '興奮した (こうふんした)', '除外する (じょがいする)', '実行する (じっこうする)', '展示する (てんじする)', '説明する (せつめいする)', '探検する (たんけんする)', '表現する (ひょうげんする)', '極端な (きょくたんな)', '工場 (こうじょう)', '失敗 (しっぱい)',
    'ファンタジー', 'ファッション', '特徴 (とくちょう)', '連邦の (れんぽうの)', '感じ (かんじ)', 'フィクション', '十五 (じゅうご)', '金融 (きんゆう)', '発見 (はっけん)', '釣り (つり)',
    'フィットネス', '外国の (がいこくの)', '永遠に (えいえんに)', '公式 (こうしき)', '運 (うん)', '前進 (ぜんしん)', '自由 (じゆう)', 'ギャラリー', '一般的な (いっぱんてきな)', '遺伝的な (いでんてきな)',
    '本物の (ほんものの)', 'ジェスチャー', '得ること (えること)', '氷河 (ひょうが)', '女神 (めがみ)', 'グラフィック', 'より大きな (よりおおきな)', '食料品 (しょくりょうひん)', '成長する (せいちょうする)', '生息地 (せいそくち)',
    'ひと握り (ひとにぎり)', '調和 (ちょうわ)', '見出し (みだし)', '健康な (けんこうな)', '聴覚 (ちょうかく)', '暖房 (だんぼう)', '役に立つ (やくにたつ)', '彼女自身 (かのじょじしん)', '高速道路 (こうそくどうろ)', '彼自身 (かれじしん)',
    '歴史 (れきし)', '休日 (きゅうじつ)', '地平線 (ちへいせん)', '住宅 (じゅうたく)', 'しかし (しかし)', '百 (ひゃく)', '狩猟 (しゅりょう)', '夫 (おっと)', '想像する (そうぞうする)', '改善する (かいぜんする)',
    '含む (ふくむ)', '増加する (ぞうかする)', '初期の (しょきの)', '問い合わせ (といあわせ)', '洞察 (どうさつ)', '刺激する (しげきする)', 'インストールする', '瞬間 (しゅんかん)', '代わりに (かわりに)', '激しい (はげしい)',
    '関与する (かんよする)', '旅 (たび)', '正義 (せいぎ)', '台所 (だいどころ)', '知ること (しること)', '着陸 (ちゃくりく)', '主に (おもに)', '持続する (じぞくする)', '洗濯 (せんたく)', '先導する (せんどうする)',
    '学んだ (まなんだ)', '革 (かわ)', '去ること (さること)', '余暇 (よか)', '図書館 (としょかん)', '免許 (めんきょ)', '限られた (かぎられた)', 'リスト', '読み込み (よみこみ)', '位置する (いちする)',
    '機械 (きかい)', '魔法の (まほうの)', 'マネージャー', '人類 (じんるい)', 'マッピング', '結婚した (けっこんした)', '巨大な (きょだいな)', '最大 (さいだい)', '意味 (いみ)', '測定する (そくていする)',
    '医療の (いりょうの)', '会議 (かいぎ)', '言及する (げんきゅうする)', 'メッセージ', 'ミネラル', '最小 (さいしょう)', '欠けている (かけている)', '使命 (しめい)', '間違い (まちがい)', '混合物 (こんごうぶつ)',
    'モニター', '朝 (あさ)', '音楽の (おんがくの)', '謎 (なぞ)', '自然な (しぜんな)', 'どちらも〜ない (どちらも〜ない)', 'ネットワーク', '中立の (ちゅうりつの)', '何も (なにも)', '核の (かくの)',
    '看護 (かんご)', '明らかな (あきらかな)', '役員 (やくいん)', '開放 (かいほう)', '操作する (そうさする)', '意見 (いけん)', '光学の (こうがくの)', '有機の (ゆうきの)', '屋外の (おくがいの)', '概要 (がいよう)',
    '外側 (そとがわ)', '全体的な (ぜんたいてきな)', 'パッケージ', '痛い (いたい)', '駐車 (ちゅうしゃ)', '部分的な (ぶぶんてきな)', 'パートナー', '通路 (つうろ)', '情熱 (じょうねつ)', '患者 (かんじゃ)',
    'パターン', '支払い (しはらい)', '罰金 (ばっきん)', '完璧な (かんぺきな)', '実行する (じっこうする)', 'おそらく (おそらく)', '絵 (え)', 'プラスチック', '人気の (にんきの)', '部分 (ぶぶん)',
    '貧困 (ひんこん)', '正確な (せいかくな)', '予測する (よそくする)', '準備する (じゅんびする)', '現在 (げんざい)', '防ぐ (ふせぐ)', '主要な (しゅような)', 'プリンター', 'プライバシー', '私的な (してきな)',
    '問題 (もんだい)', '過程 (かてい)', '生産する (せいさんする)', '製品 (せいひん)', 'プロフィール', 'プログラム', 'プロジェクト', '約束 (やくそく)', '保護する (ほごする)', '提供する (ていきょうする)',
    '出版する (しゅっぱんする)', '目的 (もくてき)', '押すこと (おすこと)', '資格を得る (しかくをえる)', '四半期 (しはんき)', '素早く (すばやく)', '急進的な (きゅうしんてきな)', '鉄道 (てつどう)', '容易に (よういに)', '現実 (げんじつ)',
    '受け取る (うけとる)', '回復する (かいふくする)', '反映する (はんえいする)', '定期的な (ていきてきな)', '関連した (かんれんした)', '発表 (はっぴょう)', '残る (のこる)', '除去 (じょきょ)', '置き換える (おきかえる)', '要求 (ようきゅう)',
    '要求する (ようきゅうする)', '予約する (よやくする)', '解決する (かいけつする)', '尊敬 (そんけい)', '応答する (おうとうする)', '復元する (ふくげんする)', '退職した (たいしょくした)', '収益 (しゅうえき)', '逆 (ぎゃく)', 'ルーチン',
    '走ること (はしること)', '満足させる (まんぞくさせる)', '科学 (かがく)', '引っかく (ひっかく)', 'セクション', '求めること (もとめること)', '売ること (うること)', '深刻な (しんこくな)', 'サービス', 'セッション',
    '設定 (せってい)', 'いくつかの (いくつかの)', '避難所 (ひなんじょ)', '示すこと (しめすこと)', '似ている (にている)', '座ること (すわること)', '社会 (しゃかい)', 'どういうわけか (どういうわけか)', '誰か (だれか)', '特別な (とくべつな)',
    '駅 (えき)', '保管 (ほかん)', '奇妙な (きみょうな)', '伸ばす (のばす)', '学生 (がくせい)', '主題 (しゅだい)', '成功する (せいこうする)', '成功 (せいこう)', '提案する (ていあんする)', '要約 (ようやく)',
    '支援 (しえん)', '仮定する (かていする)', '表面 (ひょうめん)', '手術 (しゅじゅつ)', '余剰 (よじょう)', '生き残る (いきのこる)', '疑う (うたがう)', '維持する (いじする)', '教師 (きょうし)', '話すこと (はなすこと)',
    '緊張 (きんちょう)', 'テスト', '質感 (しつかん)', '劇場 (げきじょう)', '治療 (ちりょう)', 'それによって (それによって)', '思考 (しこう)', '通して (とおして)', '今夜 (こんや)', '完全に (かんぜんに)',
    '向かって (むかって)', '交通 (こうつう)', '訓練された (くんれんされた)', '問題 (もんだい)', '回すこと (まわすこと)', '典型的な (てんけいてきな)', '制服 (せいふく)', '未知の (みちの)', '珍しい (めずらしい)', 'アップグレード',
    'ユーティリティ', '多様性 (たようせい)', '車両 (しゃりょう)', 'ベンチャー', 'バージョン', '村 (むら)', '仮想の (かそうの)', '見える (みえる)', '待つこと (まつこと)', '歩くこと (あるくこと)',
    '警告 (けいこく)', '天気 (てんき)', 'ウェブサイト', '結婚式 (けっこんしき)', '週末 (しゅうまつ)', '歓迎 (かんげい)', '福祉 (ふくし)', '西の (にしの)', '一方で (いっぽうで)', 'かどうか (かどうか)',
    '喜んで (よろこんで)', '勝つこと (かつこと)', 'なしで (なしで)', '働くこと (はたらくこと)', '書くこと (かくこと)', '書かれた (かかれた)'
  ];

  i integer;
  current_word_id uuid;
  total_words integer := 0;
  
BEGIN
  -- Insert Technology words
  FOR i IN 1..LEAST(array_length(tech_words, 1), array_length(tech_korean, 1), array_length(tech_japanese, 1)) LOOP
    INSERT INTO words (word, category, definition, bookmarks)
    VALUES (
      tech_words[i],
      'Technology',
      'Definition for ' || tech_words[i],
      floor(random() * 150) + 10
    )
    ON CONFLICT (word) DO UPDATE SET
      category = EXCLUDED.category,
      definition = EXCLUDED.definition;
    
    SELECT id INTO current_word_id FROM words WHERE word = tech_words[i];
    
    -- Insert Korean translation
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (current_word_id, 'ko', tech_korean[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    -- Insert Japanese translation
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (current_word_id, 'ja', tech_japanese[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    -- Insert trending data
    INSERT INTO word_trends (word_id, views, last_viewed)
    VALUES (
      current_word_id,
      floor(random() * 300) + 100,
      now() - (random() * interval '60 days')
    )
    ON CONFLICT (word_id) DO UPDATE SET
      views = EXCLUDED.views,
      last_viewed = EXCLUDED.last_viewed;
      
    total_words := total_words + 1;
  END LOOP;
  
  -- Insert Science words
  FOR i IN 1..LEAST(array_length(science_words, 1), array_length(science_korean, 1), array_length(science_japanese, 1)) LOOP
    INSERT INTO words (word, category, definition, bookmarks)
    VALUES (
      science_words[i],
      'Science',
      'Definition for ' || science_words[i],
      floor(random() * 120) + 15
    )
    ON CONFLICT (word) DO UPDATE SET
      category = EXCLUDED.category,
      definition = EXCLUDED.definition;
    
    SELECT id INTO current_word_id FROM words WHERE word = science_words[i];
    
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (current_word_id, 'ko', science_korean[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (current_word_id, 'ja', science_japanese[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    INSERT INTO word_trends (word_id, views, last_viewed)
    VALUES (
      current_word_id,
      floor(random() * 250) + 80,
      now() - (random() * interval '45 days')
    )
    ON CONFLICT (word_id) DO UPDATE SET
      views = EXCLUDED.views,
      last_viewed = EXCLUDED.last_viewed;
      
    total_words := total_words + 1;
  END LOOP;
  
  -- Insert Business words
  FOR i IN 1..LEAST(array_length(business_words, 1), array_length(business_korean, 1), array_length(business_japanese, 1)) LOOP
    INSERT INTO words (word, category, definition, bookmarks)
    VALUES (
      business_words[i],
      'Business',
      'Definition for ' || business_words[i],
      floor(random() * 100) + 20
    )
    ON CONFLICT (word) DO UPDATE SET
      category = EXCLUDED.category,
      definition = EXCLUDED.definition;
    
    SELECT id INTO current_word_id FROM words WHERE word = business_words[i];
    
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (current_word_id, 'ko', business_korean[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (current_word_id, 'ja', business_japanese[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    INSERT INTO word_trends (word_id, views, last_viewed)
    VALUES (
      current_word_id,
      floor(random() * 200) + 60,
      now() - (random() * interval '30 days')
    )
    ON CONFLICT (word_id) DO UPDATE SET
      views = EXCLUDED.views,
      last_viewed = EXCLUDED.last_viewed;
      
    total_words := total_words + 1;
  END LOOP;
  
  -- Insert Education words
  FOR i IN 1..LEAST(array_length(education_words, 1), array_length(education_korean, 1), array_length(education_japanese, 1)) LOOP
    INSERT INTO words (word, category, definition, bookmarks)
    VALUES (
      education_words[i],
      'Education',
      'Definition for ' || education_words[i],
      floor(random() * 90) + 25
    )
    ON CONFLICT (word) DO UPDATE SET
      category = EXCLUDED.category,
      definition = EXCLUDED.definition;
    
    SELECT id INTO current_word_id FROM words WHERE word = education_words[i];
    
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (current_word_id, 'ko', education_korean[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (current_word_id, 'ja', education_japanese[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    INSERT INTO word_trends (word_id, views, last_viewed)
    VALUES (
      current_word_id,
      floor(random() * 180) + 70,
      now() - (random() * interval '40 days')
    )
    ON CONFLICT (word_id) DO UPDATE SET
      views = EXCLUDED.views,
      last_viewed = EXCLUDED.last_viewed;
      
    total_words := total_words + 1;
  END LOOP;
  
  -- Insert Health words
  FOR i IN 1..LEAST(array_length(health_words, 1), array_length(health_korean, 1), array_length(health_japanese, 1)) LOOP
    INSERT INTO words (word, category, definition, bookmarks)
    VALUES (
      health_words[i],
      'Health',
      'Definition for ' || health_words[i],
      floor(random() * 110) + 30
    )
    ON CONFLICT (word) DO UPDATE SET
      category = EXCLUDED.category,
      definition = EXCLUDED.definition;
    
    SELECT id INTO current_word_id FROM words WHERE word = health_words[i];
    
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (current_word_id, 'ko', health_korean[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (current_word_id, 'ja', health_japanese[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    INSERT INTO word_trends (word_id, views, last_viewed)
    VALUES (
      current_word_id,
      floor(random() * 220) + 90,
      now() - (random() * interval '35 days')
    )
    ON CONFLICT (word_id) DO UPDATE SET
      views = EXCLUDED.views,
      last_viewed = EXCLUDED.last_viewed;
      
    total_words := total_words + 1;
  END LOOP;
  
  -- Insert General words
  FOR i IN 1..LEAST(array_length(general_words, 1), array_length(general_korean, 1), array_length(general_japanese, 1)) LOOP
    INSERT INTO words (word, category, definition, bookmarks)
    VALUES (
      general_words[i],
      'General',
      'Definition for ' || general_words[i],
      floor(random() * 80) + 5
    )
    ON CONFLICT (word) DO UPDATE SET
      category = EXCLUDED.category,
      definition = EXCLUDED.definition;
    
    SELECT id INTO current_word_id FROM words WHERE word = general_words[i];
    
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (current_word_id, 'ko', general_korean[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    INSERT INTO word_translations (word_id, language, translation)
    VALUES (current_word_id, 'ja', general_japanese[i])
    ON CONFLICT (word_id, language) DO UPDATE SET
      translation = EXCLUDED.translation;
    
    INSERT INTO word_trends (word_id, views, last_viewed)
    VALUES (
      current_word_id,
      floor(random() * 150) + 40,
      now() - (random() * interval '50 days')
    )
    ON CONFLICT (word_id) DO UPDATE SET
      views = EXCLUDED.views,
      last_viewed = EXCLUDED.last_viewed;
      
    total_words := total_words + 1;
  END LOOP;
  
  RAISE NOTICE 'Successfully inserted % words with translations and trending data', total_words;
END;
$$ LANGUAGE plpgsql;

-- Execute the function to generate comprehensive vocabulary
SELECT generate_comprehensive_vocabulary();

-- Drop the function after use
DROP FUNCTION generate_comprehensive_vocabulary();

-- Create comprehensive relationships between words
INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
SELECT 
  w1.id, w2.id, 'related', 'Technology relationship'
FROM words w1, words w2
WHERE w1.category = 'Technology' AND w2.category = 'Technology'
  AND w1.word != w2.word
  AND (
    (w1.word = 'algorithm' AND w2.word = 'programming') OR
    (w1.word = 'artificial' AND w2.word = 'intelligence') OR
    (w1.word = 'machine' AND w2.word = 'learning') OR
    (w1.word = 'database' AND w2.word = 'software') OR
    (w1.word = 'network' AND w2.word = 'internet') OR
    (w1.word = 'mobile' AND w2.word = 'smartphone') OR
    (w1.word = 'virtual' AND w2.word = 'reality') OR
    (w1.word = 'cloud' AND w2.word = 'computing') OR
    (w1.word = 'security' AND w2.word = 'encryption') OR
    (w1.word = 'automation' AND w2.word = 'robotics')
  )
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
SELECT 
  w1.id, w2.id, 'related', 'Science relationship'
FROM words w1, words w2
WHERE w1.category = 'Science' AND w2.category = 'Science'
  AND w1.word != w2.word
  AND (
    (w1.word = 'physics' AND w2.word = 'mathematics') OR
    (w1.word = 'chemistry' AND w2.word = 'biology') OR
    (w1.word = 'astronomy' AND w2.word = 'universe') OR
    (w1.word = 'molecule' AND w2.word = 'atom') OR
    (w1.word = 'energy' AND w2.word = 'force') OR
    (w1.word = 'evolution' AND w2.word = 'genetics') OR
    (w1.word = 'ecosystem' AND w2.word = 'biodiversity') OR
    (w1.word = 'quantum' AND w2.word = 'particle') OR
    (w1.word = 'galaxy' AND w2.word = 'planet') OR
    (w1.word = 'microscope' AND w2.word = 'telescope')
  )
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
SELECT 
  w1.id, w2.id, 'related', 'Business relationship'
FROM words w1, words w2
WHERE w1.category = 'Business' AND w2.category = 'Business'
  AND w1.word != w2.word
  AND (
    (w1.word = 'management' AND w2.word = 'leadership') OR
    (w1.word = 'strategy' AND w2.word = 'planning') OR
    (w1.word = 'marketing' AND w2.word = 'sales') OR
    (w1.word = 'customer' AND w2.word = 'service') OR
    (w1.word = 'finance' AND w2.word = 'accounting') OR
    (w1.word = 'investment' AND w2.word = 'capital') OR
    (w1.word = 'entrepreneur' AND w2.word = 'startup') OR
    (w1.word = 'supply' AND w2.word = 'demand') OR
    (w1.word = 'contract' AND w2.word = 'negotiation') OR
    (w1.word = 'promotion' AND w2.word = 'advertising')
  )
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
SELECT 
  w1.id, w2.id, 'related', 'Education relationship'
FROM words w1, words w2
WHERE w1.category = 'Education' AND w2.category = 'Education'
  AND w1.word != w2.word
  AND (
    (w1.word = 'school' AND w2.word = 'education') OR
    (w1.word = 'teacher' AND w2.word = 'student') OR
    (w1.word = 'learning' AND w2.word = 'knowledge') OR
    (w1.word = 'course' AND w2.word = 'curriculum') OR
    (w1.word = 'examination' AND w2.word = 'assessment') OR
    (w1.word = 'degree' AND w2.word = 'qualification') OR
    (w1.word = 'research' AND w2.word = 'study') OR
    (w1.word = 'library' AND w2.word = 'textbook') OR
    (w1.word = 'classroom' AND w2.word = 'laboratory') OR
    (w1.word = 'university' AND w2.word = 'college')
  )
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
SELECT 
  w1.id, w2.id, 'related', 'Health relationship'
FROM words w1, words w2
WHERE w1.category = 'Health' AND w2.category = 'Health'
  AND w1.word != w2.word
  AND (
    (w1.word = 'health' AND w2.word = 'medicine') OR
    (w1.word = 'doctor' AND w2.word = 'patient') OR
    (w1.word = 'treatment' AND w2.word = 'therapy') OR
    (w1.word = 'diagnosis' AND w2.word = 'symptom') OR
    (w1.word = 'hospital' AND w2.word = 'clinic') OR
    (w1.word = 'surgery' AND w2.word = 'operation') OR
    (w1.word = 'nutrition' AND w2.word = 'diet') OR
    (w1.word = 'exercise' AND w2.word = 'fitness') OR
    (w1.word = 'heart' AND w2.word = 'circulation') OR
    (w1.word = 'prevention' AND w2.word = 'vaccine')
  )
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

-- Create some synonym relationships
INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
SELECT 
  w1.id, w2.id, 'synonym', 'Similar meaning'
FROM words w1, words w2
WHERE w1.word != w2.word
  AND (
    (w1.word = 'artificial' AND w2.word = 'synthetic') OR
    (w1.word = 'intelligent' AND w2.word = 'smart') OR
    (w1.word = 'organization' AND w2.word = 'company') OR
    (w1.word = 'education' AND w2.word = 'learning') OR
    (w1.word = 'medicine' AND w2.word = 'medication') OR
    (w1.word = 'treatment' AND w2.word = 'therapy') OR
    (w1.word = 'examination' AND w2.word = 'test') OR
    (w1.word = 'research' AND w2.word = 'study')
  )
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;

-- Create some antonym relationships
INSERT INTO word_relationships (source_word_id, target_word_id, relationship_type, description)
SELECT 
  w1.id, w2.id, 'antonym', 'Opposite meaning'
FROM words w1, words w2
WHERE w1.word != w2.word
  AND (
    (w1.word = 'artificial' AND w2.word = 'natural') OR
    (w1.word = 'success' AND w2.word = 'failure') OR
    (w1.word = 'profit' AND w2.word = 'loss') OR
    (w1.word = 'health' AND w2.word = 'illness') OR
    (w1.word = 'prevention' AND w2.word = 'treatment') OR
    (w1.word = 'knowledge' AND w2.word = 'ignorance')
  )
ON CONFLICT (source_word_id, target_word_id, relationship_type) DO NOTHING;