-- ==============================================================================
-- CÂU HỎI 10: BÀI TOÁN TỐI ƯU & KHUYẾN NGHỊ QUẢN TRỊ (WHAT-IF ANALYSIS)
-- Mục tiêu: 
-- 1. Tính toán hiệu quả khi giảm 15% thời gian bảo dưỡng định kỳ (PM - Maintenance):
--    - Số giờ chạy thêm được (Hours gained).
--    - Sản lượng lý thuyết và sản lượng đạt chuẩn làm thêm được (Additional Biscuits).
-- 2. Phân tích đối sánh chiến lược (Sensitivity / What-If Analysis):
--    So sánh tác động của việc giảm 15% PM vs. Giảm 15% CC vs. Giảm 15% NO.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- PHẦN 1: TÍNH TOÁN CHI TIẾT KHI GIẢM 15% THỜI GIAN DỪNG PM (MAINTENANCE)
-- ------------------------------------------------------------------------------
WITH pm_base AS (
    SELECT 
        machine_name,
        product_name,
        SUM(duration_hours) AS pm_hours,
        SUM(duration_hours) * 0.15 AS hours_gained,
        AVG(target_biscuits_per_hour) AS target_speed_uph
    FROM gold.fct_production_runs
    WHERE oee_category = 'PM (Maintenance)'
    GROUP BY machine_name, product_name
),

pm_summary AS (
    SELECT 
        machine_name,
        product_name,
        ROUND(pm_hours, 2) AS current_pm_hours,
        ROUND(hours_gained, 4) AS additional_operating_hours,
        ROUND(hours_gained * 60, 1) AS additional_operating_minutes,
        ROUND(target_speed_uph, 0) AS target_speed_uph,
        ROUND(hours_gained * target_speed_uph, 0) AS additional_biscuits
    FROM pm_base
)

SELECT * FROM pm_summary
UNION ALL
SELECT 
    '--- TOTAL PLANT ---' AS machine_name,
    'All PM Products' AS product_name,
    ROUND(SUM(current_pm_hours), 2) AS current_pm_hours,
    ROUND(SUM(additional_operating_hours), 4) AS additional_operating_hours,
    ROUND(SUM(additional_operating_minutes), 1) AS additional_operating_minutes,
    NULL AS target_speed_uph,
    ROUND(SUM(additional_biscuits), 0) AS additional_biscuits
FROM pm_summary;


-- ------------------------------------------------------------------------------
-- PHẦN 2: BẢNG SO SÁNH WHAT-IF: NÊN ĐẦU TƯ CẢI TIẾN VÀO ĐÂU ĐỂ TỐI ƯU NHẤT?
-- ------------------------------------------------------------------------------
WITH category_downtime AS (
    SELECT 
        oee_category,
        ROUND(SUM(duration_hours), 2) AS current_downtime_hours
    FROM gold.fct_production_runs
    WHERE oee_category != 'Run Time'
    GROUP BY oee_category
)
SELECT 
    oee_category,
    current_downtime_hours,
    -- Giả định giảm 15% thời gian của từng nhóm
    ROUND(current_downtime_hours * 0.15, 2) AS hours_gained_15pct,
    -- Ước tính sản lượng sản xuất thêm theo tốc độ định mức trung bình toàn xưởng (~50,000 u/h)
    ROUND(current_downtime_hours * 0.15 * 50000, 0) AS estimated_biscuits_gained,
    -- Đánh giá mức độ ưu tiên chiến lược
    CASE 
        WHEN oee_category = 'NO (No Order)' THEN 'Ưu tiên số 1 về Kế hoạch & Bán hàng (Thu hồi > 344 giờ)'
        WHEN oee_category = 'CC (Changeover Cleaning)' THEN 'Ưu tiên số 1 về Kỹ thuật & Vận hành (Thu hồi > 84 giờ)'
        WHEN oee_category = 'PM (Maintenance)' THEN 'Tác động rất thấp (Chỉ thu hồi ~0.5 giờ / 32 phút)'
        ELSE 'Khác'
    END AS strategic_priority
FROM category_downtime
ORDER BY current_downtime_hours DESC;
