-- ==============================================================================
-- CÂU HỎI 4: PHÂN LOẠI TỔN THẤT (MINOR VS. MAJOR STOPPAGES)
-- Mục tiêu: 
-- 1. Phân loại dừng máy: Minor (< 3 phút) vs. Major (>= 3 phút)
-- 2. So sánh mức độ thiệt hại: Tần suất (Số lần, %) vs. Thời gian tổn thất (Giờ, %)
-- ==============================================================================

WITH stoppage_data AS (
    SELECT 
        CASE 
            WHEN duration_minutes < 3.0 THEN 'Minor Stoppage (< 3 mins)'
            ELSE 'Major Stoppage (>= 3 mins)'
        END AS stoppage_type,
        duration_hours
    FROM gold.fct_production_runs
    WHERE oee_category != 'Run Time'  -- Chỉ xét các sự kiện dừng máy
),

aggregated AS (
    SELECT 
        stoppage_type,
        COUNT(*) AS total_occurrences,
        ROUND(SUM(duration_hours), 2) AS total_downtime_hours
    FROM stoppage_data
    GROUP BY stoppage_type
),

total_summary AS (
    SELECT 
        SUM(total_occurrences) AS grand_total_occurrences,
        SUM(total_downtime_hours) AS grand_total_downtime_hours
    FROM aggregated
)

SELECT 
    a.stoppage_type,
    a.total_occurrences,
    ROUND(a.total_occurrences * 100.0 / t.grand_total_occurrences, 2) AS pct_occurrences,
    a.total_downtime_hours,
    ROUND(a.total_downtime_hours * 100.0 / t.grand_total_downtime_hours, 2) AS pct_downtime_hours,
    ROUND(a.total_downtime_hours / a.total_occurrences * 60, 2) AS avg_duration_per_stoppage_minutes
FROM aggregated a
CROSS JOIN total_summary t
ORDER BY a.total_downtime_hours DESC;
