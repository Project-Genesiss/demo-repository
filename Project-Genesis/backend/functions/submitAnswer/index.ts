// Edge function template: submitAnswer
// This is a minimal Node/TypeScript example using @supabase/supabase-js to insert evidence.
// Adapt to your environment (Supabase Edge Functions, Vercel Serverless, or any Node server).

import { createClient } from '@supabase/supabase-js';
import type { Request, Response } from 'express';

// Ensure environment variables are set (SERVICE_KEY must be a service_role key with write access)
const SUPABASE_URL = process.env.SUPABASE_URL as string;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY as string;

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables');
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
  auth: { persistSession: false }
});

// Express-style handler example
export default async function handler(req: Request, res: Response) {
  try {
    if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

    const body = req.body;
    const {
      user_id,
      evidence_type,
      source_id = null,
      skill_id = null,
      weight = 1.0,
      quality = 1.0,
      metadata = {}
    } = body;

    if (!user_id || !evidence_type) {
      return res.status(400).json({ error: 'user_id and evidence_type are required' });
    }

    const payload = {
      user_id,
      evidence_type,
      source_id,
      skill_id,
      weight,
      quality,
      metadata
    };

    const { data, error } = await supabase
      .from('evidence')
      .insert([payload])
      .select('id')
      .single();

    if (error) {
      console.error('Supabase insert error:', error);
      return res.status(500).json({ error: error.message });
    }

    // Return inserted evidence id (processing is done via DB trigger)
    return res.status(200).json({ success: true, evidence_id: data.id });
  } catch (err: any) {
    console.error('submitAnswer handler error:', err);
    return res.status(500).json({ error: err.message || 'internal_error' });
  }
}
