-- Migration 002: seeds (levels, achievements, sample skills) and additional indexes

-- Ensure pgcrypto for gen_random_uuid (if not enabled earlier)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Seeds: Levels
INSERT INTO levels (level_number, xp_required, title, reward)
VALUES
  (1, 0, 'Novice', 'Badge: Novice'),
  (2, 100, 'Apprentice', 'Badge: Apprentice'),
  (3, 300, 'Adept', 'Badge: Adept'),
  (4, 700, 'Expert', 'Badge: Expert'),
  (5, 1500, 'Master', 'Badge: Master')
ON CONFLICT (level_number) DO NOTHING;

-- Seeds: Achievements (small sample)
INSERT INTO achievements (id, name, description, icon, category, xp_reward, badge_color)
VALUES
  (gen_random_uuid(), 'First Steps', 'Complete your first assessment', 'trophy', 'onboarding', 50, '#FFD700'),
  (gen_random_uuid(), 'Consistency', 'Complete missions for 7 consecutive days', 'calendar', 'engagement', 200, '#00BFFF'),
  (gen_random_uuid(), 'High Achiever', 'Reach top 10% in a game', 'star', 'performance', 500, '#FF69B4')
ON CONFLICT DO NOTHING;

-- Seeds: Sample Skills
INSERT INTO skills (id, name, category, description, difficulty)
VALUES
  (gen_random_uuid(), 'Logical Thinking', 'Cognitive', 'Ability to reason and solve problems logically', 3),
  (gen_random_uuid(), 'Memory', 'Cognitive', 'Short and long term memory performance', 2),
  (gen_random_uuid(), 'Focus', 'Cognitive', 'Ability to maintain attention and concentrate', 2),
  (gen_random_uuid(), 'Creativity', 'Cognitive', 'Fluency and originality of ideas', 4)
ON CONFLICT DO NOTHING;

-- Additional indexes to support queries
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor_id ON audit_logs(actor_id);

-- GIN indexes already created in migration 001 for JSONB fields; add any missing ones
CREATE INDEX IF NOT EXISTS idx_reports_recommendations_gin ON reports USING gin (recommendations);

-- VACUUM / ANALYZE recommendation (not executed here)
-- Run: VACUUM ANALYZE; after large migrations in production
