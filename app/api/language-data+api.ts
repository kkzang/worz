import { supabase } from '@/utils/supabase';

export async function GET(request: Request) {
  try {
    // Get all words with their translations
    const { data: wordsData, error } = await supabase
      .from('words')
      .select(`
        word,
        category,
        definition,
        bookmarks,
        word_translations(language, translation)
      `)
      .order('word');

    if (error) {
      console.error('Language data fetch error:', error);
      return new Response('Error fetching language data', { status: 500 });
    }

    if (!wordsData || wordsData.length === 0) {
      return new Response('No language data found', { status: 404 });
    }

    // Format the data for easy consumption
    const formattedData = wordsData.map((wordItem: any) => {
      // Extract translations
      const koTranslation = wordItem.word_translations?.find((t: any) => t.language === 'ko')?.translation || '번역 필요';
      const jaTranslation = wordItem.word_translations?.find((t: any) => t.language === 'ja')?.translation || '翻訳필요';
      
      return {
        word: wordItem.word,
        category: wordItem.category || 'General',
        definition: wordItem.definition || `Definition for ${wordItem.word}`,
        bookmarks: wordItem.bookmarks || 0,
        translations: {
          korean: koTranslation,
          japanese: jaTranslation
        }
      };
    });

    return Response.json({
      success: true,
      count: formattedData.length,
      data: formattedData
    }, {
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache'
      }
    });
  } catch (error) {
    console.error('Language data API error:', error);
    return new Response('Internal server error', { status: 500 });
  }
}