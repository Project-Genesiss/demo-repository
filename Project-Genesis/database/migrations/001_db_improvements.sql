-- DB migration: indexes, constraints, triggers, and versioned reports

-- 1) Create indexes
CREATE INDEX IF NOT EXISTS idx_skill_scores_user_id ON skill_scores(user_id);
CREATE INDEX IF NOT EXISTS idx_skill_scores_skill_id ON skill_scores(skill_id);
CREATE INDEX IF NOT EXISTS idx_questions_assessment_id ON questions(assessment_id);
CREATE INDEX IF NOT EXISTS idx_answers_user_id ON answers(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON reports(user_id);
CREATE INDEX IF NOT EXISTS idx_game_sessions_user_id ON game_sessions(user_id);

-- GIN indexes for JSONB
CREATE INDEX IF NOT EXISTS idx_questions_options_gin ON questions USING gin (options);
CREATE INDEX IF NOT EXISTS idx_reports_recommendations_gin ON reports USING gin (recommendations);

-- 2) Add unique constraints and checks if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'unique_user_skill'
  ) THEN
    ALTER TABLE skill_scores ADD CONSTRAINT unique_user_skill UNIQUE (user_id, skill_id);
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'unique_level_number'
  ) THEN
    ALTER TABLE levels ADD CONSTRAINT unique_level_number UNIQUE (level_number);
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_difficulty_range'
  ) THEN
    ALTER TABLE skills ADD CONSTRAINT chk_difficulty_range CHECK (difficulty >= 1 AND difficulty <= 10);
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_skill_scores_score_range'
  ) THEN
    ALTER TABLE skill_scores ADD CONSTRAINT chk_skill_scores_score_range CHECK (score >= 0 AND score <= 100);
  END IF;
END$$;

-- 3) Create reports_history table for versioned reports
CREATE TABLE IF NOT EXISTS reports_history (
  id uuid primary key default gen_random_uuid(),
  report_id uuid not null references reports(id) on delete cascade,
  version integer not null,
  overall_score numeric,
  confidence_score numeric,
  summary text,
  recommendations jsonb,
  created_at timestamptz default now(),
  source_evidence jsonb
);

-- 4) set_updated_at function and triggers for tables that have updated_at
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'set_updated_at') THEN
    CREATE OR REPLACE FUNCTION set_updated_at()
    RETURNS trigger AS $$
    BEGIN
      NEW.updated_at = now();
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
  END IF;
END$$;

-- Create triggers for profiles and skill_scores if updated_at exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='updated_at') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_profiles_set_updated_at') THEN
      CREATE TRIGGER trg_profiles_set_updated_at
      BEFORE UPDATE ON profiles
      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
    END IF;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='skill_scores' AND column_name='updated_at') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_skill_scores_set_updated_at') THEN
      CREATE TRIGGER trg_skill_scores_set_updated_at
      BEFORE UPDATE ON skill_scores
      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
    END IF;
  END IF;
END$$;

-- 5) Example Row Level Security (RLS) policy templates (do NOT enable automatically)
-- These are templates to apply when deploying to Supabase. Use ENABLE ROW LEVEL SECURITY; then create policies.

-- Example: allow users to read/write their own profiles
-- CREATE POLICY "profiles_owner" ON profiles
-- FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 6) Notes: consider running VACUUM/ANALYZE after large migrations to refresh planner stats

-- End of migration
