-- ==============================================================================
-- CÂU HỎI 6: ĐỘ LỆCH MỤC TIÊU (PERFORMANCE GAP ANALYSIS)
-- Mục tiêu: 
-- 1. Tìm các loại máy móc (Machine) chạy chậm nhất so với định mức Target Speeds.
-- 2. Tìm các dòng sản phẩm (Product) có độ hụt sản lượng / chạy chậm nhất toàn xưởng.
-- 3. Xác định các cặp (Machine x Product) có độ lệch mục tiêu (Performance Gap) nghiêm trọng nhất.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- PHẦN 1: ĐỘ LỆCH HIỆU SUẤT THEO LOẠI MÁY (PERFORMANCE GAP BY MACHINE)
-- ------------------------------------------------------------------------------
SELECT 
    machine_name,
    ROUND(SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END), 2) AS operating_hours,
    SUM(effective_total_biscuits) AS actual_output,
    ROUND(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END), 2) AS ideal_output,
    
    -- Tốc độ thực tế vs Định mức trung bình (Bánh/giờ)
    ROUND(SUM(effective_total_biscuits) / NULLIF(SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END), 0), 0) AS actual_speed_uph,
    ROUND(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END) / NULLIF(SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END), 0), 0) AS target_speed_uph,
    
    -- Hiệu suất vận hành (Performance %) và Độ lệch mục tiêu (Performance Gap %)
    ROUND(
        LEAST(100.0, 
            SUM(effective_total_biscuits) * 100.0 / 
            NULLIF(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END), 0)
        ), 2
    ) AS performance_rate_pct,
    
    ROUND(
        100.0 - LEAST(100.0, 
            SUM(effective_total_biscuits) * 100.0 / 
            NULLIF(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END), 0)
        ), 2
    ) AS performance_gap_pct

FROM gold.fct_production_runs
GROUP BY machine_name
ORDER BY performance_rate_pct ASC;


-- ------------------------------------------------------------------------------
-- PHẦN 2: ĐỘ LỆCH HIỆU SUẤT THEO DÒNG BÁNH (PERFORMANCE GAP BY PRODUCT)
-- ------------------------------------------------------------------------------
SELECT 
    product_name,
    ROUND(SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END), 2) AS operating_hours,
    SUM(effective_total_biscuits) AS actual_output,
    ROUND(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END), 2) AS ideal_output,
    
    ROUND(SUM(effective_total_biscuits) / NULLIF(SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END), 0), 0) AS actual_speed_uph,
    ROUND(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END) / NULLIF(SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END), 0), 0) AS target_speed_uph,
    
    ROUND(
        LEAST(100.0, 
            SUM(effective_total_biscuits) * 100.0 / 
            NULLIF(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END), 0)
        ), 2
    ) AS performance_rate_pct,
    
    ROUND(
        100.0 - LEAST(100.0, 
            SUM(effective_total_biscuits) * 100.0 / 
            NULLIF(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END), 0)
        ), 2
    ) AS performance_gap_pct

FROM gold.fct_production_runs
GROUP BY product_name
ORDER BY performance_rate_pct ASC;


-- ------------------------------------------------------------------------------
-- PHẦN 3: TOP CẶP (MACHINE X PRODUCT) CHẠY CHẬM NHẤT TRONG SẢN XUẤT
-- ------------------------------------------------------------------------------
SELECT 
    machine_name,
    product_name,
    COUNT(*) AS total_runs,
    COUNT(CASE WHEN (effective_total_biscuits / NULLIF(duration_hours, 0)) < target_biscuits_per_hour THEN 1 END) AS slow_runs_count,
    ROUND(SUM(duration_hours), 2) AS operating_hours,
    SUM(effective_total_biscuits) AS actual_output,
    ROUND(SUM(ideal_production), 2) AS ideal_output,
    ROUND(SUM(effective_total_biscuits) / NULLIF(SUM(duration_hours), 0), 0) AS actual_speed_uph,
    ROUND(AVG(target_biscuits_per_hour), 0) AS target_speed_uph,
    ROUND(LEAST(100.0, SUM(effective_total_biscuits) * 100.0 / NULLIF(SUM(ideal_production), 0)), 2) AS performance_rate_pct
FROM gold.fct_production_runs
WHERE is_operating_time AND duration_hours > 0
GROUP BY machine_name, product_name
HAVING performance_rate_pct < 5.0
ORDER BY performance_rate_pct ASC, operating_hours DESC;
