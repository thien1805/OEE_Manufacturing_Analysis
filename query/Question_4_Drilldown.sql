-- ==============================================================================
-- CÂU HỎI 4 (BỔ SUNG): DRILL-DOWN MAJOR STOPPAGES (>= 3 PHÚT)
-- Mục tiêu: 
-- Phân rã từ các nhóm OEE Category (NO, CC, Unclassified, PM) xuống từng Máy móc
-- để tìm ra máy nào chịu thiệt hại nặng nhất cho từng loại dừng máy.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- CÁCH 1: DẠNG PHÂN CẤP CHA - CON (HIERARCHY DRILL-DOWN)
-- Xem tỷ trọng % đóng góp của từng máy trong từng nhóm trạng thái dừng máy
-- ------------------------------------------------------------------------------
WITH stoppage_by_machine AS (
    SELECT 
        oee_category,
        machine_name,
        COUNT(*) AS total_stoppages,
        ROUND(SUM(duration_hours), 2) AS downtime_hours,
        ROUND(AVG(duration_minutes), 2) AS avg_duration_per_stoppage_mins
    FROM gold.fct_production_runs
    WHERE oee_category != 'Run Time'
      AND duration_minutes >= 3.0 -- Tiêu chí sự cố lớn (Major Stoppage)
    GROUP BY oee_category, machine_name
),

category_totals AS (
    SELECT 
        oee_category,
        SUM(downtime_hours) AS cat_total_downtime_hours
    FROM stoppage_by_machine
    GROUP BY oee_category
)

SELECT 
    s.oee_category,
    s.machine_name,
    s.total_stoppages,
    s.downtime_hours,
    ROUND(s.downtime_hours * 100.0 / c.cat_total_downtime_hours, 2) AS pct_within_category,
    s.avg_duration_per_stoppage_mins
FROM stoppage_by_machine s
JOIN category_totals c ON s.oee_category = c.oee_category
ORDER BY c.cat_total_downtime_hours DESC, s.downtime_hours DESC;


-- ------------------------------------------------------------------------------
-- CÁCH 2: DẠNG MA TRẬN ĐỐI CHIẾU (CROSS-TAB MATRIX / HEATMAP)
-- Thống kê theo hàng ngang: Mỗi máy chịu bao nhiêu giờ cho từng trạng thái dừng
-- ------------------------------------------------------------------------------
SELECT 
    machine_name,
    ROUND(SUM(CASE WHEN oee_category = 'NO (No Order)' THEN duration_hours ELSE 0 END), 2) AS no_order_hours,
    ROUND(SUM(CASE WHEN oee_category = 'CC (Changeover Cleaning)' THEN duration_hours ELSE 0 END), 2) AS changeover_hours,
    ROUND(SUM(CASE WHEN oee_category = 'Unclassified' THEN duration_hours ELSE 0 END), 2) AS unclassified_hours,
    ROUND(SUM(CASE WHEN oee_category = 'PM (Maintenance)' THEN duration_hours ELSE 0 END), 2) AS maintenance_hours,
    ROUND(SUM(duration_hours), 2) AS total_major_downtime_hours
FROM gold.fct_production_runs
WHERE oee_category != 'Run Time'
  AND duration_minutes >= 3.0
GROUP BY machine_name
ORDER BY total_major_downtime_hours DESC;
