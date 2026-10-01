-- ==============================================================================
-- CÂU HỎI 7: TỔN THẤT DO THAY KHUÔN & VỆ SINH (CHANGEOVER CLEANING ANALYSIS)
-- Mục tiêu: 
-- 1. Tính tỷ trọng % của CC (Changeover Cleaning) trên tổng thời gian dừng máy toàn xưởng.
-- 2. Xếp hạng các loại máy (Machine) tiêu tốn nhiều thời gian vệ sinh/thay khuôn nhất.
-- 3. Phân rã CC theo quy mô: Sự cố vặt (< 3 phút) vs. Sự cố lớn (>= 3 phút).
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- PHẦN 1: TỶ TRỌNG CC TRÊN TỔNG THỜI GIAN DỪNG MÁY TOÀN NHÀ MÁY
-- ------------------------------------------------------------------------------
WITH downtime_totals AS (
    SELECT 
        oee_category,
        COUNT(*) AS total_stoppages,
        ROUND(SUM(duration_hours), 2) AS downtime_hours
    FROM gold.fct_production_runs
    WHERE oee_category != 'Run Time'
    GROUP BY oee_category
),
factory_downtime AS (
    SELECT SUM(downtime_hours) AS grand_total_downtime_hours FROM downtime_totals
)
SELECT 
    d.oee_category,
    d.total_stoppages,
    d.downtime_hours,
    ROUND(d.downtime_hours * 100.0 / f.grand_total_downtime_hours, 2) AS pct_of_total_downtime
FROM downtime_totals d
CROSS JOIN factory_downtime f
ORDER BY d.downtime_hours DESC;


-- ------------------------------------------------------------------------------
-- PHẦN 2: XẾP HẠNG MÁY MÓC TIÊU TỐN THỜI GIAN VỆ SINH/THAY KHUÔN NHẤT
-- ------------------------------------------------------------------------------
WITH cc_by_machine AS (
    SELECT 
        machine_name,
        COUNT(*) AS cc_stoppages,
        ROUND(SUM(duration_hours), 2) AS cc_hours,
        ROUND(AVG(duration_minutes), 2) AS avg_cc_duration_mins,
        ROUND(MIN(duration_minutes), 2) AS min_cc_mins,
        ROUND(MAX(duration_minutes), 2) AS max_cc_mins
    FROM gold.fct_production_runs
    WHERE oee_category = 'CC (Changeover Cleaning)'
    GROUP BY machine_name
),
total_cc AS (
    SELECT SUM(cc_hours) AS grand_total_cc_hours FROM cc_by_machine
)
SELECT 
    m.machine_name,
    m.cc_stoppages,
    m.cc_hours,
    ROUND(m.cc_hours * 100.0 / t.grand_total_cc_hours, 2) AS pct_of_cc_downtime,
    m.avg_cc_duration_mins,
    m.min_cc_mins,
    m.max_cc_mins
FROM cc_by_machine m
CROSS JOIN total_cc t
ORDER BY m.cc_hours DESC;


-- ------------------------------------------------------------------------------
-- PHẦN 3: PHÂN RÃ CC THEO MINOR (< 3 PHÚT) VS. MAJOR (>= 3 PHÚT)
-- ------------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN duration_minutes < 3.0 THEN 'Minor CC (< 3 mins) - Lau chùi nhanh'
        ELSE 'Major CC (>= 3 mins) - Đổi mã sản phẩm/thay khuôn lớn'
    END AS cc_type,
    COUNT(*) AS total_stoppages,
    ROUND(SUM(duration_hours), 2) AS cc_hours,
    ROUND(SUM(duration_hours) * 100.0 / SUM(SUM(duration_hours)) OVER (), 2) AS pct_share,
    ROUND(AVG(duration_minutes), 2) AS avg_duration_mins
FROM gold.fct_production_runs
WHERE oee_category = 'CC (Changeover Cleaning)'
GROUP BY 1

ORDER BY cc_hours DESC;
