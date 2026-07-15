-- Trigger creation for evidence AFTER INSERT
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_evidence_after_insert'
  ) THEN
    CREATE TRIGGER trg_evidence_after_insert
    AFTER INSERT ON evidence
    FOR EACH ROW
    EXECUTE FUNCTION core.process_evidence_trigger();
  END IF;
END
$$;
