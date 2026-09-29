-- ==============================================================================
-- CÂU HỎI 2: PHÂN TÍCH ĐIỂM NGHẼN (BOTTLENECK ANALYSIS)
-- Mục tiêu: Xếp hạng 10 loại máy theo OEE từ thấp đến cao và chẩn đoán nguyên nhân cốt lõi
-- ==============================================================================

SELECT 
    m.machine_name,
    
    -- 1. Thời gian vận hành (Giờ)
    ROUND(SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END), 1) AS operating_hours,
    ROUND(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 1) AS planned_hours,
    
    -- 2. Ba trụ cột OEE (%)
    ROUND(
        SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 0) * 100, 
        2
    ) AS availability_pct,
    
    ROUND(
        LEAST(100.0, 
            SUM(f.effective_total_biscuits) / 
            NULLIF(SUM(CASE WHEN f.is_operating_time THEN f.ideal_production ELSE 0 END), 0) * 100
        ), 
        2
    ) AS performance_pct,
    
    ROUND(
        SUM(f.good_biscuits_made) / NULLIF(SUM(f.effective_total_biscuits), 0) * 100, 
        2
    ) AS quality_pct,
    
    -- 3. Chỉ số OEE Tổng thể (%)
    ROUND(
        (SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END) / 
         NULLIF(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 0)) *
        LEAST(1.0, 
            SUM(f.effective_total_biscuits) / 
            NULLIF(SUM(CASE WHEN f.is_operating_time THEN f.ideal_production ELSE 0 END), 0)
        ) *
        (SUM(good_biscuits_made) / NULLIF(SUM(effective_total_biscuits), 0)) * 100, 
        2
    ) AS oee_pct,
    
    -- 4. Chẩn đoán nguyên nhân cốt lõi (Root Cause Diagnosis)
    CASE 
        WHEN ROUND(LEAST(100.0, SUM(f.effective_total_biscuits) / NULLIF(SUM(CASE WHEN f.is_operating_time THEN f.ideal_production ELSE 0 END), 0) * 100), 2) < 5 
            THEN 'Chạy quá chậm (Performance sụp đổ)'
        WHEN ROUND(SUM(f.good_biscuits_made) / NULLIF(SUM(f.effective_total_biscuits), 0) * 100, 2) < 50 
            THEN 'Hàng lỗi/Phế phẩm quá nhiều (Quality thấp)'
        WHEN ROUND(SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END) / NULLIF(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 0) * 100, 2) < 15 
            THEN 'Dừng máy quá nhiều (Availability thấp)'
        ELSE 'Vận hành tương đối ổn định'
    END AS root_cause_diagnosis

FROM gold.fct_production_runs f
JOIN gold.dim_machine m ON f.machine_id = m.machine_id
GROUP BY m.machine_name
ORDER BY oee_pct ASC;
