SubmitAnswer Edge Function (example)

Purpose
- Provides a minimal HTTP endpoint to insert an evidence row into the DB.
- The DB trigger (core.process_evidence_trigger) runs after insert and updates skill scores.

Environment variables required
- SUPABASE_URL: https://xyz.supabase.co
- SUPABASE_SERVICE_KEY: service_role key with write access

Example curl
curl -X POST $ENDPOINT \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "<user-uuid>",
    "evidence_type": "answer",
    "source_id": "<question-answer-id>",
    "skill_id": "<skill-uuid>",
    "weight": 1.2,
    "quality": 0.9,
    "metadata": {"answer":"B","time_taken":12}
  }'

Notes
- This is a template. For Supabase Edge Functions (Deno) or Vercel adapt the handler signature accordingly.
- The function uses a service role key; keep it secret and run this function server-side.
