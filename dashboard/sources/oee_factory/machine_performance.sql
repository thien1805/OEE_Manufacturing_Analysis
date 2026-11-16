SELECT 
    m.machine_name,
    m.machine_type,
    ROUND(SUM(f.duration_hours), 1) AS total_hours,
    ROUND(SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END), 1) AS run_hours,
    SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 0) AS availability_rate,
    LEAST(1.0, SUM(f.effective_total_biscuits) / 
          NULLIF(SUM(CASE WHEN f.is_operating_time THEN f.ideal_production ELSE 0 END), 0)) AS performance_rate,
    SUM(f.good_biscuits_made) / NULLIF(SUM(f.effective_total_biscuits), 0) AS quality_rate,
    (SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END) / 
         NULLIF(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 0)) *
    LEAST(1.0, SUM(f.effective_total_biscuits) / 
         NULLIF(SUM(CASE WHEN f.is_operating_time THEN f.ideal_production ELSE 0 END), 0)) *
    (SUM(f.good_biscuits_made) / NULLIF(SUM(f.effective_total_biscuits), 0)) AS oee_rate
FROM gold.fct_production_runs f
JOIN gold.dim_machine m ON f.machine_id = m.machine_id
GROUP BY m.machine_name, m.machine_type
ORDER BY oee_rate DESC;
