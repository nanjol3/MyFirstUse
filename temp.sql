import pandas as pd
import re

def extract_table_names(query):
    # 转换查询为小写以简化处理
    query = query.lower()
    
    # 正则表达式模式
    patterns = [
        # FROM 子句
        r'(?:from|join)\s+(\w+(?:\.\w+)?(?:\s+(?:as\s+)?\w+)?)',
        # WITH 子句
        r'with\s+(\w+(?:\.\w+)?(?:\s+(?:as\s+)?\w+)?)',
        # INSERT INTO 语句
        r'insert\s+into\s+(\w+(?:\.\w+)?)',
        # UPDATE 语句
        r'update\s+(\w+(?:\.\w+)?)',
        # DELETE FROM 语句
        r'delete\s+from\s+(\w+(?:\.\w+)?)',
        # TRUNCATE 语句
        r'truncate\s+(?:table\s+)?(\w+(?:\.\w+)?)',
        # CREATE TABLE 语句
        r'create\s+table\s+(\w+(?:\.\w+)?)',
        # ALTER TABLE 语句
        r'alter\s+table\s+(\w+(?:\.\w+)?)',
        # DROP TABLE 语句
        r'drop\s+table\s+(\w+(?:\.\w+)?)'
    ]
    
    tables = set()
    for pattern in patterns:
        matches = re.findall(pattern, query)
        for match in matches:
            # 清理表名（去除可能的别名）
            table = re.split(r'\s+', match.strip())[0]
            tables.add(table)
    
    return list(tables)

# 假设你的DataFrame名为df，并且有一个'query'列
df['tables'] = df['query'].apply(extract_table_names)

# 如果你想要将列表转换为字符串，可以使用：
# df['tables'] = df['tables'].apply(lambda x: ', '.join(x) if x else '')

# 显示结果
print(df[['query', 'tables']])
