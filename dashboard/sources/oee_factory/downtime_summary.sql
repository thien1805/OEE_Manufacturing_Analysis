SELECT 
    oee_category,
    ROUND(SUM(duration_hours), 1) AS downtime_hours,
    COUNT(*) AS incident_count,
    SUM(duration_hours) / SUM(SUM(duration_hours)) OVER () AS pct_of_downtime
FROM gold.fct_production_runs
WHERE NOT is_operating_time
GROUP BY oee_category
ORDER BY downtime_hours DESC;
