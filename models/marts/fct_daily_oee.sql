with prep as (
    select 
        date_id,
        machine_id,
        product_id,
        duration_hours,
        case when is_operating_time then duration_hours else 0 end as operating_hours,
        case when oee_category != 'PM (Maintenance)' then duration_hours else 0 end as planned_production_hours,
        effective_total_biscuits,
        good_biscuits_made,
        scrap_biscuits_made,
        case when is_operating_time then ideal_production else 0 end as ideal_biscuits
    from {{ ref('fct_production_runs') }}
),

daily_agg as (
    select 
        date_id,
        machine_id,
        product_id,
        count(*) as total_runs,
        round(sum(duration_hours), 4) as total_duration_hours,
        round(sum(operating_hours), 4) as operating_hours,
        round(sum(planned_production_hours), 4) as planned_production_hours,
        sum(effective_total_biscuits) as effective_total_biscuits,
        sum(good_biscuits_made) as good_biscuits_made,
        sum(scrap_biscuits_made) as scrap_biscuits_made,
        round(sum(ideal_biscuits), 2) as ideal_biscuits
    from prep
    group by date_id, machine_id, product_id
),

metrics as (
    select
        date_id,
        machine_id,
        product_id,
        total_runs,
        total_duration_hours,
        operating_hours,
        planned_production_hours,
        effective_total_biscuits,
        good_biscuits_made,
        scrap_biscuits_made,
        ideal_biscuits,
        
        -- 1. Availability (%) = Operating Time / Planned Production Time
        round(least(100.0, (operating_hours / nullif(planned_production_hours, 0)) * 100.0), 2) as availability_pct,
        
        -- 2. Performance (%) = Actual Output / Ideal Output
        round((effective_total_biscuits / nullif(ideal_biscuits, 0)) * 100.0, 2) as performance_pct_raw,
        round(least(100.0, (effective_total_biscuits / nullif(ideal_biscuits, 0)) * 100.0), 2) as performance_pct,
        
        -- 3. Quality (%) = Good Output / Actual Output
        round(least(100.0, (good_biscuits_made / nullif(effective_total_biscuits, 0)) * 100.0), 2) as quality_pct
    from daily_agg
)

select
    date_id,
    machine_id,
    product_id,
    total_runs,
    total_duration_hours,
    operating_hours,
    planned_production_hours,
    effective_total_biscuits,
    good_biscuits_made,
    scrap_biscuits_made,
    ideal_biscuits,
    availability_pct,
    performance_pct,
    performance_pct_raw,
    quality_pct,
    
    -- OEE Tổng thể (%) = Availability x Performance x Quality
    round(
        (coalesce(availability_pct, 0) / 100.0) * 
        (coalesce(performance_pct, 0) / 100.0) * 
        (coalesce(quality_pct, 0) / 100.0) * 100.0, 
        2
    ) as oee_pct
from metrics
