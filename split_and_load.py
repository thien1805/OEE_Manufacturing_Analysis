import pandas as pd
import duckdb

# 1. Đọc file Excel gốc
file_path = '/Users/thienngocpham/Downloads/OEE Manufacturing Report.xlsx'
xls = pd.ExcelFile(file_path)

# 2. Khởi tạo và kết nối file database DuckDB cục bộ
con = duckdb.connect('my_factory.duckdb')

# Tạo schema thô 'bronze'
con.execute("CREATE SCHEMA IF NOT EXISTS bronze;")

print(f"Bắt đầu xử lý {len(xls.sheet_names)} sheets...")

# 3. Lặp qua từng sheet, xuất file Excel riêng và đẩy vào DuckDB
for sheet in xls.sheet_names:
    print(f"\nĐang xử lý sheet: {sheet}")
    
    # Đọc dữ liệu từ sheet vào DataFrame
    df = pd.read_excel(file_path, sheet_name=sheet)
    
    # --- YÊU CẦU 1: TÁCH RA FILE EXCEL RIÊNG LẺ ---
    # Đặt tên file theo tên sheet (VD: Fact.xlsx)
    output_excel = f"{sheet}.xlsx" 
    df.to_excel(output_excel, index=False)
    print(f"  -> ✅ Đã lưu file Excel mới: {output_excel}")
    
    # --- YÊU CẦU 2: ĐẨY DỮ LIỆU LÊN DUCKDB ---
    # Làm sạch tên bảng: chuyển chữ thường, thay khoảng trắng bằng dấu gạch dưới
    table_name = sheet.lower().replace(' ', '_')
    
    # Đẩy trực tiếp DataFrame vào DuckDB
    con.execute(f"CREATE OR REPLACE TABLE bronze.{table_name} AS SELECT * FROM df")
    print(f"  -> ✅ Đã nạp vào DuckDB: bronze.{table_name}")

# 4. Kiểm tra thành quả
print("\n--- DANH SÁCH BẢNG TRONG DUCKDB ---")
tables = con.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'bronze';").df()
print(tables)

con.close()
print("\nHoàn tất quy trình!")