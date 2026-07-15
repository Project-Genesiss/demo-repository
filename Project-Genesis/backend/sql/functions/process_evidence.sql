-- Create schema 'core' and process_evidence functions

CREATE SCHEMA IF NOT EXISTS core;

-- process_evidence: aggregates evidence for a given skill and user, computes score/confidence, upserts into skill_scores,
-- writes snapshot to skill_history, and updates/creates brain_profiles.summary entry for the skill.

CREATE OR REPLACE FUNCTION core.process_evidence(evidence_uuid uuid) RETURNS void LANGUAGE plpgsql AS $$
DECLARE
  ev RECORD;
  total_weight numeric;
  avg_quality numeric;
  evidence_count int;
  new_score numeric;
  new_confidence numeric;
BEGIN
  -- Load evidence row
  SELECT * INTO ev FROM evidence WHERE id = evidence_uuid;
  IF NOT FOUND THEN
    RAISE NOTICE 'process_evidence: evidence % not found', evidence_uuid;
    RETURN;
  END IF;

  IF ev.skill_id IS NULL THEN
    -- Nothing to update if evidence is not linked to a skill
    RAISE NOTICE 'process_evidence: evidence % has no skill_id, skipping', evidence_uuid;
    RETURN;
  END IF;

  -- Aggregate user's evidence for this skill
  SELECT COALESCE(SUM(weight),0), COALESCE(AVG(quality),1), COUNT(*)
    INTO total_weight, avg_quality, evidence_count
  FROM evidence
  WHERE user_id = ev.user_id AND skill_id = ev.skill_id;

  IF total_weight = 0 THEN
    RETURN;
  END IF;

  -- Simple score calculation (tune this later)
  -- Example: scale total_weight*avg_quality into 0..100
  new_score := LEAST(100, (total_weight * avg_quality) * 10);
  -- Confidence as function of evidence count & avg_quality (0..100)
  new_confidence := LEAST(100, evidence_count * avg_quality * 10);

  -- Upsert into skill_scores (requires unique constraint on user_id,skill_id)
  INSERT INTO skill_scores (id, user_id, skill_id, score, confidence, trend, updated_at)
  VALUES (gen_random_uuid(), ev.user_id, ev.skill_id, new_score, new_confidence, 0, now())
  ON CONFLICT (user_id, skill_id) DO UPDATE
    SET score = EXCLUDED.score,
        confidence = EXCLUDED.confidence,
        trend = (EXCLUDED.score - skill_scores.score),
        updated_at = now();

  -- Insert snapshot into skill_history
  INSERT INTO skill_history (id, user_id, skill_id, score, confidence, xp, evidence_count, created_at)
  VALUES (gen_random_uuid(), ev.user_id, ev.skill_id, new_score, new_confidence, 0, evidence_count, now());

  -- Update brain_profiles.summary for the skill: set or merge entry by skill id (as text key)
  -- If row exists update, otherwise create new row
  UPDATE brain_profiles
  SET summary = jsonb_set(
      COALESCE(summary, '{}'::jsonb),
      ARRAY[ev.skill_id::text],
      to_jsonb(jsonb_build_object(
        'current', new_score,
        'confidence', new_confidence,
        'evidence_count', evidence_count,
        'last_updated', now()
      )),
      true
    ),
    last_updated = now()
  WHERE user_id = ev.user_id;

  IF NOT FOUND THEN
    INSERT INTO brain_profiles (user_id, summary, last_updated)
    VALUES (ev.user_id,
      jsonb_build_object(ev.skill_id::text,
        jsonb_build_object('current', new_score, 'confidence', new_confidence, 'evidence_count', evidence_count, 'last_updated', now())
      ), now())
    ON CONFLICT (user_id) DO NOTHING;
  END IF;

END;
$$;

-- Trigger wrapper to call core.process_evidence for NEW rows
CREATE OR REPLACE FUNCTION core.process_evidence_trigger() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM core.process_evidence(NEW.id);
  RETURN NEW;
END;
$$;
