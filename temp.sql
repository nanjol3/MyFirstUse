-- 请注意: 此脚本需要超级用户权限执行

-- 将m910b的角色权限授予jtdt
GRANT m910b TO jtdt;

-- 创建一个函数来为每个数据库授予权限
CREATE OR REPLACE FUNCTION grant_privileges_to_jtdt() RETURNS void AS $$
DECLARE
    db_record RECORD;
BEGIN
    -- 遍历所有非模板数据库
    FOR db_record IN SELECT datname FROM pg_database WHERE datistemplate = false LOOP
        -- 授予连接权限
        EXECUTE format('GRANT CONNECT ON DATABASE %I TO jtdt', db_record.datname);
        
        -- 连接到数据库并执行授权操作
        PERFORM dblink_connect('dbname=' || quote_ident(db_record.datname));
        
        -- 授予所有模式的权限
        PERFORM dblink_exec(format('GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE %I TO jtdt', db_record.datname));
        
        -- 授予所有表的权限
        PERFORM dblink_exec('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO jtdt');
        
        -- 为未来创建的对象设置默认权限
        PERFORM dblink_exec('ALTER DEFAULT PRIVILEGES FOR USER m910b IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO jtdt');
        PERFORM dblink_exec('ALTER DEFAULT PRIVILEGES FOR USER m910b IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO jtdt');
        PERFORM dblink_exec('ALTER DEFAULT PRIVILEGES FOR USER m910b IN SCHEMA public GRANT ALL PRIVILEGES ON FUNCTIONS TO jtdt');
        
        -- 刷新权限
        PERFORM dblink_exec('REASSIGN OWNED BY m910b TO jtdt');
        
        -- 断开连接
        PERFORM dblink_disconnect();
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 确保dblink扩展已安装
CREATE EXTENSION IF NOT EXISTS dblink;

-- 执行函数
SELECT grant_privileges_to_jtdt();

-- 清理：删除临时函数
DROP FUNCTION grant_privileges_to_jtdt();
