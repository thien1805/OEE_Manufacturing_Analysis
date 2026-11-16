SELECT 
    f.run_id,
    f.date_id,
    m.machine_name,
    m.machine_type,
    p.product_name,
    f.is_operating_time,
    f.oee_category,
    f.duration_hours,
    CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END AS operating_hours,
    CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END AS planned_hours,
    f.effective_total_biscuits AS total_biscuits,
    f.good_biscuits_made AS good_biscuits,
    f.scrap_biscuits_made AS scrap_biscuits,
    CASE WHEN f.is_operating_time THEN f.ideal_production ELSE 0 END AS ideal_biscuits
FROM gold.fct_production_runs f
JOIN gold.dim_machine m ON f.machine_id = m.machine_id
JOIN gold.dim_product p ON f.product_id = p.product_id;

