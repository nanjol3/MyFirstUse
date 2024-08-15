import psycopg2
from psycopg2 import sql

def connect_to_remote_db(host, database, user, password, port):
    try:
        connection = psycopg2.connect(
            host=host,
            database=database,
            user=user,
            password=password,
            port=port
        )
        print("成功连接到远程数据库")
        return connection
    except (Exception, psycopg2.Error) as error:
        print("连接到远程数据库时出错:", error)
        return None

def execute_query(connection, query, params=None):
    try:
        with connection.cursor() as cursor:
            if params:
                cursor.execute(query, params)
            else:
                cursor.execute(query)
            
            if cursor.description:
                return cursor.fetchall()
            else:
                connection.commit()
                return None
    except (Exception, psycopg2.Error) as error:
        print("执行查询时出错:", error)
        return None

# 数据库连接配置
db_config = {
    "host": "52.190.93.13",
    "port": 41011,
    "database": "mergeinto",
    "user": "jtdt",
    "password": "Gauss_234"
}

# 主程序
if __name__ == "__main__":
    # 连接到数据库
    conn = connect_to_remote_db(**db_config)
    
    if conn:
        try:
            # 执行示例查询，从mergeinto schema中选择一个表
            query = sql.SQL("SELECT * FROM {}.your_table LIMIT 5;").format(sql.Identifier('mergeinto'))
            results = execute_query(conn, query)
            
            if results:
                for row in results:
                    print(row)
            else:
                print("查询没有返回任何结果。")
            
        except (Exception, psycopg2.Error) as error:
            print("执行查询时出错:", error)
        
        finally:
            # 关闭数据库连接
            conn.close()
            print("数据库连接已关闭")
    else:
        print("无法建立数据库连接。")
