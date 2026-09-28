with fact_runs as (
    select * from {{ ref('stg_fact') }}
),

target_speeds as (
    select * from {{ ref('stg_target_speeds') }}
)

select
    md5(concat_ws('||', f.machine_name, cast(f.start_datetime as varchar), cast(f.end_datetime as varchar), f.product_name)) as run_id,
    cast(f.start_datetime as date) as date_id,
    md5(f.machine_name) as machine_id,
    md5(f.product_name) as product_id,
    f.machine_name,
    f.product_name,
    f.start_datetime,
    f.end_datetime,
    f.duration_minutes,
    round(f.duration_minutes / 60.0, 4) as duration_hours,
    f.oee_category,
    case 
        when f.oee_category in ('Run Time', 'CC (Changeover Cleaning)') then true 
        else false 
    end as is_operating_time,
    case 
        when f.oee_category in ('PM (Maintenance)', 'NO (No Order)') then true 
        else false 
    end as is_planned_downtime,
    coalesce(ts.target_biscuits_per_hour, 0) as target_biscuits_per_hour,
    round((f.duration_minutes / 60.0) * coalesce(ts.target_biscuits_per_hour, 0), 2) as ideal_production,
    f.total_biscuits_made,
    f.good_biscuits_made,
    greatest(f.total_biscuits_made, f.good_biscuits_made) as effective_total_biscuits,
    greatest(0, f.total_biscuits_made - f.good_biscuits_made) as scrap_biscuits_made
from fact_runs f
left join target_speeds ts 
    on f.machine_name = ts.machine_name 
   and f.product_name = ts.product_name
