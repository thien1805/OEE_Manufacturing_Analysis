import duckdb
import pandas as pd

# Thiết lập hiển thị đầy đủ tất cả các cột
pd.set_option('display.max_columns', None)
pd.set_option('display.width', 1000)

def execute_query(sql_file='query.sql'):
    with open(sql_file, 'r', encoding='utf-8') as f:
        query = f.read()
        
    con = duckdb.connect('my_factory.duckdb', read_only=True)
    df = con.execute(query).df()
    con.close()
    
    print("\n" + "=" * 90)
    print("📊 KẾT QUẢ TRUY VẤN DỮ LIỆU (DUCKDB)")
    print("=" * 90)
    print(df.to_string(index=False))
    print("=" * 90 + "\n")

if __name__ == '__main__':
    execute_query()
