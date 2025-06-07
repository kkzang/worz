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
      console.error('Language data CSV fetch error:', error);
      return new Response('Error fetching language data', { status: 500 });
    }

    if (!wordsData || wordsData.length === 0) {
      return new Response('No language data found', { status: 404 });
    }

    // Create CSV header
    const headers = [
      'Word',
      'Category',
      'Definition',
      'Korean Translation',
      'Japanese Translation',
      'Bookmarks'
    ].join(',');

    // Format data rows
    const rows = wordsData.map((wordItem: any) => {
      // Extract translations
      const koTranslation = wordItem.word_translations?.find((t: any) => t.language === 'ko')?.translation || '번역 필요';
      const jaTranslation = wordItem.word_translations?.find((t: any) => t.language === 'ja')?.translation || '翻訳필요';
      
      return [
        `"${(wordItem.word || '').replace(/"/g, '""')}"`,
        `"${(wordItem.category || 'General').replace(/"/g, '""')}"`,
        `"${(wordItem.definition || '').replace(/"/g, '""')}"`,
        `"${koTranslation.replace(/"/g, '""')}"`,
        `"${jaTranslation.replace(/"/g, '""')}"`,
        wordItem.bookmarks || 0
      ].join(',');
    });

    // Combine header and rows
    const csvContent = [headers, ...rows].join('\n');

    // Add BOM for Excel compatibility
    const encoder = new TextEncoder();
    const buffer = encoder.encode('\ufeff' + csvContent);

    return new Response(buffer, {
      headers: {
        'Content-Type': 'text/csv;charset=utf-8',
        'Content-Disposition': 'attachment; filename="language-data.csv"',
        'Cache-Control': 'no-cache'
      }
    });
  } catch (error) {
    console.error('CSV export error:', error);
    return new Response('Error exporting language data as CSV', { status: 500 });
  }
}