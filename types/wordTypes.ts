export interface RelatedWord {
  word: string;
  type: 'antonym' | 'synonym' | 'hypernym' | 'hyponym' | 'meronym' | 'holonym' | 'derivative' | 'polysemy' | 'semantic_field' | 'related' | 'center';
  category?: string;
  translations?: {
    ko: string;
    ja: string;
  };
  description?: string;
}

export interface WordData {
  word: string;
  definition: string;
  category: string;
  bookmarks: number;
  translations: {
    ko: string;
    ja: string;
  };
  relatedWords: RelatedWord[];
}