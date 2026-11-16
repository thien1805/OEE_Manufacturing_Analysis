SELECT 
    date_id,
    ROUND(SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END), 2) AS operating_hours,
    ROUND(SUM(CASE WHEN oee_category != 'PM (Maintenance)' THEN duration_hours ELSE 0 END), 2) AS planned_hours,
    SUM(effective_total_biscuits) AS total_biscuits,
    SUM(good_biscuits_made) AS good_biscuits,
    SUM(scrap_biscuits_made) AS scrap_biscuits,
    
    SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN oee_category != 'PM (Maintenance)' THEN duration_hours ELSE 0 END), 0) AS availability_rate,
        
    LEAST(1.0, SUM(effective_total_biscuits) / 
        NULLIF(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END), 0)) AS performance_rate,
        
    SUM(good_biscuits_made) / NULLIF(SUM(effective_total_biscuits), 0) AS quality_rate,
    
    (SUM(CASE WHEN is_operating_time THEN duration_hours ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN oee_category != 'PM (Maintenance)' THEN duration_hours ELSE 0 END), 0)) *
    LEAST(1.0, SUM(effective_total_biscuits) / 
        NULLIF(SUM(CASE WHEN is_operating_time THEN ideal_production ELSE 0 END), 0)) *
    (SUM(good_biscuits_made) / NULLIF(SUM(effective_total_biscuits), 0)) AS oee_rate

FROM gold.fct_production_runs
GROUP BY date_id
ORDER BY date_id;
