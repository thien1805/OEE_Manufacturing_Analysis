SELECT 
    p.product_name,
    SUM(f.effective_total_biscuits) AS total_biscuits,
    SUM(f.good_biscuits_made) AS good_biscuits,
    SUM(f.scrap_biscuits_made) AS scrap_biscuits,
    SUM(f.scrap_biscuits_made) / NULLIF(SUM(f.effective_total_biscuits), 0) AS scrap_rate,
    SUM(f.good_biscuits_made) / NULLIF(SUM(f.effective_total_biscuits), 0) AS quality_rate
FROM gold.fct_production_runs f
JOIN gold.dim_product p ON f.product_id = p.product_id
WHERE f.is_operating_time
GROUP BY p.product_name
ORDER BY scrap_rate DESC;
