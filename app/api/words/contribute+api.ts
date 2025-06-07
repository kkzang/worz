import { supabase } from '@/utils/supabase';

export async function POST(request: Request) {
  try {
    const { word, type, content } = await request.json();
    
    // Get user from session
    const { data: { session }, error: authError } = await supabase.auth.getSession();
    if (authError) throw authError;
    
    if (!session?.user) {
      return new Response('Unauthorized', { status: 401 });
    }

    // Add contribution
    const { data, error } = await supabase
      .from('word_contributions')
      .insert({
        word_id: word.id,
        contributor_id: session.user.id,
        contribution_type: type,
        content: content
      })
      .select()
      .single();

    if (error) throw error;

    return Response.json(data);
  } catch (error) {
    console.error('Contribution error:', error);
    return new Response('Error processing contribution', { status: 500 });
  }
}