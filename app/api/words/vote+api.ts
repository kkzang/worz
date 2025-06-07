import { supabase } from '@/utils/supabase';

export async function POST(request: Request) {
  try {
    const { wordId, voteType } = await request.json();
    
    // Get user from session
    const { data: { session }, error: authError } = await supabase.auth.getSession();
    if (authError) throw authError;
    
    if (!session?.user) {
      return new Response('Unauthorized', { status: 401 });
    }

    // Add or update vote
    const { data, error } = await supabase
      .from('word_votes')
      .upsert({
        word_id: wordId,
        user_id: session.user.id,
        vote_type: voteType
      })
      .select()
      .single();

    if (error) throw error;

    return Response.json(data);
  } catch (error) {
    console.error('Vote error:', error);
    return new Response('Error processing vote', { status: 500 });
  }
}