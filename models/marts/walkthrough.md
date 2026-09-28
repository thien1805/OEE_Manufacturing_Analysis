# Báo Cáo Hoàn Thành Xây Dựng Mô Hình Star Schema & Làm Sạch Dữ Liệu

Quá trình làm sạch dữ liệu và triển khai kiến trúc Star Schema (Medallion Architecture: **Bronze -> Silver -> Gold**) trên **dbt + DuckDB** đã hoàn thành xuất sắc và vượt qua 100% các bài kiểm thử tính toàn vẹn dữ liệu.

---

## 1. Kết Quả Làm Sạch Dữ Liệu (Tầng Silver)

| Bảng Staging | Vấn đề ban đầu | Giải pháp xử lý | Kết quả |
| :--- | :--- | :--- | :--- |
| **`stg_fact`** | Cột `Machine` và `Product` dính khoảng trắng thừa (`trim()`); 3 dòng trùng lặp hoàn toàn; `OEE Category` mang giá trị `'0'`. | Cắt tỉa `trim()`; chuẩn hóa `'0'` thành `'Unclassified'`; khử trùng lặp qua `row_number()`. | Dữ liệu giảm từ 8,044 xuống còn **8,041 dòng chuẩn xác**. |
| **`stg_machine`** | Tên máy và loại máy có khoảng trắng ở cuối. | Chuẩn hóa `trim("Machine Name")` và `trim("Machine Type")`. | **10 máy** sạch sẽ, chuẩn hóa. |
| **`stg_product`** | Cột `Biscuits_PER_PALLET` thực chất là số thùng/pallet (140) và thiếu cột tổng số bánh/pallet (3360). | Đọc đầy đủ và ánh xạ chuẩn: `cases_per_pallet` và `biscuits_per_pallet`. | **18 sản phẩm** đầy đủ quy cách đóng gói. |
| **`stg_target_speeds`** | Khoảng trắng thừa khi ghép với `fact`. | `trim()` đồng bộ giúp khớp 100% (8,041 / 8,041 dòng). | **72 mục tiêu** tốc độ máy theo sản phẩm. |

---

## 2. Mô Hình Star Schema Đã Triển Khai (Tầng Gold)

### Các bảng Chiều (Dimensions)
- **`gold.dim_machine`** (10 dòng):
  - Khóa chính: `machine_id` (Surrogate Key băm MD5).
  - Thuộc tính: `machine_name`, `machine_type`.
- **`gold.dim_product`** (18 dòng):
  - Khóa chính: `product_id` (Surrogate Key băm MD5).
  - Thuộc tính: `product_name`, `biscuits_per_pack`, `biscuits_per_case`, `cases_per_pallet`, `biscuits_per_pallet`.
- **`gold.dim_date`** (365 dòng):
  - Khóa chính: `date_id` (Kiểu Date).
  - Thuộc tính thời gian chi tiết: `date_day`, `day_name`, `day_of_week`, `week_of_year`, `month`, `month_name`, `quarter`, `year`, `is_weekend`.

### Các bảng Sự kiện & Chỉ số (Facts & Marts)
- **`gold.fct_production_runs`** (8,041 dòng):
  - Khóa chính: `run_id` (Surrogate Key).
  - Khóa ngoại: `date_id`, `machine_id`, `product_id`.
  - Chỉ số chi tiết: `duration_minutes`, `duration_hours`, `target_biscuits_per_hour`, `ideal_production`, `total_biscuits_made`, `good_biscuits_made`, `effective_total_biscuits`, `scrap_biscuits_made`.
  - Phân loại OEE: `is_operating_time`, `is_planned_downtime`.
- **`gold.fct_daily_oee`** (193 dòng):
  - Bảng tổng hợp theo Ngày, Máy và Sản phẩm.
  - Tính toán sẵn 3 trụ cột cốt lõi:
    - **Availability (%)**: Tỷ lệ thời gian chạy máy / Thời gian kế hoạch.
    - **Performance (%)**: Tỷ lệ sản lượng thực tế / Sản lượng lý thuyết định mức.
    - **Quality (%)**: Tỷ lệ sản phẩm đạt chuẩn / Tổng sản lượng.
    - **OEE (%)**: Chỉ số hiệu quả thiết bị tổng thể ($A \times P \times Q$).

---

## 3. Kết Quả Kiểm Thử (Validation)

### dbt Run
```bash
.venv/bin/dbt run --profiles-dir .
```
> **Kết quả:** `PASS=9 WARN=0 ERROR=0` (Xây dựng thành công 4 view Silver và 5 bảng Gold).

### dbt Test (Kiểm tra ràng buộc dữ liệu)
```bash
.venv/bin/dbt test --profiles-dir .
```
> **Kết quả:** `PASS=19 WARN=0 ERROR=0`
> - Kiểm tra khóa chính duy nhất (`unique`): 100% PASS trên tất cả các Dimensions và Fact.
> - Kiểm tra trường bắt buộc (`not_null`): 100% PASS.
> - Kiểm tra toàn vẹn quan hệ (`relationships` - Foreign Key Integrity): 100% PASS (Tất cả khóa ngoại trong `fct_production_runs` đều liên kết hợp lệ tới `dim_machine`, `dim_product`, `dim_date`).

---

## 4. Hướng Dẫn Truy Vấn & Khai Thác

Bạn có thể chạy kiểm tra dữ liệu bằng script:
```bash
python check_data.py
```

Hoặc truy vấn phân tích OEE bằng DuckDB/Python:
```sql
SELECT 
    d.date_day,
    m.machine_name,
    p.product_name,
    oee.availability_pct,
    oee.performance_pct,
    oee.quality_pct,
    oee.oee_pct
FROM gold.fct_daily_oee oee
JOIN gold.dim_date d ON oee.date_id = d.date_id
JOIN gold.dim_machine m ON oee.machine_id = m.machine_id
JOIN gold.dim_product p ON oee.product_id = p.product_id
ORDER BY oee.date_id DESC, oee.oee_pct ASC
LIMIT 10;
```
