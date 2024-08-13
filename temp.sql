import pandas as pd
import re

def extract_table_names(query):
    # 将查询转换为小写以简化处理
    query = query.lower()
    
    # 复杂的正则表达式模式
    patterns = [
        # FROM, JOIN 子句
        r'(?:from|join)\s+(\w+(?:\.\w+)?(?:\s+(?:as\s+)?\w+)?)',
        # INSERT INTO, UPDATE, DELETE FROM 语句
        r'(?:insert\s+into|update|delete\s+from)\s+(\w+(?:\.\w+)?)',
        # CREATE, ALTER, DROP TABLE 语句
        r'(?:create|alter|drop)\s+table\s+(\w+(?:\.\w+)?)',
        # TRUNCATE 语句
        r'truncate\s+(?:table\s+)?(\w+(?:\.\w+)?)',
        # VACUUM, ANALYZE, CLUSTER, REINDEX 语句 (PostgreSQL 特定)
        r'(?:vacuum\s+(?:full\s+)?|analyze\s+|cluster\s+|reindex\s+table\s+)(\w+(?:\.\w+)?)',
        # WITH 子句 (CTE)
        r'with\s+(\w+(?:\.\w+)?)\s+(?:as\s+)?\(',
        # table(column) 形式, 通常在INSERT语句中使用
        r'(\w+(?:\.\w+)?)\s*\([^\)]*\)',
    ]
    
    tables = set()
    for pattern in patterns:
        matches = re.findall(pattern, query)
        for match in matches:
            # 清理表名（去除可能的别名和额外的空格）
            table = re.split(r'\s+', match.strip())[0]
            # 移除可能的引号
            table = table.strip('"\'`')
            tables.add(table)
    
    return list(tables)

# 假设你的DataFrame名为df，并且有一个'query'列
data = {
    'query': [
        'SELECT * FROM table1 JOIN table2 ON table1.id = table2.id',
        'INSERT INTO table3 (col1, col2) SELECT * FROM table4',
        'WITH cte AS (SELECT * FROM table5) SELECT * FROM cte JOIN table6',
        'UPDATE table7 SET col = val WHERE id IN (SELECT id FROM table8)',
        'VACUUM FULL table9',
        'ANALYZE table10',
        'CLUSTER table11 USING index_name',
        'REINDEX TABLE table12',
        'CREATE TABLE new_table AS SELECT * FROM old_table',
        'ALTER TABLE table13 ADD COLUMN new_col INT',
        'DROP TABLE IF EXISTS table14',
        'TRUNCATE table15',
        'DELETE FROM table16 WHERE condition',
        'WITH RECURSIVE cte (n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM cte WHERE n < 5) SELECT * FROM cte'
    ]
}
df = pd.DataFrame(data)

# 应用函数到DataFrame
df['tables'] = df['query'].apply(extract_table_names)

# 显示结果
print(df)

# 如果你想要将列表转换为字符串，可以使用：
# df['tables'] = df['tables'].apply(lambda x: ', '.join(x) if x else '')
