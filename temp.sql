-- transfer_permissions.sql

-- 创建jtdt用户（如果不存在）
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'jtdt') THEN
    CREATE USER jtdt WITH PASSWORD 'secure_password';
  END IF;
END
$$;

-- 复制m910b的角色属性
DO $$
DECLARE
    m910b_attrs record;
BEGIN
    SELECT * INTO m910b_attrs FROM pg_authid WHERE rolname = 'm910b';
    
    EXECUTE format('ALTER USER jtdt WITH %s %s %s %s %s %s %s %s',
        CASE WHEN m910b_attrs.rolsuper THEN 'SUPERUSER' ELSE 'NOSUPERUSER' END,
        CASE WHEN m910b_attrs.rolinherit THEN 'INHERIT' ELSE 'NOINHERIT' END,
        CASE WHEN m910b_attrs.rolcreaterole THEN 'CREATEROLE' ELSE 'NOCREATEROLE' END,
        CASE WHEN m910b_attrs.rolcreatedb THEN 'CREATEDB' ELSE 'NOCREATEDB' END,
        CASE WHEN m910b_attrs.rolcanlogin THEN 'LOGIN' ELSE 'NOLOGIN' END,
        CASE WHEN m910b_attrs.rolreplication THEN 'REPLICATION' ELSE 'NOREPLICATION' END,
        CASE WHEN m910b_attrs.rolbypassrls THEN 'BYPASSRLS' ELSE 'NOBYPASSRLS' END,
        CASE WHEN m910b_attrs.rolconnlimit >= 0 THEN 'CONNECTION LIMIT ' || m910b_attrs.rolconnlimit::text ELSE '' END
    );
END $$;

-- 复制数据库级别的权限
DO $$
DECLARE
    db record;
BEGIN
    FOR db IN SELECT datname FROM pg_database WHERE datname NOT IN ('template0', 'template1', 'postgres')
    LOOP
        EXECUTE format('GRANT ALL PRIVILEGES ON DATABASE %I TO jtdt', db.datname);
    END LOOP;
END $$;

-- 复制模式级别和对象级别的权限
DO $$
DECLARE
    schema_name text;
    obj record;
BEGIN
    FOR schema_name IN SELECT nspname FROM pg_namespace WHERE nspname NOT LIKE 'pg_%' AND nspname != 'information_schema'
    LOOP
        -- 授予模式使用权限
        EXECUTE format('GRANT USAGE ON SCHEMA %I TO jtdt', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON SCHEMA %I TO jtdt', schema_name);
        
        -- 授予模式中所有表的权限
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I TO jtdt', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO jtdt', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA %I TO jtdt', schema_name);
        
        -- 设置未来对象的默认权限
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL PRIVILEGES ON TABLES TO jtdt', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL PRIVILEGES ON SEQUENCES TO jtdt', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL PRIVILEGES ON FUNCTIONS TO jtdt', schema_name);
    END LOOP;
END $$;

-- 将jtdt添加到m910b所属的所有角色中
DO $$
DECLARE
    role_name text;
BEGIN
    FOR role_name IN SELECT r.rolname
                     FROM pg_auth_members m
                     JOIN pg_roles r ON (m.roleid = r.oid)
                     WHERE m.member = (SELECT oid FROM pg_roles WHERE rolname = 'm910b')
    LOOP
        EXECUTE format('GRANT %I TO jtdt', role_name);
    END LOOP;
END $$;

-- 复制表的所有权（如果需要）
DO $$
DECLARE
    obj record;
BEGIN
    FOR obj IN SELECT schemaname, tablename 
               FROM pg_tables 
               WHERE tableowner = 'm910b'
    LOOP
        EXECUTE format('ALTER TABLE %I.%I OWNER TO jtdt', obj.schemaname, obj.tablename);
    END LOOP;
END $$;

-- 复制序列的所有权（如果需要）
DO $$
DECLARE
    obj record;
BEGIN
    FOR obj IN SELECT schemaname, sequencename 
               FROM pg_sequences 
               WHERE sequenceowner = 'm910b'
    LOOP
        EXECUTE format('ALTER SEQUENCE %I.%I OWNER TO jtdt', obj.schemaname, obj.sequencename);
    END LOOP;
END $$;

-- 复制函数的所有权（如果需要）
DO $$
DECLARE
    obj record;
BEGIN
    FOR obj IN SELECT n.nspname as schema_name, p.proname as function_name, pg_get_function_identity_arguments(p.oid) as args
               FROM pg_proc p
               JOIN pg_namespace n ON p.pronamespace = n.oid
               WHERE p.proowner = (SELECT oid FROM pg_roles WHERE rolname = 'm910b')
    LOOP
        EXECUTE format('ALTER FUNCTION %I.%I(%s) OWNER TO jtdt', obj.schema_name, obj.function_name, obj.args);
    END LOOP;
END $$;

-- 提示完成
DO $$
BEGIN
    RAISE NOTICE 'Permission transfer from m910b to jtdt completed.';
END $$;
