-- ==============================================================================
-- CÂU HỎI 3: BẮT BỆNH DỪNG MÁY (DOWNTIME ANALYSIS)
-- Mục tiêu: 
-- 1. Tính tổng thời gian dừng máy trong tháng 07/2021
-- 2. Phân tích trạng thái dừng máy nào tiêu tốn nhiều thời gian nhất (Hours & %)
-- ==============================================================================

WITH downtime_summary AS (
    SELECT 
        oee_category,
        COUNT(*) AS total_stoppages,
        ROUND(SUM(duration_hours), 2) AS downtime_hours
    FROM gold.fct_production_runs
    WHERE oee_category != 'Run Time'  -- Loại trừ thời gian máy đang chạy sản xuất
    GROUP BY oee_category
),

total_stats AS (
    SELECT SUM(downtime_hours) AS total_downtime_hours FROM downtime_summary
)

SELECT 
    d.oee_category,
    d.total_stoppages,
    d.downtime_hours,
    ROUND((d.downtime_hours / t.total_downtime_hours) * 100, 2) AS pct_of_total_downtime,
    -- Tính % tích lũy (Cumulative %) phục vụ biểu đồ Pareto 80/20
    ROUND(
        SUM(d.downtime_hours) OVER (ORDER BY d.downtime_hours DESC) / t.total_downtime_hours * 100, 
        2
    ) AS cumulative_pct
FROM downtime_summary d
CROSS JOIN total_stats t
ORDER BY d.downtime_hours DESC;
