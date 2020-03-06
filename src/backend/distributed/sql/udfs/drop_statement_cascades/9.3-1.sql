CREATE OR REPLACE FUNCTION drop_statement_cascades(
    pg_ddl_command)
    RETURNS BOOL
    LANGUAGE C STRICT
    AS 'MODULE_PATHNAME', $$drop_statement_cascades$$;

COMMENT ON FUNCTION pg_catalog.drop_statement_cascades(
    pg_ddl_command)
    IS 'returns true if the given statement is a DropStmt with CASCADE behaviour';
