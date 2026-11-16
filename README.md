# OEE Manufacturing Analysis

Dự án phân tích và tối ưu hóa chỉ số **OEE (Overall Equipment Effectiveness)** cho dây chuyền sản xuất nhà máy bánh quy (Grandma Edna), áp dụng kiến trúc **Medallion Architecture (Bronze - Silver - Gold)** kết hợp **Star Schema** với **DuckDB** và **dbt**.

---

## 🎯 Mục tiêu dự án

- **Đo lường OEE**: Tính toán chính xác 3 trụ cột Availability (A), Performance (P), Quality (Q) và chỉ số OEE tổng thể theo từng máy, sản phẩm và ca sản xuất.
- **Phân tích nguyên nhân (Root Cause Analysis)**: Xác định nguyên nhân gây downtime, lãng phí tốc độ và tỷ lệ phế phẩm (scrap).
- **Hỗ trợ ra quyết định**: Cung cấp bộ 10 truy vấn SQL chuyên sâu giải quyết các bài toán vận hành thực tế.

---

## 🛠 Công nghệ sử dụng (Tech Stack)

- **Storage / Warehouse**: [DuckDB](https://duckdb.org/) (In-process OLAP Database tốc độ cao)
- **Transformation**: [dbt-core](https://www.getdbt.com/) & `dbt-duckdb`
- **Data Ingestion & Scripts**: Python (`pandas`, `openpyxl`, `duckdb`)
- **Reporting & Specs**: SQL, Excel, Dashboard Wireframe / Documentation

---

## 🏗 Kiến trúc dữ liệu (Data Pipeline)

```
[ Excel Data Source ] 
        │
        ▼ (split_and_load.py)
[ Bronze Layer ]  ──> bronze.fact, bronze.machine, bronze.product, bronze.target_speeds
        │
        ▼ (dbt staging - silver views)
[ Silver Layer ]  ──> stg_fact, stg_machine, stg_product, stg_target_speeds
        │
        ▼ (dbt marts - gold tables)
[ Gold Layer ]    ──> Star Schema:
                      • Dimensions: dim_machine, dim_product, dim_date
                      • Facts: fct_daily_oee, fct_production_runs
```

---

## 📁 Cấu trúc thư mục

```text
├── docs/                 # Tài liệu kiến trúc, pipeline lineage và dashboard specs
├── excel/                # Dữ liệu mẫu và báo cáo phân tích Excel
├── models/
│   ├── staging/          # Silver layer: làm sạch, khử trùng lặp, chuẩn hóa
│   └── marts/            # Gold layer: Fact & Dimension tables (Star Schema)
├── query/                # 10 câu truy vấn SQL phân tích chuyên sâu (Q1 -> Q10)
├── check_data.py         # Script kiểm tra dữ liệu trong DuckDB
├── dbt_project.yml       # Cấu hình dbt project
├── profiles.yml          # Cấu hình kết nối dbt DuckDB
├── requirements.txt      # Thư viện Python cần thiết
├── run_query.py          # Script chạy nhanh truy vấn SQL
└── split_and_load.py     # Script đọc file Excel và nạp vào tầng Bronze
```

---

## 🚀 Hướng dẫn cài đặt & Khởi chạy

### 1. Cài đặt môi trường

```bash
# Tạo và kích hoạt virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Cài đặt các thư viện cần thiết
pip install -r requirements.txt
```

### 2. Nạp dữ liệu nguồn vào DuckDB (Bronze)

```bash
python split_and_load.py
```

### 3. Xây dựng Data Models với dbt (Silver & Gold)

```bash
# Kiểm tra kết nối dbt
dbt debug

# Chạy build toàn bộ model (staging views & mart tables)
dbt run

# Kiểm tra tính toàn vẹn dữ liệu
dbt test
```

### 4. Chạy truy vấn phân tích

Thực thi các script SQL trong thư mục `query/` trực tiếp trên DuckDB hoặc sử dụng script helper:

```bash
python run_query.py
```

### 5. Khởi chạy Web Dashboard (Evidence.dev)

Dự án tích hợp sẵn web dashboard tương tác xây dựng bằng **Evidence.dev** kết nối trực tiếp đến DuckDB Gold Marts:

```bash
cd dashboard

# Trích xuất dữ liệu từ DuckDB sang Evidence
npm run sources

# Khởi chạy local dev server
npm run dev
```

Mở trình duyệt tại `http://localhost:3000` để xem báo cáo trực quan gồm:
- **Thẻ KPI điều hành**: OEE toàn nhà máy, Availability, Performance, Quality.
- **Biểu đồ xu hướng OEE**: Biến thiên các trụ cột theo từng ngày.
- **Phân tích tổn thất dừng máy (Downtime)**: Biểu đồ nguyên nhân sự cố và thời gian dừng.
- **Ma trận thiết bị & chất lượng sản phẩm**: Bảng xếp hạng máy và tỷ lệ phế phẩm theo sản phẩm.

---

## 📊 10 Câu hỏi phân tích trọng tâm (`query/`)

- **Q1 - Q3**: Tổng quan OEE toàn nhà máy, xếp hạng hiệu suất máy và độ biến thiên OEE theo thời gian.
- **Q4 - Q6**: Phân tích chi tiết Downtime (nguyên nhân sự cố), Downtime theo ca làm việc và tổn thất tốc độ (Speed Loss).
- **Q7 - Q8**: Phân tích tỷ lệ phế phẩm (Scrap / Quality Loss) và ma trận tương quan giữa Sản phẩm - Thiết bị.
- **Q9 - Q10**: So sánh OEE thực tế với định mức kỹ thuật và kiến nghị tối ưu hóa năng lực sản xuất.

---

## 📄 License & Thông tin

Dự án phục vụ mục đích nghiên cứu, học tập và ứng dụng thực tiễn trong kỹ thuật dữ liệu sản xuất (Manufacturing Data Analytics).

