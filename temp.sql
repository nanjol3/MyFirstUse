-- 请注意: 此脚本需要超级用户权限执行
-- 将m910b的角色权限授予jtdt
GRANT m910b TO jtdt;

-- 创建一个函数来为每个数据库授予权限
CREATE OR REPLACE FUNCTION grant_privileges_to_jtdt() RETURNS void AS $$
DECLARE
    db_name TEXT;
BEGIN
    -- 遍历所有数据库
    FOR db_name IN (SELECT datname FROM pg_database WHERE datistemplate = false) LOOP
        -- 连接到数据库
        PERFORM dblink_connect('dbname=' || db_name);
        
        -- 授予数据库级别的权限
        PERFORM dblink_exec('GRANT ALL PRIVILEGES ON DATABASE ' || quote_ident(db_name) || ' TO jtdt');
        
        -- 授予所有现有模式的权限
        PERFORM dblink_exec('GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE ' || quote_ident(db_name) || ' TO jtdt');
        
        -- 授予所有现有表的权限
        PERFORM dblink_exec('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO jtdt');
        
        -- 为未来创建的对象设置默认权限
        PERFORM dblink_exec('ALTER DEFAULT PRIVILEGES FOR USER m910b IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO jtdt');
        PERFORM dblink_exec('ALTER DEFAULT PRIVILEGES FOR USER m910b IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO jtdt');
        PERFORM dblink_exec('ALTER DEFAULT PRIVILEGES FOR USER m910b IN SCHEMA public GRANT ALL PRIVILEGES ON FUNCTIONS TO jtdt');
        
        -- 断开连接
        PERFORM dblink_disconnect();
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 确保dblink扩展已安装
CREATE EXTENSION IF NOT EXISTS dblink;

-- 执行函数
SELECT grant_privileges_to_jtdt();

-- 刷新权限
REASSIGN OWNED BY m910b TO jtdt;

-- 清理：删除临时函数
DROP FUNCTION grant_privileges_to_jtdt();
