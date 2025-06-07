import { WordData, RelatedWord } from '@/types/wordTypes';
import { supabase } from '@/utils/supabase';

// Cache for frequently accessed data
const wordCache = new Map<string, WordData>();
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes

interface CachedWordData {
  data: WordData;
  timestamp: number;
}

// Get word data from Supabase with caching
export async function getWordData(word: string): Promise<WordData> {
  const normalizedWord = word.toLowerCase();
  
  // Check cache first
  const cached = wordCache.get(normalizedWord) as CachedWordData;
  if (cached && Date.now() - cached.timestamp < CACHE_DURATION) {
    return cached.data;
  }

  try {
    // Query word with translations and relationships
    const { data: wordDataArray, error: wordError } = await supabase
      .from('words')
      .select(`
        id,
        word,
        category,
        definition,
        bookmarks,
        word_translations(language, translation),
        source_relationships:word_relationships!source_word_id(
          relationship_type,
          description,
          target_word:words!target_word_id(word, category)
        ),
        target_relationships:word_relationships!target_word_id(
          relationship_type,
          description,
          source_word:words!source_word_id(word, category)
        )
      `)
      .eq('word', normalizedWord)
      .limit(1);

    if (wordError) {
      console.error('Error fetching word data:', wordError);
      return createDefaultWordData(normalizedWord);
    }

    if (!wordDataArray || wordDataArray.length === 0) {
      return createDefaultWordData(normalizedWord);
    }

    const wordData = wordDataArray[0];

    // Process translations
    const translations = {
      ko: wordData.word_translations?.find((t: any) => t.language === 'ko')?.translation || '번역 필요',
      ja: wordData.word_translations?.find((t: any) => t.language === 'ja')?.translation || '翻訳필요'
    };

    // Process relationships and get translations for related words
    const relatedWords: RelatedWord[] = [];
    const usedWords = new Set([normalizedWord]); // Track used words to avoid duplicates
    const relationshipTypeCount = new Map<string, number>();
    
    // Initialize relationship type counts
    ['antonym', 'synonym', 'hypernym', 'hyponym', 'meronym', 'holonym', 'derivative', 'polysemy', 'semantic_field', 'related'].forEach(type => {
      relationshipTypeCount.set(type, 0);
    });
    
    // Add source relationships (this word -> other words)
    if (wordData.source_relationships) {
      for (const rel of wordData.source_relationships) {
        if (rel.target_word?.word && !usedWords.has(rel.target_word.word)) {
          // Get translations for the related word
          const { data: relatedWordArray } = await supabase
            .from('words')
            .select('id')
            .eq('word', rel.target_word.word)
            .limit(1);

          if (relatedWordArray && relatedWordArray.length > 0) {
            const { data: relatedTranslations } = await supabase
              .from('word_translations')
              .select('language, translation')
              .eq('word_id', relatedWordArray[0].id);

            const relatedWordTranslations = {
              ko: relatedTranslations?.find((t: any) => t.language === 'ko')?.translation || '번역 필요',
              ja: relatedTranslations?.find((t: any) => t.language === 'ja')?.translation || '翻訳필요'
            };

            relatedWords.push({
              word: rel.target_word.word,
              type: rel.relationship_type as 'antonym' | 'synonym' | 'hypernym' | 'hyponym' | 'meronym' | 'holonym' | 'derivative' | 'polysemy' | 'semantic_field' | 'related',
              category: rel.target_word.category || 'General',
              description: rel.description || `Related to ${normalizedWord}`,
              translations: relatedWordTranslations
            });
            
            usedWords.add(rel.target_word.word);
            const currentCount = relationshipTypeCount.get(rel.relationship_type) || 0;
            relationshipTypeCount.set(rel.relationship_type, currentCount + 1);
          }
        }
      }
    }

    // Add target relationships (other words -> this word)
    if (wordData.target_relationships) {
      for (const rel of wordData.target_relationships) {
        if (rel.source_word?.word && !usedWords.has(rel.source_word.word)) {
          // Get translations for the related word
          const { data: relatedWordArray } = await supabase
            .from('words')
            .select('id')
            .eq('word', rel.source_word.word)
            .limit(1);

          if (relatedWordArray && relatedWordArray.length > 0) {
            const { data: relatedTranslations } = await supabase
              .from('word_translations')
              .select('language, translation')
              .eq('word_id', relatedWordArray[0].id);

            const relatedWordTranslations = {
              ko: relatedTranslations?.find((t: any) => t.language === 'ko')?.translation || '번역 필요',
              ja: relatedTranslations?.find((t: any) => t.language === 'ja')?.translation || '翻訳필요'
            };

            relatedWords.push({
              word: rel.source_word.word,
              type: rel.relationship_type as 'antonym' | 'synonym' | 'hypernym' | 'hyponym' | 'meronym' | 'holonym' | 'derivative' | 'polysemy' | 'semantic_field' | 'related',
              category: rel.source_word.category || 'General',
              description: rel.description || `Related to ${normalizedWord}`,
              translations: relatedWordTranslations
            });
            
            usedWords.add(rel.source_word.word);
            const currentCount = relationshipTypeCount.get(rel.relationship_type) || 0;
            relationshipTypeCount.set(rel.relationship_type, currentCount + 1);
          }
        }
      }
    }

    // If we don't have enough diverse relationships, get more from similar category
    if (relatedWords.length < 10) {
      const { data: similarWords } = await supabase
        .from('words')
        .select(`
          word,
          category,
          word_translations(language, translation)
        `)
        .eq('category', wordData.category || 'General')
        .neq('word', normalizedWord)
        .not('word', 'in', `(${Array.from(usedWords).map(w => `"${w}"`).join(',')})`)
        .limit(15);

      if (similarWords) {
        // Assign diverse relationship types to fill gaps
        const relationshipTypes = ['antonym', 'synonym', 'hypernym', 'hyponym', 'meronym', 'holonym', 'derivative', 'polysemy', 'semantic_field', 'related'];
        
        similarWords.forEach((similarWord: any, index: number) => {
          if (relatedWords.length < 10 && !usedWords.has(similarWord.word)) {
            // Select relationship type to ensure diversity
            const leastUsedType = relationshipTypes.reduce((min, type) => 
              (relationshipTypeCount.get(type) || 0) < (relationshipTypeCount.get(min) || 0) ? type : min
            );
            
            const similarTranslations = {
              ko: similarWord.word_translations?.find((t: any) => t.language === 'ko')?.translation || '번역 필요',
              ja: similarWord.word_translations?.find((t: any) => t.language === 'ja')?.translation || '翻訳필요'
            };

            relatedWords.push({
              word: similarWord.word,
              type: leastUsedType as 'antonym' | 'synonym' | 'hypernym' | 'hyponym' | 'meronym' | 'holonym' | 'derivative' | 'polysemy' | 'semantic_field' | 'related',
              category: similarWord.category || 'General',
              description: `Related to ${normalizedWord}`,
              translations: similarTranslations
            });
            
            usedWords.add(similarWord.word);
            const currentCount = relationshipTypeCount.get(leastUsedType) || 0;
            relationshipTypeCount.set(leastUsedType, currentCount + 1);
          }
        });
      }
    }

    // If we still don't have enough words, get random words from the database
    if (relatedWords.length < 10) {
      const { data: randomWords } = await supabase
        .from('words')
        .select(`
          word,
          category,
          word_translations(language, translation)
        `)
        .neq('word', normalizedWord)
        .not('word', 'in', `(${Array.from(usedWords).map(w => `"${w}"`).join(',')})`)
        .order('word')
        .limit(15);

      if (randomWords) {
        const relationshipTypes = ['antonym', 'synonym', 'hypernym', 'hyponym', 'meronym', 'holonym', 'derivative', 'polysemy', 'semantic_field', 'related'];
        
        randomWords.forEach((randomWord: any) => {
          if (relatedWords.length < 10 && !usedWords.has(randomWord.word)) {
            // Select relationship type to ensure diversity
            const leastUsedType = relationshipTypes.reduce((min, type) => 
              (relationshipTypeCount.get(type) || 0) < (relationshipTypeCount.get(min) || 0) ? type : min
            );
            
            const randomTranslations = {
              ko: randomWord.word_translations?.find((t: any) => t.language === 'ko')?.translation || '번역 필요',
              ja: randomWord.word_translations?.find((t: any) => t.language === 'ja')?.translation || '翻訳필요'
            };

            relatedWords.push({
              word: randomWord.word,
              type: leastUsedType as 'antonym' | 'synonym' | 'hypernym' | 'hyponym' | 'meronym' | 'holonym' | 'derivative' | 'polysemy' | 'semantic_field' | 'related',
              category: randomWord.category || 'General',
              description: `Related to ${normalizedWord}`,
              translations: randomTranslations
            });
            
            usedWords.add(randomWord.word);
            const currentCount = relationshipTypeCount.get(leastUsedType) || 0;
            relationshipTypeCount.set(leastUsedType, currentCount + 1);
          }
        });
      }
    }

    const result: WordData = {
      word: normalizedWord,
      definition: wordData.definition || `Definition for ${normalizedWord}`,
      category: wordData.category || 'General',
      bookmarks: wordData.bookmarks || 0,
      translations,
      relatedWords: relatedWords.slice(0, 12) // Limit to 12 related words
    };

    // Cache the result
    wordCache.set(normalizedWord, {
      data: result,
      timestamp: Date.now()
    });

    return result;
  } catch (error) {
    console.error('Error in getWordData:', error);
    return createDefaultWordData(normalizedWord);
  }
}

// Get all words from Supabase
export async function getAllWords(): Promise<string[]> {
  try {
    const { data, error } = await supabase
      .from('words')
      .select('word')
      .order('word');

    if (error) {
      console.error('Error fetching all words:', error);
      return [];
    }

    return data?.map(item => item.word) || [];
  } catch (error) {
    console.error('Error in getAllWords:', error);
    return [];
  }
}

// Add word to database
export async function addWordToDatabase(
  word: string,
  data: {
    type: 'antonym' | 'synonym' | 'hypernym' | 'hyponym' | 'meronym' | 'holonym' | 'derivative' | 'polysemy' | 'semantic_field' | 'related';
    description?: string;
    baseWord: string;
    translations?: {
      ko: string;
      ja: string;
    };
  }
): Promise<void> {
  const normalizedWord = word.toLowerCase();
  const normalizedBaseWord = data.baseWord.toLowerCase();

  try {
    // Get current user session
    const { data: { session } } = await supabase.auth.getSession();
    const contributorId = session?.user?.id;

    // First, check if the new word already exists
    const { data: existingWordArray } = await supabase
      .from('words')
      .select('id')
      .eq('word', normalizedWord)
      .limit(1);

    let newWordId: string;

    if (existingWordArray && existingWordArray.length > 0) {
      // Word already exists, use its ID
      newWordId = existingWordArray[0].id;
    } else {
      // Insert the new word
      const { data: newWordData, error: newWordError } = await supabase
        .from('words')
        .insert({
          word: normalizedWord,
          definition: data.description || `Definition for ${normalizedWord}`,
          category: 'General',
          contributor_id: contributorId
        })
        .select('id')
        .limit(1);

      if (newWordError) {
        console.error('Error inserting new word:', newWordError);
        throw new Error(`Failed to insert word: ${newWordError.message}`);
      }

      if (!newWordData || newWordData.length === 0) {
        throw new Error('Failed to insert word: No data returned');
      }

      newWordId = newWordData[0].id;
    }

    // Get or insert the base word
    const { data: existingBaseWordArray } = await supabase
      .from('words')
      .select('id')
      .eq('word', normalizedBaseWord)
      .limit(1);

    let baseWordId: string;

    if (existingBaseWordArray && existingBaseWordArray.length > 0) {
      // Base word already exists, use its ID
      baseWordId = existingBaseWordArray[0].id;
    } else {
      // Insert the base word
      const { data: baseWordData, error: baseWordError } = await supabase
        .from('words')
        .insert({
          word: normalizedBaseWord,
          definition: `Definition for ${normalizedBaseWord}`,
          category: 'General',
          contributor_id: contributorId
        })
        .select('id')
        .limit(1);

      if (baseWordError) {
        console.error('Error inserting base word:', baseWordError);
        throw new Error(`Failed to insert base word: ${baseWordError.message}`);
      }

      if (!baseWordData || baseWordData.length === 0) {
        throw new Error('Failed to insert base word: No data returned');
      }

      baseWordId = baseWordData[0].id;
    }

    // Add translations if provided and word was newly created
    if (data.translations && (!existingWordArray || existingWordArray.length === 0)) {
      const translationsToInsert = [];
      
      if (data.translations.ko) {
        translationsToInsert.push({
          word_id: newWordId,
          language: 'ko',
          translation: data.translations.ko,
          contributor_id: contributorId
        });
      }
      
      if (data.translations.ja) {
        translationsToInsert.push({
          word_id: newWordId,
          language: 'ja',
          translation: data.translations.ja,
          contributor_id: contributorId
        });
      }

      if (translationsToInsert.length > 0) {
        const { error: translationError } = await supabase
          .from('word_translations')
          .upsert(translationsToInsert);

        if (translationError) {
          console.error('Error inserting translations:', translationError);
          // Don't throw here, as the word was successfully created
        }
      }
    }

    // Create relationship between words (check if it already exists first)
    const { data: existingRelationshipArray } = await supabase
      .from('word_relationships')
      .select('id')
      .eq('source_word_id', baseWordId)
      .eq('target_word_id', newWordId)
      .eq('relationship_type', data.type)
      .limit(1);

    if (!existingRelationshipArray || existingRelationshipArray.length === 0) {
      const { error: relationshipError } = await supabase
        .from('word_relationships')
        .insert({
          source_word_id: baseWordId,
          target_word_id: newWordId,
          relationship_type: data.type,
          description: data.description || `${data.type} relationship`,
          contributor_id: contributorId
        });

      if (relationshipError) {
        console.error('Error creating relationship:', relationshipError);
        // Don't throw here, as the word was successfully created
      }
    }

    // Clear cache for affected words
    wordCache.delete(normalizedWord);
    wordCache.delete(normalizedBaseWord);

  } catch (error) {
    console.error('Error in addWordToDatabase:', error);
    throw error;
  }
}

// Create default word data for words not in database
function createDefaultWordData(word: string): WordData {
  return {
    word,
    definition: `Definition for ${word}`,
    category: 'General',
    bookmarks: 0,
    translations: {
      ko: '번역 필요',
      ja: '翻訳필요'
    },
    relatedWords: []
  };
}

// Clear cache (useful for refreshing data)
export function clearWordCache(): void {
  wordCache.clear();
}

// Get trending words - prioritize real English words over generated ones
export async function getTrendingWords(limit: number = 30): Promise<string[]> {
  try {
    // First try to get predefined English words
    const { data: englishWords, error: englishError } = await supabase
      .from('words')
      .select('word')
      .in('word', ['house', 'love', 'time', 'book', 'work', 'life', 'food', 'music', 'peace', 'dream', 'water', 'fire', 'earth', 'wind', 'light', 'dark', 'hope', 'faith', 'truth', 'beauty', 'nature', 'power', 'space', 'heart', 'mind', 'soul', 'spirit', 'change', 'growth', 'wisdom'])
      .order('word');

    if (englishWords && englishWords.length > 0) {
      const englishWordList = englishWords.map(item => item.word.toUpperCase());
      
      // If we have enough English words, return them
      if (englishWordList.length >= limit) {
        return englishWordList.slice(0, limit);
      }
      
      // Otherwise, get additional words from trending data
      const { data: trendingData, error: trendingError } = await supabase
        .from('word_trends')
        .select(`
          word:words(word)
        `)
        .order('trending_score', { ascending: false })
        .limit(limit - englishWordList.length);

      if (trendingData) {
        const additionalWords = trendingData
          .map((item: any) => item.word?.word)
          .filter(Boolean)
          .filter((word: string) => !word.startsWith('word_')) // Filter out generated words
          .map((word: string) => word.toUpperCase());
        
        return [...englishWordList, ...additionalWords].slice(0, limit);
      }
      
      return englishWordList;
    }

    // Fallback to default trending words if database query fails
    return [
      'LOVE', 'TIME', 'HOUSE', 'BOOK', 'WORK', 'LIFE', 'FOOD', 'MUSIC',
      'PEACE', 'DREAM', 'HOPE', 'MIND', 'HEART', 'WORLD', 'LIGHT',
      'TRUTH', 'FAITH', 'POWER', 'SPACE', 'EARTH', 'WATER', 'FIRE',
      'WIND', 'SOUL', 'SPIRIT', 'NATURE', 'BEAUTY', 'WISDOM', 'CHANGE', 'GROWTH'
    ].slice(0, limit);

  } catch (error) {
    console.error('Error in getTrendingWords:', error);
    // Return fallback trending words
    return [
      'LOVE', 'TIME', 'HOUSE', 'BOOK', 'WORK', 'LIFE', 'FOOD', 'MUSIC',
      'PEACE', 'DREAM', 'HOPE', 'MIND', 'HEART', 'WORLD', 'LIGHT',
      'TRUTH', 'FAITH', 'POWER', 'SPACE', 'EARTH', 'WATER', 'FIRE',
      'WIND', 'SOUL', 'SPIRIT', 'NATURE', 'BEAUTY', 'WISDOM', 'CHANGE', 'GROWTH'
    ].slice(0, limit);
  }
}

// Update word view count
export async function updateWordView(word: string): Promise<void> {
  try {
    const { data: wordDataArray } = await supabase
      .from('words')
      .select('id')
      .eq('word', word.toLowerCase())
      .limit(1);

    if (!wordDataArray || wordDataArray.length === 0) {
      return;
    }

    const wordData = wordDataArray[0];

    // Check if a trend record already exists for this word
    const { data: existingTrendArray } = await supabase
      .from('word_trends')
      .select('id, views')
      .eq('word_id', wordData.id)
      .limit(1);

    if (existingTrendArray && existingTrendArray.length > 0) {
      const existingTrend = existingTrendArray[0];
      // Update existing record by incrementing views
      await supabase
        .from('word_trends')
        .update({
          views: (existingTrend.views || 0) + 1,
          last_viewed: new Date().toISOString()
        })
        .eq('id', existingTrend.id);
    } else {
      // Insert new record with initial view count of 1
      await supabase
        .from('word_trends')
        .insert({
          word_id: wordData.id,
          views: 1,
          last_viewed: new Date().toISOString()
        });
    }
  } catch (error) {
    console.error('Error updating word view:', error);
  }
}