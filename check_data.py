import duckdb

# Kết nối đến file database DuckDB (chế độ chỉ đọc read_only=True để tránh lock file)
con = duckdb.connect('my_factory.duckdb', read_only=True)

# Danh sách các schema cần kiểm tra
schemas_to_check = ['bronze', 'silver', 'gold']

for schema in schemas_to_check:
    tables = con.execute(f"SELECT table_name, table_type FROM information_schema.tables WHERE table_schema = '{schema}';").fetchall()
    if not tables:
        continue
        
    print("\n" + "=" * 60)
    print(f"📌 TỔNG QUAN SCHEMA: '{schema.upper()}'")
    print("=" * 60)
    
    for table_name, table_type in tables:
        full_table_name = f"{schema}.{table_name}"
        count = con.execute(f"SELECT COUNT(*) FROM {full_table_name}").fetchone()[0]
        
        print(f"\n🔹 {table_type}: {full_table_name} (Tổng số dòng: {count:,})")
        print("-" * 50)
        preview_df = con.execute(f"SELECT * FROM {full_table_name} LIMIT 5").df()
        print(preview_df)

con.close()
