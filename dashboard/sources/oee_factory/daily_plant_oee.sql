SELECT 
    f.date_id,
    ROUND(SUM(f.operating_hours), 2) AS operating_hours,
    ROUND(SUM(f.planned_production_hours), 2) AS planned_hours,
    SUM(f.effective_total_biscuits) AS total_biscuits,
    SUM(f.good_biscuits_made) AS good_biscuits,
    SUM(f.scrap_biscuits_made) AS scrap_biscuits,
    ROUND(SUM(f.operating_hours) / NULLIF(SUM(f.planned_production_hours), 0) * 100, 2) AS availability_pct,
    ROUND(LEAST(100.0, SUM(f.effective_total_biscuits) / NULLIF(SUM(f.ideal_biscuits), 0) * 100), 2) AS performance_pct,
    ROUND(SUM(f.good_biscuits_made) / NULLIF(SUM(f.effective_total_biscuits), 0) * 100, 2) AS quality_pct,
    ROUND(
        (SUM(f.operating_hours) / NULLIF(SUM(f.planned_production_hours), 0)) *
        LEAST(1.0, SUM(f.effective_total_biscuits) / NULLIF(SUM(f.ideal_biscuits), 0)) *
        (SUM(f.good_biscuits_made) / NULLIF(SUM(f.effective_total_biscuits), 0)) * 100,
        2
    ) AS oee_pct
FROM gold.fct_daily_oee f
GROUP BY f.date_id
ORDER BY f.date_id;

