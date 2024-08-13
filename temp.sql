CREATE OR REPLACE FUNCTION get_all_tables()
RETURNS TABLE (database_name TEXT, schema_name TEXT, table_name TEXT) AS $$
DECLARE
    db_name TEXT;
BEGIN
    FOR db_name IN 
        SELECT datname 
        FROM pg_database 
        WHERE datistemplate = false AND datname != 'postgres'
    LOOP
        RETURN QUERY
        EXECUTE format('
            SELECT %L::TEXT AS database_name, table_schema::TEXT, table_name::TEXT
            FROM information_schema.tables
            WHERE table_schema NOT IN (''pg_catalog'', ''information_schema'')
              AND table_schema NOT LIKE ''pg_toast%%''
              AND table_type = ''BASE TABLE''
        ', db_name);
    END LOOP;
END;
$$ LANGUAGE plpgsql;