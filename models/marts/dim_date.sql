with date_spine as (
    select unnest(generate_series(date '2021-01-01', date '2021-12-31', interval 1 day))::date as date_day
)

select
    date_day as date_id,
    date_day,
    dayname(date_day) as day_name,
    dayofweek(date_day) as day_of_week,
    week(date_day) as week_of_year,
    month(date_day) as month,
    monthname(date_day) as month_name,
    quarter(date_day) as quarter,
    year(date_day) as year,
    case when dayofweek(date_day) in (0, 6) then true else false end as is_weekend
from date_spine
