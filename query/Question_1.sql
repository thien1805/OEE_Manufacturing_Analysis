SELECT 
    -- 1. Đo lường thời gian (Giờ)
    ROUND(SUM(duration_hours), 2) AS total_hours,
    ROUND(SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END), 2) AS operating_hours,
    ROUND(SUM(CASE WHEN oee_category != 'PM (Maintenance)' THEN duration_hours ELSE 0 END), 2) AS planned_hours,
    
    -- 2. Đo lường sản lượng (Bánh)
    SUM(effective_total_biscuits) AS total_biscuits,
    SUM(good_biscuits_made) AS good_biscuits,
    SUM(scrap_biscuits_made) AS scrap_biscuits,
    
    -- 3. Ba trụ cột OEE (%)
    ROUND(
        SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN oee_category != 'PM (Maintenance)' THEN duration_hours ELSE 0 END), 0) * 100, 
        2
    ) AS availability_pct,
    
    ROUND(
        LEAST(100.0, 
            SUM(effective_total_biscuits) / 
            NULLIF(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END), 0) * 100
        ), 
        2
    ) AS performance_pct,
    
    ROUND(
        SUM(good_biscuits_made) / NULLIF(SUM(effective_total_biscuits), 0) * 100, 
        2
    ) AS quality_pct,
    
    -- 4. OEE Toàn Nhà Máy (%)
    ROUND(
        (SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END) / 
         NULLIF(SUM(CASE WHEN oee_category != 'PM (Maintenance)' THEN duration_hours ELSE 0 END), 0)) *
        LEAST(1.0, 
            SUM(effective_total_biscuits) / 
            NULLIF(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END), 0)
        ) *
        (SUM(good_biscuits_made) / NULLIF(SUM(effective_total_biscuits), 0)) * 100, 
        2
    ) AS plant_oee_pct

FROM gold.fct_production_runs
WHERE date_id BETWEEN '2021-07-01' AND '2021-07-31';
