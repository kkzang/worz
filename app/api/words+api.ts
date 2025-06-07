import { WordData, RelatedWord } from '@/types/wordTypes';
import { getWordData, addWordToDatabase } from '@/utils/wordUtils';

export async function GET(request: Request) {
  const url = new URL(request.url);
  const word = url.searchParams.get('word');

  if (!word) {
    return new Response('Word parameter is required', { status: 400 });
  }

  try {
    const wordData = await getWordData(word.toLowerCase());
    return Response.json(wordData);
  } catch (error) {
    console.error('Error in GET /api/words:', error);
    return new Response('Error fetching word data', { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { word, type, description, translations, baseWord } = body;

    if (!word || !type || !baseWord) {
      return new Response('Missing required fields', { status: 400 });
    }

    await addWordToDatabase(word.toLowerCase(), {
      type,
      description,
      baseWord: baseWord.toLowerCase(),
      translations
    });

    const updatedWordData = await getWordData(baseWord.toLowerCase());
    return Response.json(updatedWordData);
  } catch (error) {
    console.error('Error in POST /api/words:', error);
    return new Response('Error processing request', { status: 500 });
  }
}