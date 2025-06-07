import { supabase } from '@/utils/supabase';

export async function GET(request: Request) {
  try {
    // Get all words with their translations and relationships
    const { data: wordsData, error } = await supabase
      .from('words')
      .select(`
        word,
        category,
        definition,
        bookmarks,
        word_translations(language, translation),
        word_relationships!source_word_id(
          relationship_type,
          description,
          target_word:words!target_word_id(word)
        )
      `)
      .order('word');

    if (error) {
      console.error('Export error:', error);
      return new Response('Error exporting database', { status: 500 });
    }

    if (!wordsData || wordsData.length === 0) {
      return new Response('No data to export', { status: 404 });
    }

    // Create CSV header
    const headers = [
      'Word',
      'Category',
      'Definition',
      'Korean Translation',
      'Japanese Translation',
      'Bookmarks',
      'Related Words',
      'Relationship Types',
      'Related Descriptions'
    ].join(',');

    // Format data rows
    const rows = wordsData.map((wordItem: any) => {
      // Extract translations
      const koTranslation = wordItem.word_translations?.find((t: any) => t.language === 'ko')?.translation || '';
      const jaTranslation = wordItem.word_translations?.find((t: any) => t.language === 'ja')?.translation || '';
      
      // Extract related words data - handle the nested structure properly
      const relatedWords = wordItem.word_relationships
        ?.map((rel: any) => rel.target_word?.word)
        .filter(Boolean)
        .join('|') || '';
      
      const relationshipTypes = wordItem.word_relationships
        ?.map((rel: any) => rel.relationship_type)
        .filter(Boolean)
        .join('|') || '';
      
      // Handle description field safely
      const relatedDescriptions = wordItem.word_relationships
        ?.map((rel: any) => rel.description || '')
        .filter(desc => desc !== '')
        .join('|') || '';

      return [
        wordItem.word || '',
        wordItem.category || '',
        (wordItem.definition || '').replace(/,/g, ';').replace(/"/g, '""'),
        koTranslation,
        jaTranslation,
        wordItem.bookmarks || 0,
        relatedWords,
        relationshipTypes,
        relatedDescriptions.replace(/,/g, ';').replace(/"/g, '""')
      ].map(field => `"${String(field)}"`).join(',');
    });

    // Combine header and rows
    const csvContent = [headers, ...rows].join('\n');

    // Add BOM for Excel compatibility
    const encoder = new TextEncoder();
    const buffer = encoder.encode('\ufeff' + csvContent);

    return new Response(buffer, {
      headers: {
        'Content-Type': 'text/csv;charset=utf-8',
        'Content-Disposition': 'attachment; filename="word-database.csv"',
        'Cache-Control': 'no-cache'
      }
    });
  } catch (error) {
    console.error('Export error:', error);
    return new Response('Error exporting database', { status: 500 });
  }
}