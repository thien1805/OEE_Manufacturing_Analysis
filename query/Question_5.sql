-- ==============================================================================
-- CÂU HỎI 5: CẢNH BÁO CHẤT LƯỢNG (QUALITY INDEX & WASTE ANALYSIS)
-- Mục tiêu: 
-- 1. Tìm loại bánh (Product) có tỷ lệ phế phẩm/hàng hủy (Waste %) cao nhất.
-- 2. Đánh giá loại bánh gây thiệt hại sản lượng phế phẩm (Scrap Volume) lớn nhất.
-- 3. Xác định quy trình máy móc (Machine) nào là thủ phạm gây lỗi cho từng loại bánh.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- PHẦN 1: BẢNG XẾP HẠNG CHẤT LƯỢNG THEO LOẠI BÁNH (PRODUCT QUALITY RANKING)
-- ------------------------------------------------------------------------------
WITH product_quality AS (
    SELECT 
        product_name,
        SUM(effective_total_biscuits) AS total_biscuits,
        SUM(good_biscuits_made) AS good_biscuits,
        SUM(scrap_biscuits_made) AS scrap_biscuits,
        ROUND(SUM(good_biscuits_made) * 100.0 / NULLIF(SUM(effective_total_biscuits), 0), 2) AS quality_rate_pct,
        ROUND(SUM(scrap_biscuits_made) * 100.0 / NULLIF(SUM(effective_total_biscuits), 0), 2) AS waste_rate_pct
    FROM gold.fct_production_runs
    GROUP BY product_name
),

plant_total AS (
    SELECT SUM(scrap_biscuits) AS total_plant_scrap FROM product_quality
)

SELECT 
    p.product_name,
    p.total_biscuits,
    p.good_biscuits,
    p.scrap_biscuits,
    p.quality_rate_pct,
    p.waste_rate_pct,
    -- Tỷ trọng đóng góp vào tổng số bánh hỏng của cả nhà máy
    ROUND(p.scrap_biscuits * 100.0 / t.total_plant_scrap, 2) AS pct_of_total_plant_scrap
FROM product_quality p
CROSS JOIN plant_total t
ORDER BY p.waste_rate_pct DESC, p.scrap_biscuits DESC;


-- ------------------------------------------------------------------------------
-- PHẦN 2: BẮT BỆNH QUY TRÌNH (DRILL-DOWN PRODUCT -> MACHINE GÂY PHẾ PHẨM)
-- ------------------------------------------------------------------------------
SELECT 
    f.product_name,
    f.machine_name,
    SUM(f.effective_total_biscuits) AS total_biscuits,
    SUM(f.good_biscuits_made) AS good_biscuits,
    SUM(f.scrap_biscuits_made) AS scrap_biscuits,
    ROUND(SUM(f.scrap_biscuits_made) * 100.0 / NULLIF(SUM(f.effective_total_biscuits), 0), 2) AS waste_rate_pct
FROM gold.fct_production_runs f
WHERE f.scrap_biscuits_made > 0
GROUP BY f.product_name, f.machine_name
ORDER BY scrap_biscuits DESC;
