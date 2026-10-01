-- ==============================================================================
-- CÂU HỎI 9: VINH DANH CỖ MÁY TỐI ƯU (OPTIMAL MACHINE CHAMPION)
-- Mục tiêu: 
-- 1. Tìm loại máy có OEE cao nhất toàn nhà máy và sự kết hợp giữa 3 trụ cột (A, P, Q).
-- 2. Xếp hạng toàn bộ 10 cỗ máy theo thứ tự OEE từ cao xuống thấp.
-- 3. Đánh giá tính ổn định và tần suất vận hành của các máy dẫn đầu.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- PHẦN 1: BẢNG XẾP HẠNG OEE VÀ 3 TRỤ CỘT TOÀN BỘ 10 MÁY (TỪ CAO XUỐNG THẤP)
-- ------------------------------------------------------------------------------
SELECT 
    m.machine_name,
    ROUND(SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END), 2) AS operating_hours,
    ROUND(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 2) AS planned_hours,
    
    -- 1. Hiệu suất khả dụng (Availability %)
    ROUND(
        SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 0) * 100, 
        2
    ) AS availability_pct,
    
    -- 2. Hiệu suất vận hành (Performance %)
    ROUND(
        LEAST(100.0, 
            SUM(f.effective_total_biscuits) / 
            NULLIF(SUM(CASE WHEN f.is_operating_time THEN f.ideal_production ELSE 0 END), 0) * 100
        ), 
        2
    ) AS performance_pct,
    
    -- 3. Tỷ lệ chất lượng (Quality %)
    ROUND(
        SUM(f.good_biscuits_made) / NULLIF(SUM(f.effective_total_biscuits), 0) * 100, 
        2
    ) AS quality_pct,
    
    -- 4. OEE Tổng thể (%)
    ROUND(
        (SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END) / 
         NULLIF(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 0)) *
        LEAST(1.0, 
            SUM(f.effective_total_biscuits) / 
            NULLIF(SUM(CASE WHEN f.is_operating_time THEN f.ideal_production ELSE 0 END), 0)
        ) *
        (SUM(f.good_biscuits_made) / NULLIF(SUM(effective_total_biscuits), 0)) * 100, 
        2
    ) AS oee_pct,
    
    -- 5. Đánh giá & Xếp hạng
    CASE 
        WHEN DENSE_RANK() OVER (ORDER BY 
            (SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END) / 
             NULLIF(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 0)) *
            LEAST(1.0, 
                SUM(f.effective_total_biscuits) / 
                NULLIF(SUM(CASE WHEN f.is_operating_time THEN f.ideal_production ELSE 0 END), 0)
            ) *
            (SUM(f.good_biscuits_made) / NULLIF(SUM(effective_total_biscuits), 0)) DESC
        ) = 1 THEN 'Quán quân (Champion - OEE cao nhất)'
        WHEN DENSE_RANK() OVER (ORDER BY 
            (SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END) / 
             NULLIF(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 0)) *
            LEAST(1.0, 
                SUM(f.effective_total_biscuits) / 
                NULLIF(SUM(CASE WHEN f.is_operating_time THEN f.ideal_production ELSE 0 END), 0)
            ) *
            (SUM(f.good_biscuits_made) / NULLIF(SUM(effective_total_biscuits), 0)) DESC
        ) = 2 THEN 'Á quân (Runner-up - Quality 100%)'
        ELSE 'Cần cải tiến (OEE < 1%)'
    END AS machine_status

FROM gold.fct_production_runs f
JOIN gold.dim_machine m ON f.machine_id = m.machine_id
GROUP BY m.machine_name
ORDER BY oee_pct DESC;


-- ------------------------------------------------------------------------------
-- PHẦN 2: ĐO LƯỜNG TÍNH ỔN ĐỊNH VÀ BỀN BỈ QUA CÁC NGÀY TRONG THÁNG
-- ------------------------------------------------------------------------------
WITH daily_oee AS (
    SELECT 
        date_id,
        machine_name,
        ROUND(SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END), 2) AS op_hours,
        ROUND(SUM(CASE WHEN oee_category != 'PM (Maintenance)' THEN duration_hours ELSE 0 END), 2) AS plan_hours,
        SUM(effective_total_biscuits) AS total,
        SUM(good_biscuits_made) AS good,
        ROUND(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END), 2) AS ideal
    FROM gold.fct_production_runs
    GROUP BY date_id, machine_name
)
SELECT 
    machine_name,
    COUNT(DISTINCT date_id) AS active_days_in_month,
    ROUND(AVG(
        (op_hours / NULLIF(plan_hours, 0)) *
        LEAST(1.0, total / NULLIF(ideal, 0)) *
        (good / NULLIF(total, 0)) * 100
    ), 2) AS avg_daily_oee_pct,
    ROUND(STDDEV_POP(
        (op_hours / NULLIF(plan_hours, 0)) *
        LEAST(1.0, total / NULLIF(ideal, 0)) *
        (good / NULLIF(total, 0)) * 100
    ), 2) AS oee_stability_stddev
FROM daily_oee
GROUP BY machine_name
ORDER BY avg_daily_oee_pct DESC;
