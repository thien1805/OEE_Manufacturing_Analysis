with source as (
    select * from {{ source('bronze', 'fact') }}
),

cleaned as (
    select
        trim("Machine") as machine_name,
        cast("StartDateTime" as timestamp) as start_datetime,
        cast("EndDateTime" as timestamp) as end_datetime,
        cast("Duration" as double) as duration_minutes,
        cast("TotalBiscuitsMade" as bigint) as total_biscuits_made,
        cast("GoodMadeBiscuits" as bigint) as good_biscuits_made,
        case 
            when trim(cast("OEE Category" as varchar)) = '0' then 'Unclassified'
            else trim(cast("OEE Category" as varchar))
        end as oee_category,
        trim("Product") as product_name
    from source
),


deduped as (
    select
        *,
        row_number() over (
            partition by machine_name, start_datetime, end_datetime, product_name
            order by total_biscuits_made desc, good_biscuits_made desc
        ) as row_num
    from cleaned
)

select
    machine_name,
    start_datetime,
    end_datetime,
    duration_minutes,
    total_biscuits_made,
    good_biscuits_made,
    oee_category,
    product_name
from deduped
where row_num = 1
