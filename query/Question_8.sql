-- ==============================================================================
-- CÂU HỎI 8: PHÂN TÍCH XU HƯỚNG THỜI GIAN (WEEKLY TREND & WEEKEND OEE)
-- Mục tiêu: 
-- 1. Đo lường sự biến động của OEE và 3 trụ cột (A, P, Q) giữa các ngày trong tuần (Thứ 2 -> Chủ Nhật).
-- 2. So sánh hiệu suất ca làm việc giữa Ngày thường (Weekday: T2-T6) và Ngày cuối tuần (Weekend: T7-CN).
-- 3. Đánh giá xem cuối tuần có bị suy giảm hiệu suất so với ngày thường hay không.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- PHẦN 1: CHỈ SỐ OEE THEO TỪNG NGÀY TRONG TUẦN (DAY OF WEEK: MON -> SUN)
-- ------------------------------------------------------------------------------
WITH daily_stats AS (
    SELECT 
        EXTRACT('isodow' FROM date_id) AS day_of_week_num,
        DAYNAME(date_id) AS day_of_week_name,
        ROUND(SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END), 2) AS operating_hours,
        ROUND(SUM(CASE WHEN oee_category != 'PM (Maintenance)' THEN duration_hours ELSE 0 END), 2) AS planned_hours,
        SUM(effective_total_biscuits) AS total_biscuits,
        SUM(good_biscuits_made) AS good_biscuits,
        ROUND(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END), 2) AS ideal_production
    FROM gold.fct_production_runs
    GROUP BY 1, 2
)
SELECT 
    day_of_week_num,
    day_of_week_name,
    operating_hours,
    planned_hours,
    
    -- 1. Hiệu suất khả dụng (Availability Rate %)
    ROUND(operating_hours * 100.0 / NULLIF(planned_hours, 0), 2) AS availability_pct,
    
    -- 2. Hiệu suất vận hành (Performance Rate %)
    ROUND(LEAST(100.0, total_biscuits * 100.0 / NULLIF(ideal_production, 0)), 2) AS performance_pct,
    
    -- 3. Tỷ lệ chất lượng (Quality Rate %)
    ROUND(good_biscuits * 100.0 / NULLIF(total_biscuits, 0), 2) AS quality_pct,
    
    -- 4. OEE Tổng thể (%)
    ROUND(
        (operating_hours / NULLIF(planned_hours, 0)) *
        LEAST(1.0, total_biscuits / NULLIF(ideal_production, 0)) *
        (good_biscuits / NULLIF(total_biscuits, 0)) * 100,
        2
    ) AS oee_pct

FROM daily_stats
ORDER BY day_of_week_num;


-- ------------------------------------------------------------------------------
-- PHẦN 2: SO SÁNH TRỰC DIỆN NGÀY THƯỜNG (WEEKDAY) VS. CUỐI TUẦN (WEEKEND)
-- ------------------------------------------------------------------------------
WITH day_classification AS (
    SELECT 
        CASE 
            WHEN EXTRACT('isodow' FROM date_id) IN (6, 7) THEN 'Weekend (Sat - Sun)'
            ELSE 'Weekday (Mon - Fri)'
        END AS day_type,
        ROUND(SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END), 2) AS operating_hours,
        ROUND(SUM(CASE WHEN oee_category != 'PM (Maintenance)' THEN duration_hours ELSE 0 END), 2) AS planned_hours,
        SUM(effective_total_biscuits) AS total_biscuits,
        SUM(good_biscuits_made) AS good_biscuits,
        ROUND(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END), 2) AS ideal_production
    FROM gold.fct_production_runs
    GROUP BY 1
)
SELECT 
    day_type,
    operating_hours,
    planned_hours,
    ROUND(operating_hours * 100.0 / NULLIF(planned_hours, 0), 2) AS availability_pct,
    ROUND(LEAST(100.0, total_biscuits * 100.0 / NULLIF(ideal_production, 0)), 2) AS performance_pct,
    ROUND(good_biscuits * 100.0 / NULLIF(total_biscuits, 0), 2) AS quality_pct,
    ROUND(
        (operating_hours / NULLIF(planned_hours, 0)) *
        LEAST(1.0, total_biscuits / NULLIF(ideal_production, 0)) *
        (good_biscuits / NULLIF(total_biscuits, 0)) * 100,
        2
    ) AS oee_pct
FROM day_classification
ORDER BY day_type DESC;
